use "../../notcurses"
use "random"
use "time"

class iso ReelDemo is TimerNotify
  let _main: Main tag
  let _nc: Pointer[NcNotcurses] tag
  let _delay_ns: U64
  var _nr: Pointer[NcReel] tag = Pointer[NcReel]
  var _lplane: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _id: U32 = 0
  var _deadline_ns: U64 = 0
  var _aborted: Bool = false
  var _ret: I32 = 0
  var _done: Bool = false

  new iso create(main: Main tag, nc: Pointer[NcNotcurses] tag, delay_ns: U64) =>
    _main = main
    _nc = nc
    _delay_ns = delay_ns

    NotCursesFFI.plane_greyscale(NotCursesFFI.stdplane(nc))
    (let std, let dimy, let dimx) = NotCursesFFI.stddim_yx(nc)

    // Create reel plane
    var nopts = Ncplaneoptions
    nopts.y = 4
    nopts.x = 8
    nopts.rows = dimy - 12
    nopts.cols = dimx - 16
    let n = NotCursesFFI.plane_create(std,
      NullablePointer[Ncplaneoptions](consume nopts))
    if n.is_null() then
      _ret = -1
      _done = true
      return
    end

    // Reel options
    var popts = Ncreeloptions
    popts.flags = NcReelOption.infinitescroll() or NcReelOption.circular()
    popts.focusedchan = NcChannels.set_fg_rgb8(
      NcChannels.set_bg_rgb8(popts.focusedchan, 97, 214, 214), 58, 150, 221)
    popts.tabletchan = NcChannels.set_fg_rgb8(popts.tabletchan, 19, 161, 14)
    popts.borderchan = NcChannels.set_fg_rgb8(
      NcChannels.set_bg_rgb8(popts.borderchan, 0, 0, 0), 136, 23, 152)

    // Transparent base
    var bgchan: U64 = 0
    bgchan = NcChannels.set_fg_alpha(bgchan, NcAlpha.transparent())
    bgchan = NcChannels.set_bg_alpha(bgchan, NcAlpha.transparent())
    NotCursesFFI.plane_set_base(n, "".cpointer(), 0, bgchan)

    _nr = NotCursesFFI.reel_create(n,
      NullablePointer[Ncreeloptions](consume popts))
    if _nr.is_null() then
      NotCursesFFI.plane_destroy(n)
      _ret = -1
      _done = true
      return
    end

    // Legend plane
    var lopts = Ncplaneoptions
    lopts.rows = 4
    lopts.cols = dimx - 2
    _lplane = NotCursesFFI.plane_create(std,
      NullablePointer[Ncplaneoptions](consume lopts))
    if _lplane.is_null() then
      NotCursesFFI.reel_destroy(_nr)
      _ret = -1
      _done = true
      return
    end
    NotCursesFFI.plane_on_styles(_lplane, NcStyle.bold() or NcStyle.italic())
    NotCursesFFI.plane_set_fg_rgb8(_lplane, 58, 150, 221)
    var lchan: U64 = 0
    lchan = NcChannels.set_fg_alpha(lchan, NcAlpha.transparent())
    lchan = NcChannels.set_bg_alpha(lchan, NcAlpha.transparent())
    NotCursesFFI.plane_set_base(_lplane, "".cpointer(), 0, lchan)
    NotCursesFFI.plane_set_bg_default(_lplane)
    NcPlaneFFI.putstr_yx(_lplane, 1, 2, "a, b, c create tablets, DEL deletes.")
    NotCursesFFI.plane_off_styles(_lplane, NcStyle.bold() or NcStyle.italic())

    // Add initial tablets
    var tablet_count: U32 = 0
    let initial_count = dimy / 8
    while tablet_count < initial_count do
      _id = _id + 1
      let t = NotCursesFFI.reel_add(_nr, Pointer[NcTablet], Pointer[NcTablet],
        @{(t: Pointer[NcTablet] tag, drawfromtop: Bool): I32 =>
          var rng = Rand(Time.nanos())
          let p = NotCursesFFI.tablet_plane(t)
          (let my, _) = NotCursesFFI.plane_dim_yx(p)
          let lines = my.min(5)
          var yy: U32 = 0
          while yy < lines do
            let rgb: U32 = (rng.next().u32() and 0xFFFFFF)
            NotCursesFFI.plane_set_fg_rgb8(p,
              (rgb >> 16) and 0xFF, (rgb >> 8) and 0xFF, rgb and 0xFF)
            var xx: U32 = 0
            (_, let mx) = NotCursesFFI.plane_dim_yx(p)
            while xx < mx do
              let hex = "0123456789abcdef"
              let ch = try hex(yy.usize() % hex.size())? else '0' end
              var cell = Nccell
              let cell' = consume ref cell
              NcCellHelper.load_char(cell', ch.u32())
              cell'.channels = NotCursesFFI.plane_channels(p)
              cell'.stylemask = NotCursesFFI.plane_styles(p)
              NotCursesFFI.plane_putc_yx(p, yy.i32(), xx.i32(),
                NullablePointer[Nccell](cell'))
              xx = xx + 1
            end
            yy = yy + 1
          end
          lines.i32()
        },
        Pointer[None])
      if t.is_null() then break end
      tablet_count = tablet_count + 1
    end

    _deadline_ns = Time.nanos() + (delay_ns * 5)

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _done then return false end
    if _aborted or (Time.nanos() >= _deadline_ns) then return false end

    // Update legend
    NotCursesFFI.plane_set_styles(_lplane, NcStyle.none())
    NotCursesFFI.plane_set_fg_rgb8(_lplane, 197, 15, 31)
    let cnt = NotCursesFFI.reel_tabletcount(_nr)
    NotCursesFFI.plane_on_styles(_lplane, NcStyle.bold())
    let count_str: String val = cnt.string() + " tablet"
      + if cnt == 1 then "" else "s" end
    NcPlaneFFI.putstr_yx(_lplane, 2, 2, count_str)
    NotCursesFFI.plane_off_styles(_lplane, NcStyle.bold())

    NotCursesFFI.reel_redraw(_nr)
    _ret = _DemoUtil.render(_nc)
    if _ret != 0 then return false end

    // Poll for input (non-blocking)
    var ni = Ncinput
    let rw = NotCursesFFI.get_nblock(_nc,
      NullablePointer[Ncinput](consume ni))
    match rw
    | 113 => _aborted = true; return false  // 'q'
    | 107 => NotCursesFFI.reel_prev(_nr)  // 'k'
    | 106 => NotCursesFFI.reel_next(_nr)  // 'j'
    | 97 | 98 | 99 =>              // 'a', 'b', 'c'
      _id = _id + 1
      NotCursesFFI.reel_add(_nr, Pointer[NcTablet], Pointer[NcTablet],
        @{(t: Pointer[NcTablet] tag, drawfromtop: Bool): I32 =>
          var rng = Rand(Time.nanos())
          let p = NotCursesFFI.tablet_plane(t)
          (let my, _) = NotCursesFFI.plane_dim_yx(p)
          let lines = my.min(5)
          var yy: U32 = 0
          while yy < lines do
            let rgb: U32 = (rng.next().u32() and 0xFFFFFF)
            NotCursesFFI.plane_set_fg_rgb8(p,
              (rgb >> 16) and 0xFF, (rgb >> 8) and 0xFF, rgb and 0xFF)
            var xx: U32 = 0
            (_, let mx) = NotCursesFFI.plane_dim_yx(p)
            while xx < mx do
              let hex = "0123456789abcdef"
              let ch = try hex(yy.usize() % hex.size())? else '0' end
              var cell = Nccell
              let cell' = consume ref cell
              NcCellHelper.load_char(cell', ch.u32())
              cell'.channels = NotCursesFFI.plane_channels(p)
              cell'.stylemask = NotCursesFFI.plane_styles(p)
              NotCursesFFI.plane_putc_yx(p, yy.i32(), xx.i32(),
                NullablePointer[Nccell](cell'))
              xx = xx + 1
            end
            yy = yy + 1
          end
          lines.i32()
        },
        Pointer[None])
    end
    true

  fun ref cancel(timer: Timer) =>
    if not _nr.is_null() then
      NotCursesFFI.reel_destroy(_nr)
    end
    if not _lplane.is_null() then
      NotCursesFFI.plane_destroy(_lplane)
    end
    if _aborted then _ret = 1 end
    _main.demo_finished(_ret)
