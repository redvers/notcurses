use "../../notcurses"

actor Main
  new create(env: Env) =>
    ReaderDemo(env)

actor ReaderDemo is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _reader: NotCursesReader = NotCursesReader.none()

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

      std.style().>bold().>fg(200, 200, 200).apply()?
      std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
      std.home()
      std.output().putstr_yx("Reader Demo - Type text, Esc to quit", 0, 2)?

      _reader = NotCursesReader(_nc, std, 2, 2,
        rows - 4, cols - 4,
        NcReaderOption.horscroll() or NcReaderOption.cursor())?

      _nc.focus(_reader)
      _nc.render()?
    else
      _env.out.print("Setup failed")
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 27 then  // Escape
        try _nc.stop()? end
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
