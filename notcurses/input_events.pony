type InputEvent is (KeyEvent | MouseEvent | ResizeEvent | UnknownEvent)

type InputEventType is (InputPress | InputRelease | InputRepeat)
primitive InputPress
primitive InputRelease
primitive InputRepeat

class val KeyEvent
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
  new val create() => None

class val UnknownEvent
  """
  Escape hatch for unclassified events.
  Copies fields from Ncinput since struct is ref and cannot be held by val.
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
