// C constants as Pony primitives.
// Values sourced from notcurses.h and nckeys.h (v3.0.7).

primitive NcOption
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
  fun none(): U32 =>      0x0000
  fun struck(): U32 =>    0x0001
  fun bold(): U32 =>      0x0002
  fun undercurl(): U32 => 0x0004
  fun underline(): U32 => 0x0008
  fun italic(): U32 =>    0x0010
  fun mask(): U32 =>      0xFFFF

primitive NcPlaneOption
  fun horaligned(): U64 =>    0x0001
  fun veraligned(): U64 =>    0x0002
  fun marginalized(): U64 => 0x0004
  fun fixed(): U64 =>        0x0008
  fun autogrow(): U64 =>     0x0010
  fun vscroll(): U64 =>      0x0020

primitive NcLogLevel
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
  fun unknown(): I32 =>      0
  fun press(): I32 =>        1
  fun repeat_input(): I32 => 2
  fun release(): I32 =>      3

primitive NcKeyMod
  fun shift(): U32 =>    1
  fun alt(): U32 =>       2
  fun ctrl(): U32 =>      4
  fun super_key(): U32 => 8
  fun hyper(): U32 =>     16
  fun meta(): U32 =>      32
  fun capslock(): U32 =>  64
  fun numlock(): U32 =>   128

primitive NcMice
  fun no_events(): U32 =>     0
  fun move_event(): U32 =>    0x1
  fun button_event(): U32 =>  0x2
  fun drag_event(): U32 =>    0x4
  fun all_events(): U32 =>    0x7
