class PlaneOutput
  var _ptr: NullablePointer[NcPlaneT] tag

  new create(ptr': NullablePointer[NcPlaneT] tag) =>
    _ptr = ptr'

  fun putstr(string: String)? =>
    if NcPlaneFFI.putstr(_ptr, string) < 0 then error end

  fun putstr_yx(string: String, y: I32 = -1, x: I32 = -1)? =>
    if NcPlaneFFI.putstr_yx(_ptr, y, x, string) < 0 then error end

  fun puttext(string: String, y: I32 = -1, align: I32 = NcAlign.left())? =>
    if @ncplane_puttext(_ptr, y, align, string.cstring(), Pointer[USize]) < 0 then
      error
    end
