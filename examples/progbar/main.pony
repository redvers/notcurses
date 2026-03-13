use "../../notcurses"
use "time"

actor Main
  new create(env: Env) =>
    ProgbarDemo(env)

actor ProgbarDemo is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _bar: NotCursesProgbar = NotCursesProgbar.none()
  var _progress: F64 = 0.0
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

      std.style().>bold().>fg(100, 100, 255).apply()?
      std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
      std.home()
      std.output().putstr_yx("Progress Bar Demo", 0, 2)?

      _bar = NotCursesProgbar(std,
        (rows / 2) - 1, 4, 3, cols - 8)?

      _nc.render()?

      let timers = Timers
      let timer = Timer(
        _ProgressTick(this),
        100_000_000, 100_000_000)  // 100ms
      timers(consume timer)
      _timers = timers
    else
      _env.out.print("Setup failed")
    end

  be tick() =>
    _progress = _progress + 0.02
    if _progress >= 1.0 then
      _progress = 1.0
    end
    try
      _bar.set_progress(_progress)?
      _nc.render()?
    end
    if _progress >= 1.0 then
      match _timers
      | let ts: Timers => ts.dispose()
      end
      try _nc.stop()? end
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 113 then  // 'q'
        match _timers
        | let ts: Timers => ts.dispose()
        end
        try _nc.stop()? end
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc


class _ProgressTick is TimerNotify
  let _app: ProgbarDemo

  new iso create(app: ProgbarDemo) =>
    _app = app

  fun ref apply(timer: Timer, count: U64): Bool =>
    _app.tick()
    true
