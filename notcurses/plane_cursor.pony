class PlaneCursor
  var _ptr: NullablePointer[NcPlaneT] tag

  new create(ptr': NullablePointer[NcPlaneT] tag) =>
    _ptr = ptr'

  fun move_yx(y: I32, x: I32)? =>
    if NotCursesFFI.plane_cursor_move_yx(_ptr, y, x) != 0 then error end

  fun yx(): (U32, U32) =>
    NotCursesFFI.plane_cursor_yx(_ptr)

  fun home() =>
    NotCursesFFI.plane_home(_ptr)
