# Tutorial 6: Putting It Together

In this final tutorial you will build the complete task selector application. It combines everything from the previous tutorials: a styled layout with a title bar and status bar, a selector widget for picking tasks, a detail pane that shows information about the selected task, and a progress bar tracking completion.

## What We Are Building

- **Title bar** -- bold, colored title on the standard plane border
- **Selector** -- a widget listing tasks on the left side of the content area
- **Detail pane** -- a child plane on the right that shows task details when Enter is pressed
- **Progress bar** -- tracks how many tasks have been reviewed
- **Status bar** -- shows the current state
- **Quit** -- press 'q' to exit cleanly

## The Complete Program

```pony
use "notcurses"

actor Main
  new create(env: Env) =>
    TaskSelectorApp(env)

actor TaskSelectorApp is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _sel: NotCursesSelector = NotCursesSelector.none()
  var _bar: NotCursesProgbar = NotCursesProgbar.none()
  var _detail: NotCursesPlane = NotCursesPlane.none()
  var _status: NotCursesPlane = NotCursesPlane.none()
  var _reviewed: USize = 0
  let _task_count: USize = 5

  let _details: Array[(String, String)] = [
    ("Design", "Define the module boundaries, data types,\nand API surface before writing code.")
    ("Implement", "Write the code following the design.\nKeep functions small and testable.")
    ("Test", "Write property-based tests for core logic.\nVerify edge cases with targeted examples.")
    ("Deploy", "Build the release artifact, run smoke\ntests, and push to production.")
    ("Review", "Review the code for clarity, correctness,\nand adherence to project conventions.")
  ]

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

      // -- Outer border and title --
      std.style().>fg(80, 80, 180).apply()?
      std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
      std.style().>bold().>fg(180, 180, 255).apply()?
      std.output().putstr_yx(" Task Selector ", 0, 2)?
      std.style().reset()

      // -- Selector widget (left side) --
      let items = recover val
        let a = Array[SelectorItem]
        a.push(SelectorItem("Design", "Architecture"))
        a.push(SelectorItem("Implement", "Write code"))
        a.push(SelectorItem("Test", "Verify"))
        a.push(SelectorItem("Deploy", "Ship it"))
        a.push(SelectorItem("Review", "Check quality"))
        a
      end

      let sel_cols = (cols / 2) - 2
      let opt_colors = NcChannels.initializer(0, 255, 128, 0, 0, 0)
      let desc_colors = NcChannels.initializer(180, 180, 180, 0, 0, 0)

      _sel = NotCursesSelector(_nc, std, 2, 2,
        rows - 6, sel_cols, items,
        "Tasks", None, "Enter: details | q: quit"
        where opchannels = opt_colors,
        descchannels = desc_colors)?

      _nc.focus(_sel)

      // -- Detail pane (right side) --
      let detail_x = (cols / 2) + 1
      let detail_cols = cols - detail_x - 2
      _detail = std.child(Ncplaneoptions(where
        y' = 2, x' = detail_x.i32(),
        rows' = rows - 6, cols' = detail_cols))?

      _draw_detail("Select a task and press Enter.")?

      // -- Progress bar (below content) --
      _bar = NotCursesProgbar(std,
        rows - 3, 2, 1, cols - 4)?
      _bar.set_progress(0.0)?

      // -- Status bar --
      _status = std.child(Ncplaneoptions(where
        y' = (rows - 2).i32(), x' = 2,
        rows' = 1, cols' = cols - 4))?

      _draw_status("Navigate with arrow keys.")?

      _nc.render()?
    end

  fun ref _draw_detail(text: String val)? =>
    """Redraw the detail pane with the given text."""
    _detail.erase()
    _detail.style().>fg(80, 80, 160).apply()?
    _detail.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
    _detail.style().>bold().>fg(200, 200, 255).apply()?
    _detail.output().putstr_yx(" Details ", 0, 2)?
    _detail.style().>fg(220, 220, 220).apply()?

    // Split text on newlines and write each line
    var line_y: I32 = 2
    var start: ISize = 0
    let text_arr = text.array()
    var i: ISize = 0
    while i.usize() < text_arr.size() do
      try
        if text_arr(i.usize())? == '\n' then
          let line = text.substring(start, i)
          _detail.output().putstr_yx(consume line, line_y, 2)?
          line_y = line_y + 1
          start = i + 1
        end
      end
      i = i + 1
    end
    // Write the last line
    let last_line = text.substring(start)
    _detail.output().putstr_yx(consume last_line, line_y, 2)?

  fun ref _draw_status(msg: String val)? =>
    """Redraw the status bar with the given message."""
    _status.erase()
    _status.style().>fg(200, 200, 200).>bg(30, 30, 80).apply()?
    (let _, let status_cols) = _status.dim_yx()
    var j: U32 = 0
    while j < status_cols do
      _status.output().putstr(" ")?
      j = j + 1
    end

    let progress_text: String val =
      " [" + _reviewed.string() + "/" + _task_count.string() + " reviewed]"
    _status.output().putstr_yx(msg + progress_text, 0, 0)?

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 113 then  // 'q'
        _cleanup()
        return
      end

      if k.codepoint == 1115121 then  // NCKEY_ENTER
        let choice = _sel.selected()

        // Find the detail text for the selected task
        var detail_text: String val = "No details available."
        for (name, desc) in _details.values() do
          if name == choice then
            detail_text = desc
            break
          end
        end

        // Track progress
        _reviewed = _reviewed + 1
        if _reviewed > _task_count then
          _reviewed = _task_count
        end
        let progress = _reviewed.f64() / _task_count.f64()

        try
          _draw_detail(detail_text)?
          _bar.set_progress(progress)?
          let status_msg: String val = "Viewed: " + choice
          _draw_status(status_msg)?
          _nc.render()?
        end
      end
    end

  fun ref _cleanup() =>
    """Destroy all widgets, then stop notcurses."""
    _sel.destroy()
    _bar.destroy()
    try _nc.stop()? end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
```

## Walkthrough

### Layout Structure

The layout divides the terminal into regions:

```
Row 0:        ╭─ Task Selector ──────────────╮
Rows 2..N-6:  │ [Selector]  │  [Detail Pane] │
Row N-3:      │ [========Progress========]    │
Row N-2:      │ Status: ...                   │
Row N-1:      ╰──────────────────────────────╯
```

The outer border is drawn on the standard plane. The selector widget and detail pane sit side by side in the content area. The progress bar spans the width below them. The status bar is at the bottom.

### Selector Setup

```pony
let items = recover val
  let a = Array[SelectorItem]
  a.push(SelectorItem("Design", "Architecture"))
  // ...
  a
end
```

The items array is built in a `recover val` block to produce a `val` reference. Each `SelectorItem` has an option string (shown in the selection list) and a description string (shown alongside it).

Widget colors are built with `NcChannels.initializer()`:

```pony
let opt_colors = NcChannels.initializer(0, 255, 128, 0, 0, 0)
let desc_colors = NcChannels.initializer(180, 180, 180, 0, 0, 0)
```

The six arguments are: foreground red, green, blue, then background red, green, blue.

### Focus and Input Flow

```pony
_nc.focus(_sel)
```

After focusing the selector, the input flow is:

1. Arrow keys are consumed by the selector -- it moves its own highlight
2. Enter (1115121) passes through to `input_received()` -- you handle selection
3. 'q' (113) passes through -- you handle quitting

Events consumed by the widget trigger an automatic render by the polling loop. Events you handle yourself require an explicit `_nc.render()?`.

### Detail Pane Updates

When the user presses Enter, the detail pane is erased and redrawn with the selected task's description:

```pony
_detail.erase()
_detail.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
_detail.output().putstr_yx(text, 2, 2)?
```

`erase()` clears all content from the plane. The border and text are redrawn from scratch. This is the standard pattern for updating a region: erase, restyle, redraw, render.

### Progress Bar Updates

```pony
let progress = _reviewed.f64() / _task_count.f64()
_bar.set_progress(progress)?
```

The progress bar takes an `F64` from 0.0 to 1.0. Each time the user views a task's details, the progress increments. After setting progress, call `_nc.render()?` to show the change.

### Cleanup Order

```pony
fun ref _cleanup() =>
  _sel.destroy()
  _bar.destroy()
  try _nc.stop()? end
```

Widgets are destroyed before `stop()`. This is not optional -- the C library frees all planes during `stop()`, so destroying a widget afterward would free an already-freed pointer. The order between widget destructions does not matter, but all must come before `stop()`.

Child planes created with `child()` (like `_detail` and `_status`) do not need explicit destruction -- they are cleaned up when `stop()` destroys their parent (the standard plane). Only widgets with their own `destroy()` method need explicit cleanup.

### Extracting Helpers

The `_draw_detail()` and `_draw_status()` methods are `fun ref` functions (not behaviors). They run synchronously within the calling behavior. This is the right choice: they modify planes (which are `ref`), and they should complete before `_nc.render()?` is called.

Keeping rendering logic in helper functions makes behaviors like `input_received()` more readable.

## What You Have Learned

Across these six tutorials:

1. **[Hello World](01-hello-world.md)** -- the `NotCursesActor` pattern, lifecycle, `none()` constructors
2. **[Planes and Layout](02-planes-and-layout.md)** -- child planes, positioning, borders, the plane hierarchy
3. **[Styling](03-styling.md)** -- `PlaneStyleBuilder` fluent API, RGB colors, text attributes
4. **[Input](04-input.md)** -- event classification, pattern matching, modifiers, arrow keys, mouse
5. **[Widgets](05-widgets.md)** -- selector, progress bar, reader, plot, focus, `NcChannels`
6. **[Putting It Together](06-putting-it-together.md)** -- combining everything into a working application

## What is Next

The concept pages go deeper into each topic:

- [Architecture](../concepts/architecture.md) -- why embedding, the trait contract, the `none()` pattern
- [Planes](../concepts/planes.md) -- plane lifecycle, sub-accessors, resize callbacks
- [Input](../concepts/input.md) -- the polling architecture, focus system internals
- [Rendering](../concepts/rendering.md) -- double-buffer model, the two color systems
- [Widgets](../concepts/widgets.md) -- all available widgets, input vs display, lifecycle rules

---

Previous: [Widgets](05-widgets.md)
