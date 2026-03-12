use "lib:notcurses-core"

// Lifecycle
use @notcurses_core_init[NullablePointer[NcNotcurses]](
  opts: NullablePointer[Notcursesoptions] tag, fp: NullablePointer[CFile] tag)
use @notcurses_stop[I32](nc: NullablePointer[NcNotcurses] tag)
use @notcurses_stdplane[NullablePointer[NcPlaneT]](nc: NullablePointer[NcNotcurses] tag)
use @notcurses_version[Pointer[U8]]()
use @notcurses_supported_styles[U16](nc: NullablePointer[NcNotcurses] tag)
// Planes — creation, destruction, geometry
use @ncplane_create[NullablePointer[NcPlaneT]](
  n: NullablePointer[NcPlaneT] tag, nopts: NullablePointer[Ncplaneoptions] tag)
use @ncplane_userptr[NotCursesResizeCallback](t: NullablePointer[NcPlaneT] tag)
use @ncplane_destroy[I32](n: NullablePointer[NcPlaneT] tag)
use @ncplane_dup[NullablePointer[NcPlaneT]](
  n: NullablePointer[NcPlaneT] tag, opaque: Pointer[None] tag)
use @ncplane_dim_yx[None](
  n: NullablePointer[NcPlaneT] tag, y: Pointer[U32] tag, x: Pointer[U32] tag)
use @ncplane_cursor_move_yx[I32](
  n: NullablePointer[NcPlaneT] tag, y: I32, x: I32)
use @ncplane_cursor_yx[None](
  n: NullablePointer[NcPlaneT] tag, y: Pointer[U32] tag, x: Pointer[U32] tag)
use @ncplane_home[None](n: NullablePointer[NcPlaneT] tag)
use @ncplane_erase[None](n: NullablePointer[NcPlaneT] tag)
use @ncplane_abs_yx[None](
  n: NullablePointer[NcPlaneT] tag, y: Pointer[I32] tag, x: Pointer[I32] tag)
use @ncplane_yx[None](
  n: NullablePointer[NcPlaneT] tag, y: Pointer[I32] tag, x: Pointer[I32] tag)
use @ncplane_move_yx[I32](n: NullablePointer[NcPlaneT] tag, y: I32, x: I32)
use @ncplane_move_below[I32](
  n: NullablePointer[NcPlaneT] tag, below: NullablePointer[NcPlaneT] tag)
use @ncplane_resize[I32](
  n: NullablePointer[NcPlaneT] tag, keepy: I32, keepx: I32,
  keepleny: U32, keeplenx: U32, yoff: I32, xoff: I32,
  ylen: U32, xlen: U32)
use @ncplane_notcurses[NullablePointer[NcNotcurses]](n: NullablePointer[NcPlaneT] tag)
use @ncplane_scrolling_p[Bool](n: NullablePointer[NcPlaneT] tag)
use @ncplane_set_scrolling[Bool](n: NullablePointer[NcPlaneT] tag, scrollp: U32)

// Output
use @ncplane_putc_yx[I32](
  n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
  c: NullablePointer[Nccell] tag)
use @ncplane_putegc_yx[I32](
  n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
  gclust: Pointer[U8] tag, sbytes: Pointer[USize] tag)
use @ncplane_puttext[I32](
  n: NullablePointer[NcPlaneT] tag, y: I32, align: I32,
  text: Pointer[U8] tag, bytes: Pointer[USize] tag)
use @ncplane_vprintf_yx[I32](
  n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
  format: Pointer[U8] tag, ap: Pointer[None] tag)
use @ncplane_putstr[I32](n: NullablePointer[NcPlaneT] tag, str: Pointer[U8] tag)
use @ncplane_putstr_yx[I32](n: NullablePointer[NcPlaneT] tag, y: I32, x: I32, str: Pointer[U8] tag)

// Content retrieval
use @ncplane_at_yx[Pointer[U8]](
  n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
  stylemask: Pointer[U16] tag, channels: Pointer[U64] tag)
use @ncplane_at_yx_cell[I32](
  n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
  c: NullablePointer[Nccell] tag)

// Drawing
use @ncplane_box[I32](
  n: NullablePointer[NcPlaneT] tag,
  ul: NullablePointer[Nccell] tag, ur: NullablePointer[Nccell] tag,
  ll: NullablePointer[Nccell] tag, lr: NullablePointer[Nccell] tag,
  hline: NullablePointer[Nccell] tag, vline: NullablePointer[Nccell] tag,
  ystop: U32, xstop: U32, ctlword: U32)
use @ncplane_hline_interp[I32](
  n: NullablePointer[NcPlaneT] tag, c: NullablePointer[Nccell] tag,
  len: U32, c1: U64, c2: U64)
use @ncplane_gradient[I32](
  n: NullablePointer[NcPlaneT] tag, y: I32, x: I32, ylen: U32, xlen: U32,
  egc: Pointer[U8] tag, styles: U16,
  ul: U64, ur: U64, ll: U64, lr: U64)
use @ncplane_gradient2x1[I32](
  n: NullablePointer[NcPlaneT] tag, y: I32, x: I32, ylen: U32, xlen: U32,
  ul: U32, ur: U32, ll: U32, lr: U32)
use @ncplane_greyscale[None](n: NullablePointer[NcPlaneT] tag)
use @ncplane_fadein[I32](
  n: NullablePointer[NcPlaneT] tag, ts: Pointer[None] tag,
  fader: Pointer[None] tag, curry: Pointer[None] tag)
use @ncplane_mergedown_simple[I32](
  src: NullablePointer[NcPlaneT] tag, dst: NullablePointer[NcPlaneT] tag)
use @ncplane_qrcode[I32](
  n: NullablePointer[NcPlaneT] tag, ymax: Pointer[U32] tag, xmax: Pointer[U32] tag,
  data: Pointer[None] tag, len: USize)

// Styles & Colors
use @ncplane_channels[U64](n: NullablePointer[NcPlaneT] tag)
use @ncplane_styles[U16](n: NullablePointer[NcPlaneT] tag)
use @ncplane_set_styles[None](n: NullablePointer[NcPlaneT] tag, stylebits: U32)
use @ncplane_on_styles[None](n: NullablePointer[NcPlaneT] tag, stylebits: U32)
use @ncplane_off_styles[None](n: NullablePointer[NcPlaneT] tag, stylebits: U32)
use @ncplane_set_fg_rgb[I32](n: NullablePointer[NcPlaneT] tag, channel: U32)
use @ncplane_set_bg_rgb[I32](n: NullablePointer[NcPlaneT] tag, channel: U32)
use @ncplane_set_fg_rgb8[I32](
  n: NullablePointer[NcPlaneT] tag, r: U32, g: U32, b: U32)
use @ncplane_set_bg_rgb8[I32](
  n: NullablePointer[NcPlaneT] tag, r: U32, g: U32, b: U32)
use @ncplane_set_fg_alpha[I32](n: NullablePointer[NcPlaneT] tag, alpha: I32)
use @ncplane_set_bg_alpha[I32](n: NullablePointer[NcPlaneT] tag, alpha: I32)
use @ncplane_set_fg_default[None](n: NullablePointer[NcPlaneT] tag)
use @ncplane_set_bg_default[None](n: NullablePointer[NcPlaneT] tag)
use @ncplane_set_base[I32](
  n: NullablePointer[NcPlaneT] tag, egc: Pointer[U8] tag,
  stylemask: U16, channels: U64)
use @ncplane_set_base_cell[I32](
  n: NullablePointer[NcPlaneT] tag, c: NullablePointer[Nccell] tag)

// Cell functions
use @nccell_load[I32](
  n: NullablePointer[NcPlaneT] tag, c: NullablePointer[Nccell] tag,
  gcluster: Pointer[U8] tag)
use @nccell_release[None](
  n: NullablePointer[NcPlaneT] tag, c: NullablePointer[Nccell] tag)

// Rendering
use @ncpile_render[I32](n: NullablePointer[NcPlaneT] tag)
use @ncpile_rasterize[I32](n: NullablePointer[NcPlaneT] tag)

// Input
use @notcurses_get[U32](
  n: NullablePointer[NcNotcurses] tag, ts: Pointer[None] tag,
  ni: NullablePointer[Ncinput] tag)

// Capabilities & Mouse
use @notcurses_capabilities[NullablePointer[Nccapabilities]](
  n: NullablePointer[NcNotcurses] tag)
use @notcurses_mice_enable[I32](
  n: NullablePointer[NcNotcurses] tag, eventmask: U32)

// Widgets — Progress Bar
use @ncprogbar_create[NullablePointer[NcProgbar]](
  n: NullablePointer[NcPlaneT] tag, opts: NullablePointer[Ncprogbaroptions] tag)
use @ncprogbar_destroy[None](n: NullablePointer[NcProgbar] tag)
use @ncprogbar_plane[NullablePointer[NcPlaneT]](n: NullablePointer[NcProgbar] tag)
use @ncprogbar_set_progress[I32](n: NullablePointer[NcProgbar] tag, p: F64)

// Widgets — Reel
use @ncreel_create[NullablePointer[NcReel]](
  n: NullablePointer[NcPlaneT] tag, popts: NullablePointer[Ncreeloptions] tag)
use @ncreel_destroy[None](nr: NullablePointer[NcReel] tag)
use @ncreel_add[NullablePointer[NcTablet]](
  nr: NullablePointer[NcReel] tag, after: NullablePointer[NcTablet] tag,
  before: NullablePointer[NcTablet] tag,
  cb: Pointer[None] tag, opaque: Pointer[None] tag)
use @ncreel_del[I32](
  nr: NullablePointer[NcReel] tag, t: NullablePointer[NcTablet] tag)
use @ncreel_focused[NullablePointer[NcTablet]](nr: NullablePointer[NcReel] tag)
use @ncreel_next[NullablePointer[NcTablet]](nr: NullablePointer[NcReel] tag)
use @ncreel_prev[NullablePointer[NcTablet]](nr: NullablePointer[NcReel] tag)
use @ncreel_redraw[I32](nr: NullablePointer[NcReel] tag)
use @ncreel_tabletcount[I32](nr: NullablePointer[NcReel] tag)
use @ncreel_plane[NullablePointer[NcPlaneT]](nr: NullablePointer[NcReel] tag)
use @nctablet_plane[NullablePointer[NcPlaneT]](t: NullablePointer[NcTablet] tag)
use @nctablet_userptr[Pointer[None]](t: NullablePointer[NcTablet] tag)

// Utility
use @ncstrwidth[I32](
  egcs: Pointer[U8] tag, validbytes: Pointer[I32] tag,
  validwidth: Pointer[I32] tag)
use @free[None](ptr: Pointer[None] tag)

// Pony reimplementations of inline C functions from notcurses.h.
primitive NotCursesFFI
  fun render(nc: NullablePointer[NcNotcurses] tag): I32 =>
    """
    Renders and rasterizes the standard plane pile.
    Reimplements notcurses_render() which is inline in the C header.
    """
    let stdn = @notcurses_stdplane(nc)
    if @ncpile_render(stdn) != 0 then return -1 end
    @ncpile_rasterize(stdn)

  fun stddim_yx(nc: NullablePointer[NcNotcurses] tag): (NullablePointer[NcPlaneT], U32, U32) =>
    let stdn = @notcurses_stdplane(nc)
    var y: U32 = 0
    var x: U32 = 0
    @ncplane_dim_yx(stdn, addressof y, addressof x)
    (stdn, y, x)

  fun get_nblock(
    nc: NullablePointer[NcNotcurses] tag,
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
    nc: NullablePointer[NcNotcurses] tag,
    ni: NullablePointer[Ncinput])
    : U32
  =>
    """
    Blocking input. Waits indefinitely for input.
    Reimplements notcurses_get_blocking().
    """
    @notcurses_get(nc, Pointer[None], ni)

  fun cantruecolor(nc: NullablePointer[NcNotcurses] tag): Bool =>
    try (@notcurses_capabilities(nc))()?.rgb != 0 else false end

  fun canutf8(nc: NullablePointer[NcNotcurses] tag): Bool =>
    try (@notcurses_capabilities(nc))()?.utf8 != 0 else false end

  // ---- FFI wrappers (callable from any package) ----

  // Lifecycle
  fun core_init(opts: NullablePointer[Notcursesoptions],
    fp: NullablePointer[CFile]): NullablePointer[NcNotcurses]
  =>
    @notcurses_core_init(opts, fp)

  fun stop(nc: NullablePointer[NcNotcurses] tag): I32 =>
    @notcurses_stop(nc)

  fun stdplane(nc: NullablePointer[NcNotcurses] tag): NullablePointer[NcPlaneT] =>
    @notcurses_stdplane(nc)

  fun term_dim_yx(nc: NullablePointer[NcNotcurses] tag): (U32, U32) =>
    var rows: U32 = 0
    var cols: U32 = 0
    @ncplane_dim_yx(@notcurses_stdplane(nc), addressof rows, addressof cols)
    (rows, cols)

  // Planes — creation, destruction
  fun plane_create(n: NullablePointer[NcPlaneT] tag,
    nopts: NullablePointer[Ncplaneoptions]): NullablePointer[NcPlaneT]
  =>
    @ncplane_create(n, nopts)

  fun plane_destroy(n: NullablePointer[NcPlaneT] tag): I32 =>
    @ncplane_destroy(n)

  fun plane_dup(n: NullablePointer[NcPlaneT] tag,
    opaque: Pointer[None]): NullablePointer[NcPlaneT]
  =>
    @ncplane_dup(n, opaque)

  // Planes — geometry
  fun plane_dim_yx(n: NullablePointer[NcPlaneT] tag): (U32, U32) =>
    var y: U32 = 0
    var x: U32 = 0
    @ncplane_dim_yx(n, addressof y, addressof x)
    (y, x)

  fun plane_yx(n: NullablePointer[NcPlaneT] tag): (I32, I32) =>
    var y: I32 = 0
    var x: I32 = 0
    @ncplane_yx(n, addressof y, addressof x)
    (y, x)

  fun plane_cursor_yx(n: NullablePointer[NcPlaneT] tag): (U32, U32) =>
    var y: U32 = 0
    var x: U32 = 0
    @ncplane_cursor_yx(n, addressof y, addressof x)
    (y, x)

  fun plane_cursor_move_yx(n: NullablePointer[NcPlaneT] tag, y: I32, x: I32): I32 =>
    @ncplane_cursor_move_yx(n, y, x)

  fun plane_home(n: NullablePointer[NcPlaneT] tag) =>
    @ncplane_home(n)

  fun plane_erase(n: NullablePointer[NcPlaneT] tag) =>
    @ncplane_erase(n)

  fun plane_move_yx(n: NullablePointer[NcPlaneT] tag, y: I32, x: I32): I32 =>
    @ncplane_move_yx(n, y, x)

  // Output
  fun plane_putc_yx(n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
    c: NullablePointer[Nccell]): I32
  =>
    @ncplane_putc_yx(n, y, x, c)

  fun plane_putegc_yx(n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
    gclust: Pointer[U8] tag, sbytes: Pointer[USize] tag): I32
  =>
    @ncplane_putegc_yx(n, y, x, gclust, sbytes)

  // Content retrieval
  fun plane_at_yx_cell(n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
    c: NullablePointer[Nccell]): I32
  =>
    @ncplane_at_yx_cell(n, y, x, c)

  // Drawing
  fun plane_gradient(n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
    ylen: U32, xlen: U32, egc: Pointer[U8] tag, styles: U16,
    ul: U64, ur: U64, ll: U64, lr: U64): I32
  =>
    @ncplane_gradient(n, y, x, ylen, xlen, egc, styles, ul, ur, ll, lr)

  fun plane_gradient2x1(n: NullablePointer[NcPlaneT] tag, y: I32, x: I32,
    ylen: U32, xlen: U32, ul: U32, ur: U32, ll: U32, lr: U32): I32
  =>
    @ncplane_gradient2x1(n, y, x, ylen, xlen, ul, ur, ll, lr)

  fun plane_greyscale(n: NullablePointer[NcPlaneT] tag) =>
    @ncplane_greyscale(n)

  fun plane_mergedown_simple(src: NullablePointer[NcPlaneT] tag,
    dst: NullablePointer[NcPlaneT] tag): I32
  =>
    @ncplane_mergedown_simple(src, dst)

  fun plane_qrcode(n: NullablePointer[NcPlaneT] tag, ymax: U32, xmax: U32,
    data: Pointer[U8] tag, len: USize): (I32, U32, U32)
  =>
    var y = ymax
    var x = xmax
    let ret = @ncplane_qrcode(n, addressof y, addressof x, data, len)
    (ret, y, x)

//use @ncplane_userptr[NotCursesResizeCallback](t: NullablePointer[NcPlaneT] tag)
  fun plane_userptr(t: NullablePointer[NcPlaneT] tag): NotCursesResizeCallback =>
    @ncplane_userptr(t)

  // Styles & Colors
  fun plane_channels(n: NullablePointer[NcPlaneT] tag): U64 =>
    @ncplane_channels(n)

  fun plane_styles(n: NullablePointer[NcPlaneT] tag): U16 =>
    @ncplane_styles(n)

  fun plane_set_styles(n: NullablePointer[NcPlaneT] tag, stylebits: U32) =>
    @ncplane_set_styles(n, stylebits)

  fun plane_on_styles(n: NullablePointer[NcPlaneT] tag, stylebits: U32) =>
    @ncplane_on_styles(n, stylebits)

  fun plane_off_styles(n: NullablePointer[NcPlaneT] tag, stylebits: U32) =>
    @ncplane_off_styles(n, stylebits)

  fun plane_set_fg_rgb(n: NullablePointer[NcPlaneT] tag, channel: U32): I32 =>
    @ncplane_set_fg_rgb(n, channel)

  fun plane_set_bg_rgb(n: NullablePointer[NcPlaneT] tag, channel: U32): I32 =>
    @ncplane_set_bg_rgb(n, channel)

  fun plane_set_fg_rgb8(n: NullablePointer[NcPlaneT] tag,
    r: U32, g: U32, b: U32): I32
  =>
    @ncplane_set_fg_rgb8(n, r, g, b)

  fun plane_set_bg_rgb8(n: NullablePointer[NcPlaneT] tag,
    r: U32, g: U32, b: U32): I32
  =>
    @ncplane_set_bg_rgb8(n, r, g, b)

  fun plane_set_fg_default(n: NullablePointer[NcPlaneT] tag) =>
    @ncplane_set_fg_default(n)

  fun plane_set_bg_default(n: NullablePointer[NcPlaneT] tag) =>
    @ncplane_set_bg_default(n)

  fun plane_set_base(n: NullablePointer[NcPlaneT] tag, egc: Pointer[U8] tag,
    stylemask: U16, channels: U64): I32
  =>
    @ncplane_set_base(n, egc, stylemask, channels)

  fun plane_scrolling_p(n: NullablePointer[NcPlaneT] tag): Bool =>
    @ncplane_scrolling_p(n)

  fun plane_set_scrolling(n: NullablePointer[NcPlaneT] tag, scrollp: U32): Bool =>
    @ncplane_set_scrolling(n, scrollp)

  // Cell functions
  fun cell_load(n: NullablePointer[NcPlaneT] tag, c: NullablePointer[Nccell],
    gcluster: Pointer[U8] tag): I32
  =>
    @nccell_load(n, c, gcluster)

  fun cell_release(n: NullablePointer[NcPlaneT] tag, c: NullablePointer[Nccell]) =>
    @nccell_release(n, c)

  // Widgets — Progress Bar
  fun progbar_create(n: NullablePointer[NcPlaneT] tag,
    opts: NullablePointer[Ncprogbaroptions]): NullablePointer[NcProgbar]
  =>
    @ncprogbar_create(n, opts)

  fun progbar_destroy(n: NullablePointer[NcProgbar] tag) =>
    @ncprogbar_destroy(n)

  fun progbar_set_progress(n: NullablePointer[NcProgbar] tag, p: F64): I32 =>
    @ncprogbar_set_progress(n, p)

  // Widgets — Reel
  fun reel_create(n: NullablePointer[NcPlaneT] tag,
    popts: NullablePointer[Ncreeloptions]): NullablePointer[NcReel]
  =>
    @ncreel_create(n, popts)

  fun reel_destroy(nr: NullablePointer[NcReel] tag) =>
    @ncreel_destroy(nr)

  fun reel_add(nr: NullablePointer[NcReel] tag, after: NullablePointer[NcTablet] tag,
    before: NullablePointer[NcTablet] tag,
    cb: Pointer[None], opaque: Pointer[None]): NullablePointer[NcTablet]
  =>
    @ncreel_add(nr, after, before, cb, opaque)

  fun reel_next(nr: NullablePointer[NcReel] tag): NullablePointer[NcTablet] =>
    @ncreel_next(nr)

  fun reel_prev(nr: NullablePointer[NcReel] tag): NullablePointer[NcTablet] =>
    @ncreel_prev(nr)

  fun reel_redraw(nr: NullablePointer[NcReel] tag): I32 =>
    @ncreel_redraw(nr)

  fun reel_tabletcount(nr: NullablePointer[NcReel] tag): I32 =>
    @ncreel_tabletcount(nr)

  fun tablet_plane(t: NullablePointer[NcTablet] tag): NullablePointer[NcPlaneT] =>
    @nctablet_plane(t)
