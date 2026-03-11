use "../notcurses"

class AnimateDemo is DemoRunner
  let _delay_ns: U64

  new create(delay_ns: U64) =>
    _delay_ns = delay_ns

  fun ref run(nc: Pointer[NcNotcurses]): I32 =>
    if not NotCursesFFI.canutf8(nc) then return 0 end
    (let n, let dimy, let dimx) = NotCursesFFI.stddim_yx(nc)
    NotCursesFFI.plane_erase(n)
    NotCursesFFI.plane_home(n)

    // Background gradient
    var tl: U32 = 0
    var tr: U32 = 0
    var bl: U32 = 0
    var br: U32 = 0
    tl = NcChannel.set_rgb8(tl, 0, 0, 0)
    tr = NcChannel.set_rgb8(tr, 0, 0xFF, 0)
    bl = NcChannel.set_rgb8(bl, 0, 0, 0xFF)
    br = NcChannel.set_rgb8(br, 0, 0xFF, 0xFF)
    if NotCursesFFI.plane_gradient2x1(n, -1, -1, 0, 0, tl, tr, bl, br) < 0 then
      return -1
    end
    NotCursesFFI.plane_set_fg_rgb(n, 0xf0f0a0)
    NotCursesFFI.plane_set_bg_rgb(n, 0)

    var width: U32 = 40
    if width > (dimx - 8) then
      width = dimx - 8
      if width == 0 then return -1 end
    end
    var height: U32 = 40
    if height >= (dimy - 4) then
      height = dimy - 5
      if height == 0 then return -1 end
    end
    let planey = ((dimy - height) / 2) + 1

    // Create column plane (centered)
    var nopts = Ncplaneoptions
    nopts.y = planey.i32()
    nopts.x = NcAlign.center()
    nopts.rows = height
    nopts.cols = width
    nopts.flags = NcPlaneOption.horaligned()
    let column = NotCursesFFI.plane_create(n,
      NullablePointer[Ncplaneoptions](consume nopts))
    if column.is_null() then return -1 end

    // Create left/right progress bars
    (let coly, let colx) = NotCursesFFI.plane_dim_yx(column)
    (let colposy, let colposx) = NotCursesFFI.plane_yx(column)

    // Left pbar plane
    var lopts = Ncplaneoptions
    lopts.x = (colposx / 4) * -3
    lopts.rows = coly
    lopts.cols = (dimx - colx) / 4
    let leftp = NotCursesFFI.plane_create(column,
      NullablePointer[Ncplaneoptions](consume lopts))
    if leftp.is_null() then
      NotCursesFFI.plane_destroy(column)
      return -1
    end
    NotCursesFFI.plane_set_base(leftp, " ".cpointer(), 0,
      NcChannels.initializer(0xdd, 0xdd, 0xdd, 0x1b, 0x1b, 0x1b))

    var lpopts = Ncprogbaroptions
    lpopts.brchannel = NcChannel.set_rgb8(0, 0, 0, 0)
    lpopts.blchannel = NcChannel.set_rgb8(0, 0, 0xff, 0)
    lpopts.urchannel = NcChannel.set_rgb8(0, 0, 0, 0xff)
    lpopts.ulchannel = NcChannel.set_rgb8(0, 0, 0xff, 0xff)
    let left = NotCursesFFI.progbar_create(leftp,
      NullablePointer[Ncprogbaroptions](consume lpopts))
    if left.is_null() then
      NotCursesFFI.plane_destroy(column)
      return -1
    end

    // Right pbar plane
    var ropts = Ncplaneoptions
    ropts.x = colx.i32() + (colposx / 4)
    ropts.rows = coly
    ropts.cols = (dimx - colx) / 4
    let rightp = NotCursesFFI.plane_create(column,
      NullablePointer[Ncplaneoptions](consume ropts))
    if rightp.is_null() then
      NotCursesFFI.progbar_destroy(left)
      NotCursesFFI.plane_destroy(column)
      return -1
    end
    NotCursesFFI.plane_set_base(rightp, " ".cpointer(), 0,
      NcChannels.initializer(0xdd, 0xdd, 0xdd, 0x1b, 0x1b, 0x1b))

    var rpopts = Ncprogbaroptions
    rpopts.brchannel = NcChannel.set_rgb8(0, 0, 0, 0)
    rpopts.blchannel = NcChannel.set_rgb8(0, 0, 0xff, 0)
    rpopts.urchannel = NcChannel.set_rgb8(0, 0, 0, 0xff)
    rpopts.ulchannel = NcChannel.set_rgb8(0, 0, 0xff, 0xff)
    rpopts.flags = NcProgbarOption.retrograde()
    let right = NotCursesFFI.progbar_create(rightp,
      NullablePointer[Ncprogbaroptions](consume rpopts))
    if right.is_null() then
      NotCursesFFI.progbar_destroy(left)
      NotCursesFFI.plane_destroy(column)
      return -1
    end
    NotCursesFFI.plane_destroy(column)

    // Animate spiral
    let ret = _animate_spiral(nc, left, right)
    NotCursesFFI.progbar_destroy(left)
    NotCursesFFI.progbar_destroy(right)
    ret

  fun ref _animate_spiral(nc: Pointer[NcNotcurses],
    left: Pointer[NcProgbar], right: Pointer[NcProgbar]): I32
  =>
    (let std, let dimy, let dimx) = NotCursesFFI.stddim_yx(nc)

    // Simplified spiral: write colored characters outward from center
    let total_steps: U32 = dimy * dimx
    let iterns = (_delay_ns * 5) / total_steps.u64()
    var step: U32 = 0
    var x: I32 = (dimx / 2).i32()
    var y: I32 = (dimy / 2).i32()
    var dx: I32 = 1
    var dy: I32 = 0
    var segment_len: I32 = 1
    var segment_passed: I32 = 0
    var turns: I32 = 0

    while step < total_steps do
      if (y >= 1) and (y < dimy.i32()) and (x >= 0) and (x < dimx.i32()) then
        let rgb = ((step * 7) % 256).u32()
        NotCursesFFI.plane_set_fg_rgb8(std, rgb, 255 - rgb, (rgb * 3) % 256)
        NotCursesFFI.plane_set_bg_rgb(std, 0)
        let egc: String val = "▄"
        NotCursesFFI.plane_putegc_yx(std, y, x, egc.cpointer(), Pointer[USize])
      end

      x = x + dx
      y = y + dy
      segment_passed = segment_passed + 1
      if segment_passed >= segment_len then
        segment_passed = 0
        // Turn counterclockwise
        let tmp = dx
        dx = dy
        dy = -tmp
        turns = turns + 1
        if (turns % 2) == 0 then
          segment_len = segment_len + 1
        end
      end

      let progress = step.f64() / total_steps.f64()
      NotCursesFFI.progbar_set_progress(left, progress)
      NotCursesFFI.progbar_set_progress(right, progress)

      if (step % 4) == 0 then
        let ret = _DemoUtil.render(nc)
        if ret != 0 then return ret end
      end
      step = step + 1
    end
    NotCursesFFI.progbar_set_progress(left, F64(1))
    NotCursesFFI.progbar_set_progress(right, F64(1))
    _DemoUtil.render(nc)
