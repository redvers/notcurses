// Pure Pony bit manipulation on U64 channel pairs and U32 single channels.
// Reimplements inline ncchannel/ncchannels functions from notcurses.h.
//
// A channel pair (U64) packs two 32-bit channels:
//   bits 63..32 = foreground channel
//   bits 31..0  = background channel
//
// Each 32-bit channel:
//   bits 31..30 = alpha (2 bits)
//   bit  29     = not-default flag (set when RGB is explicitly set)
//   bit  28     = palette-indexed flag
//   bits 23..16 = red
//   bits 15..8  = green
//   bits  7..0  = blue

primitive NcChannel
  fun r(channel: U32): U32 => (channel >> 16) and 0xFF
  fun g(channel: U32): U32 => (channel >> 8) and 0xFF
  fun b(channel: U32): U32 => channel and 0xFF
  fun rgb8(channel: U32): (U32, U32, U32) => (r(channel), g(channel), b(channel))

  fun set_rgb8(channel: U32, r': U32, g': U32, b': U32): U32 =>
    let c = (channel and 0xFF000000) // preserve alpha + flags
      or ((r' and 0xFF) << 16)
      or ((g' and 0xFF) << 8)
      or (b' and 0xFF)
    c or 0x20000000 // set not-default flag

  fun set_rgb(channel: U32, rgb: U32): U32 =>
    let c = (channel and 0xFF000000) or (rgb and 0x00FFFFFF)
    c or 0x20000000

  fun alpha(channel: U32): U32 => (channel >> 28) and 0x03 // just the 2 alpha bits
  fun set_alpha(channel: U32, a: U32): U32 =>
    (channel and 0x0FFFFFFF) or ((a and 0x03) << 28)

primitive NcChannels
  fun fg(channels: U64): U32 => (channels >> 32).u32()
  fun bg(channels: U64): U32 => (channels and 0xFFFFFFFF).u32()

  fun fg_rgb(channels: U64): U32 => fg(channels) and 0x00FFFFFF
  fun bg_rgb(channels: U64): U32 => bg(channels) and 0x00FFFFFF

  fun fg_r(channels: U64): U32 => NcChannel.r(fg(channels))
  fun fg_g(channels: U64): U32 => NcChannel.g(fg(channels))
  fun fg_b(channels: U64): U32 => NcChannel.b(fg(channels))

  fun bg_r(channels: U64): U32 => NcChannel.r(bg(channels))
  fun bg_g(channels: U64): U32 => NcChannel.g(bg(channels))
  fun bg_b(channels: U64): U32 => NcChannel.b(bg(channels))

  fun fg_rgb8(channels: U64): (U32, U32, U32) => NcChannel.rgb8(fg(channels))
  fun bg_rgb8(channels: U64): (U32, U32, U32) => NcChannel.rgb8(bg(channels))

  fun fg_alpha(channels: U64): U32 => NcChannel.alpha(fg(channels))
  fun bg_alpha(channels: U64): U32 => NcChannel.alpha(bg(channels))

  fun set_fg(channels: U64, fchan: U32): U64 =>
    (channels and 0x00000000_FFFFFFFF) or (fchan.u64() << 32)

  fun set_bg(channels: U64, bchan: U32): U64 =>
    (channels and 0xFFFFFFFF_00000000) or bchan.u64()

  fun set_fg_rgb8(channels: U64, r: U32, g: U32, b: U32): U64 =>
    set_fg(channels, NcChannel.set_rgb8(fg(channels), r, g, b))

  fun set_bg_rgb8(channels: U64, r: U32, g: U32, b: U32): U64 =>
    set_bg(channels, NcChannel.set_rgb8(bg(channels), r, g, b))

  fun set_fg_rgb(channels: U64, rgb: U32): U64 =>
    set_fg(channels, NcChannel.set_rgb(fg(channels), rgb))

  fun set_bg_rgb(channels: U64, rgb: U32): U64 =>
    set_bg(channels, NcChannel.set_rgb(bg(channels), rgb))

  fun set_fg_alpha(channels: U64, alpha: U32): U64 =>
    set_fg(channels, NcChannel.set_alpha(fg(channels), alpha))

  fun set_bg_alpha(channels: U64, alpha: U32): U64 =>
    set_bg(channels, NcChannel.set_alpha(bg(channels), alpha))

  fun initializer(fr: U32, fg': U32, fb: U32,
    br: U32, bg': U32, bb: U32): U64
  =>
    var ch: U64 = 0
    ch = set_fg_rgb8(ch, fr, fg', fb)
    ch = set_bg_rgb8(ch, br, bg', bb)
    ch
