trait tag NotCursesActor
  fun ref _notcurses(): NotCurses
  be _initiate()
  be _exit()
  be input_received(event: InputEvent)
