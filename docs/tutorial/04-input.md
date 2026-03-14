# Tutorial 4: Input

In this tutorial you will extend the styled layout to respond to keyboard input. Arrow keys move a highlight through a list of items, and the status bar shows the last key pressed. This covers event classification, pattern matching, modifier keys, and mouse events.

## What We Are Building

A list of items in the content area. Arrow keys move a highlight marker. The status bar updates to show each key press. Ctrl+Q quits.

## The Complete Program

```pony
use "notcurses"

actor Main
  new create(env: Env) =>
    InputApp(env)

actor InputApp is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _content: NotCursesPlane = NotCursesPlane.none()
  var _status: NotCursesPlane = NotCursesPlane.none()
  var _selected: USize = 0
  let _items: Array[String] = ["Design"; "Implement"; "Test"; "Deploy"; "Review"]

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

      std.style().>fg(100, 100, 200).apply()?
      std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
      std.style().>bold().>fg(180, 180, 255).apply()?
      std.output().putstr_yx(" Task Selector ", 0, 2)?
      std.style().reset()

      _content = std.child(Ncplaneoptions(where
        y' = 2, x' = 2, rows' = rows - 5, cols' = cols - 4))?

      _status = std.child(Ncplaneoptions(where
        y' = (rows - 2).i32(), x' = 2,
        rows' = 1, cols' = cols - 4))?

      _draw_list()?
      _draw_status("Arrow keys: navigate | Ctrl+Q: quit")?
      _nc.render()?
    end

  fun ref _draw_list()? =>
    _content.erase()
    _content.style().>fg(80, 80, 160).apply()?
    _content.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?

    var i: USize = 0
    while i < _items.size() do
      let item = try _items(i)? else "" end
      if i == _selected then
        _content.style().>bold().>fg(0, 255, 128).apply()?
        _content.output().putstr_yx("> " + item, (i + 1).i32(), 2)?
      else
        _content.style().>fg(180, 180, 180).apply()?
        _content.output().putstr_yx("  " + item, (i + 1).i32(), 2)?
      end
      i = i + 1
    end
    _content.style().reset()

  fun ref _draw_status(msg: String val)? =>
    _status.erase()
    _status.style().>fg(220, 220, 220).>bg(30, 30, 100).apply()?
    (let _, let cols) = _status.dim_yx()
    var j: U32 = 0
    while j < cols do
      _status.output().putstr(" ")?
      j = j + 1
    end
    _status.output().putstr_yx(msg, 0, 0)?

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      // Ctrl+Q to quit (113 = 'q')
      if (k.codepoint == 113) and ((k.modifiers and NcKeyMod.ctrl()) != 0) then
        try _nc.stop()? end
        return
      end

      match k.codepoint
      | 1115002 =>  // NCKEY_UP
        if _selected > 0 then _selected = _selected - 1 end
        try _draw_list()?; _draw_status("UP")?; _nc.render()? end
      | 1115004 =>  // NCKEY_DOWN
        if _selected < (_items.size() - 1) then
          _selected = _selected + 1
        end
        try _draw_list()?; _draw_status("DOWN")?; _nc.render()? end
      | 1115121 =>  // NCKEY_ENTER
        let item = try _items(_selected)? else "?" end
        try _draw_status("Selected: " + item)?; _nc.render()? end
      else
        let msg: String val = "Key: codepoint=" + k.codepoint.string()
        try _draw_status(msg)?; _nc.render()? end
      end
    | let m: MouseEvent =>
      let msg: String val = "Mouse: (" + m.y.string() + "," + m.x.string() + ")"
      try _draw_status(msg)?; _nc.render()? end
    | let r: ResizeEvent =>
      try _draw_status("Terminal resized")?; _nc.render()? end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
```

## Event Types

The `InputEvent` type is a union:

```pony
type InputEvent is (KeyEvent | MouseEvent | ResizeEvent | UnknownEvent)
```

Pattern match in `input_received()` to handle each variant:

```pony
match event
| let k: KeyEvent    => // keyboard input
| let m: MouseEvent  => // mouse input
| let r: ResizeEvent => // terminal resized
| let u: UnknownEvent => None  // ignore
end
```

All event types are `val` -- immutable values that can be sent across actor boundaries.

## KeyEvent

A `KeyEvent` carries three fields:

- **`codepoint: U32`** -- the Unicode codepoint for printable characters (e.g., 113 for 'q', 65 for 'A'), or an NCKEY constant for special keys
- **`modifiers: U32`** -- a bitmask of held modifier keys
- **`event_type: InputEventType`** -- `InputPress`, `InputRelease`, or `InputRepeat`

### Special Key Codepoints

Special keys use codepoint values above the Unicode range. The base value is 1115000. Common keys:

| Key | Codepoint | Constant |
|-----|-----------|----------|
| Resize | 1115001 | NCKEY_RESIZE |
| Up arrow | 1115002 | NCKEY_UP |
| Right arrow | 1115003 | NCKEY_RIGHT |
| Down arrow | 1115004 | NCKEY_DOWN |
| Left arrow | 1115005 | NCKEY_LEFT |
| Enter | 1115121 | NCKEY_ENTER |
| Escape | 27 | (standard ASCII) |

These values come from the notcurses C header. Use them as raw integers in your match expressions.

### Modifier Keys

Check modifiers with `NcKeyMod` constants using bitwise AND:

```pony
if (k.modifiers and NcKeyMod.ctrl()) != 0 then
  // Ctrl was held
end
```

Available modifier flags:

| Modifier | Method |
|----------|--------|
| Shift | `NcKeyMod.shift()` |
| Alt | `NcKeyMod.alt()` |
| Ctrl | `NcKeyMod.ctrl()` |
| Super | `NcKeyMod.super_key()` |
| Hyper | `NcKeyMod.hyper()` |
| Meta | `NcKeyMod.meta()` |
| Caps Lock | `NcKeyMod.capslock()` |
| Num Lock | `NcKeyMod.numlock()` |

### Distinguishing Modified Keys

Ctrl+Q and plain Q both arrive with codepoint 113. The difference is the modifier bitmask:

```pony
| let k: KeyEvent =>
  if (k.modifiers and NcKeyMod.ctrl()) != 0 then
    if k.codepoint == 113 then  // Ctrl+Q
      try _nc.stop()? end
    end
  else
    if k.codepoint == 113 then  // plain 'q'
      // different action
    end
  end
```

### Event Type: Press, Release, Repeat

Most applications only care about press events. If you need to distinguish:

```pony
| let k: KeyEvent =>
  match k.event_type
  | InputPress => // key was just pressed
  | InputRelease => // key was released
  | InputRepeat => // key is being held down
  end
```

## Mouse Events

Mouse events are opt-in. Enable them in `_initiate()`:

```pony
_nc.mice_enable(NcMice.all_events())?
```

`NcMice` constants control which events are reported:

| Constant | Events |
|----------|--------|
| `NcMice.all_events()` | Move + button + drag |
| `NcMice.button_event()` | Button press/release only |
| `NcMice.move_event()` | Movement only |
| `NcMice.drag_event()` | Drag only |

`MouseEvent` fields:

- `y: I32`, `x: I32` -- cell coordinates
- `button: U32` -- which button
- `modifiers: U32` -- held modifier keys
- `event_type: InputEventType` -- press, release, or repeat

```pony
| let m: MouseEvent =>
  if m.event_type is InputPress then
    // handle click at (m.y, m.x)
  end
```

## Resize Events

When the terminal is resized, a `ResizeEvent` is delivered. Query `_nc.dim_yx()` or `std.dim_yx()` for the new dimensions. In most applications, the response is to redraw the layout at the new size.

```pony
| let r: ResizeEvent =>
  (let new_rows, let new_cols) = _nc.dim_yx()
  // Recreate or resize planes, then redraw
```

## How Polling Works

You do not call a read function yourself. The `NotCursesActor` trait includes a default `_poll_input()` behavior that runs on a timer (every 10ms by default). It drains all pending input without blocking the Pony scheduler, classifies each event, and delivers it to your `input_received()` behavior.

If a widget is focused (covered in [Tutorial 5](05-widgets.md)), the event is offered to the widget first. If the widget consumes it, your `input_received()` is not called for that event.

See [Input](../concepts/input.md) for the full polling architecture.

## Rendering After Input

In `input_received()`, after modifying plane content, you must call `_nc.render()?` explicitly. The only case where rendering happens automatically is when a focused widget consumes an input event -- the polling loop handles that. For your own input handling, always render at the end:

```pony
| 1115002 =>  // UP
  _selected = _selected - 1
  try _draw_list()?; _draw_status("UP")?; _nc.render()? end
```

---

Previous: [Styling](03-styling.md) | Next: [Widgets](05-widgets.md)

See also: [Input](../concepts/input.md).
