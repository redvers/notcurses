class PlaneBoxDraw
  var _ptr: NullablePointer[NcPlaneT] tag

  new create(ptr': NullablePointer[NcPlaneT] tag) =>
    _ptr = ptr'

  fun perimeter_rounded(ctlword: U32, stylemask: U16 = 0, channels: U64 = 0)? =>
    if NcPlaneFFI.perimeter_rounded(_ptr, stylemask, channels, ctlword) != 0 then
      error
    end

  fun perimeter_double(ctlword: U32, stylemask: U16 = 0, channels: U64 = 0)? =>
    if NcPlaneFFI.perimeter_double(_ptr, stylemask, channels, ctlword) != 0 then
      error
    end

  fun rounded(ystop: U32, xstop: U32, ctlword: U32,
    stylemask: U16 = 0, channels: U64 = 0)? =>
    if NcPlaneFFI.rounded_box(_ptr, stylemask, channels, ystop, xstop, ctlword) != 0 then
      error
    end

  fun double_box(ystop: U32, xstop: U32, ctlword: U32,
    stylemask: U16 = 0, channels: U64 = 0)? =>
    if NcPlaneFFI.double_box(_ptr, stylemask, channels, ystop, xstop, ctlword) != 0 then
      error
    end
