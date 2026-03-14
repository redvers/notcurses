// Union of all input event types. Pattern match to handle each variant.
type InputEvent is (KeyEvent | MouseEvent | ResizeEvent | UnknownEvent)

// Whether an input event is a press, release, or repeat.
type InputEventType is (InputPress | InputRelease | InputRepeat)

primitive InputPress
  """A key or button press event."""

primitive InputRelease
  """A key or button release event."""

primitive InputRepeat
  """A key repeat event (key held down)."""

class val KeyEvent
  """
  A keyboard input event.

  `codepoint` is the Unicode codepoint for printable characters, or an NCKEY_* constant for special keys (arrow keys, function keys, etc.). Check `modifiers` against `NcKeyMod` constants to detect Shift, Alt, Ctrl.
  """
  let codepoint: U32
  let modifiers: U32
  let event_type: InputEventType

  new val create(codepoint': U32, modifiers': U32,
    event_type': InputEventType)
  =>
    codepoint = codepoint'
    modifiers = modifiers'
    event_type = event_type'

class val MouseEvent
  """
  A mouse input event.

  `y` and `x` are the cell coordinates of the event. `button` identifies which mouse button. Enable mouse events with `NotCurses.mice_enable()`.
  """
  let y: I32
  let x: I32
  let button: U32
  let modifiers: U32
  let event_type: InputEventType

  new val create(y': I32, x': I32, button': U32, modifiers': U32,
    event_type': InputEventType)
  =>
    y = y'
    x = x'
    button = button'
    modifiers = modifiers'
    event_type = event_type'

class val ResizeEvent
  """A terminal resize event. Query `NotCurses.dim_yx()` for the new dimensions."""
  new val create() => None

class val UnknownEvent
  """
  An input event that could not be classified as key, mouse, or resize. Copies fields from `Ncinput` since the struct is `ref` and cannot be held by a `val` event.
  """
  let id: U32
  let y: I32
  let x: I32
  let evtype: I32
  let modifiers: U32

  new val create(id': U32, y': I32, x': I32, evtype': I32, modifiers': U32) =>
    id = id'
    y = y'
    x = x'
    evtype = evtype'
    modifiers = modifiers'
