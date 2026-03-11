use "../notcurses"

class ReelDemo is DemoRunner
  let _delay_ns: U64

  new create(delay_ns: U64) =>
    _delay_ns = delay_ns

  fun ref run(nc: Pointer[NcNotcurses]): I32 =>
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
    if n.is_null() then return -1 end

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

    let nr = NotCursesFFI.reel_create(n,
      NullablePointer[Ncreeloptions](consume popts))
    if nr.is_null() then
      NotCursesFFI.plane_destroy(n)
      return -1
    end

    // Legend plane
    var lopts = Ncplaneoptions
    lopts.rows = 4
    lopts.cols = dimx - 2
    let lplane = NotCursesFFI.plane_create(std,
      NullablePointer[Ncplaneoptions](consume lopts))
    if lplane.is_null() then
      NotCursesFFI.reel_destroy(nr)
      return -1
    end
    NotCursesFFI.plane_on_styles(lplane, NcStyle.bold() or NcStyle.italic())
    NotCursesFFI.plane_set_fg_rgb8(lplane, 58, 150, 221)
    var lchan: U64 = 0
    lchan = NcChannels.set_fg_alpha(lchan, NcAlpha.transparent())
    lchan = NcChannels.set_bg_alpha(lchan, NcAlpha.transparent())
    NotCursesFFI.plane_set_base(lplane, "".cpointer(), 0, lchan)
    NotCursesFFI.plane_set_bg_default(lplane)
    NcPlaneFFI.putstr_yx(lplane, 1, 2, "a, b, c create tablets, DEL deletes.")
    NotCursesFFI.plane_off_styles(lplane, NcStyle.bold() or NcStyle.italic())

    // Add initial tablets
    var id: U32 = 0
    var tablet_count: U32 = 0
    let initial_count = dimy / 8
    while tablet_count < initial_count do
      id = id + 1
      let t = NotCursesFFI.reel_add(nr, Pointer[NcTablet], Pointer[NcTablet],
        @{(t: Pointer[NcTablet], drawfromtop: Bool): I32 =>
          let p = NotCursesFFI.tablet_plane(t)
          (let my, _) = NotCursesFFI.plane_dim_yx(p)
          let lines = my.min(5)
          var yy: U32 = 0
          while yy < lines do
            let rgb: U32 = (@rand().u32() and 0xFFFFFF)
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

    // Main loop: timed, with input handling
    let deadline_ns = _DemoUtil.clock_ns() + (_delay_ns * 5)
    var aborted = false
    while (not aborted) and (_DemoUtil.clock_ns() < deadline_ns) do
      // Update legend
      NotCursesFFI.plane_set_styles(lplane, NcStyle.none())
      NotCursesFFI.plane_set_fg_rgb8(lplane, 197, 15, 31)
      let count = NotCursesFFI.reel_tabletcount(nr)
      NotCursesFFI.plane_on_styles(lplane, NcStyle.bold())
      let count_str: String val = count.string() + " tablet"
        + if count == 1 then "" else "s" end
      NcPlaneFFI.putstr_yx(lplane, 2, 2, count_str)
      NotCursesFFI.plane_off_styles(lplane, NcStyle.bold())

      NotCursesFFI.reel_redraw(nr)
      let ret = _DemoUtil.render(nc)
      if ret != 0 then
        NotCursesFFI.reel_destroy(nr)
        NotCursesFFI.plane_destroy(lplane)
        return ret
      end

      // Poll for input (non-blocking)
      var ni = Ncinput
      let rw = NotCursesFFI.get_nblock(nc,
        NullablePointer[Ncinput](consume ni))
      match rw
      | 113 => aborted = true        // 'q'
      | 107 => NotCursesFFI.reel_prev(nr)  // 'k'
      | 106 => NotCursesFFI.reel_next(nr)  // 'j'
      | 97 | 98 | 99 =>              // 'a', 'b', 'c'
        id = id + 1
        NotCursesFFI.reel_add(nr, Pointer[NcTablet], Pointer[NcTablet],
          @{(t: Pointer[NcTablet], drawfromtop: Bool): I32 =>
            let p = NotCursesFFI.tablet_plane(t)
            (let my, _) = NotCursesFFI.plane_dim_yx(p)
            let lines = my.min(5)
            var yy: U32 = 0
            while yy < lines do
              let rgb: U32 = (@rand().u32() and 0xFFFFFF)
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
      _DemoUtil.sleep_ns(50_000_000) // 50ms between polls
    end

    NotCursesFFI.reel_destroy(nr)
    NotCursesFFI.plane_destroy(lplane)
    if aborted then I32(1) else I32(0) end
