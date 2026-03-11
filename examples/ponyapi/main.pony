use "../../notcurses"
use "debug"

actor Main
  var env: Env

  new create(env': Env) =>
    env = env'
    var options: Notcursesoptions iso = recover iso
      var o: Notcursesoptions = Notcursesoptions
      o.flags = (
        NcOption.suppress_banners() or
        NcOption.cli_mode())
      o
    end
    let q: TestCtx = TestCtx(consume options, env)


actor TestCtx is (NotCursesActor & NotCursesResizeCallback)
  var env: Env
  var notcurses: NotCurses = NotCurses.none()
  var stdplane: NotCursesPlane = NotCursesPlane.none()
  var txtplane: NotCursesPlane = NotCursesPlane.none()

  new create(options: Notcursesoptions iso, env': Env) =>
    env = env'
    try
      notcurses = NotCurses(this)?
      stdplane = notcurses.stdplane()

      txtplane = stdplane.child(Ncplaneoptions(
        where
        y' = 2,
        x' = 2,
        rows' = 15,
        cols' = 15,
        userptr' = ResizeCallbackWrapper(this)
        ))
    else
      env.out.print("We failed to initialize - exitting")
    end

  be _initiate() =>
    stdplane.perimeter_rounded(NcBoxCtl.all_borders())
    stdplane.home()
    stdplane.putstr_yx("Main Window", 0, 2)
    txtplane.dim_yx()
    txtplane.puttext("Hello, from notcurses - yay?" + NcOption.cli_mode().string())
    notcurses.render()

  be on_resize() => None

  be _exit() => None
    if (notcurses.stop() != 0) then
      env.out.print("I failed to shutdown")
    end



  fun ref _notcurses(): NotCurses => notcurses
