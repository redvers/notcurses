use "pony_test"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestLinkage)
    test(_TestInputClassifier)
    test(_TestStyleBuilder)

class iso _TestLinkage is UnitTest
  fun name(): String => "notcurses/linkage"

  fun apply(h: TestHelper) =>
    // Verify FFI linkage by calling notcurses_version() which requires
    // no terminal and returns a static string pointer.
    let ver = @notcurses_version()
    h.assert_true(ver.is_null() == false, "notcurses_version returned null")

    let version = String.from_cstring(ver)
    h.assert_true(version.size() > 0, "version string is empty")
    h.log("notcurses version: " + version)

    // Verify struct sizes are plausible by constructing them.
    var opts = Notcursesoptions
    opts.flags = NcOption.suppress_banners()
    h.assert_eq[U64](opts.flags, 0x0020)

    var cell = Nccell
    h.assert_eq[U64](cell.channels, 0)

    var ni = Ncinput
    h.assert_eq[U32](ni.id, 0)

    // Verify init/stop cycle. init may return null if no TTY is available
    // (e.g., in CI), which is fine — we just test that linkage works.
    let nc = @notcurses_core_init(
      NullablePointer[Notcursesoptions](consume opts), NullablePointer[CFile].none())
    if not nc.is_none() then
      h.log("notcurses initialized successfully, stopping")
      @notcurses_stop(nc)
    else
      h.log("notcurses_init returned null (no TTY), linkage still verified")
    end

class iso _TestInputClassifier is UnitTest
  fun name(): String => "notcurses/input-classifier"

  fun apply(h: TestHelper) =>
    // Key press event
    var ni: Ncinput ref = Ncinput
    ni.id = 113  // 'q'
    ni.evtype = NcInputType.press()
    ni.modifiers = 0
    match InputClassifier.classify(ni)
    | let k: KeyEvent =>
      h.assert_eq[U32](k.codepoint, 113)
      h.assert_is[InputEventType](k.event_type, InputPress)
    else
      h.fail("Expected KeyEvent")
    end

    // Mouse button event — NCKEY_BUTTON1 = 1115201
    ni = Ncinput
    ni.id = 1115201
    ni.y = 5
    ni.x = 10
    ni.evtype = NcInputType.press()
    ni.modifiers = 0
    match InputClassifier.classify(ni)
    | let m: MouseEvent =>
      h.assert_eq[I32](m.y, 5)
      h.assert_eq[I32](m.x, 10)
      h.assert_eq[U32](m.button, 1115201)
      h.assert_is[InputEventType](m.event_type, InputPress)
    else
      h.fail("Expected MouseEvent")
    end

    // Resize event — NCKEY_RESIZE = 1115001
    ni = Ncinput
    ni.id = 1115001
    ni.evtype = NcInputType.press()
    match InputClassifier.classify(ni)
    | let r: ResizeEvent => None  // correct
    else
      h.fail("Expected ResizeEvent")
    end

    // Unknown event (id = 0)
    ni = Ncinput
    ni.id = 0
    match InputClassifier.classify(ni)
    | let u: UnknownEvent => None  // correct
    else
      h.fail("Expected UnknownEvent for id=0")
    end

    // Repeat event type
    ni = Ncinput
    ni.id = 65  // 'A'
    ni.evtype = NcInputType.repeat_input()
    ni.modifiers = NcKeyMod.shift()
    match InputClassifier.classify(ni)
    | let k: KeyEvent =>
      h.assert_eq[U32](k.codepoint, 65)
      h.assert_is[InputEventType](k.event_type, InputRepeat)
      h.assert_eq[U32](k.modifiers, NcKeyMod.shift())
    else
      h.fail("Expected KeyEvent for repeat")
    end

class iso _TestStyleBuilder is UnitTest
  fun name(): String => "notcurses/style-builder"

  fun apply(h: TestHelper) =>
    // Test style accumulation
    let builder = PlaneStyleBuilder._for_test()
    builder.>bold().>italic()
    h.assert_eq[U32](builder._test_styles(),
      NcStyle.bold() or NcStyle.italic())

    // Test color accumulation
    builder.fg(255, 0, 128)
    match builder._test_fg()
    | let rgb: U32 =>
      h.assert_eq[U32](rgb, (U32(255) << 16) or (U32(0) << 8) or U32(128))
    else
      h.fail("Expected fg color to be set")
    end

    // Test fresh builder starts empty
    let builder2 = PlaneStyleBuilder._for_test()
    h.assert_eq[U32](builder2._test_styles(), 0)
    match builder2._test_fg()
    | None => None
    else
      h.fail("Expected fg color to be None on fresh builder")
    end
