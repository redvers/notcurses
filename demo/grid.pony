use "../notcurses"

class GridDemo is DemoRunner
  let _delay_ns: U64

  new create(delay_ns: U64) =>
    _delay_ns = delay_ns

  fun ref run(nc: Pointer[NcNotcurses]): I32 =>
    let n = NotCursesFFI.stdplane(nc)
    NotCursesFFI.plane_erase(n)
    var ret = _grid_main(nc, n)
    if ret != 0 then return ret end
    _gridswitch(nc, n)

  fun ref _clip_set_fg(c: Nccell ref, r: I32, g: I32, b: I32) =>
    NcCellHelper.set_fg_rgb8(c,
      if r < 0 then 0 else r.u32() end,
      if g < 0 then 0 else g.u32() end,
      if b < 0 then 0 else b.u32() end)

  fun ref _clip_set_bg(c: Nccell ref, r: I32, g: I32, b: I32) =>
    NcCellHelper.set_bg_rgb8(c,
      if r < 0 then 0 else r.u32() end,
      if g < 0 then 0 else g.u32() end,
      if b < 0 then 0 else b.u32() end)

  fun ref _grid_main(nc: Pointer[NcNotcurses], n: Pointer[NcPlaneT]): I32 =>
    // Prepare 9 cells with grid characters: ┍┯┑┝┿┥┕┷┙
    var ul = Nccell
    var uc = Nccell
    var ur = Nccell
    var cl = Nccell
    var cc = Nccell
    var cr = Nccell
    var ll = Nccell
    var lc = Nccell
    var lr' = Nccell
    let ul' = consume ref ul
    let uc' = consume ref uc
    let ur' = consume ref ur
    let cl' = consume ref cl
    let cc' = consume ref cc
    let cr' = consume ref cr
    let ll' = consume ref ll
    let lc' = consume ref lc
    let lr'' = consume ref lr'
    _load_grid_cells(n, ul', uc', ur', cl', cc', cr', ll', lc', lr'',
      "┍┯┑┝┿┥┕┷┙")

    var i: U32 = 0
    while i < 256 do
      (let maxy, let maxx) = NotCursesFFI.term_dim_yx(nc)
      let rs: I32 = (255 / maxx).i32()
      let gs: I32 = (255 / (maxx + maxy)).i32()
      let bs: I32 = (255 / maxy).i32()

      // top line
      var x: U32 = 0
      var y: U32 = 1
      _clip_set_bg(ul', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
      _clip_set_fg(ul', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
        (255 - (bs * y.i32())))
      if NotCursesFFI.plane_putc_yx(n, y.i32(), 0, NullablePointer[Nccell](ul')) <= 0 then
        return -1
      end
      x = 1
      while x < (maxx - 1) do
        _clip_set_bg(uc', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
        _clip_set_fg(uc', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
          (255 - (bs * y.i32())))
        if NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](uc')) <= 0 then
          return -1
        end
        x = x + 1
      end
      _clip_set_bg(ur', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
      _clip_set_fg(ur', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
        (255 - (bs * y.i32())))
      if NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](ur')) <= 0 then
        return -1
      end

      // center rows
      y = 2
      while y < (maxy - 1) do
        x = 0
        _clip_set_bg(cl', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
        _clip_set_fg(cl', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
          (255 - (bs * y.i32())))
        if NotCursesFFI.plane_putc_yx(n, y.i32(), x.i32(), NullablePointer[Nccell](cl')) <= 0 then
          return -1
        end
        x = 1
        while x < (maxx - 1) do
          _clip_set_bg(cc', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
          _clip_set_fg(cc', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
            (255 - (bs * y.i32())))
          if NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](cc')) <= 0 then
            return -1
          end
          x = x + 1
        end
        _clip_set_bg(cr', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
        _clip_set_fg(cr', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
          (255 - (bs * y.i32())))
        if NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](cr')) <= 0 then
          return -1
        end
        y = y + 1
      end

      // bottom line
      x = 0
      _clip_set_bg(ll', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
      _clip_set_fg(ll', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
        (255 - (bs * y.i32())))
      if NotCursesFFI.plane_putc_yx(n, y.i32(), x.i32(), NullablePointer[Nccell](ll')) <= 0 then
        return -1
      end
      x = 1
      while x < (maxx - 1) do
        _clip_set_bg(lc', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
        _clip_set_fg(lc', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
          (255 - (bs * y.i32())))
        if NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](lc')) <= 0 then
          return -1
        end
        x = x + 1
      end
      _clip_set_bg(lr'', i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
      _clip_set_fg(lr'', (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
        (255 - (bs * y.i32())))
      if NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](lr'')) <= 0 then
        return -1
      end
      let rr = _DemoUtil.render(nc)
      if rr != 0 then return rr end
      i = i + 1
    end
    _release_9(n, ul', uc', ur', cl', cc', cr', ll', lc', lr'')
    0

  fun ref _gridswitch(nc: Pointer[NcNotcurses], n: Pointer[NcPlaneT]): I32 =>
    NotCursesFFI.plane_erase(n)
    var ul = Nccell
    var uc = Nccell
    var ur = Nccell
    var cl = Nccell
    var cc = Nccell
    var cr = Nccell
    var ll = Nccell
    var lc = Nccell
    var lr' = Nccell
    let ul' = consume ref ul
    let uc' = consume ref uc
    let ur' = consume ref ur
    let cl' = consume ref cl
    let cc' = consume ref cc
    let cr' = consume ref cr
    let ll' = consume ref ll
    let lc' = consume ref lc
    let lr'' = consume ref lr'
    _load_grid_cells(n, ul', uc', ur', cl', cc', cr', ll', lc', lr'',
      "┍┯┑┝┿┥┕┷┙")
    var bgr: I32 = 0
    var bgg: I32 = 0x80
    var bgb: I32 = 0
    var i: U32 = 0
    while i < 256 do
      (let maxy, let maxx) = NotCursesFFI.term_dim_yx(nc)
      let rs: I32 = (256 / maxx).i32()
      let gs: I32 = (256 / (maxx + maxy)).i32()
      let bs: I32 = (256 / maxy).i32()
      bgr = i.i32()
      bgg = 0x80
      bgb = i.i32()

      var x: U32 = 0
      var y: U32 = 1
      _clip_set_fg(ul', 255 - (rs * y.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      _bgnext(ul', bgr, bgg, bgb)
      if NotCursesFFI.plane_putc_yx(n, y.i32(), x.i32(), NullablePointer[Nccell](ul')) <= 0 then
        return -1
      end
      x = 1
      while x < (maxx - 1) do
        _clip_set_fg(uc', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * x.i32()))
        _bgnext(uc', bgr, bgg, bgb)
        if NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](uc')) <= 0 then
          return -1
        end
        x = x + 1
      end
      _clip_set_fg(ur', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * x.i32()))
      _bgnext(ur', bgr, bgg, bgb)
      NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](ur'))

      y = 2
      while y < (maxy - 1) do
        x = 0
        _clip_set_fg(cl', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * x.i32()))
        _bgnext(cl', bgr, bgg, bgb)
        NotCursesFFI.plane_putc_yx(n, y.i32(), x.i32(), NullablePointer[Nccell](cl'))
        x = 1
        while x < (maxx - 1) do
          _clip_set_fg(cc', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
            255 - (bs * x.i32()))
          _bgnext(cc', bgr, bgg, bgb)
          NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](cc'))
          x = x + 1
        end
        _clip_set_fg(cr', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * x.i32()))
        _bgnext(cr', bgr, bgg, bgb)
        NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](cr'))
        y = y + 1
      end

      x = 0
      _clip_set_fg(ll', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * x.i32()))
      _bgnext(ll', bgr, bgg, bgb)
      NotCursesFFI.plane_putc_yx(n, y.i32(), x.i32(), NullablePointer[Nccell](ll'))
      x = 1
      while x < (maxx - 1) do
        _clip_set_fg(lc', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * x.i32()))
        _bgnext(lc', bgr, bgg, bgb)
        NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](lc'))
        x = x + 1
      end
      _clip_set_fg(lr'', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * x.i32()))
      _bgnext(lr'', bgr, bgg, bgb)
      NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](lr''))
      let rr = _DemoUtil.render(nc)
      if rr != 0 then return rr end
      i = i + 1
    end
    _release_9(n, ul', uc', ur', cl', cc', cr', ll', lc', lr'')

    // Now do gridinv
    _gridinv(nc, n)

  fun ref _gridinv(nc: Pointer[NcNotcurses], n: Pointer[NcPlaneT]): I32 =>
    NotCursesFFI.plane_erase(n)
    var ul = Nccell
    var uc = Nccell
    var ur = Nccell
    var cl = Nccell
    var cc = Nccell
    var cr = Nccell
    var ll = Nccell
    var lc = Nccell
    var lr' = Nccell
    let ul' = consume ref ul
    let uc' = consume ref uc
    let ur' = consume ref ur
    let cl' = consume ref cl
    let cc' = consume ref cc
    let cr' = consume ref cr
    let ll' = consume ref ll
    let lc' = consume ref lc
    let lr'' = consume ref lr'
    _load_grid_cells(n, ul', uc', ur', cl', cc', cr', ll', lc', lr'',
      "╔╦╗╠╬╣╚╩╝")

    var i: U32 = 0
    while i < 256 do
      (let maxy, let maxx) = NotCursesFFI.term_dim_yx(nc)
      let rs: I32 = (255 / maxx).i32()
      let gs: I32 = (255 / (maxx + maxy)).i32()
      let bs: I32 = (255 / maxy).i32()
      var x: U32 = 0
      var y: U32 = 1

      _clip_set_fg(ul', (i / 2).i32(), i.i32(), (i / 2).i32())
      _clip_set_bg(ul', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      NotCursesFFI.plane_putc_yx(n, y.i32(), x.i32(), NullablePointer[Nccell](ul'))
      x = 1
      while x < (maxx - 1) do
        _clip_set_fg(uc', (i / 2).i32(), i.i32(), (i / 2).i32())
        _clip_set_bg(uc', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * y.i32()))
        NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](uc'))
        x = x + 1
      end
      _clip_set_fg(ur', (i / 2).i32(), i.i32(), (i / 2).i32())
      _clip_set_bg(ur', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](ur'))

      y = 2
      while y < (maxy - 1) do
        x = 0
        _clip_set_fg(cl', (i / 2).i32(), i.i32(), (i / 2).i32())
        _clip_set_bg(cl', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * y.i32()))
        NotCursesFFI.plane_putc_yx(n, y.i32(), x.i32(), NullablePointer[Nccell](cl'))
        x = 1
        while x < (maxx - 1) do
          _clip_set_fg(cc', (i / 2).i32(), i.i32(), (i / 2).i32())
          _clip_set_bg(cc', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
            255 - (bs * y.i32()))
          NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](cc'))
          x = x + 1
        end
        _clip_set_fg(cr', (i / 2).i32(), i.i32(), (i / 2).i32())
        _clip_set_bg(cr', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * y.i32()))
        NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](cr'))
        y = y + 1
      end

      x = 0
      _clip_set_fg(ll', (i / 2).i32(), i.i32(), (i / 2).i32())
      _clip_set_bg(ll', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      NotCursesFFI.plane_putc_yx(n, y.i32(), x.i32(), NullablePointer[Nccell](ll'))
      x = 1
      while x < (maxx - 1) do
        _clip_set_fg(lc', (i / 2).i32(), i.i32(), (i / 2).i32())
        _clip_set_bg(lc', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * y.i32()))
        NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](lc'))
        x = x + 1
      end
      _clip_set_fg(lr'', (i / 2).i32(), i.i32(), (i / 2).i32())
      _clip_set_bg(lr'', 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      NotCursesFFI.plane_putc_yx(n, -1, -1, NullablePointer[Nccell](lr''))
      let rr = _DemoUtil.render(nc)
      if rr != 0 then return rr end
      i = i + 1
    end
    _release_9(n, ul', uc', ur', cl', cc', cr', ll', lc', lr'')
    0

  fun _load_grid_cells(n: Pointer[NcPlaneT],
    ul: Nccell ref, uc: Nccell ref, ur: Nccell ref,
    cl: Nccell ref, cc: Nccell ref, cr: Nccell ref,
    ll: Nccell ref, lc: Nccell ref, lr: Nccell ref,
    chars: String val)
  =>
    var idx: USize = 0
    let cells = [as Nccell ref: ul; uc; ur; cl; cc; cr; ll; lc; lr]
    for c in cells.values() do
      let ret = NotCursesFFI.cell_load(n, NullablePointer[Nccell](c),
        chars.cpointer(idx))
      if ret > 0 then idx = idx + ret.usize() end
    end

  fun _release_9(n: Pointer[NcPlaneT],
    ul: Nccell ref, uc: Nccell ref, ur: Nccell ref,
    cl: Nccell ref, cc: Nccell ref, cr: Nccell ref,
    ll: Nccell ref, lc: Nccell ref, lr: Nccell ref)
  =>
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](ul))
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](uc))
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](ur))
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](cl))
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](cc))
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](cr))
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](ll))
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](lc))
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](lr))

  fun ref _bgnext(c: Nccell ref, bgr: I32, bgg: I32, bgb: I32) =>
    _clip_set_bg(c, bgr, bgg, bgb)
