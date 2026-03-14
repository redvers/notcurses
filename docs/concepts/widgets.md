# Widgets

## What Are Widgets

Widgets are higher-level UI components that wrap notcurses C widget APIs. Each widget creates and manages its own child plane — you specify the parent plane, position, and size, and the widget handles the rest. Widgets render themselves; you do not write to their planes directly.

All widgets must be destroyed before `_nc.stop()` is called. The C library frees all planes during `stop()`; destroying a widget after that frees an already-freed pointer.

## Input Widgets vs Display Widgets

Widgets fall into two categories based on whether they can receive keyboard input.

**Input widgets** implement the `InputWidget` trait. They can be given focus with `_nc.focus(widget)`, after which keyboard events are offered to them before reaching your `input_received()` behavior. The widget handles its own navigation internally (arrow keys, selection, etc.) and returns `true` from `_offer_input()` to consume events it handles.

**Display widgets** do not implement `InputWidget`. They show data — progress, charts — but do not respond to input. You cannot pass them to `_nc.focus()`.

## Widget Lifecycle

Every widget follows the same lifecycle:

1. **Create** in `_initiate()` using the widget's `create()` constructor (which is partial — it can fail). Store as an actor field initialized with `none()`.
2. **Use** throughout the application: update data, query state.
3. **Destroy** explicitly before `_nc.stop()`. Call `widget.destroy()`.

```pony
actor MyApp is NotCursesActor
  var _nc: NotCurses = NotCurses.none()
  var _sel: NotCursesSelector = NotCursesSelector.none()  // none() for initialization

  be _initiate() =>
    try
      let std = _nc.stdplane()
      (let rows, let cols) = std.dim_yx()
      let items = recover val
        let a = Array[SelectorItem]
        a.push(SelectorItem("Option A", "First choice"))
        a.push(SelectorItem("Option B", "Second choice"))
        a
      end
      _sel = NotCursesSelector(_nc, std, 2, 2, rows - 4, cols - 4, items)?
      _nc.focus(_sel)
      _nc.render()?
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 113 then  // 'q'
        _sel.destroy()             // destroy before stop
        try _nc.stop()? end
      end
    end
```

## Focus Management

Only one input widget can be focused at a time.

`_nc.focus(widget)` sets the focused widget. `_nc.unfocus()` clears it. `_nc.unfocus_if(widget)` clears focus only if the given widget is currently focused — this is useful in cleanup code when you are not sure whether the widget has focus.

Widget `destroy()` methods call `_nc.unfocus_if(this)` internally, so you do not need to unfocus explicitly before destroying a widget. The pattern is simply:

```pony
_widget.destroy()
try _nc.stop()? end
```

When a focused widget is destroyed and focus is cleared, input events go directly to `input_received()` again.

## Available Widgets

| Widget | Type | Purpose |
|--------|------|---------|
| `NotCursesSelector` | Input | Single-selection menu with arrow-key navigation |
| `NotCursesMultiselector` | Input | Multi-selection menu; multiple items can be selected |
| `NotCursesReader` | Input | Single-line text input field |
| `NotCursesProgbar` | Display | Progress bar; set value with `set_progress(0.0..1.0)` |
| `NotCursesUPlot` | Display | Unsigned integer line chart; add data with `add_sample()` or `set_sample()` |

### NotCursesSelector

Single-selection menu. Items are `SelectorItem` values with an option string and a description string. The focused widget handles arrow-key navigation and Enter internally. Query the current selection with `selected()`.

Colors for option text and description text are set via `opchannels` and `descchannels` — U64 channel pairs built with `NcChannels`. See [Rendering](rendering.md) for how to build channel values.

### NotCursesMultiselector

Like `NotCursesSelector` but multiple items can be selected simultaneously. Query selections with `selected(count)` which returns an array of booleans, one per item.

### NotCursesReader

A text input field. The focused widget handles printable character input and backspace. Query the entered text with `contents()`.

### NotCursesProgbar

A progress bar. Not interactive. Call `set_progress(p)?` with a `F64` between 0.0 and 1.0, then call `_nc.render()?` to show the updated state.

```pony
_bar.set_progress(0.75)?
try _nc.render()? end
```

### NotCursesUPlot

An unsigned integer line chart. Not interactive. Add data points with `add_sample(x, y)?` (accumulates with any existing value at x) or `set_sample(x, y)?` (replaces). The plot auto-scales within the configured min/max range.

```pony
var i: U64 = 0
while i < 20 do
  _plot.set_sample(i, some_value(i))?
  i = i + 1
end
try _nc.render()? end
```

---

See also: [Input](input.md), [Rendering](rendering.md), [Tutorial: Widgets](../tutorial/05-widgets.md).
