class PlaneOutput
  """
  Text output operations for a plane.

  Obtained via `NotCursesPlane.output()`. Writes text at the cursor position or at specific coordinates.
  """
  var _ptr: NullablePointer[NcPlaneT] tag

  new create(ptr': NullablePointer[NcPlaneT] tag) =>
    _ptr = ptr'

  fun putstr(string: String)? =>
    """Write a string at the current cursor position. The cursor advances past the written text."""
    if NcPlaneFFI.putstr(_ptr, string) < 0 then error end

  fun putstr_yx(string: String, y: I32 = -1, x: I32 = -1)? =>
    """Write a string at position (y, x). Pass -1 for either coordinate to keep the current cursor position on that axis."""
    if NcPlaneFFI.putstr_yx(_ptr, y, x, string) < 0 then error end

  fun puttext(string: String, y: I32 = -1, align: I32 = NcAlign.left())? =>
    """Write aligned text. Use `NcAlign.left()`, `NcAlign.center()`, or `NcAlign.right()` for alignment."""
    if @ncplane_puttext(_ptr, y, align, string.cstring(), Pointer[USize]) < 0 then
      error
    end
