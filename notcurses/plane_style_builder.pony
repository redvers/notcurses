class PlaneStyleBuilder
  """
  Fluent builder for setting text styles and colors on a plane.

  Obtained via `NotCursesPlane.style()`. Accumulate styles and colors with chaining, then call `apply()` to set them on the plane. All text written after `apply()` uses these styles until changed or `reset()`.

  Example:
  ```pony
  plane.style().>bold().>fg(255, 0, 0).apply()?
  plane.output().putstr("Red bold text")?
  plane.style().reset()
  ```

  For widget colors (selector, multiselector options), use `NcChannels` instead — `PlaneStyleBuilder` only applies to plane text output.
  """
  var _ptr: NullablePointer[NcPlaneT] tag
  var _styles: U32 = 0
  var _fg: (U32 | None) = None
  var _bg: (U32 | None) = None

  new create(ptr': NullablePointer[NcPlaneT] tag) =>
    _ptr = ptr'

  new _for_test() =>
    """Test-only constructor with null pointer."""
    _ptr = NullablePointer[NcPlaneT].none()

  // Style methods — mutate internal state
  fun ref bold() =>
    """Enable bold text."""
    _styles = _styles or NcStyle.bold()
  fun ref italic() =>
    """Enable italic text."""
    _styles = _styles or NcStyle.italic()
  fun ref underline() =>
    """Enable underlined text."""
    _styles = _styles or NcStyle.underline()
  fun ref struck() =>
    """Enable strikethrough text."""
    _styles = _styles or NcStyle.struck()
  fun ref blink() =>
    """Enable blinking text (terminal support varies)."""
    _styles = _styles or NcStyle.blink()

  // Color methods — pack r/g/b into U32
  fun ref fg(r: U8, g: U8, b: U8) =>
    """Set foreground color from RGB components (0-255 each)."""
    _fg = (r.u32() << 16) or (g.u32() << 8) or b.u32()

  fun ref bg(r: U8, g: U8, b: U8) =>
    """Set background color from RGB components (0-255 each)."""
    _bg = (r.u32() << 16) or (g.u32() << 8) or b.u32()

  fun ref fg_default() =>
    """Reset foreground to the terminal's default color."""
    _fg = None
  fun ref bg_default() =>
    """Reset background to the terminal's default color."""
    _bg = None

  fun ref apply()? =>
    """Apply the accumulated styles and colors to the plane. All subsequent text output on this plane uses these settings."""
    NotCursesFFI.plane_set_styles(_ptr, _styles)
    match _fg
    | let rgb: U32 =>
      if NotCursesFFI.plane_set_fg_rgb(_ptr, rgb) != 0 then error end
    | None =>
      NotCursesFFI.plane_set_fg_default(_ptr)
    end
    match _bg
    | let rgb: U32 =>
      if NotCursesFFI.plane_set_bg_rgb(_ptr, rgb) != 0 then error end
    | None =>
      NotCursesFFI.plane_set_bg_default(_ptr)
    end

  fun ref reset() =>
    """Reset all styles and colors to terminal defaults. Takes effect immediately — does not require a subsequent `apply()` call."""
    NotCursesFFI.plane_set_styles(_ptr, NcStyle.none())
    NotCursesFFI.plane_set_fg_default(_ptr)
    NotCursesFFI.plane_set_bg_default(_ptr)

  // Test accessors
  fun _test_styles(): U32 => _styles
  fun _test_fg(): (U32 | None) => _fg
  fun _test_bg(): (U32 | None) => _bg
