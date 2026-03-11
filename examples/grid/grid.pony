use "../../notcurses"
use "time"

class iso GridDemo is TimerNotify
  let _main: Main tag
  let _nc: Pointer[NcNotcurses] tag
  var _n: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _phase: U32 = 0  // 0=grid_main, 1=gridswitch, 2=gridinv
  var _i: U32 = 0
  var _ul: Nccell = Nccell
  var _uc: Nccell = Nccell
  var _ur: Nccell = Nccell
  var _cl: Nccell = Nccell
  var _cc: Nccell = Nccell
  var _cr: Nccell = Nccell
  var _ll: Nccell = Nccell
  var _lc: Nccell = Nccell
  var _lr: Nccell = Nccell
  var _ret: I32 = 0
  var _done: Bool = false

  new iso create(main: Main tag, nc: Pointer[NcNotcurses] tag, delay_ns: U64) =>
    _main = main
    _nc = nc
    _n = NotCursesFFI.stdplane(nc)
    NotCursesFFI.plane_erase(_n)
    _load_grid_cells(_n, _ul, _uc, _ur, _cl, _cc, _cr, _ll, _lc, _lr,
      "┍┯┑┝┿┥┕┷┙")

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _done then return false end

    // Batch 4 iterations per tick
    var batch: U32 = 0
    while (batch < 4) and (_i < 256) do
      match _phase
      | 0 => _do_grid_main_iter()
      | 1 => _do_gridswitch_iter()
      | 2 => _do_gridinv_iter()
      end
      if _ret != 0 then return false end
      _i = _i + 1
      batch = batch + 1
    end

    if _i >= 256 then
      _release_9(_n, _ul, _uc, _ur, _cl, _cc, _cr, _ll, _lc, _lr)
      _phase = _phase + 1
      _i = 0
      if _phase > 2 then
        return false
      end
      // Init next phase
      _ul = Nccell; _uc = Nccell; _ur = Nccell
      _cl = Nccell; _cc = Nccell; _cr = Nccell
      _ll = Nccell; _lc = Nccell; _lr = Nccell
      match _phase
      | 1 =>
        NotCursesFFI.plane_erase(_n)
        _load_grid_cells(_n, _ul, _uc, _ur, _cl, _cc, _cr, _ll, _lc, _lr,
          "┍┯┑┝┿┥┕┷┙")
      | 2 =>
        NotCursesFFI.plane_erase(_n)
        _load_grid_cells(_n, _ul, _uc, _ur, _cl, _cc, _cr, _ll, _lc, _lr,
          "╔╦╗╠╬╣╚╩╝")
      end
    end
    true

  fun ref cancel(timer: Timer) =>
    _main.demo_finished(_ret)

  fun ref _do_grid_main_iter() =>
    (let maxy, let maxx) = NotCursesFFI.term_dim_yx(_nc)
    let rs: I32 = (255 / maxx).i32()
    let gs: I32 = (255 / (maxx + maxy)).i32()
    let bs: I32 = (255 / maxy).i32()

    // top line
    var x: U32 = 0
    var y: U32 = 1
    _clip_set_bg(_ul, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
    _clip_set_fg(_ul, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
      (255 - (bs * y.i32())))
    if NotCursesFFI.plane_putc_yx(_n, y.i32(), 0, NullablePointer[Nccell](_ul)) <= 0 then
      _ret = -1; return
    end
    x = 1
    while x < (maxx - 1) do
      _clip_set_bg(_uc, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
      _clip_set_fg(_uc, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
        (255 - (bs * y.i32())))
      if NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_uc)) <= 0 then
        _ret = -1; return
      end
      x = x + 1
    end
    _clip_set_bg(_ur, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
    _clip_set_fg(_ur, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
      (255 - (bs * y.i32())))
    if NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_ur)) <= 0 then
      _ret = -1; return
    end

    // center rows
    y = 2
    while y < (maxy - 1) do
      x = 0
      _clip_set_bg(_cl, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
      _clip_set_fg(_cl, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
        (255 - (bs * y.i32())))
      if NotCursesFFI.plane_putc_yx(_n, y.i32(), x.i32(), NullablePointer[Nccell](_cl)) <= 0 then
        _ret = -1; return
      end
      x = 1
      while x < (maxx - 1) do
        _clip_set_bg(_cc, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
        _clip_set_fg(_cc, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
          (255 - (bs * y.i32())))
        if NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_cc)) <= 0 then
          _ret = -1; return
        end
        x = x + 1
      end
      _clip_set_bg(_cr, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
      _clip_set_fg(_cr, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
        (255 - (bs * y.i32())))
      if NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_cr)) <= 0 then
        _ret = -1; return
      end
      y = y + 1
    end

    // bottom line
    x = 0
    _clip_set_bg(_ll, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
    _clip_set_fg(_ll, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
      (255 - (bs * y.i32())))
    if NotCursesFFI.plane_putc_yx(_n, y.i32(), x.i32(), NullablePointer[Nccell](_ll)) <= 0 then
      _ret = -1; return
    end
    x = 1
    while x < (maxx - 1) do
      _clip_set_bg(_lc, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
      _clip_set_fg(_lc, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
        (255 - (bs * y.i32())))
      if NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_lc)) <= 0 then
        _ret = -1; return
      end
      x = x + 1
    end
    _clip_set_bg(_lr, _i.i32(), (x * rs.u32()).i32(), (y * bs.u32()).i32())
    _clip_set_fg(_lr, (255 - (rs * x.i32())), (255 - (gs * (x + y).i32())),
      (255 - (bs * y.i32())))
    if NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_lr)) <= 0 then
      _ret = -1; return
    end
    _ret = _DemoUtil.render(_nc)

  fun ref _do_gridswitch_iter() =>
    (let maxy, let maxx) = NotCursesFFI.term_dim_yx(_nc)
    let rs: I32 = (256 / maxx).i32()
    let gs: I32 = (256 / (maxx + maxy)).i32()
    let bs: I32 = (256 / maxy).i32()
    let bgr: I32 = _i.i32()
    let bgg: I32 = 0x80
    let bgb: I32 = _i.i32()

    var x: U32 = 0
    var y: U32 = 1
    _clip_set_fg(_ul, 255 - (rs * y.i32()), 255 - (gs * (x + y).i32()),
      255 - (bs * y.i32()))
    _bgnext(_ul, bgr, bgg, bgb)
    if NotCursesFFI.plane_putc_yx(_n, y.i32(), x.i32(), NullablePointer[Nccell](_ul)) <= 0 then
      _ret = -1; return
    end
    x = 1
    while x < (maxx - 1) do
      _clip_set_fg(_uc, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * x.i32()))
      _bgnext(_uc, bgr, bgg, bgb)
      if NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_uc)) <= 0 then
        _ret = -1; return
      end
      x = x + 1
    end
    _clip_set_fg(_ur, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
      255 - (bs * x.i32()))
    _bgnext(_ur, bgr, bgg, bgb)
    NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_ur))

    y = 2
    while y < (maxy - 1) do
      x = 0
      _clip_set_fg(_cl, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * x.i32()))
      _bgnext(_cl, bgr, bgg, bgb)
      NotCursesFFI.plane_putc_yx(_n, y.i32(), x.i32(), NullablePointer[Nccell](_cl))
      x = 1
      while x < (maxx - 1) do
        _clip_set_fg(_cc, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * x.i32()))
        _bgnext(_cc, bgr, bgg, bgb)
        NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_cc))
        x = x + 1
      end
      _clip_set_fg(_cr, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * x.i32()))
      _bgnext(_cr, bgr, bgg, bgb)
      NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_cr))
      y = y + 1
    end

    x = 0
    _clip_set_fg(_ll, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
      255 - (bs * x.i32()))
    _bgnext(_ll, bgr, bgg, bgb)
    NotCursesFFI.plane_putc_yx(_n, y.i32(), x.i32(), NullablePointer[Nccell](_ll))
    x = 1
    while x < (maxx - 1) do
      _clip_set_fg(_lc, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * x.i32()))
      _bgnext(_lc, bgr, bgg, bgb)
      NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_lc))
      x = x + 1
    end
    _clip_set_fg(_lr, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
      255 - (bs * x.i32()))
    _bgnext(_lr, bgr, bgg, bgb)
    NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_lr))
    _ret = _DemoUtil.render(_nc)

  fun ref _do_gridinv_iter() =>
    (let maxy, let maxx) = NotCursesFFI.term_dim_yx(_nc)
    let rs: I32 = (255 / maxx).i32()
    let gs: I32 = (255 / (maxx + maxy)).i32()
    let bs: I32 = (255 / maxy).i32()
    var x: U32 = 0
    var y: U32 = 1

    _clip_set_fg(_ul, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
    _clip_set_bg(_ul, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
      255 - (bs * y.i32()))
    NotCursesFFI.plane_putc_yx(_n, y.i32(), x.i32(), NullablePointer[Nccell](_ul))
    x = 1
    while x < (maxx - 1) do
      _clip_set_fg(_uc, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
      _clip_set_bg(_uc, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_uc))
      x = x + 1
    end
    _clip_set_fg(_ur, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
    _clip_set_bg(_ur, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
      255 - (bs * y.i32()))
    NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_ur))

    y = 2
    while y < (maxy - 1) do
      x = 0
      _clip_set_fg(_cl, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
      _clip_set_bg(_cl, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      NotCursesFFI.plane_putc_yx(_n, y.i32(), x.i32(), NullablePointer[Nccell](_cl))
      x = 1
      while x < (maxx - 1) do
        _clip_set_fg(_cc, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
        _clip_set_bg(_cc, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
          255 - (bs * y.i32()))
        NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_cc))
        x = x + 1
      end
      _clip_set_fg(_cr, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
      _clip_set_bg(_cr, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_cr))
      y = y + 1
    end

    x = 0
    _clip_set_fg(_ll, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
    _clip_set_bg(_ll, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
      255 - (bs * y.i32()))
    NotCursesFFI.plane_putc_yx(_n, y.i32(), x.i32(), NullablePointer[Nccell](_ll))
    x = 1
    while x < (maxx - 1) do
      _clip_set_fg(_lc, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
      _clip_set_bg(_lc, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
        255 - (bs * y.i32()))
      NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_lc))
      x = x + 1
    end
    _clip_set_fg(_lr, (_i / 2).i32(), _i.i32(), (_i / 2).i32())
    _clip_set_bg(_lr, 255 - (rs * x.i32()), 255 - (gs * (x + y).i32()),
      255 - (bs * y.i32()))
    NotCursesFFI.plane_putc_yx(_n, -1, -1, NullablePointer[Nccell](_lr))
    _ret = _DemoUtil.render(_nc)

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

  fun ref _bgnext(c: Nccell ref, bgr: I32, bgg: I32, bgb: I32) =>
    _clip_set_bg(c, bgr, bgg, bgb)

  fun _load_grid_cells(n: Pointer[NcPlaneT] tag,
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

  fun _release_9(n: Pointer[NcPlaneT] tag,
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
