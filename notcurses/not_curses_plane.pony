class NotCursesPlane
  var _ptr: NullablePointer[NcPlaneT] tag
  var _children: Array[NotCursesPlane]
  var _parent: (NotCursesPlane | None)
  var _destroyed: Bool = false
  var _is_stdplane: Bool = false

  new none() =>
    _ptr = NullablePointer[NcPlaneT].none()
    _children = Array[NotCursesPlane]
    _parent = None

  new from_ptr(ptr': NullablePointer[NcPlaneT] tag,
    is_stdplane: Bool = false)
  =>
    _ptr = ptr'
    _children = Array[NotCursesPlane]
    _parent = None
    _is_stdplane = is_stdplane

  fun raw_ptr(): NullablePointer[NcPlaneT] tag => _ptr

  new create(parent: NotCursesPlane, opts: Ncplaneoptions)? =>
    // Check is_none() on the ref result before assigning to tag field
    let result = NotCursesFFI.plane_create(parent._ptr,
      NullablePointer[Ncplaneoptions](opts))
    if result.is_none() then error end
    _ptr = result
    _children = Array[NotCursesPlane]
    _parent = parent
    parent._children.push(this)

  fun ref child(opts: Ncplaneoptions): NotCursesPlane ? =>
    NotCursesPlane.create(this, opts)?

  // Geometry
  fun dim_yx(): (U32, U32) =>
    NotCursesFFI.plane_dim_yx(_ptr)

  fun yx(): (I32, I32) =>
    NotCursesFFI.plane_yx(_ptr)

  fun erase() =>
    NotCursesFFI.plane_erase(_ptr)

  fun home() =>
    NotCursesFFI.plane_home(_ptr)

  fun move_yx(y: I32, x: I32)? =>
    if NotCursesFFI.plane_move_yx(_ptr, y, x) != 0 then error end

  // Sub-object accessors
  fun cursor(): PlaneCursor =>
    PlaneCursor(_ptr)

  fun style(): PlaneStyleBuilder =>
    PlaneStyleBuilder(_ptr)

  fun box_draw(): PlaneBoxDraw =>
    PlaneBoxDraw(_ptr)

  fun output(): PlaneOutput =>
    PlaneOutput(_ptr)

  // Destruction
  fun ref _mark_destroyed() =>
    _destroyed = true
    for child' in _children.values() do
      child'._mark_destroyed()
    end

  fun ref destroy()? =>
    if _destroyed then error end
    if _is_stdplane then error end
    _mark_destroyed()
    NotCursesFFI.plane_destroy(_ptr)
    match _parent
    | let p: NotCursesPlane =>
      var i: USize = 0
      while i < p._children.size() do
        try
          if p._children(i)? is this then
            p._children.delete(i)?
            break
          end
        end
        i = i + 1
      end
    end

  // WARNING: If GC finalizes a parent plane before its children without
  // an explicit destroy() call, the C library will have already freed the
  // children when the parent's _final() calls plane_destroy. The children's
  // _final() then double-frees. This is inherent to Pony's GC model —
  // finalizer ordering is not guaranteed. Users should call destroy()
  // explicitly on parent planes to avoid this.
  fun _final() =>
    if (not _destroyed) and (not _is_stdplane) then
      NotCursesFFI.plane_destroy(_ptr)
    end
