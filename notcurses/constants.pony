// C constants as Pony primitives.
// Values sourced from notcurses.h and nckeys.h (v3.0.7).

primitive NcOption
  """Flags for `NotCurses` initialization. Combine with bitwise OR."""
  fun inhibit_setlocale(): U64 =>   0x0001
  fun no_clear_bitmaps(): U64 =>    0x0002
  fun no_winch_sighandler(): U64 => 0x0004
  fun no_quit_sighandlers(): U64 => 0x0008
  fun preserve_cursor(): U64 =>     0x0010
  fun suppress_banners(): U64 =>    0x0020
  fun no_alternate_screen(): U64 => 0x0040
  fun no_font_changes(): U64 =>     0x0080
  fun drain_input(): U64 =>         0x0100
  fun scrolling(): U64 =>           0x0200
  fun cli_mode(): U64 =>
    no_alternate_screen() or no_clear_bitmaps()
      or preserve_cursor() or scrolling()

primitive NcStyle
  """Text style flags. Used with `PlaneStyleBuilder` or raw style operations."""
  fun none(): U32 =>      0x0000
  fun struck(): U32 =>    0x0001
  fun bold(): U32 =>      0x0002
  fun undercurl(): U32 => 0x0004
  fun underline(): U32 => 0x0008
  fun italic(): U32 =>    0x0010
  fun blink(): U32 =>     0x0020
  fun mask(): U32 =>      0xFFFF

primitive NcPlaneOption
  """Flags for `Ncplaneoptions`. Control plane alignment, growth, and scrolling."""
  fun horaligned(): U64 =>    0x0001
  fun veraligned(): U64 =>    0x0002
  fun marginalized(): U64 => 0x0004
  fun fixed(): U64 =>        0x0008
  fun autogrow(): U64 =>     0x0010
  fun vscroll(): U64 =>      0x0020

primitive NcLogLevel
  """Log verbosity levels for notcurses initialization."""
  fun silent(): I32 =>  -1
  fun panic(): I32 =>    0
  fun fatal(): I32 =>    1
  fun nc_error(): I32 => 2
  fun warning(): I32 =>  3
  fun info(): I32 =>     4
  fun verbose(): I32 =>  5
  fun debug(): I32 =>    6
  fun trace(): I32 =>    7

primitive NcInputType
  """Raw input event type constants. Prefer pattern matching on `InputEventType`."""
  fun unknown(): I32 =>      0
  fun press(): I32 =>        1
  fun repeat_input(): I32 => 2
  fun release(): I32 =>      3

primitive NcKeyMod
  """
  Keyboard modifier flags. Check against `KeyEvent.modifiers` with bitwise AND:
  ```pony
  if (key.modifiers and NcKeyMod.ctrl()) != 0 then
    // Ctrl was held
  end
  ```
  """
  fun shift(): U32 =>    1
  fun alt(): U32 =>       2
  fun ctrl(): U32 =>      4
  fun super_key(): U32 => 8
  fun hyper(): U32 =>     16
  fun meta(): U32 =>      32
  fun capslock(): U32 =>  64
  fun numlock(): U32 =>   128

primitive NcMice
  """Mouse event mask constants for `NotCurses.mice_enable()`."""
  fun no_events(): U32 =>     0
  fun move_event(): U32 =>    0x1
  fun button_event(): U32 =>  0x2
  fun drag_event(): U32 =>    0x4
  fun all_events(): U32 =>    0x7

primitive NcAlign
  """Text alignment constants for `PlaneOutput.puttext()`."""
  fun unaligned(): I32 => 0
  fun left(): I32 =>      1
  fun center(): I32 =>    2
  fun right(): I32 =>     3

primitive NcAlpha
  """Alpha blending constants for channel operations."""
  fun highcontrast(): U32 => 0x30000000
  fun transparent(): U32 =>  0x20000000
  fun blend(): U32 =>        0x10000000
  fun opaque(): U32 =>       0x00000000

primitive NcBoxGrad
  """Gradient direction flags for box drawing."""
  fun top(): U32 =>    0x0010
  fun right(): U32 =>  0x0020
  fun bottom(): U32 => 0x0040
  fun left(): U32 =>   0x0080

primitive NcReelOption
  """Flags for reel widget options."""
  fun infinitescroll(): U64 => 0x0001
  fun circular(): U64 =>       0x0002

primitive NcProgbarOption
  """Flags for progress bar options."""
  fun retrograde(): U64 => 0x0001

primitive NcBoxCtl
  """Border control flags for `PlaneBoxDraw` methods. Use `all_borders()` for a complete border, or `no_borders()` to suppress."""
  fun no_borders(): U32 => 0b0000_1111
  fun all_borders(): U32 => 0b0000_0000
  fun hgradient(): U32 => 0b0001_0000
  fun vgradient(): U32 => 0b0010_0000

primitive NcPlotOption
  """Flags for plot widget options."""
  fun labelticksd(): U64 =>   0x0001
  fun exponentiald(): U64 =>  0x0002
  fun verticali(): U64 =>     0x0004
  fun nodegrade(): U64 =>     0x0008
  fun detectmaxonly(): U64 => 0x0010
  fun printsample(): U64 =>   0x0020

primitive NcBlitter
  """Blitter type constants controlling the character set used for rendering."""
  fun default_blitter(): I32 => 0
  fun blit_1x1(): I32 =>       1
  fun blit_2x1(): I32 =>       2
  fun blit_2x2(): I32 =>       3
  fun blit_3x2(): I32 =>       4
  fun braille(): I32 =>        5
  fun pixel(): I32 =>          6
  fun blit_4x1(): I32 =>       7
  fun blit_8x1(): I32 =>       8

