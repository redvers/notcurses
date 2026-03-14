class PlaneBoxDraw
  """
  Box drawing operations for a plane.

  Obtained via `NotCursesPlane.box_draw()`. Draws borders and boxes using rounded or double-line Unicode characters.

  The `ctlword` parameter controls which borders to draw. Use `NcBoxCtl` constants: `NcBoxCtl.all_borders()` for all four sides, or combine individual sides.
  """
  var _ptr: NullablePointer[NcPlaneT] tag

  new create(ptr': NullablePointer[NcPlaneT] tag) =>
    _ptr = ptr'

  fun perimeter_rounded(ctlword: U32, stylemask: U16 = 0, channels: U64 = 0)? =>
    """Draw a rounded border around the entire plane perimeter."""
    if NcPlaneFFI.perimeter_rounded(_ptr, stylemask, channels, ctlword) != 0 then
      error
    end

  fun perimeter_double(ctlword: U32, stylemask: U16 = 0, channels: U64 = 0)? =>
    """Draw a double-line border around the entire plane perimeter."""
    if NcPlaneFFI.perimeter_double(_ptr, stylemask, channels, ctlword) != 0 then
      error
    end

  fun rounded(ystop: U32, xstop: U32, ctlword: U32,
    stylemask: U16 = 0, channels: U64 = 0)? =>
    """Draw a rounded box from the current cursor position to (ystop, xstop)."""
    if NcPlaneFFI.rounded_box(_ptr, stylemask, channels, ystop, xstop, ctlword) != 0 then
      error
    end

  fun double_box(ystop: U32, xstop: U32, ctlword: U32,
    stylemask: U16 = 0, channels: U64 = 0)? =>
    """Draw a double-line box from the current cursor position to (ystop, xstop)."""
    if NcPlaneFFI.double_box(_ptr, stylemask, channels, ystop, xstop, ctlword) != 0 then
      error
    end
