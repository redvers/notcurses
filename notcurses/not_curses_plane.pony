class NotCursesPlane
  var ptr: NullablePointer[NcPlaneT] tag

  new none() =>
    ptr = NullablePointer[NcPlaneT].none()

  new from_ptr(ptr': NullablePointer[NcPlaneT] tag) =>
    ptr = ptr'

  new create(parent: NotCursesPlane, opts: Ncplaneoptions) =>
    ptr = NotCursesFFI.plane_create(parent.ptr, NullablePointer[Ncplaneoptions](opts))

  fun ref child(opt: Ncplaneoptions): NotCursesPlane =>
    NotCursesPlane.create(this, opt)

  fun duplicate(newparent: NotCursesPlane = NotCursesPlane.none()) =>
    NotCursesPlane.from_ptr(NotCursesFFI.plane_dup(ptr, Pointer[None]))

  fun dim_yx(): (U32, U32) =>
    NotCursesFFI.plane_dim_yx(ptr)

  fun yx(): (I32, I32) =>
    NotCursesFFI.plane_yx(ptr)

  fun cursor_move_yx(y: I32, x: I32): I32 =>
    NotCursesFFI.plane_cursor_move_yx(ptr, y, x)

  fun home() =>
    NotCursesFFI.plane_home(ptr)

  fun erase() =>
    NotCursesFFI.plane_erase(ptr)

  fun move_yx(y: I32, x: I32): I32 =>
    NotCursesFFI.plane_move_yx(ptr, y, x)

  fun puttext(string: String, y: I32 = -1, align: I32 = NcAlign.left()): I32 =>
    @ncplane_puttext(ptr, y, align, string.cstring(), Pointer[USize])

  fun putstr(string: String): I32 =>
    @ncplane_putstr(ptr, string.cstring())

  fun putstr_yx(string: String, y: I32 = -1, x: I32 = -1): I32 =>
    NcPlaneFFI.putstr_yx(ptr, y, x, string)


  fun render(): I32 =>
    @ncpile_render(ptr)

  fun rasterize(): I32 =>
    @ncpile_rasterize(ptr)

  fun perimeter_rounded(ctlword: U32, stylemask: U16 = 0, channels: U64 = 0): I32 =>
    NcPlaneFFI.perimeter_rounded(ptr, stylemask, channels, ctlword)

  fun perimeter_double(ctlword: U32, stylemask: U16 = 0, channels: U64 = 0): I32 =>
    NcPlaneFFI.perimeter_double(ptr, stylemask, channels, ctlword)
  //NcBoxCtl.all_borders


  fun _final() =>
    NotCursesFFI.plane_destroy(ptr)
