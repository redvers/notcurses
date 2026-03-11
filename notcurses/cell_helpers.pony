// Pony reimplementations of inline nccell functions that modify Nccell structs.
// These operate on the cell's channels field via NcChannels.

primitive NcCellHelper
  fun set_fg_rgb8(c: Nccell ref, r: U32, g: U32, b: U32) =>
    c.channels = NcChannels.set_fg_rgb8(c.channels, r, g, b)

  fun set_bg_rgb8(c: Nccell ref, r: U32, g: U32, b: U32) =>
    c.channels = NcChannels.set_bg_rgb8(c.channels, r, g, b)

  fun set_fg_rgb(c: Nccell ref, rgb: U32) =>
    c.channels = NcChannels.set_fg_rgb(c.channels, rgb)

  fun set_bg_rgb(c: Nccell ref, rgb: U32) =>
    c.channels = NcChannels.set_bg_rgb(c.channels, rgb)

  fun set_fg_alpha(c: Nccell ref, alpha: U32) =>
    c.channels = NcChannels.set_fg_alpha(c.channels, alpha)

  fun set_bg_alpha(c: Nccell ref, alpha: U32) =>
    c.channels = NcChannels.set_bg_alpha(c.channels, alpha)

  fun load_char(c: Nccell ref, ch: U32) =>
    c.gcluster = ch

  fun fg_rgb8(c: Nccell box): (U32, U32, U32) =>
    NcChannels.fg_rgb8(c.channels)

  fun bg_rgb8(c: Nccell box): (U32, U32, U32) =>
    NcChannels.bg_rgb8(c.channels)

  fun wide_right_p(c: Nccell box): Bool =>
    c.width == 0
