// Pure Pony bit manipulation on U64 channel pairs and U32 single channels.
// Reimplements inline ncchannel/ncchannels functions from notcurses.h.
//
// A channel pair (U64) packs two 32-bit channels:
//   bits 63..32 = foreground channel
//   bits 31..0  = background channel
//
// Each 32-bit channel:
//   bit  30     = not-default flag (set when RGB is explicitly set)
//   bits 29..28 = alpha (2 bits)
//   bit  27     = palette-indexed flag
//   bits 23..16 = red
//   bits 15..8  = green
//   bits  7..0  = blue

primitive NcChannel
  """
  Operations on a single 32-bit color channel (foreground or background).

  A channel encodes RGB color (24 bits) and alpha (2 bits) in a U32. Use `NcChannels` to work with foreground/background pairs (U64).
  """
  fun r(channel: U32): U32 =>
    """Extract the red component (0-255)."""
    (channel >> 16) and 0xFF
  fun g(channel: U32): U32 =>
    """Extract the green component (0-255)."""
    (channel >> 8) and 0xFF
  fun b(channel: U32): U32 =>
    """Extract the blue component (0-255)."""
    channel and 0xFF
  fun rgb8(channel: U32): (U32, U32, U32) =>
    """Extract all RGB components as (red, green, blue)."""
    (r(channel), g(channel), b(channel))

  fun set_rgb8(channel: U32, r': U32, g': U32, b': U32): U32 =>
    """Set RGB from individual components. Returns the modified channel."""
    let c = (channel and 0x30000000) // preserve alpha
      or ((r' and 0xFF) << 16)
      or ((g' and 0xFF) << 8)
      or (b' and 0xFF)
    c or 0x40000000 // set not-default flag

  fun set_rgb(channel: U32, rgb: U32): U32 =>
    """Set RGB from a packed 24-bit value. Returns the modified channel."""
    let c = (channel and 0x30000000) or (rgb and 0x00FFFFFF)
    c or 0x40000000

  fun alpha(channel: U32): U32 =>
    """Extract the alpha value. See `NcAlpha` for constants."""
    channel and 0x30000000
  fun set_alpha(channel: U32, a: U32): U32 =>
    """Set the alpha value. Use `NcAlpha` constants. Returns the modified channel."""
    (channel and 0xCFFFFFFF) or (a and 0x30000000)

primitive NcChannels
  """
  Operations on a 64-bit channel pair (foreground in high 32 bits, background in low 32).

  Widget constructors (selector, multiselector) take U64 channel values for colors. Use this primitive to build them instead of manual bit-packing:

  ```pony
  let channels = NcChannels.initializer(255, 0, 0, 0, 0, 0)  // red on black
  // Or build incrementally:
  var ch: U64 = 0
  ch = NcChannels.set_fg_rgb8(ch, 255, 0, 0)
  ch = NcChannels.set_bg_rgb8(ch, 0, 0, 0)
  ```
  """
  fun fg(channels: U64): U32 =>
    """Extract the foreground channel (high 32 bits)."""
    (channels >> 32).u32()
  fun bg(channels: U64): U32 =>
    """Extract the background channel (low 32 bits)."""
    (channels and 0xFFFFFFFF).u32()

  fun fg_rgb(channels: U64): U32 =>
    """Extract the foreground as a packed 24-bit RGB value."""
    fg(channels) and 0x00FFFFFF
  fun bg_rgb(channels: U64): U32 =>
    """Extract the background as a packed 24-bit RGB value."""
    bg(channels) and 0x00FFFFFF

  fun fg_r(channels: U64): U32 =>
    """Extract the foreground red component (0-255)."""
    NcChannel.r(fg(channels))
  fun fg_g(channels: U64): U32 =>
    """Extract the foreground green component (0-255)."""
    NcChannel.g(fg(channels))
  fun fg_b(channels: U64): U32 =>
    """Extract the foreground blue component (0-255)."""
    NcChannel.b(fg(channels))

  fun bg_r(channels: U64): U32 =>
    """Extract the background red component (0-255)."""
    NcChannel.r(bg(channels))
  fun bg_g(channels: U64): U32 =>
    """Extract the background green component (0-255)."""
    NcChannel.g(bg(channels))
  fun bg_b(channels: U64): U32 =>
    """Extract the background blue component (0-255)."""
    NcChannel.b(bg(channels))

  fun fg_rgb8(channels: U64): (U32, U32, U32) =>
    """Extract foreground RGB as (red, green, blue)."""
    NcChannel.rgb8(fg(channels))
  fun bg_rgb8(channels: U64): (U32, U32, U32) =>
    """Extract background RGB as (red, green, blue)."""
    NcChannel.rgb8(bg(channels))

  fun fg_alpha(channels: U64): U32 =>
    """Extract the foreground alpha value."""
    NcChannel.alpha(fg(channels))
  fun bg_alpha(channels: U64): U32 =>
    """Extract the background alpha value."""
    NcChannel.alpha(bg(channels))

  fun set_fg(channels: U64, fchan: U32): U64 =>
    """Replace the entire foreground channel. Returns modified pair."""
    (channels and 0x00000000_FFFFFFFF) or (fchan.u64() << 32)

  fun set_bg(channels: U64, bchan: U32): U64 =>
    """Replace the entire background channel. Returns modified pair."""
    (channels and 0xFFFFFFFF_00000000) or bchan.u64()

  fun set_fg_rgb8(channels: U64, r: U32, g: U32, b: U32): U64 =>
    """Set foreground RGB. Returns the modified channel pair."""
    set_fg(channels, NcChannel.set_rgb8(fg(channels), r, g, b))

  fun set_bg_rgb8(channels: U64, r: U32, g: U32, b: U32): U64 =>
    """Set background RGB. Returns the modified channel pair."""
    set_bg(channels, NcChannel.set_rgb8(bg(channels), r, g, b))

  fun set_fg_rgb(channels: U64, rgb: U32): U64 =>
    """Set foreground from a packed 24-bit RGB value. Returns modified pair."""
    set_fg(channels, NcChannel.set_rgb(fg(channels), rgb))

  fun set_bg_rgb(channels: U64, rgb: U32): U64 =>
    """Set background from a packed 24-bit RGB value. Returns modified pair."""
    set_bg(channels, NcChannel.set_rgb(bg(channels), rgb))

  fun set_fg_alpha(channels: U64, alpha: U32): U64 =>
    """Set foreground alpha. Use `NcAlpha` constants. Returns modified pair."""
    set_fg(channels, NcChannel.set_alpha(fg(channels), alpha))

  fun set_bg_alpha(channels: U64, alpha: U32): U64 =>
    """Set background alpha. Use `NcAlpha` constants. Returns modified pair."""
    set_bg(channels, NcChannel.set_alpha(bg(channels), alpha))

  fun initializer(fr: U32, fg': U32, fb: U32,
    br: U32, bg': U32, bb: U32): U64
  =>
    """Create a channel pair from foreground and background RGB components. `initializer(fg_r, fg_g, fg_b, bg_r, bg_g, bg_b)`."""
    var ch: U64 = 0
    ch = set_fg_rgb8(ch, fr, fg', fb)
    ch = set_bg_rgb8(ch, br, bg', bb)
    ch
