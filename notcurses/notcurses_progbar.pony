class NotCursesProgbar
  var _ptr: NullablePointer[NcProgbar] tag = NullablePointer[NcProgbar].none()
  var _destroyed: Bool = false

  new none() =>
    None

  new create(parent: NotCursesPlane, y: U32, x: U32,
    rows: U32, cols: U32, opts: Ncprogbaroptions = Ncprogbaroptions)?
  =>
    let plane_opts = Ncplaneoptions(where
      y' = y.i32(), x' = x.i32(), rows' = rows, cols' = cols)
    let plane_result = NotCursesFFI.plane_create(parent.raw_ptr(),
      NullablePointer[Ncplaneoptions](plane_opts))
    if plane_result.is_none() then error end
    let result = NotCursesFFI.progbar_create(plane_result,
      NullablePointer[Ncprogbaroptions](opts))
    if result.is_none() then
      NotCursesFFI.plane_destroy(plane_result)
      error
    end
    _ptr = result

  fun set_progress(p: F64)? =>
    if NotCursesFFI.progbar_set_progress(_ptr, p) != 0 then error end

  fun progress(): F64 =>
    NotCursesFFI.progbar_progress(_ptr)

  fun ref destroy() =>
    if not _destroyed then
      _destroyed = true
      NotCursesFFI.progbar_destroy(_ptr)
    end

  fun _final() =>
    if not _destroyed then
      NotCursesFFI.progbar_destroy(_ptr)
    end
