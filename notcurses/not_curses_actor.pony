trait tag NotCursesActor
  fun ref _notcurses(): NotCurses
  be _initiate()
  be _exit()
  be input_received(event: InputEvent)
  be _poll_input() =>
    _notcurses()._poll_and_route(this)
