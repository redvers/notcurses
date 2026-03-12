use "time"

class NotCurses
  var ptr: NullablePointer[NcNotcurses] tag = NullablePointer[NcNotcurses].none()
  var enclosing: (NotCursesActor | None)
  var _timers: (Timers | None) = None
  var _input_timer: (Timer tag | None) = None
  var _stdplane: (NotCursesPlane | None) = None
  var _focused: (InputWidget | None) = None

  new none() =>
    enclosing = None

  new create(enc: NotCursesActor ref,
    termtype: (String | None) = None,
    loglevel: I32 = 0,
    margin_t: U32 = 0,
    margin_r: U32 = 0,
    margin_b: U32 = 0,
    margin_l: U32 = 0,
    flags: U64 = NcOption.suppress_banners(),
    poll_interval_ms: U64 = 10
  )? =>
    let options: Notcursesoptions = Notcursesoptions
    match termtype
    | let x: String => options.termtype = x.cstring()
    | let x: None   => options.termtype = Pointer[U8]
    end
    options.loglevel = loglevel
    options.margin_t = margin_t
    options.margin_r = margin_r
    options.margin_b = margin_b
    options.margin_l = margin_l
    options.flags = flags
    enclosing = enc

    let result = NotCursesFFI.core_init(
      NullablePointer[Notcursesoptions](options), NullablePointer[CFile].none()
    )

    if result.is_none() then error end
    ptr = result

    // Start input polling
    let timers = Timers
    let interval = poll_interval_ms * 1_000_000  // ms to ns
    let timer = Timer(
      _InputPollNotify(enc),
      interval, interval)
    _input_timer = timer
    timers(consume timer)
    _timers = timers

    enc._initiate()

  fun ref stdplane(): NotCursesPlane =>
    match _stdplane
    | let p: NotCursesPlane => p
    else
      let p = NotCursesPlane.from_ptr(NotCursesFFI.stdplane(ptr), true)
      _stdplane = p
      p
    end

  fun dim_yx(): (U32, U32) =>
    NotCursesFFI.term_dim_yx(ptr)

  fun render()? =>
    if NotCursesFFI.render(ptr) != 0 then error end

  fun can_true_color(): Bool =>
    NotCursesFFI.cantruecolor(ptr)

  fun can_utf8(): Bool =>
    NotCursesFFI.canutf8(ptr)

  fun ref focus(widget: InputWidget) =>
    _focused = widget

  fun ref unfocus() =>
    _focused = None

  fun ref unfocus_if(widget: InputWidget) =>
    match _focused
    | let w: InputWidget =>
      if w is widget then _focused = None end
    end

  fun ref _poll_and_route(enc': NotCursesActor ref) =>
    var ni: Ncinput ref = Ncinput
    var ret = NotCursesFFI.get_nblock(ptr,
      NullablePointer[Ncinput](ni))
    while (ret != 0) and (ret != 0xFFFFFFFF) do
      var consumed = false
      match _focused
      | let w: InputWidget =>
        consumed = w._offer_input(ni)
      end
      if not consumed then
        let event = InputClassifier.classify(ni)
        enc'.input_received(event)
      end
      ni = Ncinput
      ret = NotCursesFFI.get_nblock(ptr,
        NullablePointer[Ncinput](ni))
    end

  fun ref stop()? =>
    // Cancel input polling
    match (_timers, _input_timer)
    | (let ts: Timers, let t: Timer tag) =>
      ts.cancel(t)
      ts.dispose()
    end
    _timers = None
    _input_timer = None

    // Mark all plane wrappers as destroyed before calling notcurses_stop(),
    // which frees all planes at the C level. Without this, GC finalizers
    // on the Pony wrappers would double-free the already-destroyed C planes.
    match _stdplane
    | let std: NotCursesPlane => std._mark_destroyed()
    end
    _stdplane = None

    if NotCursesFFI.stop(ptr) != 0 then error end


class _InputPollNotify is TimerNotify
  let _actor: NotCursesActor

  new iso create(actor': NotCursesActor) =>
    _actor = actor'

  fun ref apply(timer: Timer, count: U64): Bool =>
    _actor._poll_input()
    true
