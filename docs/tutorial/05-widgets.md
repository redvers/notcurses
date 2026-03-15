# Tutorial 5: Widgets

In this tutorial you will replace hand-built list UI with notcurses widgets. Widgets are higher-level components that handle their own rendering and -- for input widgets -- their own keyboard navigation. This covers the selector, progress bar, reader, and plot widgets, plus the focus system and widget color channels.

## Widget Colors with NcChannels

Widgets use a different color system than `PlaneStyleBuilder`. Widget constructors take `U64` channel pair values where the upper 32 bits encode the foreground color and the lower 32 bits encode the background color.

Build channel values with `NcChannels`:

```pony
// One-step: (fg_r, fg_g, fg_b, bg_r, bg_g, bg_b)
let green_on_black = NcChannels.initializer(0, 255, 0, 0, 0, 0)

// Incremental:
var channels: U64 = 0
channels = NcChannels.set_fg_rgb8(channels, 200, 200, 200)
channels = NcChannels.set_bg_rgb8(channels, 0, 0, 0)
```

Both approaches produce the same result. Pass the U64 values to widget constructors as `opchannels`, `descchannels`, etc.

## NotCursesSelector

A single-selection menu with built-in arrow-key navigation. This is an input widget -- it can be focused to receive keyboard events.

```pony
use "notcurses"

actor Main
  new create(env: Env) =>
    SelectorApp(env)

actor SelectorApp is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _sel: NotCursesSelector = NotCursesSelector.none()

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

      let items = recover val
        let a = Array[SelectorItem]
        a.push(SelectorItem("Design", "Plan the architecture"))
        a.push(SelectorItem("Implement", "Write the code"))
        a.push(SelectorItem("Test", "Verify correctness"))
        a.push(SelectorItem("Deploy", "Ship to production"))
        a
      end

      let opt_colors = NcChannels.initializer(0, 255, 128, 0, 0, 0)
      let desc_colors = NcChannels.initializer(180, 180, 180, 0, 0, 0)

      _sel = NotCursesSelector(_nc, std, 2, 2,
        rows - 4, cols - 4, items,
        "Tasks", "Arrow keys to navigate",
        "Enter to select, q to quit"
        where opchannels = opt_colors,
        descchannels = desc_colors)?

      _nc.focus(_sel)
      _nc.render()?
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 'q' then
        _sel.destroy()
        try _nc.stop()? end
      elseif k.codepoint == 1115121 then  // NCKEY_ENTER
        let choice = _sel.selected()
        _sel.destroy()
        try _nc.stop()? end
        _env.out.print("Selected: " + choice)
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
```

### How It Works

**Items** are `SelectorItem` values with an option string and a description string. The items array must be `val` -- construct it in a `recover val` block.

**Constructor** takes the `NotCurses` instance, a parent plane, position and size, the items array, and optional title/secondary/footer strings. The `opchannels` and `descchannels` named parameters control the colors of option text and description text respectively.

**Focus** -- call `_nc.focus(_sel)` to route keyboard input to the selector. The widget handles arrow-key navigation and highlight rendering internally. Events it consumes (arrow keys, page up/down) never reach your `input_received()`. Events it does not consume (letter keys, Enter, Escape) pass through to you.

**Querying selection** -- `_sel.selected()` returns the option string of the currently highlighted item.

**Dynamic items** -- add items after creation with `_sel.add_item("Option", "Description")?` or remove with `_sel.del_item("Option")?`.

## NotCursesProgbar

A progress bar. This is a display widget -- it does not accept input and cannot be focused.

```pony
use "notcurses"
use "time"

actor Main
  new create(env: Env) =>
    ProgbarApp(env)

actor ProgbarApp is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _bar: NotCursesProgbar = NotCursesProgbar.none()
  var _progress: F64 = 0.0
  var _timers: (Timers | None) = None

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

      _bar = NotCursesProgbar(std,
        (rows / 2) - 1, 4, 3, cols - 8)?

      _nc.render()?

      // Start a timer to advance the progress
      let timers = Timers
      let timer = Timer(
        _TickNotify(this), 100_000_000, 100_000_000)  // 100ms
      timers(consume timer)
      _timers = timers
    end

  be tick() =>
    _progress = _progress + 0.02
    if _progress > 1.0 then _progress = 1.0 end
    try
      _bar.set_progress(_progress)?
      _nc.render()?
    end
    if _progress >= 1.0 then
      match _timers | let ts: Timers => ts.dispose() end
      _bar.destroy()
      try _nc.stop()? end
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 'q' then
        match _timers | let ts: Timers => ts.dispose() end
        _bar.destroy()
        try _nc.stop()? end
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc

class _TickNotify is TimerNotify
  let _app: ProgbarApp
  new iso create(app: ProgbarApp) => _app = app
  fun ref apply(timer: Timer, count: U64): Bool =>
    _app.tick()
    true
```

### How It Works

**Constructor** takes a parent plane, position (y, x), and size (rows, cols). No `NotCurses` instance is needed -- the progress bar has no input to route.

**Setting progress** -- `_bar.set_progress(p)?` takes an `F64` from 0.0 (empty) to 1.0 (full). Call `_nc.render()?` afterward to show the update.

**Timer pattern** -- Pony timers use a `TimerNotify` class. The timer calls a behavior on your actor, which updates the progress bar. This is the standard pattern for animations or periodic updates.

## NotCursesReader

A text input field. This is an input widget that accepts typed characters when focused.

```pony
be _initiate() =>
  try
    let std = _nc.stdplane()
    (let rows, let cols) = std.dim_yx()

    _reader = NotCursesReader(_nc, std, 2, 2,
      3, cols - 4,
      NcReaderOption.horscroll() or NcReaderOption.cursor())?

    _nc.focus(_reader)
    _nc.render()?
  end
```

### How It Works

**Constructor** takes the `NotCurses` instance, parent plane, position, size, and optional flags. Common flags from `NcReaderOption`:

| Flag | Effect |
|------|--------|
| `horscroll()` | Horizontal scrolling when text exceeds width |
| `verscroll()` | Vertical scrolling for multi-line input |
| `cursor()` | Show the cursor in the reader |
| `nocmdkeys()` | Disable command key interpretation |

Combine flags with bitwise OR: `NcReaderOption.horscroll() or NcReaderOption.cursor()`.

**Focus** -- when focused, printable characters are typed into the reader. Escape (codepoint 27) and Enter (codepoint 1115121) pass through to your `input_received()`, so you can use them to submit or cancel.

**Getting text** -- `_reader.contents()` returns the current text as a `String val`.

**Clearing** -- `_reader.clear()?` removes all entered text.

## NotCursesUPlot

An unsigned integer line chart. Display-only.

```pony
be _initiate() =>
  try
    let std = _nc.stdplane()
    (let rows, let cols) = std.dim_yx()

    _plot = NotCursesUPlot(std, 2, 2, rows - 4, cols - 4,
      where maxy = 100, title = "Data")?

    var i: U64 = 0
    while i < 20 do
      _plot.set_sample(i, i * 5)?
      i = i + 1
    end

    _nc.render()?
  end
```

### How It Works

**Constructor** takes a parent plane, position, size, and optional parameters: `miny`/`maxy` for the Y-axis range, `title`, `gridtype` (from `NcBlitter`), `rangex` for the X-axis window, `flags` (from `NcPlotOption`), and channel colors.

**Adding data** -- `add_sample(x, y)?` accumulates with any existing value at x. `set_sample(x, y)?` replaces it. Both take `U64` values.

**Reading data** -- `sample(x)?` returns the current value at position x.

## NotCursesMultiselector

Like `NotCursesSelector` but allows multiple items to be selected. Items are `MultiselectorItem` values with an option, description, and initial selection state:

```pony
let items = recover val
  let a = Array[MultiselectorItem]
  a.push(MultiselectorItem("Lint", "Run linter", true))
  a.push(MultiselectorItem("Test", "Run tests", true))
  a.push(MultiselectorItem("Build", "Compile", false))
  a
end

_msel = NotCursesMultiselector(_nc, std, 2, 2,
  rows - 4, cols - 4, items, "Select Steps")?
_nc.focus(_msel)
```

Navigate with arrow keys, toggle selection with Space. Query selected state with `_msel.selected(count)` which returns an `Array[Bool]`.

## Input vs Display Widgets

| Widget | Type | Focusable | Key interaction |
|--------|------|-----------|-----------------|
| `NotCursesSelector` | Input | Yes | Arrow keys, Enter |
| `NotCursesMultiselector` | Input | Yes | Arrow keys, Space |
| `NotCursesReader` | Input | Yes | Typing, backspace |
| `NotCursesProgbar` | Display | No | None |
| `NotCursesUPlot` | Display | No | None |

Only input widgets implement the `InputWidget` trait and can be passed to `_nc.focus()`. Display widgets show data but do not respond to keyboard input. You update them programmatically and call `_nc.render()?`.

## Cleanup: Destroy Before Stop

Every widget must be destroyed before `_nc.stop()` is called. The C library frees all planes during `stop()`. If you destroy a widget after `stop()`, its plane pointer has already been freed -- that is a double-free crash.

The correct order:

```pony
_sel.destroy()          // destroy widgets first
_bar.destroy()
try _nc.stop()? end     // then stop notcurses
```

Widget `destroy()` methods are idempotent -- calling `destroy()` twice is safe. They also call `_nc.unfocus_if(this)` internally, so you do not need to unfocus before destroying.

---

Previous: [Input](04-input.md) | Next: [Putting It Together](06-putting-it-together.md)

See also: [Widgets](../concepts/widgets.md).
