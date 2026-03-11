use "../../notcurses"
use "random"
use "time"

class iso QrcodeDemo is TimerNotify
  let _main: Main tag
  let _nc: Pointer[NcNotcurses] tag
  var _stdn: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _n: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _dimy: U32 = 0
  var _dimx: U32 = 0
  var _data: Array[U8] ref
  var _rand: Rand
  var _i: I32 = 0
  var _ret: I32 = 0
  var _done: Bool = false

  new iso create(main: Main tag, nc: Pointer[NcNotcurses] tag, delay_ns: U64) =>
    _main = main
    _nc = nc
    _rand = Rand(Time.nanos())
    _data = Array[U8].init(0, 128)

    if not NotCursesFFI.canutf8(nc) then
      _done = true
      return
    end

    (let stdn, let dimy, let dimx) = NotCursesFFI.stddim_yx(nc)
    _stdn = stdn
    _dimy = dimy
    _dimx = dimx
    NotCursesFFI.plane_erase(stdn)

    _n = NotCursesFFI.plane_dup(stdn, Pointer[None])
    if _n.is_null() then
      _ret = -1
      _done = true
    end

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _done then return false end
    if _i >= 1024 then return false end

    // Batch 4 QR codes per tick
    var batch: I32 = 0
    while (batch < 4) and (_i < 1024) do
      NotCursesFFI.plane_erase(_n)
      let len = _rand.int[USize](128) + 1

      // Fill with random data
      var done': USize = 0
      while done' < len do
        try _data(done')? = _rand.next().u8() end
        done' = done' + 1
      end

      NotCursesFFI.plane_home(_n)
      NotCursesFFI.plane_home(_n)
      (let qlen, let y, let x) = NotCursesFFI.plane_qrcode(_n, _dimy, _dimx,
        _data.cpointer(), len)
      if qlen > 0 then
        NotCursesFFI.plane_move_yx(_n,
          ((_dimy - y) / 2).i32(),
          ((_dimx - x) / 2).i32())
        NotCursesFFI.plane_home(_n)
        NotCursesFFI.plane_set_fg_rgb8(_n,
          _rand.int[U32](255) + 1,
          _rand.int[U32](255) + 1,
          _rand.int[U32](255) + 1)
        _ret = _DemoUtil.render(_nc)
        if _ret != 0 then return false end
      end
      _i = _i + 1
      batch = batch + 1
    end

    if _i >= 1024 then
      NotCursesFFI.plane_mergedown_simple(_n, _stdn)
      NotCursesFFI.plane_destroy(_n)
      _n = Pointer[NcPlaneT]
      false
    else
      true
    end

  fun ref cancel(timer: Timer) =>
    if not _n.is_null() then
      NotCursesFFI.plane_destroy(_n)
    end
    _main.demo_finished(_ret)
