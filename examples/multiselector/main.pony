use "../../notcurses"

actor Main
  new create(env: Env) => None
    /*
    MultiselectorDemo(env)

actor MultiselectorDemo is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _msel: NotCursesMultiselector = NotCursesMultiselector.none()

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
        let a = Array[MultiselectorItem]
        a.push(MultiselectorItem("Pepperoni", "Classic meat topping"))
        a.push(MultiselectorItem("Mushrooms", "Earthy and savory"))
        a.push(MultiselectorItem("Onions", "Sweet when cooked"))
        a.push(MultiselectorItem("Peppers", "Crunchy and colorful"))
        a.push(MultiselectorItem("Olives", "Briny and rich"))
        a.push(MultiselectorItem("Pineapple", "Controversial but delicious"))
        a
      end

      _msel = NotCursesMultiselector(_nc, std, 2, 2,
        rows - 4, cols - 4, items,
        "Pizza Toppings", "Space to toggle, arrows to navigate",
        "Press q to quit")?

      _nc.focus(_msel)
      _nc.render()?
    else
      _env.out.print("Setup failed")
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 113 then  // 'q'
        _msel.destroy()
        try _nc.stop()? end
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
  */
