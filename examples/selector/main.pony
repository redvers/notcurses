use "../../notcurses"

actor Main
  new create(env: Env) =>
    SelectorDemo(env)

actor SelectorDemo is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _sel: NotCursesSelector = NotCursesSelector.none()

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

      let items = recover val
        let a = Array[SelectorItem]
        a.push(SelectorItem("Pony", "Actor-model language"))
        a.push(SelectorItem("Rust", "Systems programming"))
        a.push(SelectorItem("Go", "Concurrent simplicity"))
        a.push(SelectorItem("Zig", "Low-level control"))
        a.push(SelectorItem("Haskell", "Pure functional"))
        a
      end

      // Channel encoding: upper 32 = FG, lower 32 = BG
      // Bit 30 (0x40000000) = "not default color", lower 24 = RGB
      let green_on_black: U64 = (0x40_00FF00 << 32) or 0x40_000000
      let white_on_black: U64 = (0x40_CCCCCC << 32) or 0x40_000000

      _sel = NotCursesSelector(_nc, std, 2, 2,
        rows - 4, cols - 4, items,
        "Pick a Language", "Use arrows to navigate",
        "Press Enter to select, q to quit"
        where opchannels = green_on_black,
        descchannels = white_on_black)?

      _nc.focus(_sel)
      _nc.render()?
    else
      _env.out.print("Setup failed")
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 113 then  // 'q'
        _sel.destroy()
        try _nc.stop()? end
      elseif k.codepoint == 1115121 then  // NCKEY_ENTER
        let choice = _sel.selected()
        _sel.destroy()
        try _nc.stop()? end
        _env.out.print("Selected: " + choice)
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
