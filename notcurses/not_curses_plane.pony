class NotCursesPlane
  """
  A rectangular region of the terminal with its own cursor, styles, and content.

  Planes form a hierarchy — child planes are positioned relative to their parent
  and are destroyed when the parent is destroyed. The standard plane covers the
  entire terminal and is obtained via `NotCurses.stdplane()`.

  Access plane operations through sub-accessors:
  - `style()` — colors and text attributes via `PlaneStyleBuilder`
  - `output()` — writing text via `PlaneOutput`
  - `cursor()` — cursor positioning via `PlaneCursor`
  - `box_draw()` — borders and boxes via `PlaneBoxDraw`

  The `none()` constructor provides a default empty value for field initialization.
  """
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
    """Wrap an existing plane pointer. Used internally to wrap the standard plane."""
    _ptr = ptr'
    _children = Array[NotCursesPlane]
    _parent = None
    _is_stdplane = is_stdplane

  fun raw_ptr(): NullablePointer[NcPlaneT] tag =>
    """Access the underlying C pointer. Needed when passing planes to widget constructors or FFI functions."""
    _ptr

  new create(parent: NotCursesPlane, opts: Ncplaneoptions)? =>
    """Create a child plane. The plane is positioned relative to its parent according to the coordinates in `opts`. Errors if the C allocation fails."""
    // Check is_none() on the ref result before assigning to tag field
    let result = NotCursesFFI.plane_create(parent._ptr,
      NullablePointer[Ncplaneoptions](opts))
    if result.is_none() then error end
    _ptr = result
    _children = Array[NotCursesPlane]
    _parent = parent
    parent._children.push(this)

  fun ref child(opts: Ncplaneoptions): NotCursesPlane ? =>
    """
    Create a child plane positioned relative to this plane.

    Shorthand for `NotCursesPlane(this, opts)?`. The child is tracked and will be cleaned up when this plane is destroyed.
    """
    NotCursesPlane.create(this, opts)?

  // Geometry
  fun dim_yx(): (U32, U32) =>
    """Get this plane's dimensions as (rows, columns)."""
    NotCursesFFI.plane_dim_yx(_ptr)

  fun yx(): (I32, I32) =>
    """Get this plane's position as (y, x) relative to its parent."""
    NotCursesFFI.plane_yx(_ptr)

  fun erase() =>
    """Clear all content from this plane, resetting every cell to empty."""
    NotCursesFFI.plane_erase(_ptr)

  fun home() =>
    """Move the cursor to the origin (0, 0) of this plane."""
    NotCursesFFI.plane_home(_ptr)

  fun move_yx(y: I32, x: I32)? =>
    """Move this plane to position (y, x) relative to its parent. This moves the plane itself, not the cursor — see `cursor().move_yx()`."""
    if NotCursesFFI.plane_move_yx(_ptr, y, x) != 0 then error end

  // Sub-object accessors
  fun cursor(): PlaneCursor =>
    """Access cursor positioning operations for this plane."""
    PlaneCursor(_ptr)

  fun style(): PlaneStyleBuilder =>
    """Access the style builder for this plane. Use it to set colors and text attributes with a fluent API: `plane.style().>bold().>fg(255, 0, 0).apply()?`."""
    PlaneStyleBuilder(_ptr)

  fun box_draw(): PlaneBoxDraw =>
    """Access box drawing operations for this plane. Draw borders and boxes with rounded or double-line styles."""
    PlaneBoxDraw(_ptr)

  fun output(): PlaneOutput =>
    """Access text output operations for this plane. Write strings at the cursor position or at specific coordinates."""
    PlaneOutput(_ptr)

  // Destruction
  fun ref _mark_destroyed() =>
    _destroyed = true
    for child' in _children.values() do
      child'._mark_destroyed()
    end

  fun ref destroy()? =>
    """Destroy this plane and all its children. Cannot destroy the standard plane. After destruction, do not use this plane instance."""
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
