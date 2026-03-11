use "../notcurses"

class WhiteoutDemo is DemoRunner
  let _delay_ns: U64

  new create(delay_ns: U64) =>
    _delay_ns = delay_ns

  fun ref run(nc: Pointer[NcNotcurses]): I32 =>
    if not NotCursesFFI.canutf8(nc) then return 0 end
    let strs: Array[String val] val = [
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

    let steps: Array[U32] val = [0; 0x10040; 0x20110; 0x120; 0x12020]
    let starts: Array[U32] val = [0; 0x10101; 0x004000; 0x000040; 0x400040]

    let n = NotCursesFFI.stdplane(nc)
    let initial_scroll = NotCursesFFI.plane_scrolling_p(n)
    NotCursesFFI.plane_set_scrolling(n, 1)
    NotCursesFFI.plane_erase(n)

    var screen_idx: USize = 0
    while screen_idx < steps.size() do
      try
        let start = starts(screen_idx)?
        let step = steps(screen_idx)?
        (let maxy, let maxx) = NotCursesFFI.plane_dim_yx(n)
        var rgb: U32 = start

        NotCursesFFI.plane_cursor_move_yx(n, 1, 0)
        NotCursesFFI.plane_set_bg_rgb8(n, 20, 20, 20)

        // Fill screen with text strings
        var done = false
        while not done do
          let s = try strs((@rand().usize()) % strs.size())? else "" end
          NotCursesFFI.plane_set_fg_rgb8(n,
            NcChannel.r(rgb), NcChannel.g(rgb), NcChannel.b(rgb))
          NcPlaneFFI.putstr(n, s)
          rgb = rgb + step
          (let cy, let cx) = NotCursesFFI.plane_cursor_yx(n)
          if (cy >= (maxy - 1)) or ((cy >= (maxy - 2)) and (cx >= (maxx - 2))) then
            done = true
          end
        end

        // Message overlay
        var mopts = Ncplaneoptions
        mopts.y = 2
        mopts.x = 4
        mopts.rows = 7
        mopts.cols = 57
        let mess = NotCursesFFI.plane_create(n,
          NullablePointer[Ncplaneoptions](consume mopts))
        if not mess.is_null() then
          var mchan: U64 = 0
          mchan = NcChannels.set_fg_alpha(mchan, NcAlpha.transparent())
          mchan = NcChannels.set_bg_alpha(mchan, NcAlpha.transparent())
          NotCursesFFI.plane_set_base(mess, "".cpointer(), 0, mchan)
          NotCursesFFI.plane_set_fg_rgb8(mess, 224, 128, 224)
          NcPlaneFFI.putstr_yx(mess, 3, 1,
            " unicode, resize awareness, 24b truecolor ")
          NotCursesFFI.plane_set_fg_rgb8(mess, 255, 255, 255)
        end

        let ret = _DemoUtil.render(nc)
        if ret != 0 then
          if not mess.is_null() then NotCursesFFI.plane_destroy(mess) end
          NotCursesFFI.plane_set_scrolling(n, if initial_scroll then U32(1) else 0 end)
          return ret
        end

        // Worms phase: lighten random cells
        let wormcount = ((maxy * maxx) / 800).max(1)
        let worm_deadline = _DemoUtil.clock_ns() + _delay_ns
        var wx = Array[I32](wormcount.usize())
        var wy = Array[I32](wormcount.usize())
        var wpx = Array[I32](wormcount.usize())
        var wpy = Array[I32](wormcount.usize())
        var wi: U32 = 0
        while wi < wormcount do
          wx.push((@rand() % maxx.i32()))
          wy.push((@rand() % (maxy - 1).i32()) + 1)
          wpx.push(0)
          wpy.push(0)
          wi = wi + 1
        end

        while _DemoUtil.clock_ns() < worm_deadline do
          // Move and lighten each worm
          var ws: USize = 0
          while ws < wormcount.usize() do
            try
              let wxx = wx(ws)?
              let wyy = wy(ws)?
              // Lighten the cell under the worm
              var c = Nccell
              let c' = consume ref c
              NotCursesFFI.plane_at_yx_cell(n, wyy, wxx, NullablePointer[Nccell](c'))
              let old = NcCellHelper.fg_rgb8(c')
              NcCellHelper.set_fg_rgb8(c',
                (old._1 + (@rand().u32() % 32)).min(255),
                (old._2 + (@rand().u32() % 32)).min(255),
                (old._3 + (@rand().u32() % 32)).min(255))
              NotCursesFFI.plane_putc_yx(n, wyy, wxx, NullablePointer[Nccell](c'))
              NotCursesFFI.cell_release(n, NullablePointer[Nccell](c'))
              // Move worm
              let oldx = wxx
              let oldy = wyy
              var nx = wxx
              var ny = wyy
              while ((nx == oldx) and (ny == oldy)) or
                ((nx == wpx(ws)?) and (ny == wpy(ws)?))
              do
                nx = oldx
                ny = oldy
                match @rand() % 4
                | 0 => ny = ny - 1
                | 1 => nx = nx + 1
                | 2 => ny = ny + 1
                | 3 => nx = nx - 1
                end
                if ny <= 1 then ny = maxy.i32() - 1 end
                if ny >= maxy.i32() then ny = 1 end  // skip row 0
                if nx <= 0 then nx = maxx.i32() - 1 end
                if nx >= maxx.i32() then nx = 0 end
              end
              wpx(ws)? = oldx
              wpy(ws)? = oldy
              wx(ws)? = nx
              wy(ws)? = ny
            end
            ws = ws + 1
          end
          let ret' = _DemoUtil.render(nc)
          if ret' != 0 then
            if not mess.is_null() then NotCursesFFI.plane_destroy(mess) end
            NotCursesFFI.plane_set_scrolling(n, if initial_scroll then U32(1) else 0 end)
            return ret'
          end
          _DemoUtil.sleep_ns(_delay_ns / 10000)
        end

        if not mess.is_null() then NotCursesFFI.plane_destroy(mess) end
      end
      screen_idx = screen_idx + 1
    end
    NotCursesFFI.plane_set_scrolling(n, if initial_scroll then U32(1) else 0 end)
    0
