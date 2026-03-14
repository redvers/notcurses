# Input

## Why Polling

Notcurses input reads from a file descriptor. The blocking form of this call — "wait until input arrives" — would freeze the scheduler thread it runs on, preventing any other Pony actors from running on that thread until input arrives.

Pony's runtime schedules actors across a fixed-size thread pool. If one thread is blocked in a C call, the pool has effectively shrunk. For a single-actor application this is merely inefficient; for an application with concurrent actors it is a correctness problem.

The solution is non-blocking polling: a Pony `Timer` fires every 10 milliseconds (configurable via `poll_interval_ms` in the `NotCurses` constructor), calls `notcurses_get_nblock()` to drain any pending input without waiting, and returns immediately. The thread is never blocked.

## The Polling Flow

Each timer tick triggers this sequence:

1. `Timer` fires `_InputPollNotify.apply()`
2. `_InputPollNotify` calls `_poll_input()` on your actor
3. Your actor's `_poll_input()` behavior (provided by the `NotCursesActor` trait default) calls `_notcurses()._poll_and_route(this)`
4. `_poll_and_route()` loops, calling `notcurses_get_nblock()` until no more input is pending:
   - If a widget is focused and `widget._offer_input(ni)` returns `true`: the event is consumed, render is flagged as needed
   - Otherwise: `InputClassifier.classify(ni)` converts the raw `Ncinput` struct to a typed `InputEvent`, and `enc'.input_received(event)` is called on your actor
5. After draining all pending input: if any event was consumed by a widget, `_nc.render()?` is called automatically

You do not call any part of this yourself. The trait default on `_poll_input` handles it.

## Input Classification

Raw notcurses input arrives as an `Ncinput` struct with an `id` field (a U32 codepoint or NCKEY constant), coordinate fields for mouse events, and a modifier bitmask. `InputClassifier.classify()` converts this into one of four typed variants:

```pony
type InputEvent is (KeyEvent | MouseEvent | ResizeEvent | UnknownEvent)
```

Pattern match in `input_received()` to handle each:

```pony
be input_received(event: InputEvent) =>
  match event
  | let k: KeyEvent    => // keyboard input
  | let m: MouseEvent  => // mouse input
  | let r: ResizeEvent => // terminal resized
  | let u: UnknownEvent => None  // ignore
  end
```

All four event types are `val` — they are immutable and can be sent across actor boundaries if needed.

## Key Events and Modifiers

`KeyEvent` carries:

- `codepoint: U32` — the Unicode codepoint for printable characters, or an NCKEY_* value for special keys (arrows, function keys, Enter, etc.)
- `modifiers: U32` — a bitmask of held modifier keys
- `event_type: InputEventType` — `InputPress`, `InputRelease`, or `InputRepeat`

Check modifiers with `NcKeyMod` constants using bitwise AND:

```pony
be input_received(event: InputEvent) =>
  match event
  | let k: KeyEvent =>
    if (k.modifiers and NcKeyMod.ctrl()) != 0 then
      if k.codepoint == 113 then  // Ctrl+Q (113 = 'q')
        try _nc.stop()? end
      end
    elseif k.codepoint == 113 then  // plain 'q'
      // different action
    end
  end
```

Available modifier flags from `NcKeyMod`: `shift()`, `alt()`, `ctrl()`, `super_key()`, `hyper()`, `meta()`, `capslock()`, `numlock()`.

Special key codepoints use raw integer values. Some common ones appear in the source: NCKEY_ENTER is `1115121`. For others, consult the notcurses documentation or check what value arrives with a test print.

Note: character literal method calls like `'q'.u32()` do not work in match case patterns in Pony — use raw integer values (e.g., `113` for 'q').

## Mouse Events

Mouse events are opt-in. Enable them before your first render:

```pony
be _initiate() =>
  try
    _nc.mice_enable(NcMice.all_events())?
    // ... setup ...
    _nc.render()?
  end
```

`NcMice` constants: `all_events()` (move + button + drag), `button_event()`, `move_event()`, `drag_event()`, `no_events()`.

`MouseEvent` fields:

- `y: I32`, `x: I32` — cell coordinates of the event
- `button: U32` — which mouse button
- `modifiers: U32` — held modifier keys (same `NcKeyMod` constants)
- `event_type: InputEventType` — press, release, or repeat

```pony
| let m: MouseEvent =>
  if m.event_type is InputPress then
    // handle click at (m.y, m.x)
  end
```

## Focus System

The focus system routes input to a widget before your actor sees it. One widget can be focused at a time.

**`_nc.focus(widget)`** — set the focused widget. Input events are offered to it via `_offer_input()` before reaching `input_received()`. If the widget returns `true` from `_offer_input()`, the event is consumed and you never see it.

**`_nc.unfocus()`** — clear focus. All input goes directly to `input_received()`.

**`_nc.unfocus_if(widget)`** — clear focus only if the given widget is currently focused. Use this in cleanup code when you are not sure whether the widget has focus:

```pony
_sel.destroy()           // destroy() calls unfocus_if internally
try _nc.stop()? end
```

`NotCursesSelector.destroy()` already calls `_nc.unfocus_if(this)` internally, so you do not need to unfocus manually before destroying a widget. Other widgets follow the same pattern.

Only widgets that implement the `InputWidget` trait can be focused. Display-only widgets (`NotCursesProgbar`, `NotCursesUPlot`) do not implement `InputWidget` and cannot be passed to `focus()`.

---

See also: [Architecture](architecture.md), [Widgets](widgets.md), [Tutorial: Input](../tutorial/04-input.md).
