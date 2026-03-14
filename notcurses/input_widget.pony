trait InputWidget
  """
  Trait for widgets that can receive input events via the focus system.

  When a widget is focused with `NotCurses.focus(widget)`, input events are
  offered to it before reaching `input_received`. The widget returns `true`
  to consume the event or `false` to let it pass through.

  Display-only widgets (like `NotCursesProgbar` and `NotCursesUPlot`) do not
  implement this trait and cannot be focused.
  """

  fun ref _offer_input(ni: Ncinput): Bool =>
    """
    Offer an input event to this widget. Return `true` if the widget consumed
    the event (it will not be passed to `input_received`), or `false` to let
    it pass through.
    """
    false
