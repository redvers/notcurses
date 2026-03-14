# Tutorial 3: Styling

In this tutorial you will add color and text attributes to the layout from [Tutorial 2](02-planes-and-layout.md). The title gets bold colored text, the content area gets a distinct palette, and the status bar gets a colored background.

## What We Are Building

The same three-region layout, now with:

- A bold, light-blue title
- Green content text
- A status bar with a dark blue background and white text

## The Complete Program

```pony
use "notcurses"

actor Main
  new create(env: Env) =>
    StyledApp(env)

actor StyledApp is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()
  var _content: NotCursesPlane = NotCursesPlane.none()
  var _status: NotCursesPlane = NotCursesPlane.none()

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

      // Style the border
      std.style().>fg(100, 100, 200).apply()?
      std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?

      // Style and write the title
      std.style().>bold().>fg(180, 180, 255).apply()?
      std.output().putstr_yx(" Task Selector ", 0, 2)?
      std.style().reset()

      // Content area
      _content = std.child(Ncplaneoptions(where
        y' = 2, x' = 2, rows' = rows - 5, cols' = cols - 4))?
      _content.style().>fg(80, 80, 160).apply()?
      _content.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
      _content.style().>fg(0, 220, 128).apply()?
      _content.output().putstr_yx("Pick a task to see details.", 1, 2)?

      // Status bar with background color
      _status = std.child(Ncplaneoptions(where
        y' = (rows - 2).i32(), x' = 2,
        rows' = 1, cols' = cols - 4))?
      _status.style().>fg(220, 220, 220).>bg(30, 30, 100).apply()?

      // Fill the entire status bar with the background color
      var i: U32 = 0
      while i < (cols - 4) do
        _status.output().putstr(" ")?
        i = i + 1
      end
      _status.output().putstr_yx("Status: Ready | Press 'q' to quit", 0, 0)?

      _nc.render()?
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 113 then  // 'q'
        try _nc.stop()? end
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
```

## PlaneStyleBuilder

`plane.style()` returns a `PlaneStyleBuilder` -- a fluent builder that accumulates style settings before applying them.

### The Fluent API with `.>`

Pony's cascade operator `.>` calls a method on an object and returns the object itself (rather than the method's return value). This allows chaining:

```pony
std.style().>bold().>fg(180, 180, 255).apply()?
```

This is equivalent to:

```pony
let s = std.style()
s.bold()
s.fg(180, 180, 255)
s.apply()?
```

The cascade form is more concise. Note that `apply()` is called with `.` (not `.>`), because `apply()` is the final call and you want its return value (to propagate the `?`).

### Available Text Attributes

| Method | Effect |
|--------|--------|
| `bold()` | Bold text |
| `italic()` | Italic text |
| `underline()` | Underlined text |
| `struck()` | Strikethrough text |
| `blink()` | Blinking text (terminal support varies) |

Combine multiple attributes in one chain:

```pony
plane.style().>bold().>italic().>fg(255, 255, 0).apply()?
```

### RGB Colors

`fg(r, g, b)` sets the foreground color. `bg(r, g, b)` sets the background color. Each component is a `U8` in the range 0--255.

```pony
// Green text on dark blue background
plane.style().>fg(0, 220, 128).>bg(30, 30, 100).apply()?
```

### Applying and Resetting

`apply()?` writes the accumulated styles and colors to the plane. All text written after `apply()` uses these settings until they are changed.

`reset()` clears all styles and resets colors to the terminal's defaults. Unlike `apply()`, `reset()` takes effect immediately -- you do not need to call `apply()` after it.

```pony
// Write styled text, then reset for plain text
plane.style().>bold().>fg(255, 0, 0).apply()?
plane.output().putstr("Important!")?
plane.style().reset()
plane.output().putstr("Normal text")?
```

### Style Scope

Styles apply per-plane. Setting bold on the standard plane does not affect child planes. Each plane has its own independent style state.

When you create a new plane, it starts with default styles (no attributes, terminal default colors). Set styles explicitly on each plane where you want them.

## Styling Borders

Borders use the plane's current style when drawn. Set the style before calling `box_draw()`:

```pony
// Draw a blue border
std.style().>fg(100, 100, 200).apply()?
std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
```

The border color is baked in at draw time. Changing the style afterward does not retroactively change the border -- it only affects text written after the change.

## Background Color Fills

Background color only appears where characters have been written. An empty plane shows the terminal's default background, not the plane's configured background color. To fill a status bar with a solid background, write spaces across its width:

```pony
_status.style().>fg(220, 220, 220).>bg(30, 30, 100).apply()?
var i: U32 = 0
while i < (cols - 4) do
  _status.output().putstr(" ")?
  i = i + 1
end
```

Then write your text on top -- it uses the same style, so the background remains consistent.

## Preview: Widget Colors

Widget constructors (`NotCursesSelector`, `NotCursesMultiselector`) use a different color system. Instead of `PlaneStyleBuilder`, they take `U64` channel pair values built with `NcChannels`:

```pony
let colors = NcChannels.initializer(0, 255, 0, 0, 0, 0)  // green on black
```

This is covered in [Tutorial 5: Widgets](05-widgets.md). The key point: `PlaneStyleBuilder` is for plane text you write yourself; `NcChannels` is for widget internal rendering. They are separate systems.

---

Previous: [Planes and Layout](02-planes-and-layout.md) | Next: [Input](04-input.md)

See also: [Rendering](../concepts/rendering.md).
