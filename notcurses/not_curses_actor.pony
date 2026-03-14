trait tag NotCursesActor
  """
  Trait for actors that host a NotCurses instance.

  Your main TUI actor implements this trait to integrate with the notcurses
  lifecycle and input system. The required pattern:

  ```pony
  actor MyApp is NotCursesActor
    var _nc: NotCurses = NotCurses.none()

    new create(env: Env) =>
      try _nc = NotCurses(this)? end

    fun ref _notcurses(): NotCurses => _nc
    be _initiate() => // setup planes, widgets, initial render
    be _exit() => None
    be input_received(event: InputEvent) => // handle input
  ```

  `_initiate()` is called as a behavior after construction, so the terminal
  is fully initialized when it runs. Do all setup there, not in the constructor.
  """
  // Return the embedded NotCurses instance. Called internally by the input
  // polling system.
  fun ref _notcurses(): NotCurses

  be _initiate() =>
    """
    Called after notcurses initialization. Set up planes, create widgets,
    and perform the initial render here.
    """

  be _exit() =>
    """
    User-provided cleanup hook. Called by your own code (not automatically)
    after `stop()`. Use it for post-TUI cleanup, or leave as `None`.
    """

  be input_received(event: InputEvent) =>
    """
    Called when an input event is not consumed by a focused widget.

    Pattern match on the event type to handle it:
    ```pony
    match event
    | let k: KeyEvent => // handle key
    | let m: MouseEvent => // handle mouse
    | let r: ResizeEvent => // handle terminal resize
    end
    ```
    """

  be _poll_input() =>
    """
    Internal: called by the input polling timer. Do not call directly.
    """
    _notcurses()._poll_and_route(this)
