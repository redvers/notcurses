use "../../notcurses"
use "time"

class iso AnimateDemo is TimerNotify
  let _main: Main tag
  let _nc: Pointer[NcNotcurses] tag
  var _std: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _left: Pointer[NcProgbar] tag = Pointer[NcProgbar]
  var _right: Pointer[NcProgbar] tag = Pointer[NcProgbar]
  var _total_steps: U32 = 0
  var _step: U32 = 0
  var _x: I32 = 0
  var _y: I32 = 0
  var _dx: I32 = 1
  var _dy: I32 = 0
  var _segment_len: I32 = 1
  var _segment_passed: I32 = 0
  var _turns: I32 = 0
  var _ret: I32 = 0
  var _done: Bool = false

  new iso create(main: Main tag, nc: Pointer[NcNotcurses] tag, delay_ns: U64) =>
    _main = main
    _nc = nc
    if not NotCursesFFI.canutf8(nc) then
      _done = true
      return
    end
    (let n, let dimy, let dimx) = NotCursesFFI.stddim_yx(nc)
    _std = n
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
      _ret = -1
      _done = true
      return
    end
    NotCursesFFI.plane_set_fg_rgb(n, 0xf0f0a0)
    NotCursesFFI.plane_set_bg_rgb(n, 0)

    var width: U32 = 40
    if width > (dimx - 8) then
      width = dimx - 8
      if width == 0 then
        _ret = -1
        _done = true
        return
      end
    end
    var height: U32 = 40
    if height >= (dimy - 4) then
      height = dimy - 5
      if height == 0 then
        _ret = -1
        _done = true
        return
      end
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
    if column.is_null() then
      _ret = -1
      _done = true
      return
    end

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
      _ret = -1
      _done = true
      return
    end
    NotCursesFFI.plane_set_base(leftp, " ".cpointer(), 0,
      NcChannels.initializer(0xdd, 0xdd, 0xdd, 0x1b, 0x1b, 0x1b))

    var lpopts = Ncprogbaroptions
    lpopts.brchannel = NcChannel.set_rgb8(0, 0, 0, 0)
    lpopts.blchannel = NcChannel.set_rgb8(0, 0, 0xff, 0)
    lpopts.urchannel = NcChannel.set_rgb8(0, 0, 0, 0xff)
    lpopts.ulchannel = NcChannel.set_rgb8(0, 0, 0xff, 0xff)
    _left = NotCursesFFI.progbar_create(leftp,
      NullablePointer[Ncprogbaroptions](consume lpopts))
    if _left.is_null() then
      NotCursesFFI.plane_destroy(column)
      _ret = -1
      _done = true
      return
    end

    // Right pbar plane
    var ropts = Ncplaneoptions
    ropts.x = colx.i32() + (colposx / 4)
    ropts.rows = coly
    ropts.cols = (dimx - colx) / 4
    let rightp = NotCursesFFI.plane_create(column,
      NullablePointer[Ncplaneoptions](consume ropts))
    if rightp.is_null() then
      NotCursesFFI.progbar_destroy(_left)
      NotCursesFFI.plane_destroy(column)
      _ret = -1
      _done = true
      return
    end
    NotCursesFFI.plane_set_base(rightp, " ".cpointer(), 0,
      NcChannels.initializer(0xdd, 0xdd, 0xdd, 0x1b, 0x1b, 0x1b))

    var rpopts = Ncprogbaroptions
    rpopts.brchannel = NcChannel.set_rgb8(0, 0, 0, 0)
    rpopts.blchannel = NcChannel.set_rgb8(0, 0, 0xff, 0)
    rpopts.urchannel = NcChannel.set_rgb8(0, 0, 0, 0xff)
    rpopts.ulchannel = NcChannel.set_rgb8(0, 0, 0xff, 0xff)
    rpopts.flags = NcProgbarOption.retrograde()
    _right = NotCursesFFI.progbar_create(rightp,
      NullablePointer[Ncprogbaroptions](consume rpopts))
    if _right.is_null() then
      NotCursesFFI.progbar_destroy(_left)
      NotCursesFFI.plane_destroy(column)
      _ret = -1
      _done = true
      return
    end
    NotCursesFFI.plane_destroy(column)

    // Init spiral state
    _total_steps = dimy * dimx
    _x = (dimx / 2).i32()
    _y = (dimy / 2).i32()

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _done then return false end
    if _step >= _total_steps then return false end

    // Batch 16 steps per tick, render every 4th step
    var batch: U32 = 0
    while (batch < 16) and (_step < _total_steps) do
      (let dimy, let dimx) = NotCursesFFI.plane_dim_yx(_std)
      if (_y >= 1) and (_y < dimy.i32()) and (_x >= 0) and (_x < dimx.i32()) then
        let rgb = ((_step * 7) % 256).u32()
        NotCursesFFI.plane_set_fg_rgb8(_std, rgb, 255 - rgb, (rgb * 3) % 256)
        NotCursesFFI.plane_set_bg_rgb(_std, 0)
        let egc: String val = "▄"
        NotCursesFFI.plane_putegc_yx(_std, _y, _x, egc.cpointer(), Pointer[USize])
      end

      _x = _x + _dx
      _y = _y + _dy
      _segment_passed = _segment_passed + 1
      if _segment_passed >= _segment_len then
        _segment_passed = 0
        let tmp = _dx
        _dx = _dy
        _dy = -tmp
        _turns = _turns + 1
        if (_turns % 2) == 0 then
          _segment_len = _segment_len + 1
        end
      end

      let progress = _step.f64() / _total_steps.f64()
      NotCursesFFI.progbar_set_progress(_left, progress)
      NotCursesFFI.progbar_set_progress(_right, progress)

      if (_step % 4) == 0 then
        _ret = _DemoUtil.render(_nc)
        if _ret != 0 then return false end
      end
      _step = _step + 1
      batch = batch + 1
    end

    if _step >= _total_steps then
      NotCursesFFI.progbar_set_progress(_left, F64(1))
      NotCursesFFI.progbar_set_progress(_right, F64(1))
      _ret = _DemoUtil.render(_nc)
      false
    else
      true
    end

  fun ref cancel(timer: Timer) =>
    if not _left.is_null() then
      NotCursesFFI.progbar_destroy(_left)
    end
    if not _right.is_null() then
      NotCursesFFI.progbar_destroy(_right)
    end
    _main.demo_finished(_ret)
