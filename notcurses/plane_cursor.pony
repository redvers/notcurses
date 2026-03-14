class PlaneCursor
  """
  Cursor positioning operations for a plane.

  Obtained via `NotCursesPlane.cursor()`. The cursor determines where the next text output will appear on the plane.
  """
  var _ptr: NullablePointer[NcPlaneT] tag

  new create(ptr': NullablePointer[NcPlaneT] tag) =>
    _ptr = ptr'

  fun move_yx(y: I32, x: I32)? =>
    """Move the cursor to position (y, x) within the plane."""
    if NotCursesFFI.plane_cursor_move_yx(_ptr, y, x) != 0 then error end

  fun yx(): (U32, U32) =>
    """Get the current cursor position as (y, x)."""
    NotCursesFFI.plane_cursor_yx(_ptr)

  fun home() =>
    """Move the cursor to the origin (0, 0)."""
    NotCursesFFI.plane_home(_ptr)
