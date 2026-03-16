use "../../notcurses"

actor Main
  new create(env: Env) =>
    NcEv(env)

actor NcEv is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _line: U32 = 1

  new create(env: Env) =>
    _env = env
    try
      _nc = NotCurses(this
        where flags = NcOption.suppress_banners())?
    else
      env.out.print("Failed to initialize notcurses")
    end

  be _initiate() =>
    try
      _nc.mice_enable(NcMice.all_events())?
    end
    let std = _nc.stdplane()
    NotCursesFFI.plane_set_scrolling(std.raw_ptr(), 1)
    (let rows, let cols) = std.dim_yx()

    try
      std.style().>bold().>fg(100, 200, 100).apply()?
      std.output().putstr("ncev — press 'q' to quit")?
      std.style().reset()
    end
    try _nc.render()? end

  be input_received(event: InputEvent) =>
    let std = _nc.stdplane()
    let text = _format(event)
    try
      std.output().putstr_yx("\n" + text)?
      _nc.render()?
    end
    _line = _line + 1

    match event
    | let k: KeyEvent =>
      if (k.codepoint == 113) and (k.event_type is InputPress) then
        try _nc.stop()? end
      end
    end

  fun _format(event: InputEvent): String val =>
    match event
    | let k: KeyEvent =>
      let evstr = _evtype_str(k.event_type)
      let mods = _mods_str(k.modifiers)
      let cp = k.codepoint
      if cp < 128 then
        let ch: String val = String.from_utf32(cp)
        "Key " + evstr + " cp=" + cp.string() + " '" + ch + "'" + mods
      elseif cp >= 1115000 then
        "Key " + evstr + " special=" + cp.string() + _special_name(cp) + mods
      else
        let ch: String val = String.from_utf32(cp)
        "Key " + evstr + " cp=U+" + _hex(cp) + " '" + ch + "'" + mods
      end
    | let m: MouseEvent =>
      let evstr = _evtype_str(m.event_type)
      let btn = m.button - 1115200
      let mods = _mods_str(m.modifiers)
      "Mouse " + evstr + " btn=" + btn.string()
        + " y=" + m.y.string() + " x=" + m.x.string() + mods
    | let r: ResizeEvent =>
      (let rows, let cols) = _nc.dim_yx()
      "Resize " + rows.string() + "x" + cols.string()
    | let u: UnknownEvent =>
      "Unknown id=" + u.id.string() + " evtype=" + u.evtype.string()
        + " y=" + u.y.string() + " x=" + u.x.string()
    end

  fun _evtype_str(et: InputEventType): String val =>
    match et
    | InputPress => "press"
    | InputRelease => "release"
    | InputRepeat => "repeat"
    end

  fun _mods_str(modifiers: U32): String val =>
    if modifiers == 0 then return "" end
    var s: String iso = recover iso String end
    if (modifiers and NcKeyMod.shift()) != 0 then s.append(" Shift") end
    if (modifiers and NcKeyMod.alt()) != 0 then s.append(" Alt") end
    if (modifiers and NcKeyMod.ctrl()) != 0 then s.append(" Ctrl") end
    if (modifiers and NcKeyMod.super_key()) != 0 then s.append(" Super") end
    if (modifiers and NcKeyMod.hyper()) != 0 then s.append(" Hyper") end
    if (modifiers and NcKeyMod.meta()) != 0 then s.append(" Meta") end
    if (modifiers and NcKeyMod.capslock()) != 0 then s.append(" CapsLock") end
    if (modifiers and NcKeyMod.numlock()) != 0 then s.append(" NumLock") end
    " [" + consume s + " ]"

  fun _hex(v: U32): String val =>
    let digits = "0123456789ABCDEF"
    var n = v
    var s: String iso = recover iso String(8) end
    if n == 0 then return "0" end
    while n > 0 do
      try s.push(digits(((n and 0xF)).usize())?) end
      n = n >> 4
    end
    s.reverse_in_place()
    consume s

  fun _special_name(cp: U32): String val =>
    // NCKEY_* values: preterunicode(n) = 1115000 + n
    // See notcurses/nckeys.h for authoritative values
    if     cp == 1115001 then " (Resize)"    // preterunicode(1)
    elseif cp == 1115002 then " (Up)"        // preterunicode(2)
    elseif cp == 1115003 then " (Right)"     // preterunicode(3)
    elseif cp == 1115004 then " (Down)"      // preterunicode(4)
    elseif cp == 1115005 then " (Left)"      // preterunicode(5)
    elseif cp == 1115006 then " (Ins)"       // preterunicode(6)
    elseif cp == 1115007 then " (Del)"       // preterunicode(7)
    elseif cp == 1115008 then " (Backspace)" // preterunicode(8)
    elseif cp == 1115009 then " (PgDown)"    // preterunicode(9)
    elseif cp == 1115010 then " (PgUp)"      // preterunicode(10)
    elseif cp == 1115011 then " (Home)"      // preterunicode(11)
    elseif cp == 1115012 then " (End)"       // preterunicode(12)
    elseif cp == 1115020 then " (F00)"       // preterunicode(20)
    elseif cp == 1115021 then " (F01)"       // preterunicode(21)
    elseif cp == 1115022 then " (F02)"       // preterunicode(22)
    elseif cp == 1115023 then " (F03)"       // preterunicode(23)
    elseif cp == 1115024 then " (F04)"       // preterunicode(24)
    elseif cp == 1115025 then " (F05)"       // preterunicode(25)
    elseif cp == 1115026 then " (F06)"       // preterunicode(26)
    elseif cp == 1115027 then " (F07)"       // preterunicode(27)
    elseif cp == 1115028 then " (F08)"       // preterunicode(28)
    elseif cp == 1115029 then " (F09)"       // preterunicode(29)
    elseif cp == 1115030 then " (F10)"       // preterunicode(30)
    elseif cp == 1115031 then " (F11)"       // preterunicode(31)
    elseif cp == 1115032 then " (F12)"       // preterunicode(32)
    elseif cp == 1115121 then " (Enter)"     // preterunicode(121)
    elseif cp == 1115122 then " (CLS)"       // preterunicode(122)
    elseif cp == 1115123 then " (DLeft)"     // preterunicode(123)
    elseif cp == 1115124 then " (DRight)"    // preterunicode(124)
    elseif cp == 1115125 then " (ULeft)"     // preterunicode(125)
    elseif cp == 1115126 then " (URight)"    // preterunicode(126)
    elseif cp == 1115127 then " (Center)"    // preterunicode(127)
    elseif cp == 1115128 then " (Begin)"     // preterunicode(128)
    elseif cp == 1115129 then " (Cancel)"    // preterunicode(129)
    elseif cp == 1115130 then " (Close)"     // preterunicode(130)
    elseif cp == 1115200 then " (ScrollUp)"  // preterunicode(200)
    elseif cp == 1115201 then " (Button1)"   // preterunicode(201)
    elseif cp == 1115202 then " (Button2)"   // preterunicode(202)
    elseif cp == 1115203 then " (Button3)"   // preterunicode(203)
    else ""
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
