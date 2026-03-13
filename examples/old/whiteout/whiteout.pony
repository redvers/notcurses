use "../../notcurses"
use "random"
use "time"

class iso WhiteoutDemo is TimerNotify
  let _main: Main tag
  let _nc: Pointer[NcNotcurses] tag
  let _delay_ns: U64
  var _n: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _initial_scroll: Bool = false
  var _rand: Rand
  var _screen_idx: USize = 0
  var _need_fill: Bool = true
  var _worm_deadline: U64 = 0
  var _mess: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _wx: Array[I32] = Array[I32]
  var _wy: Array[I32] = Array[I32]
  var _wpx: Array[I32] = Array[I32]
  var _wpy: Array[I32] = Array[I32]
  var _wormcount: U32 = 0
  var _ret: I32 = 0
  var _done: Bool = false

  let _strs: Array[String val] val = [
    "Война и мир"
    "Бра́тья Карама́зовы"
    "Tonio Kröger"
    "Meg tudom enni az üveget, nem lesztőle bajom"
    "Voin syödä lasia, se ei vahingoita minua"
    "Mohu jíst sklo, neublíží mi"
    "Mogę jeść szkło i mi nie szkodzi"
    "Ja mogu jesti staklo, i to mi ne šteti"
    "Я могу есть стекло, оно мне не вредит"
    "kācaṃ śaknomyattum; nopahinasti mām"
    "ὕαλον ϕαγεῖν δύναμαι· τοῦτο οὔ με βλάπτει"
    "Vitrum edere possum; mihi non nocet"
    "Je peux manger du verre, ça ne me fait pas mal"
    "overall there is a smell of fried onions"
    "Puedo comer vidrio, no me hace daño"
    "Posso comer vidro, não me faz mal"
    "三体"
    "三国演义"
    "紅樓夢"
    "I can eat glass and it doesn't hurt me"
    "Ich kann Glas essen, ohne mir zu schaden"
    "나는 유리를 먹을 수 있어요. 그래도 아프지 않아"
    "我能吞下玻璃而不伤身体"
    "私はガラスを食べられますそれは私を傷つけません"
    "Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn"
    "Ewige Blumenkraft"
    "μῆλον τῆς Ἔριδος"
    "ineluctable modality of the visible"
    "𝐸 = 𝑚𝑐²"
    "F·ds=ΔE"
    "iℏ∂∂tΨ=−ℏ²2m∇2Ψ+VΨ"
  ]

  let _steps: Array[U32] val = [0; 0x10040; 0x20110; 0x120; 0x12020]
  let _starts: Array[U32] val = [0; 0x10101; 0x004000; 0x000040; 0x400040]

  new iso create(main: Main tag, nc: Pointer[NcNotcurses] tag, delay_ns: U64) =>
    _main = main
    _nc = nc
    _delay_ns = delay_ns
    _rand = Rand(Time.nanos())

    if not NotCursesFFI.canutf8(nc) then
      _done = true
      return
    end

    _n = NotCursesFFI.stdplane(nc)
    _initial_scroll = NotCursesFFI.plane_scrolling_p(_n)
    NotCursesFFI.plane_set_scrolling(_n, 1)
    NotCursesFFI.plane_erase(_n)

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _done then return false end
    if _screen_idx >= _steps.size() then return false end

    if _need_fill then
      // Fill screen for current screen_idx
      try
        let start = _starts(_screen_idx)?
        let step = _steps(_screen_idx)?
        (let maxy, let maxx) = NotCursesFFI.plane_dim_yx(_n)
        var rgb: U32 = start

        NotCursesFFI.plane_cursor_move_yx(_n, 1, 0)
        NotCursesFFI.plane_set_bg_rgb8(_n, 20, 20, 20)

        var fill_done = false
        while not fill_done do
          let s = try _strs(_rand.int[USize](_strs.size()))? else "" end
          NotCursesFFI.plane_set_fg_rgb8(_n,
            NcChannel.r(rgb), NcChannel.g(rgb), NcChannel.b(rgb))
          NcPlaneFFI.putstr(_n, s)
          rgb = rgb + step
          (let cy, let cx) = NotCursesFFI.plane_cursor_yx(_n)
          if (cy >= (maxy - 1)) or ((cy >= (maxy - 2)) and (cx >= (maxx - 2))) then
            fill_done = true
          end
        end

        // Message overlay
        var mopts = Ncplaneoptions
        mopts.y = 2
        mopts.x = 4
        mopts.rows = 7
        mopts.cols = 57
        _mess = NotCursesFFI.plane_create(_n,
          NullablePointer[Ncplaneoptions](consume mopts))
        if not _mess.is_null() then
          var mchan: U64 = 0
          mchan = NcChannels.set_fg_alpha(mchan, NcAlpha.transparent())
          mchan = NcChannels.set_bg_alpha(mchan, NcAlpha.transparent())
          NotCursesFFI.plane_set_base(_mess, "".cpointer(), 0, mchan)
          NotCursesFFI.plane_set_fg_rgb8(_mess, 224, 128, 224)
          NcPlaneFFI.putstr_yx(_mess, 3, 1,
            " unicode, resize awareness, 24b truecolor ")
          NotCursesFFI.plane_set_fg_rgb8(_mess, 255, 255, 255)
        end

        _ret = _DemoUtil.render(_nc)
        if _ret != 0 then
          _cleanup_screen()
          return false
        end

        // Setup worms
        _wormcount = ((maxy * maxx) / 800).max(1)
        _worm_deadline = Time.nanos() + _delay_ns
        _wx = Array[I32](_wormcount.usize())
        _wy = Array[I32](_wormcount.usize())
        _wpx = Array[I32](_wormcount.usize())
        _wpy = Array[I32](_wormcount.usize())
        var wi: U32 = 0
        while wi < _wormcount do
          _wx.push(_rand.int[U32](maxx).i32())
          _wy.push(_rand.int[U32](maxy - 1).i32() + 1)
          _wpx.push(0)
          _wpy.push(0)
          wi = wi + 1
        end
        _need_fill = false
      end
      return true
    end

    // Worm phase
    if Time.nanos() >= _worm_deadline then
      _cleanup_screen()
      _screen_idx = _screen_idx + 1
      _need_fill = true
      return _screen_idx < _steps.size()
    end

    (let maxy, let maxx) = NotCursesFFI.plane_dim_yx(_n)
    var ws: USize = 0
    while ws < _wormcount.usize() do
      try
        let wxx = _wx(ws)?
        let wyy = _wy(ws)?
        var c = Nccell
        let c' = consume ref c
        NotCursesFFI.plane_at_yx_cell(_n, wyy, wxx, NullablePointer[Nccell](c'))
        let old = NcCellHelper.fg_rgb8(c')
        NcCellHelper.set_fg_rgb8(c',
          (old._1 + _rand.int[U32](32)).min(255),
          (old._2 + _rand.int[U32](32)).min(255),
          (old._3 + _rand.int[U32](32)).min(255))
        NotCursesFFI.plane_putc_yx(_n, wyy, wxx, NullablePointer[Nccell](c'))
        NotCursesFFI.cell_release(_n, NullablePointer[Nccell](c'))
        // Move worm
        let oldx = wxx
        let oldy = wyy
        var nx = wxx
        var ny = wyy
        while ((nx == oldx) and (ny == oldy)) or
          ((nx == _wpx(ws)?) and (ny == _wpy(ws)?))
        do
          nx = oldx
          ny = oldy
          match _rand.int[U32](4)
          | 0 => ny = ny - 1
          | 1 => nx = nx + 1
          | 2 => ny = ny + 1
          | 3 => nx = nx - 1
          end
          if ny <= 1 then ny = maxy.i32() - 1 end
          if ny >= maxy.i32() then ny = 1 end
          if nx <= 0 then nx = maxx.i32() - 1 end
          if nx >= maxx.i32() then nx = 0 end
        end
        _wpx(ws)? = oldx
        _wpy(ws)? = oldy
        _wx(ws)? = nx
        _wy(ws)? = ny
      end
      ws = ws + 1
    end
    _ret = _DemoUtil.render(_nc)
    if _ret != 0 then
      _cleanup_screen()
      return false
    end
    true

  fun ref cancel(timer: Timer) =>
    NotCursesFFI.plane_set_scrolling(_n, if _initial_scroll then U32(1) else 0 end)
    _main.demo_finished(_ret)

  fun ref _cleanup_screen() =>
    if not _mess.is_null() then
      NotCursesFFI.plane_destroy(_mess)
      _mess = Pointer[NcPlaneT]
    end
