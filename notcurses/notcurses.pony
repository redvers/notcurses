use "time"

class NotCurses
  """
  The main notcurses instance. Manages terminal lifecycle, rendering, and input routing.

  Embed this in your actor (which must implement `NotCursesActor`). The instance
  is `ref` capability — it must live inside the actor that uses it, because Pony's
  capability system prevents sharing mutable state across actors. This is the design,
  not a limitation: your actor serializes all terminal access, eliminating data races.

  Lifecycle: construct with `NotCurses(actor)` in your actor's constructor, then
  `_initiate()` is called as a behavior to begin setup. Call `stop()` to shut down.

  The `none()` constructor provides a default empty value for field initialization
  before the real instance is created in your constructor.
  """
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
    """
    Get the standard plane, which covers the entire terminal.

    The standard plane is created automatically and persists for the lifetime of the NotCurses instance. It is the root of the plane hierarchy — all other planes are children (or descendants) of it.
    """
    match _stdplane
    | let p: NotCursesPlane => p
    else
      let p = NotCursesPlane.from_ptr(NotCursesFFI.stdplane(ptr), true)
      _stdplane = p
      p
    end

  fun dim_yx(): (U32, U32) =>
    """Get the terminal dimensions as (rows, columns)."""
    NotCursesFFI.term_dim_yx(ptr)

  fun render()? =>
    """
    Render all planes to the terminal.

    Notcurses uses a double-buffer model: write to planes, then call `render()` to push everything to the terminal at once. Call this after finishing all updates for a frame — one render per batch of changes.
    """
    if NotCursesFFI.render(ptr) != 0 then error end

  fun mice_enable(eventmask: U32)? =>
    """
    Enable mouse event reporting with the given event mask.

    Use `NcMice` constants to build the mask: `NcMice.all_events()`, `NcMice.button_event()`, `NcMice.move_event()`, `NcMice.drag_event()`.
    """
    if NotCursesFFI.mice_enable(ptr, eventmask) != 0 then error end

  fun can_true_color(): Bool =>
    """Check whether the terminal supports 24-bit true color."""
    NotCursesFFI.cantruecolor(ptr)

  fun can_utf8(): Bool =>
    """Check whether the terminal supports UTF-8."""
    NotCursesFFI.canutf8(ptr)

  fun ref focus(widget: InputWidget) =>
    """
    Set the focused input widget. Input events are offered to the focused widget first. If the widget consumes the event, your actor's `input_received` is not called. Only one widget can be focused at a time.
    """
    _focused = widget

  fun ref unfocus() =>
    """Clear the focused widget. All input events go directly to `input_received`."""
    _focused = None

  fun ref unfocus_if(widget: InputWidget) =>
    """Clear focus only if the given widget is currently focused. Useful when destroying a widget that might or might not have focus."""
    match _focused
    | let w: InputWidget =>
      if w is widget then _focused = None end
    end

  fun ref _poll_and_route(enc': NotCursesActor ref) =>
    var ni: Ncinput ref = Ncinput
    var needs_render = false
    var ret = NotCursesFFI.get_nblock(ptr,
      NullablePointer[Ncinput](ni))
    while (ret != 0) and (ret != 0xFFFFFFFF) do
      var consumed = false
      match _focused
      | let w: InputWidget =>
        consumed = w._offer_input(ni)
        if consumed then needs_render = true end
      end
      if not consumed then
        let event = InputClassifier.classify(ni)
        enc'.input_received(event)
      end
      ni = Ncinput
      ret = NotCursesFFI.get_nblock(ptr,
        NullablePointer[Ncinput](ni))
    end
    if needs_render then try render()? end end

  fun ref stop()? =>
    """
    Shut down notcurses and restore the terminal to its original state.

    Destroy all widgets before calling this. The C library frees planes during stop, so destroying a widget after stop causes a double-free.
    """
    // Cancel input polling
    match (_timers, _input_timer)
    | (let ts: Timers, let t: Timer tag) =>
      ts.cancel(t)
      ts.dispose()
    end
    _timers = None
    _input_timer = None
    _focused = None

    // Mark all plane wrappers as destroyed before calling notcurses_stop(),
    // which frees all planes at the C level. Without this, GC finalizers
    // on the Pony wrappers would double-free the already-destroyed C planes.
    match _stdplane
    | let std: NotCursesPlane => std._mark_destroyed()
    end
    _stdplane = None
    @printf("\x1b[=0u".cstring())
    if NotCursesFFI.stop(ptr) != 0 then error end


class _InputPollNotify is TimerNotify
  let _actor: NotCursesActor

  new iso create(actor': NotCursesActor) =>
    _actor = actor'

  fun ref apply(timer: Timer, count: U64): Bool =>
    _actor._poll_input()
    true
