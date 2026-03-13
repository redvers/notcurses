use "../../notcurses"
use "time"

actor Main
  new create(env: Env) =>
    UPlotDemo(env)

actor UPlotDemo is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _plot: NotCursesUPlot = NotCursesUPlot.none()
  var _x: U64 = 0
  var _timers: (Timers | None) = None

  new create(env: Env) =>
    _env = env
    try
      _nc = NotCurses(this)?
    else
      env.out.print("Failed to initialize notcurses")
    end

  be _initiate() =>
    try
      let std = _nc.stdplane()
      (let rows, let cols) = std.dim_yx()

      _plot = NotCursesUPlot(std, 1, 1, rows - 2, cols - 2
        where gridtype = NcBlitter.blit_8x1(),
        flags = NcPlotOption.labelticksd() or NcPlotOption.printsample(),
        title = "Sine Wave")?

      _nc.render()?

      let timers = Timers
      let timer = Timer(
        _PlotTick(this),
        50_000_000, 50_000_000)  // 50ms
      timers(consume timer)
      _timers = timers
    else
      _env.out.print("Setup failed")
    end

  be tick() =>
    let amplitude: F64 = 500
    let offset: F64 = 500
    let frequency: F64 = 0.1
    let y = ((amplitude * (_x.f64() * frequency).sin()) + offset).u64()
    try
      _plot.add_sample(_x, y)?
      _nc.render()?
    end
    _x = _x + 1

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 113 then  // 'q'
        match _timers
        | let ts: Timers => ts.dispose()
        end
        _plot.destroy()
        try _nc.stop()? end
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc


class _PlotTick is TimerNotify
  let _app: UPlotDemo

  new iso create(app: UPlotDemo) =>
    _app = app

  fun ref apply(timer: Timer, count: U64): Bool =>
    _app.tick()
    true
