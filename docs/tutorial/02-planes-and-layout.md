# Tutorial 2: Planes and Layout

In this tutorial you will divide the terminal into three regions -- a title bar, a content area, and a status bar -- using child planes. This introduces the plane hierarchy, positioning, sizing, and borders.

## What We Are Building

A terminal layout with three visual regions:

```
╭─ Task Selector ─────────────────────╮
│                                     │
│  ╭─────────────────────────────────╮│
│  │                                 ││
│  │  (content area)                 ││
│  │                                 ││
│  ╰─────────────────────────────────╯│
│                                     │
│  Status: Ready                      │
╰─────────────────────────────────────╯
```

## The Complete Program

```pony
use "notcurses"

actor Main
  new create(env: Env) =>
    LayoutApp(env)

actor LayoutApp is NotCursesActor
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

      // Draw border on the standard plane
      std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?

      // Title text on the standard plane, inside the top border
      std.output().putstr_yx(" Task Selector ", 0, 2)?

      // Content area: inset from the border, leaving room for status bar
      _content = std.child(Ncplaneoptions(where
        y' = 2, x' = 2, rows' = rows - 5, cols' = cols - 4))?
      _content.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
      _content.output().putstr_yx("Content goes here", 1, 2)?

      // Status bar: near the bottom, inside the outer border
      _status = std.child(Ncplaneoptions(where
        y' = (rows - 2).i32(), x' = 2,
        rows' = 1, cols' = cols - 4))?
      _status.output().putstr("Status: Ready | Press 'q' to quit")?

      _nc.render()?
    end

  be input_received(event: InputEvent) =>
    match event
    | let k: KeyEvent =>
      if k.codepoint == 'q' then
        try _nc.stop()? end
      end
    end

  be _exit() => None
  fun ref _notcurses(): NotCurses => _nc
```

## How It Works

### Getting Terminal Dimensions

```pony
let std = _nc.stdplane()
(let rows, let cols) = std.dim_yx()
```

`dim_yx()` returns the plane's dimensions as a `(U32, U32)` tuple -- rows first, then columns. On the standard plane this gives you the terminal size. Use these values for relative sizing so your layout adapts to different terminal sizes.

### Creating Child Planes

```pony
_content = std.child(Ncplaneoptions(where
  y' = 2, x' = 2, rows' = rows - 5, cols' = cols - 4))?
```

`child(opts)?` creates a new plane positioned relative to its parent. The `Ncplaneoptions` struct specifies:

- `y'` and `x'` -- position relative to the parent plane's origin (not the terminal)
- `rows'` and `cols'` -- the size of the child plane

The constructor uses Pony's named arguments with the `where` keyword. The field names have a trailing `'` to distinguish constructor parameters from struct fields.

You can equivalently write `NotCursesPlane(std, opts)?`, which does the same thing.

### The `none()` Pattern for Planes

```pony
var _content: NotCursesPlane = NotCursesPlane.none()
var _status: NotCursesPlane = NotCursesPlane.none()
```

Child planes are created in `_initiate()`, but fields must be initialized in the constructor. `NotCursesPlane.none()` provides the default value. This is the same pattern as `NotCurses.none()` from [Tutorial 1](01-hello-world.md).

### Drawing Borders

```pony
std.box_draw().perimeter_rounded(NcBoxCtl.all_borders())?
```

`box_draw()` returns a `PlaneBoxDraw` accessor. `perimeter_rounded()` draws a rounded-corner Unicode border around the entire plane perimeter.

The `ctlword` parameter controls which borders are drawn. `NcBoxCtl.all_borders()` draws all four sides. `NcBoxCtl.no_borders()` suppresses all sides.

There is also `perimeter_double()` for double-line borders:

```pony
_content.box_draw().perimeter_double(NcBoxCtl.all_borders())?
```

### Writing Text at Specific Positions

```pony
std.output().putstr_yx(" Task Selector ", 0, 2)?
```

`output()` returns a `PlaneOutput` accessor. `putstr_yx(string, y, x)?` writes text at a specific position within the plane. Position `(0, 2)` places the title on the top row, two columns in -- overlapping the border character to create a titled border effect.

`putstr(string)?` writes at the current cursor position, which advances after each write.

### Plane Hierarchy

The standard plane is the root. The content plane and status plane are its children. This hierarchy means:

- Children are positioned relative to their parent, not the terminal
- When a parent is destroyed, all children are destroyed
- Planes stack visually -- higher (more recently created) planes occlude lower ones where they overlap

### Layout Math

The sizing arithmetic in this example:

- **Content area**: starts at row 2 (below the border + gap), column 2 (inside the border + gap). Its height is `rows - 5` to leave room for the top border, top gap, bottom gap, status bar, and bottom border. Its width is `cols - 4` to leave room for left and right borders plus gaps.
- **Status bar**: sits at row `rows - 2` (one row above the bottom border), same horizontal inset. One row tall.

Note that `rows - 2` is a `U32` subtraction. To pass it as the `y'` parameter (which is `I32`), call `.i32()` on the result.

### Writing Inside a Bordered Plane

```pony
_content.output().putstr_yx("Content goes here", 1, 2)?
```

When a plane has a perimeter border, the border occupies the outermost row and column on each side. Write content starting at position `(1, 1)` or further inward to avoid overwriting the border characters.

## Plane Lifecycle

Child planes created with `child()` or `NotCursesPlane()` are tracked by their parent. When `_nc.stop()` is called, the standard plane and all its descendants are cleaned up automatically.

If you need to destroy a child plane before shutdown, call `plane.destroy()?`. After destruction, do not use the plane instance. Importantly, destroy child planes **before** calling `_nc.stop()` -- the C library frees all planes during `stop()`, so destroying afterward is a double-free.

In this example we do not destroy the planes explicitly because `stop()` handles it.

---

Previous: [Hello World](01-hello-world.md) | Next: [Styling](03-styling.md)

See also: [Planes](../concepts/planes.md).
