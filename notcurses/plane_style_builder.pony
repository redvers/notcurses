class PlaneStyleBuilder
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
  fun ref bold() => _styles = _styles or NcStyle.bold()
  fun ref italic() => _styles = _styles or NcStyle.italic()
  fun ref underline() => _styles = _styles or NcStyle.underline()
  fun ref struck() => _styles = _styles or NcStyle.struck()
  fun ref blink() => _styles = _styles or NcStyle.blink()

  // Color methods — pack r/g/b into U32
  fun ref fg(r: U8, g: U8, b: U8) =>
    _fg = (r.u32() << 16) or (g.u32() << 8) or b.u32()

  fun ref bg(r: U8, g: U8, b: U8) =>
    _bg = (r.u32() << 16) or (g.u32() << 8) or b.u32()

  fun ref fg_default() => _fg = None
  fun ref bg_default() => _bg = None

  fun ref apply()? =>
    """Set accumulated styles and colors on the plane via FFI."""
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
    """Clear all styles and colors on the plane."""
    NotCursesFFI.plane_set_styles(_ptr, NcStyle.none())
    NotCursesFFI.plane_set_fg_default(_ptr)
    NotCursesFFI.plane_set_bg_default(_ptr)

  // Test accessors
  fun _test_styles(): U32 => _styles
  fun _test_fg(): (U32 | None) => _fg
  fun _test_bg(): (U32 | None) => _bg
