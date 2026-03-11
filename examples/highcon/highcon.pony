use "../../notcurses"
use "time"

class iso HighconDemo is TimerNotify
  let _main: Main tag
  let _nc: Pointer[NcNotcurses] tag
  var _n: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _dimx: U32 = 0
  var _totcells: I32 = 0
  var _c: Nccell = Nccell
  var _offset: I32 = 0
  var _ret: I32 = 0
  var _done: Bool = false

  new iso create(main: Main tag, nc: Pointer[NcNotcurses] tag, delay_ns: U64) =>
    _main = main
    _nc = nc

    let step: U32 = 16
    (let n, let dimy, let dimx) = NotCursesFFI.stddim_yx(nc)
    _n = n
    _dimx = dimx
    _totcells = ((dimy - 1) * dimx).i32()
    if _totcells <= 1 then
      _ret = -1
      _done = true
      return
    end

    let motto = " high contrast text is evaluated relative to the solved background"
    var total: U32 = 0
    var r: U32 = 0
    var g: U32 = 0
    var b: U32 = 0

    // Build up initial screen with high-contrast text on colored background
    var out: I32 = 0
    while out < _totcells do
      let color = _generate_next_color(total, r, g, b, step)
      total = color._1
      r = color._2
      g = color._3
      b = color._4
      let rgb = color._5
      if total > 768 then
        total = 0; r = 0; g = 0; b = 0
      end
      let ch_idx = (out.usize() % motto.size())
      try
        NcCellHelper.load_char(_c, motto(ch_idx)?.u32())
      end
      NcCellHelper.set_fg_alpha(_c, NcAlpha.highcontrast())
      NcCellHelper.set_bg_rgb(_c, rgb)
      let py = ((out.u32() + dimx) / dimx).i32()
      let px = (out.u32() % dimx).i32()
      NotCursesFFI.plane_putc_yx(n, py, px, NullablePointer[Nccell](_c))
      out = out + 1
    end

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _done then return false end
    if _offset > (_totcells / 2) then return false end

    if _offset > 0 then
      NcCellHelper.set_fg_alpha(_c, NcAlpha.opaque())
      let f = (_offset - 1) + _dimx.i32()
      let l = (_totcells + _dimx.i32()) - _offset

      NotCursesFFI.plane_at_yx_cell(_n, f / _dimx.i32(), f % _dimx.i32(),
        NullablePointer[Nccell](_c))
      NcCellHelper.set_fg_rgb(_c, (0x004000 + (16 * _offset.u32())))
      NcCellHelper.set_bg_rgb(_c, 0)
      NcCellHelper.set_fg_alpha(_c, NcAlpha.opaque())
      NotCursesFFI.plane_putc_yx(_n, f / _dimx.i32(), f % _dimx.i32(),
        NullablePointer[Nccell](_c))

      NotCursesFFI.plane_at_yx_cell(_n, l / _dimx.i32(), l % _dimx.i32(),
        NullablePointer[Nccell](_c))
      NcCellHelper.set_fg_rgb(_c, (0x004000 + (16 * _offset.u32())))
      NcCellHelper.set_bg_rgb(_c, 0)
      NcCellHelper.set_fg_alpha(_c, NcAlpha.opaque())
      NotCursesFFI.plane_putc_yx(_n, l / _dimx.i32(), l % _dimx.i32(),
        NullablePointer[Nccell](_c))
    end
    _ret = _DemoUtil.render(_nc)
    if _ret != 0 then
      NotCursesFFI.cell_release(_n, NullablePointer[Nccell](_c))
      return false
    end
    _offset = _offset + 1
    _offset <= (_totcells / 2)

  fun ref cancel(timer: Timer) =>
    if not _n.is_null() then
      NotCursesFFI.cell_release(_n, NullablePointer[Nccell](_c))
    end
    _main.demo_finished(_ret)

  fun _generate_next_color(total_in: U32, r_in: U32, g_in: U32, b_in: U32,
    step: U32): (U32, U32, U32, U32, U32)
  =>
    var total = total_in
    var r = r_in
    var g = g_in
    var b = b_in
    let ret = ((((r - if r == 256 then U32(1) else 0 end) << 8)
      + (g - if g == 256 then U32(1) else 0 end)) << 8)
      + (b - if b == 256 then U32(1) else 0 end)

    if total <= 256 then
      if r == total then
        _minimize(total, r, g, b, step)
        total = total + step
        b = if r >= 256 then U32(256) else r + step end
        r = total - (b + g)
      else
        if b > 0 then
          g = g + step
        else
          r = r + step
          g = 0
        end
        b = total - (g + r)
      end
    elseif total <= 512 then
      if (r == 256) and ((r + g) == total) then
        total = total + step
        b = if r >= 256 then U32(256) else r + step end
        r = total - (b + g)
      else
        if (g == 256) or (g == (total - r)) then
          r = r + step
          b = if (total - r) > 256 then U32(256) else total - r end
        else
          b = b - step
        end
        g = total - (b + r)
      end
    else
      if (r == 256) and (g == 256) then
        total = total + step
        b = if r >= 256 then U32(256) else r + step end
        r = total - (b + g)
      else
        if g == 256 then
          r = r + step
          b = 256
        else
          b = b - step
        end
        g = total - (r + b)
      end
    end
    (total, r, g, b, ret)

  fun _minimize(total: U32, r: U32, g: U32, b: U32, step: U32)
    : (U32, U32, U32, U32)
  =>
    let new_total = total + step
    let new_b: U32 = if r >= 256 then 256 else r + step end
    let new_r = new_total - (new_b + g)
    (new_total, new_r, g, new_b)
