use "lib:notcurses-core"

// Lifecycle
use @notcurses_core_init[Pointer[_NcNotcurses]](
  opts: NullablePointer[Notcursesoptions] tag, fp: Pointer[_File] tag)
use @notcurses_stop[I32](nc: Pointer[_NcNotcurses] tag)
use @notcurses_stdplane[Pointer[_NcPlane]](nc: Pointer[_NcNotcurses] tag)
use @notcurses_version[Pointer[U8]]()

// Planes
use @ncplane_create[Pointer[_NcPlane]](
  n: Pointer[_NcPlane] tag, nopts: NullablePointer[Ncplaneoptions] tag)
use @ncplane_destroy[I32](n: Pointer[_NcPlane] tag)
use @ncplane_dim_yx[None](
  n: Pointer[_NcPlane] tag, y: Pointer[U32] tag, x: Pointer[U32] tag)
use @ncplane_cursor_move_yx[I32](
  n: Pointer[_NcPlane] tag, y: I32, x: I32)
use @ncplane_cursor_yx[None](
  n: Pointer[_NcPlane] tag, y: Pointer[U32] tag, x: Pointer[U32] tag)
use @ncplane_home[None](n: Pointer[_NcPlane] tag)
use @ncplane_erase[None](n: Pointer[_NcPlane] tag)

// Output
use @ncplane_putc_yx[I32](
  n: Pointer[_NcPlane] tag, y: I32, x: I32,
  c: NullablePointer[Nccell] tag)
use @ncplane_putegc_yx[I32](
  n: Pointer[_NcPlane] tag, y: I32, x: I32,
  gclust: Pointer[U8] tag, sbytes: Pointer[USize] tag)

// Styles & Colors
use @ncplane_set_styles[None](n: Pointer[_NcPlane] tag, stylebits: U32)
use @ncplane_on_styles[None](n: Pointer[_NcPlane] tag, stylebits: U32)
use @ncplane_off_styles[None](n: Pointer[_NcPlane] tag, stylebits: U32)
use @ncplane_set_fg_rgb[I32](n: Pointer[_NcPlane] tag, channel: U32)
use @ncplane_set_bg_rgb[I32](n: Pointer[_NcPlane] tag, channel: U32)
use @ncplane_set_base[I32](
  n: Pointer[_NcPlane] tag, egc: Pointer[U8] tag,
  stylemask: U16, channels: U64)

// Rendering
use @ncpile_render[I32](n: Pointer[_NcPlane] tag)
use @ncpile_rasterize[I32](n: Pointer[_NcPlane] tag)

// Input
use @notcurses_get[U32](
  n: Pointer[_NcNotcurses] tag, ts: Pointer[None] tag,
  ni: NullablePointer[Ncinput] tag)

// Capabilities & Mouse
use @notcurses_capabilities[NullablePointer[Nccapabilities]](
  n: Pointer[_NcNotcurses] tag)
use @notcurses_mice_enable[I32](
  n: Pointer[_NcNotcurses] tag, eventmask: U32)

// Pony reimplementations of inline C functions from notcurses.h.
primitive Notcurses
  fun render(nc: Pointer[_NcNotcurses]): I32 =>
    """
    Renders and rasterizes the standard plane pile.
    Reimplements notcurses_render() which is inline in the C header.
    """
    let stdn = @notcurses_stdplane(nc)
    if @ncpile_render(stdn) != 0 then return -1 end
    @ncpile_rasterize(stdn)

  fun get_nblock(
    nc: Pointer[_NcNotcurses],
    ni: NullablePointer[Ncinput])
    : U32
  =>
    """
    Non-blocking input. Returns immediately with 0 if no input available.
    Reimplements notcurses_get_nblock().
    """
    var ts: (I64, I64) = (0, 0)
    @notcurses_get(nc, addressof ts, ni)

  fun get_blocking(
    nc: Pointer[_NcNotcurses],
    ni: NullablePointer[Ncinput])
    : U32
  =>
    """
    Blocking input. Waits indefinitely for input.
    Reimplements notcurses_get_blocking().
    """
    @notcurses_get(nc, Pointer[None], ni)

  fun cantruecolor(nc: Pointer[_NcNotcurses]): Bool =>
    try (@notcurses_capabilities(nc))()?.rgb != 0 else false end

  fun canutf8(nc: Pointer[_NcNotcurses]): Bool =>
    try (@notcurses_capabilities(nc))()?.utf8 != 0 else false end
