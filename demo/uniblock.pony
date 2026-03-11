use "../notcurses"

class UniblockDemo is DemoRunner
  let _delay_ns: U64

  new create(delay_ns: U64) =>
    _delay_ns = delay_ns

  fun ref run(nc: Pointer[NcNotcurses]): I32 =>
    if not NotCursesFFI.canutf8(nc) then return 0 end
    let blocksize: U32 = 512
    let chunksize: U32 = 32
    (let n, let maxy, let maxx) = NotCursesFFI.stddim_yx(nc)

    NotCursesFFI.plane_greyscale(NotCursesFFI.stdplane(nc))

    let blocks: Array[(String val, U32)] val = [
      ("Basic Latin, Latin 1 Supplement, Latin Extended", 0)
      ("IPA Extensions, Spacing Modifiers, Greek and Coptic", 0x200)
      ("Cyrillic, Cyrillic Supplement, Armenian, Hebrew", 0x400)
      ("Arabic, Syriac, Arabic Supplement", 0x600)
      ("General Punctuation, Letterlike Symbols, Arrows", 0x2000)
      ("Mathematical Operators, Miscellaneous Technical", 0x2200)
      ("Control Pictures, Box Drawing, Block Elements", 0x2400)
      ("Miscellaneous Symbols, Dingbats", 0x2600)
      ("Braille Patterns, Supplemental Arrows", 0x2800)
      ("Mahjong Tiles, Domino Tiles, Playing Cards", 0x1f000)
      ("Enclosed Ideographic Supplement, Misc Symbols", 0x1f200)
      ("Emoticons, Ornamental Dingbats, Transport", 0x1f600)
      ("Chess Symbols, Symbols Extended-A", 0x1fa00)
    ]

    // Create header plane
    var hopts = Ncplaneoptions
    hopts.y = 2
    hopts.x = NcAlign.center()
    hopts.rows = 2
    hopts.cols = (chunksize * 2) - 2
    hopts.flags = NcPlaneOption.horaligned()
    let header = NotCursesFFI.plane_create(n,
      NullablePointer[Ncplaneoptions](consume hopts))
    if header.is_null() then return -1 end
    var hchan: U64 = 0
    hchan = NcChannels.set_fg_alpha(hchan, NcAlpha.blend())
    hchan = NcChannels.set_fg_rgb(hchan, 0x004000)
    hchan = NcChannels.set_bg_rgb(hchan, 0)
    NotCursesFFI.plane_set_base(header, "".cpointer(), 0, hchan)

    let subdelay_ns = _delay_ns / 5

    var sindex: USize = 0
    while sindex < blocks.size() do
      try
        (let description, let blockstart) = blocks(sindex)?
        NotCursesFFI.plane_set_bg_rgb8(n, 0, 0, 0)
        NotCursesFFI.plane_set_bg_rgb(header, 0)
        NotCursesFFI.plane_set_fg_rgb(header, 0xbde8f6)
        let label: String val = "Unicode block at 0x" + blockstart.string()
        NcPlaneFFI.putstr_aligned(header, 1, NcAlign.center(), label)

        // Create block display plane
        var bopts = Ncplaneoptions
        bopts.rows = (blocksize / chunksize) + 2
        bopts.cols = (chunksize * 2) + 2
        bopts.y = 4
        bopts.x = NcAlign.center()
        bopts.flags = NcPlaneOption.horaligned()
        let nn = NotCursesFFI.plane_create(n,
          NullablePointer[Ncplaneoptions](consume bopts))
        if nn.is_null() then
          NotCursesFFI.plane_destroy(header)
          return -1
        end

        _draw_block(nn, blockstart, blocksize, chunksize)

        NotCursesFFI.plane_set_fg_rgb8(n, 0x40, 0xc0, 0x40)
        NcPlaneFFI.putstr_aligned(n,
          (6 + (blocksize / chunksize)).i32(), NcAlign.center(), description)

        let ret = _DemoUtil.render(nc)
        _DemoUtil.sleep_ns(subdelay_ns)
        NotCursesFFI.plane_destroy(nn)
        if ret != 0 then
          NotCursesFFI.plane_destroy(header)
          return ret
        end
      end
      sindex = sindex + 1
    end
    NotCursesFFI.plane_destroy(header)
    0

  fun _draw_block(nn: Pointer[NcPlaneT], blockstart: U32,
    blocksize: U32, chunksize: U32)
  =>
    (let my, let mx) = NotCursesFFI.plane_dim_yx(nn)

    // Draw rounded box border
    NotCursesFFI.plane_home(nn)
    NcPlaneFFI.rounded_box(nn, 0, 0, my - 1, mx - 1,
      NcBoxGrad.top() or NcBoxGrad.bottom() or NcBoxGrad.left() or NcBoxGrad.right())

    // Fill with unicode characters
    var chunk: U32 = 0
    while chunk < (blocksize / chunksize) do
      NotCursesFFI.plane_set_bg_rgb8(nn, 8 * chunk, 8 * chunk, 8 * chunk)
      var z: U32 = 0
      while z < chunksize do
        let w = blockstart + (chunk * chunksize) + z
        // Skip problematic characters
        if (w != 0x070f) and (w != 0x08e2) and (w != 0x06dd) then
          NotCursesFFI.plane_set_fg_rgb8(nn,
            (0xad + (z * 2)) and 0xFF,
            0xff,
            if (0x2f - (z * 2)) > 0x2f then U32(0) else 0x2f - (z * 2) end)
          // Encode codepoint as UTF-8 and write it
          let utf8 = _encode_utf8(w)
          NcPlaneFFI.putstr_yx(nn, (chunk + 1).i32(), ((z * 2) + 1).i32(), utf8)
        end
        z = z + 1
      end
      chunk = chunk + 1
    end

  fun _encode_utf8(cp: U32): String val =>
    recover val
      let s = String(4)
      if cp < 0x80 then
        s.push(cp.u8())
      elseif cp < 0x800 then
        s.push((0xC0 or (cp >> 6)).u8())
        s.push((0x80 or (cp and 0x3F)).u8())
      elseif cp < 0x10000 then
        s.push((0xE0 or (cp >> 12)).u8())
        s.push((0x80 or ((cp >> 6) and 0x3F)).u8())
        s.push((0x80 or (cp and 0x3F)).u8())
      else
        s.push((0xF0 or (cp >> 18)).u8())
        s.push((0x80 or ((cp >> 12) and 0x3F)).u8())
        s.push((0x80 or ((cp >> 6) and 0x3F)).u8())
        s.push((0x80 or (cp and 0x3F)).u8())
      end
      s
    end
