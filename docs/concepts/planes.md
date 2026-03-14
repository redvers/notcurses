# Planes

A plane is a rectangular region of the terminal. It has its own cursor, its own content buffer, and its own style settings. Planes stack: higher planes occlude lower ones where they overlap. When you write text to a plane, it appears in the composed view when you call `render()`.

## What Is a Plane

Each `NotCursesPlane` instance wraps a C `ncplane` pointer. A plane has:

- A position (y, x) relative to its parent
- A size (rows, cols)
- A cursor that advances as you write text
- Style settings (colors, bold, italic) that apply to subsequent writes
- A content buffer separate from the terminal screen

None of this appears on screen until you call `_nc.render()?`. See [Rendering](rendering.md).

## The Standard Plane

Every notcurses instance has a standard plane obtained via `_nc.stdplane()`. It covers the entire terminal and always exists. It is the root of the plane hierarchy — all other planes are children or descendants of it.

You cannot destroy the standard plane. It is destroyed automatically when `_nc.stop()` is called.

```pony
be _initiate() =>
  try
    let std = _nc.stdplane()
    (let rows, let cols) = std.dim_yx()
    // Use std for background content, borders, etc.
    std.style().>fg(200, 200, 200).apply()?
    std.output().putstr("Hello")?
    _nc.render()?
  end
```

## Child Planes

Child planes are positioned relative to their parent. When the parent moves, children move with it. When the parent is destroyed, all children are destroyed.

Create a child with `parent.child(opts)?` or `NotCursesPlane(parent, opts)?` — both do the same thing:

```pony
// Create a 10-row by 40-column child at position (2, 2) relative to std
let opts = Ncplaneoptions(where y' = 2, x' = 2, rows' = 10, cols' = 40)
let panel = std.child(opts)?

// Or equivalently:
let panel = NotCursesPlane(std, opts)?
```

`Ncplaneoptions` is a struct; fill in only the fields you need. Positions are relative to the parent plane, not the terminal.

Store child planes as actor fields when you need to keep a reference to them after `_initiate()` returns. Use `NotCursesPlane.none()` for field initialization (see [Architecture](architecture.md)).

## Sub-Accessor Pattern

`NotCursesPlane` organizes its operations into focused accessor classes. Each accessor is a lightweight object that holds the same underlying plane pointer — creating one is cheap.

| Accessor | Method | Purpose |
|----------|--------|---------|
| `PlaneStyleBuilder` | `plane.style()` | Set colors and text attributes |
| `PlaneOutput` | `plane.output()` | Write text |
| `PlaneCursor` | `plane.cursor()` | Position the cursor |
| `PlaneBoxDraw` | `plane.box_draw()` | Draw borders and boxes |

This keeps the `NotCursesPlane` class itself small and makes the API discoverable: `plane.` followed by a tab shows you the categories, not dozens of individual methods.

`PlaneStyleBuilder` uses a fluent API with Pony's cascade operator (`.>`):

```pony
// Set bold, red foreground, black background, then apply
plane.style().>bold().>fg(255, 0, 0).>bg(0, 0, 0).apply()?

// Reset all styles to defaults
plane.style().reset()
```

Text output:

```pony
// Write at current cursor position
plane.output().putstr("text")?

// Write at specific position (y, x)
plane.output().putstr_yx("text", 1, 4)?

// Write with alignment
plane.output().puttext("centered", 5, NcAlign.center())?
```

Other plane operations directly on `NotCursesPlane`:

```pony
plane.erase()           // Clear all content
plane.home()            // Move cursor to (0, 0)
plane.move_yx(y, x)?   // Move the plane itself (not the cursor)
(let rows, let cols) = plane.dim_yx()   // Get dimensions
(let y, let x) = plane.yx()             // Get position
```

## Plane Lifecycle

Planes are created, used, and destroyed explicitly. The rules:

- **Standard plane**: created by notcurses, destroyed by `stop()`. Never call `destroy()` on it.
- **Child planes**: created by you, destroyed by you with `plane.destroy()?`. Or destroyed automatically when their parent is destroyed.
- **Widget planes**: each widget creates and owns its child plane. Destroy the widget with `widget.destroy()`, which also destroys its plane.

The critical ordering: destroy widgets and planes **before** calling `_nc.stop()`. The C library frees all planes during `stop()`. If you call `widget.destroy()` after `stop()`, the plane pointer is already freed — that is a double-free crash.

```pony
// Correct order:
_panel.destroy()?    // destroy child plane first
_widget.destroy()    // destroy widget (and its plane)
try _nc.stop()? end  // now stop notcurses
```

After `destroy()`, do not use the plane or widget instance again.

## Resize Callbacks (Advanced)

When the terminal is resized, notcurses fires resize callbacks on planes. Implement the `NotCursesResizeCallback` trait and wrap it with `ResizeCallbackWrapper` to attach a callback to a plane. Most applications handle resize by catching `ResizeEvent` in `input_received()` and redrawing instead. Callbacks are for cases where a plane must resize itself automatically.

---

See also: [Architecture](architecture.md), [Rendering](rendering.md), [Tutorial: Planes and Layout](../tutorial/02-planes-and-layout.md).
