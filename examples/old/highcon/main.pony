use "../../notcurses"
use "time"

actor Main
  let _env: Env
  var _nc: Pointer[NcNotcurses] tag = Pointer[NcNotcurses]
  let _timers: Timers = Timers

  new create(env: Env) =>
    _env = env
    var delay_ns: U64 = 500_000_000
    try
      if env.args(1)? == "-d" then
        delay_ns = (env.args(2)?.f64()? * 1_000_000_000).u64()
      end
    end
    var opts = Notcursesoptions
    opts.flags = NcOption.suppress_banners()
    _nc = NotCursesFFI.core_init(
      NullablePointer[Notcursesoptions](consume opts), Pointer[CFile])
    if _nc.is_null() then
      env.err.print("Failed to initialize notcurses")
      env.exitcode(1)
      return
    end
    // Compute timer interval from terminal dimensions
    (let stdn, let dimy, let dimx) = NotCursesFFI.stddim_yx(_nc)
    let totcells = ((dimy - 1) * dimx).i32()
    let totalns = delay_ns * 2
    let iterns: U64 = if totcells > 2 then totalns / (totcells.u64() / 2)
      else totalns end
    let notify = HighconDemo.create(this, _nc, delay_ns)
    let timer = Timer(consume notify, 0, iterns.max(1))
    _timers(consume timer)

  be demo_finished(ret: I32) =>
    _timers.dispose()
    NotCursesFFI.stop(_nc)
    if ret != 0 then
      _env.err.print("highcon failed: " + ret.string())
      _env.exitcode(1)
    end

primitive _DemoUtil
  fun render(nc: Pointer[NcNotcurses] tag): I32 =>
    NotCursesFFI.render(nc)

  fun clock_ns(): U64 =>
    Time.nanos()
