use "../../notcurses"
use "time"

class iso UniblockDemo is TimerNotify
  let _main: Main tag
  let _nc: Pointer[NcNotcurses] tag
  var _n: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _header: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _sindex: USize = 0
  var _ret: I32 = 0
  var _done: Bool = false

  let _blocks: Array[(String val, U32)] val = [
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

  new iso create(main: Main tag, nc: Pointer[NcNotcurses] tag, delay_ns: U64) =>
    _main = main
    _nc = nc
    if not NotCursesFFI.canutf8(nc) then
      _done = true
      return
    end
    let chunksize: U32 = 32
    (let n, let maxy, let maxx) = NotCursesFFI.stddim_yx(nc)
    _n = n

    NotCursesFFI.plane_greyscale(NotCursesFFI.stdplane(nc))

    var hopts = Ncplaneoptions
    hopts.y = 2
    hopts.x = NcAlign.center()
    hopts.rows = 2
    hopts.cols = (chunksize * 2) - 2
    hopts.flags = NcPlaneOption.horaligned()
    _header = NotCursesFFI.plane_create(n,
      NullablePointer[Ncplaneoptions](consume hopts))
    if _header.is_null() then
      _ret = -1
      _done = true
      return
    end
    var hchan: U64 = 0
    hchan = NcChannels.set_fg_alpha(hchan, NcAlpha.blend())
    hchan = NcChannels.set_fg_rgb(hchan, 0x004000)
    hchan = NcChannels.set_bg_rgb(hchan, 0)
    NotCursesFFI.plane_set_base(_header, "".cpointer(), 0, hchan)

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _done then return false end
    if _sindex >= _blocks.size() then return false end

    let blocksize: U32 = 512
    let chunksize: U32 = 32

    try
      (let description, let blockstart) = _blocks(_sindex)?
      NotCursesFFI.plane_set_bg_rgb8(_n, 0, 0, 0)
      NotCursesFFI.plane_set_bg_rgb(_header, 0)
      NotCursesFFI.plane_set_fg_rgb(_header, 0xbde8f6)
      let label: String val = "Unicode block at 0x" + blockstart.string()
      NcPlaneFFI.putstr_aligned(_header, 1, NcAlign.center(), label)

      // Create block display plane
      var bopts = Ncplaneoptions
      bopts.rows = (blocksize / chunksize) + 2
      bopts.cols = (chunksize * 2) + 2
      bopts.y = 4
      bopts.x = NcAlign.center()
      bopts.flags = NcPlaneOption.horaligned()
      let nn = NotCursesFFI.plane_create(_n,
        NullablePointer[Ncplaneoptions](consume bopts))
      if nn.is_null() then
        _ret = -1
        return false
      end

      _draw_block(nn, blockstart, blocksize, chunksize)

      NotCursesFFI.plane_set_fg_rgb8(_n, 0x40, 0xc0, 0x40)
      NcPlaneFFI.putstr_aligned(_n,
        (6 + (blocksize / chunksize)).i32(), NcAlign.center(), description)

      _ret = _DemoUtil.render(_nc)
      NotCursesFFI.plane_destroy(nn)
      if _ret != 0 then return false end
    end
    _sindex = _sindex + 1
    _sindex < _blocks.size()

  fun ref cancel(timer: Timer) =>
    if not _header.is_null() then
      NotCursesFFI.plane_destroy(_header)
    end
    _main.demo_finished(_ret)

  fun _draw_block(nn: Pointer[NcPlaneT] tag, blockstart: U32,
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
