class NotCursesUPlot
  """
  An unsigned integer plot widget. Display-only — does not implement `InputWidget`.

  Creates and manages its own child plane. Add data points with `add_sample()` (accumulates) or `set_sample()` (replaces). The plot auto-scales to fit the data within the configured min/max range.

  Call `destroy()` before `NotCurses.stop()` to prevent double-free.
  """
  var _ptr: NullablePointer[NcUPlot] tag = NullablePointer[NcUPlot].none()
  var _destroyed: Bool = false

  new none() =>
    None

  new create(parent: NotCursesPlane, y: U32, x: U32,
    rows: U32, cols: U32,
    miny: U64 = 0, maxy: U64 = 0,
    title: (String | None) = None,
    gridtype: I32 = 0,
    rangex: I32 = 0,
    flags: U64 = 0,
    maxchannels: U64 = 0,
    minchannels: U64 = 0,
    legendstyle: U16 = 0)?
  =>
    var opts = Ncplotoptions
    opts.maxchannels = maxchannels
    opts.minchannels = minchannels
    opts.legendstyle = legendstyle
    opts.gridtype = gridtype
    opts.rangex = rangex
    match title
    | let s: String => opts.title = s.cstring()
    end
    opts.flags = flags

    let plane_opts = Ncplaneoptions(where
      y' = y.i32(), x' = x.i32(), rows' = rows, cols' = cols)
    let plane_result = NotCursesFFI.plane_create(parent.raw_ptr(),
      NullablePointer[Ncplaneoptions](plane_opts))
    if plane_result.is_none() then error end

    let result = NotCursesFFI.uplot_create(plane_result,
      NullablePointer[Ncplotoptions](consume opts), miny, maxy)
    if result.is_none() then
      NotCursesFFI.plane_destroy(plane_result)
      error
    end
    _ptr = result

  fun ref add_sample(x: U64, y: U64)? =>
    """Add a data point, accumulating with any existing value at x."""
    if NotCursesFFI.uplot_add_sample(_ptr, x, y) != 0 then error end

  fun ref set_sample(x: U64, y: U64)? =>
    """Set a data point, replacing any existing value at x."""
    if NotCursesFFI.uplot_set_sample(_ptr, x, y) != 0 then error end

  fun ref sample(x: U64): U64? =>
    """Get the current value at x."""
    var y: U64 = 0
    if @ncuplot_sample(_ptr, x, addressof y) != 0 then error end
    y

  fun ref destroy() =>
    """Destroy the plot and its child plane."""
    if not _destroyed then
      _destroyed = true
      NotCursesFFI.uplot_destroy(_ptr)
    end

  fun _final() =>
    if not _destroyed then
      NotCursesFFI.uplot_destroy(_ptr)
    end
