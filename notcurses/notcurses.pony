use "time"

class NotCurses
  var ptr: NullablePointer[NcNotcurses] tag = NullablePointer[NcNotcurses].none()
  var enclosing: (NotCursesActor | None)
  var _timers: (Timers | None) = None
  var _input_timer: (Timer tag | None) = None

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
      _InputPollNotify(ptr, enc),
      interval, interval)
    _input_timer = timer
    timers(consume timer)
    _timers = timers

    enc._initiate()

  fun stdplane(): NotCursesPlane =>
    NotCursesPlane.from_ptr(NotCursesFFI.stdplane(ptr), true)

  fun dim_yx(): (U32, U32) =>
    NotCursesFFI.term_dim_yx(ptr)

  fun render()? =>
    if NotCursesFFI.render(ptr) != 0 then error end

  fun can_true_color(): Bool =>
    NotCursesFFI.cantruecolor(ptr)

  fun can_utf8(): Bool =>
    NotCursesFFI.canutf8(ptr)

  fun ref stop()? =>
    // Cancel input polling
    match (_timers, _input_timer)
    | (let ts: Timers, let t: Timer tag) =>
      ts.cancel(t)
      ts.dispose()
    end
    _timers = None
    _input_timer = None

    if NotCursesFFI.stop(ptr) != 0 then error end


class _InputPollNotify is TimerNotify
  let _nc_ptr: NullablePointer[NcNotcurses] tag
  let _actor: NotCursesActor

  new iso create(nc_ptr: NullablePointer[NcNotcurses] tag,
    actor': NotCursesActor)
  =>
    _nc_ptr = nc_ptr
    _actor = actor'

  fun ref apply(timer: Timer, count: U64): Bool =>
    // Poll for all available input in this tick
    _poll()
    true  // keep timer alive

  fun ref _poll() =>
    var ni: Ncinput ref = Ncinput
    var ret = NotCursesFFI.get_nblock(_nc_ptr,
      NullablePointer[Ncinput](ni))
    // ret == 0 means no input, ret == 0xFFFFFFFF means error ((U32)-1)
    while (ret != 0) and (ret != 0xFFFFFFFF) do
      let event = InputClassifier.classify(ni)
      _actor.input_received(event)
      ni = Ncinput
      ret = NotCursesFFI.get_nblock(_nc_ptr,
        NullablePointer[Ncinput](ni))
    end
