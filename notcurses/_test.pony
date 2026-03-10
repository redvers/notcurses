use "pony_test"

actor Main is TestList
  new create(env: Env) =>
    PonyTest(env, this)

  new make() =>
    None

  fun tag tests(test: PonyTest) =>
    test(_TestLinkage)

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
      NullablePointer[Notcursesoptions](consume opts), Pointer[_File])
    if not nc.is_null() then
      h.log("notcurses initialized successfully, stopping")
      @notcurses_stop(nc)
    else
      h.log("notcurses_init returned null (no TTY), linkage still verified")
    end
