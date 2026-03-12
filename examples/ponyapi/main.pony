use "../../notcurses"

actor Main
  new create(env: Env) =>
    MyApp(env)

actor MyApp is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _content: NotCursesPlane = NotCursesPlane.none()

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

      _content = std.child(Ncplaneoptions(where
        y' = 2, x' = 2, rows' = 10, cols' = 40
      ))?

      std.style().>bold().>fg(200, 200, 200).apply()?
      std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
      std.home()
      std.output().putstr_yx("Main Window", 0, 2)?

      _content.style().>fg(0, 255, 128).apply()?
      _content.output().putstr("Hello from notcurses!")?

      _nc.render()?
    else
      _env.out.print("Drawing failed")
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 113 then  // 'q'
        try _nc.stop()? end
      end
    end

  be _exit() => None

  fun ref _notcurses(): NotCurses => _nc
