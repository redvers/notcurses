// Pony reimplementations of inline ncplane helper functions from notcurses.h.

primitive NcPlaneFFI
  fun putc(n: NullablePointer[NcPlaneT] tag, c: NullablePointer[Nccell] tag): I32 =>
    @ncplane_putc_yx(n, -1, -1, c)

  fun putegc(n: NullablePointer[NcPlaneT] tag, egc: Pointer[U8] tag,
    sbytes: Pointer[USize]): I32
  =>
    @ncplane_putegc_yx(n, -1, -1, egc, sbytes)

  fun putstr_yx(n: NullablePointer[NcPlaneT] tag, y: I32, x: I32, s: String box): I32 =>
    var ret: I32 = 0
    var idx: USize = 0
    var cur_y = y
    var cur_x = x
    while idx < s.size() do
      var wcs: USize = 0
      let cols = @ncplane_putegc_yx(n, cur_y, cur_x,
        s.cpointer(idx), addressof wcs)
      if cols < 0 then return -ret end
      if wcs == 0 then break end
      cur_y = -1
      cur_x = -1
      ret = ret + cols
      idx = idx + wcs
    end
    ret

  fun putstr(n: NullablePointer[NcPlaneT] tag, s: String box): I32 =>
    putstr_yx(n, -1, -1, s)

  fun putstr_aligned(n: NullablePointer[NcPlaneT] tag, y: I32, align: I32,
    s: String box): I32
  =>
    var validbytes: I32 = 0
    var validwidth: I32 = 0
    @ncstrwidth(s.cpointer(), addressof validbytes, addressof validwidth)
    var xpos = halign(n, align, validwidth)
    if xpos < 0 then xpos = 0 end
    putstr_yx(n, y, xpos, s)

  fun dim_y(n: NullablePointer[NcPlaneT] tag): U32 =>
    var dimy: U32 = 0
    @ncplane_dim_yx(n, addressof dimy, Pointer[U32])
    dimy

  fun dim_x(n: NullablePointer[NcPlaneT] tag): U32 =>
    var dimx: U32 = 0
    @ncplane_dim_yx(n, Pointer[U32], addressof dimx)
    dimx

  fun halign(n: NullablePointer[NcPlaneT] tag, align: I32, c: I32): I32 =>
    let dimx = dim_x(n).i32()
    match align
    | NcAlign.left() => 0
    | NcAlign.center() => (dimx - c) / 2
    | NcAlign.right() => dimx - c
    else
      -0x7FFFFFFF
    end

  fun box_sized(n: NullablePointer[NcPlaneT] tag,
    ul: NullablePointer[Nccell] tag, ur: NullablePointer[Nccell] tag,
    ll: NullablePointer[Nccell] tag, lr: NullablePointer[Nccell] tag,
    hline: NullablePointer[Nccell] tag, vline: NullablePointer[Nccell] tag,
    ylen: U32, xlen: U32, ctlword: U32): I32
  =>
    var y: U32 = 0
    var x: U32 = 0
    @ncplane_cursor_yx(n, addressof y, addressof x)
    @ncplane_box(n, ul, ur, ll, lr, hline, vline,
      (y + ylen) - 1, (x + xlen) - 1, ctlword)

  fun _prime_cell(n: NullablePointer[NcPlaneT] tag, c: Nccell ref,
    chars: String box, idx: USize, styles: U16, channels: U64): I32
  =>
    c.stylemask = styles
    c.channels = channels
    @nccell_load(n, NullablePointer[Nccell](c), chars.cpointer(idx))

  fun rounded_box(n: NullablePointer[NcPlaneT] tag, styles: U16, channels: U64,
    ystop: U32, xstop: U32, ctlword: U32): I32
  =>
    // "╭╮╰╯─│" — 6 multi-byte UTF-8 characters
    let chars: String val = "╭╮╰╯─│"
    var ul = Nccell
    var ur = Nccell
    var ll = Nccell
    var lr = Nccell
    var hl = Nccell
    var vl = Nccell
    // Load each cell from the box string — must consume iso to ref
    let ul' = consume ref ul
    let ur' = consume ref ur
    let ll' = consume ref ll
    let lr' = consume ref lr
    let hl' = consume ref hl
    let vl' = consume ref vl
    var idx: USize = 0
    var ulen = _prime_cell(n, ul', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ur', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ll', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, lr', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, hl', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, vl', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    let ret = @ncplane_box(n,
      NullablePointer[Nccell](ul'), NullablePointer[Nccell](ur'),
      NullablePointer[Nccell](ll'), NullablePointer[Nccell](lr'),
      NullablePointer[Nccell](hl'), NullablePointer[Nccell](vl'),
      ystop, xstop, ctlword)
    @nccell_release(n, NullablePointer[Nccell](ul'))
    @nccell_release(n, NullablePointer[Nccell](ur'))
    @nccell_release(n, NullablePointer[Nccell](ll'))
    @nccell_release(n, NullablePointer[Nccell](lr'))
    @nccell_release(n, NullablePointer[Nccell](hl'))
    @nccell_release(n, NullablePointer[Nccell](vl'))
    ret

  fun double_box(n: NullablePointer[NcPlaneT] tag, styles: U16, channels: U64,
    ystop: U32, xstop: U32, ctlword: U32): I32
  =>
    let chars: String val = "╔╗╚╝═║"
    var ul = Nccell
    var ur = Nccell
    var ll = Nccell
    var lr = Nccell
    var hl = Nccell
    var vl = Nccell
    let ul' = consume ref ul
    let ur' = consume ref ur
    let ll' = consume ref ll
    let lr' = consume ref lr
    let hl' = consume ref hl
    let vl' = consume ref vl
    var idx: USize = 0
    var ulen = _prime_cell(n, ul', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ur', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ll', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, lr', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, hl', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, vl', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    let ret = @ncplane_box(n,
      NullablePointer[Nccell](ul'), NullablePointer[Nccell](ur'),
      NullablePointer[Nccell](ll'), NullablePointer[Nccell](lr'),
      NullablePointer[Nccell](hl'), NullablePointer[Nccell](vl'),
      ystop, xstop, ctlword)
    @nccell_release(n, NullablePointer[Nccell](ul'))
    @nccell_release(n, NullablePointer[Nccell](ur'))
    @nccell_release(n, NullablePointer[Nccell](ll'))
    @nccell_release(n, NullablePointer[Nccell](lr'))
    @nccell_release(n, NullablePointer[Nccell](hl'))
    @nccell_release(n, NullablePointer[Nccell](vl'))
    ret

  fun ascii_box(n: NullablePointer[NcPlaneT] tag, styles: U16, channels: U64,
    ystop: U32, xstop: U32, ctlword: U32): I32
  =>
    let chars: String val = "/\\\\/-|"
    var ul = Nccell
    var ur = Nccell
    var ll = Nccell
    var lr = Nccell
    var hl = Nccell
    var vl = Nccell
    let ul' = consume ref ul
    let ur' = consume ref ur
    let ll' = consume ref ll
    let lr' = consume ref lr
    let hl' = consume ref hl
    let vl' = consume ref vl
    var idx: USize = 0
    var ulen = _prime_cell(n, ul', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ur', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ll', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, lr', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, hl', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, vl', chars, idx, styles, channels)
    if ulen <= 0 then return -1 end
    let ret = @ncplane_box(n,
      NullablePointer[Nccell](ul'), NullablePointer[Nccell](ur'),
      NullablePointer[Nccell](ll'), NullablePointer[Nccell](lr'),
      NullablePointer[Nccell](hl'), NullablePointer[Nccell](vl'),
      ystop, xstop, ctlword)
    @nccell_release(n, NullablePointer[Nccell](ul'))
    @nccell_release(n, NullablePointer[Nccell](ur'))
    @nccell_release(n, NullablePointer[Nccell](ll'))
    @nccell_release(n, NullablePointer[Nccell](lr'))
    @nccell_release(n, NullablePointer[Nccell](hl'))
    @nccell_release(n, NullablePointer[Nccell](vl'))
    ret

  fun perimeter_rounded(n: NullablePointer[NcPlaneT] tag, stylemask: U16,
    channels: U64, ctlword: U32): I32
  =>
    if @ncplane_cursor_move_yx(n, 0, 0) != 0 then return -1 end
    var dimy: U32 = 0
    var dimx: U32 = 0
    @ncplane_dim_yx(n, addressof dimy, addressof dimx)
    let chars: String val = "╭╮╰╯─│"
    var ul = Nccell
    var ur = Nccell
    var ll = Nccell
    var lr = Nccell
    var hl = Nccell
    var vl = Nccell
    let ul' = consume ref ul
    let ur' = consume ref ur
    let ll' = consume ref ll
    let lr' = consume ref lr
    let hl' = consume ref hl
    let vl' = consume ref vl
    var idx: USize = 0
    var ulen = _prime_cell(n, ul', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ur', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ll', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, lr', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, hl', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, vl', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    let r = box_sized(n,
      NullablePointer[Nccell](ul'), NullablePointer[Nccell](ur'),
      NullablePointer[Nccell](ll'), NullablePointer[Nccell](lr'),
      NullablePointer[Nccell](hl'), NullablePointer[Nccell](vl'),
      dimy, dimx, ctlword)
    @nccell_release(n, NullablePointer[Nccell](ul'))
    @nccell_release(n, NullablePointer[Nccell](ur'))
    @nccell_release(n, NullablePointer[Nccell](ll'))
    @nccell_release(n, NullablePointer[Nccell](lr'))
    @nccell_release(n, NullablePointer[Nccell](hl'))
    @nccell_release(n, NullablePointer[Nccell](vl'))
    r

  fun perimeter_double(n: NullablePointer[NcPlaneT] tag, stylemask: U16,
    channels: U64, ctlword: U32): I32
  =>
    if @ncplane_cursor_move_yx(n, 0, 0) != 0 then return -1 end
    var dimy: U32 = 0
    var dimx: U32 = 0
    @ncplane_dim_yx(n, addressof dimy, addressof dimx)
    let chars: String val = "╔╗╚╝═║"
    var ul = Nccell
    var ur = Nccell
    var ll = Nccell
    var lr = Nccell
    var hl = Nccell
    var vl = Nccell
    let ul' = consume ref ul
    let ur' = consume ref ur
    let ll' = consume ref ll
    let lr' = consume ref lr
    let hl' = consume ref hl
    let vl' = consume ref vl
    var idx: USize = 0
    var ulen = _prime_cell(n, ul', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ur', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, ll', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, lr', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, hl', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    idx = idx + ulen.usize()
    ulen = _prime_cell(n, vl', chars, idx, stylemask, channels)
    if ulen <= 0 then return -1 end
    let r = box_sized(n,
      NullablePointer[Nccell](ul'), NullablePointer[Nccell](ur'),
      NullablePointer[Nccell](ll'), NullablePointer[Nccell](lr'),
      NullablePointer[Nccell](hl'), NullablePointer[Nccell](vl'),
      dimy, dimx, ctlword)
    @nccell_release(n, NullablePointer[Nccell](ul'))
    @nccell_release(n, NullablePointer[Nccell](ur'))
    @nccell_release(n, NullablePointer[Nccell](ll'))
    @nccell_release(n, NullablePointer[Nccell](lr'))
    @nccell_release(n, NullablePointer[Nccell](hl'))
    @nccell_release(n, NullablePointer[Nccell](vl'))
    r
