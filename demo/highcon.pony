use "../notcurses"

class HighconDemo is DemoRunner
  let _delay_ns: U64

  new create(delay_ns: U64) =>
    _delay_ns = delay_ns

  fun ref run(nc: Pointer[NcNotcurses]): I32 =>
    let step: U32 = 16
    (let n, let dimy, let dimx) = NotCursesFFI.stddim_yx(nc)
    let totcells: I32 = ((dimy - 1) * dimx).i32()
    if totcells <= 1 then return -1 end

    let motto = " high contrast text is evaluated relative to the solved background"
    var c = Nccell
    let c' = consume ref c
    var total: U32 = 0
    var r: U32 = 0
    var g: U32 = 0
    var b: U32 = 0

    // Build up initial screen with high-contrast text on colored background
    var out: I32 = 0
    while out < totcells do
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
        NcCellHelper.load_char(c', motto(ch_idx)?.u32())
      end
      NcCellHelper.set_fg_alpha(c', NcAlpha.highcontrast())
      NcCellHelper.set_bg_rgb(c', rgb)
      let py = ((out.u32() + dimx) / dimx).i32()
      let px = (out.u32() % dimx).i32()
      NotCursesFFI.plane_putc_yx(n, py, px, NullablePointer[Nccell](c'))
      out = out + 1
    end

    // Animate: draw background in from both corners
    var offset: I32 = 0
    let startns = _DemoUtil.clock_ns()
    let totalns = _delay_ns * 2
    let iterns: U64 = if totcells > 2 then totalns / (totcells.u64() / 2)
      else totalns end

    while offset <= (totcells / 2) do
      if offset > 0 then
        NcCellHelper.set_fg_alpha(c', NcAlpha.opaque())
        let f = (offset - 1) + dimx.i32()
        let l = (totcells + dimx.i32()) - offset

        NotCursesFFI.plane_at_yx_cell(n, f / dimx.i32(), f % dimx.i32(),
          NullablePointer[Nccell](c'))
        NcCellHelper.set_fg_rgb(c', (0x004000 + (16 * offset.u32())))
        NcCellHelper.set_bg_rgb(c', 0)
        NcCellHelper.set_fg_alpha(c', NcAlpha.opaque())
        NotCursesFFI.plane_putc_yx(n, f / dimx.i32(), f % dimx.i32(),
          NullablePointer[Nccell](c'))

        NotCursesFFI.plane_at_yx_cell(n, l / dimx.i32(), l % dimx.i32(),
          NullablePointer[Nccell](c'))
        NcCellHelper.set_fg_rgb(c', (0x004000 + (16 * offset.u32())))
        NcCellHelper.set_bg_rgb(c', 0)
        NcCellHelper.set_fg_alpha(c', NcAlpha.opaque())
        NotCursesFFI.plane_putc_yx(n, l / dimx.i32(), l % dimx.i32(),
          NullablePointer[Nccell](c'))
      end
      let ret = _DemoUtil.render(nc)
      if ret != 0 then
        NotCursesFFI.cell_release(n, NullablePointer[Nccell](c'))
        return ret
      end
      let targns = startns + (offset.u64() * iterns)
      let now = _DemoUtil.clock_ns()
      if targns > now then
        _DemoUtil.sleep_ns(targns - now)
      end
      offset = offset + 1
    end
    NotCursesFFI.cell_release(n, NullablePointer[Nccell](c'))
    0

  fun _generate_next_color(total_in: U32, r_in: U32, g_in: U32, b_in: U32,
    step: U32): (U32, U32, U32, U32, U32)
  =>
    // Returns (new_total, new_r, new_g, new_b, rgb_value)
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
