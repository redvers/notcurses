# Rendering

## Double-Buffer Model

Notcurses uses a double-buffer model. When you write text to a plane or update a widget, nothing changes on the terminal screen. The changes accumulate in an off-screen buffer. When you call `_nc.render()?`, notcurses computes what changed since the last render and emits only the necessary terminal escape sequences to update the screen. This avoids flicker and is far more efficient than writing to the terminal directly.

The consequence: **no call to `putstr`, style change, or widget update is visible until you call `render()`.**

## When to Render

Call `render()` once after all updates for a frame are complete. Think of a frame as one logical visual state — draw everything that needs to change, then render once.

```pony
// Draw a frame: move a panel and update its content
_panel.move_yx(new_y, 0)?
_panel.output().putstr_yx("Updated content", 0, 0)?
_nc.render()?   // one render per frame, not one per operation
```

Calling `render()` after every `putstr()` is wasteful and can cause visible flickering on slow terminals. Batch all updates, then render.

## Automatic vs Explicit Rendering

The input polling loop renders automatically in one specific case: when a focused widget consumes an input event. The widget updates its internal display state (e.g., the selector moves the highlight), and `_poll_and_route()` calls `render()` after draining all pending input for that tick.

In all other cases — your own input handling, timer-driven updates, initial setup — you are responsible for calling `_nc.render()?` yourself.

```pony
be _initiate() =>
  try
    // Setup: you must render explicitly
    std.output().putstr("Hello")?
    _nc.render()?          // required, nothing shows without this
  end

be input_received(event: InputEvent) =>
  match event
  | let k: KeyEvent =>
    if k.codepoint == 114 then  // 'r' — refresh
      // Update something, then render explicitly
      _panel.erase()
      _panel.output().putstr("Refreshed")?
      try _nc.render()? end
    end
  end
```

## Two Color Systems

There are two ways to set colors, depending on what you are styling.

### PlaneStyleBuilder — for plane text

Use `plane.style()` to set colors and attributes for text written to a plane with `plane.output()`. This is the right tool for your own content: labels, status text, borders you draw manually.

```pony
// Red bold text on black background
plane.style().>bold().>fg(255, 0, 0).>bg(0, 0, 0).apply()?
plane.output().putstr("Error: something went wrong")?

// Reset to terminal defaults
plane.style().reset()
```

The cascade operator (`.>`) accumulates style changes on the same `PlaneStyleBuilder` object before calling `apply()`. After `apply()`, all subsequent text written to that plane uses those styles until changed.

`fg()` and `bg()` take `U8` components (0–255 each) for red, green, and blue.

### NcChannels — for widget colors

Widget constructors (`NotCursesSelector`, `NotCursesMultiselector`) take `U64` channel pair values for colors, not `PlaneStyleBuilder`. A channel pair packs a foreground channel (high 32 bits) and a background channel (low 32 bits), each encoding RGB and alpha.

Use `NcChannels` to build these values:

```pony
// One-step initializer: (fg_r, fg_g, fg_b, bg_r, bg_g, bg_b)
let green_on_black = NcChannels.initializer(0, 255, 0, 0, 0, 0)

// Incremental approach:
var channels: U64 = 0
channels = NcChannels.set_fg_rgb8(channels, 0, 255, 0)   // green foreground
channels = NcChannels.set_bg_rgb8(channels, 0, 0, 0)     // black background
```

Both produce the same result. `initializer()` is more concise when you know the colors upfront; `set_fg_rgb8`/`set_bg_rgb8` are cleaner when colors are computed separately.

Pass the result directly to widget constructors:

```pony
let op_colors = NcChannels.initializer(0, 255, 0, 0, 0, 0)
let desc_colors = NcChannels.initializer(200, 200, 200, 0, 0, 0)

_sel = NotCursesSelector(_nc, std, 2, 2, rows - 4, cols - 4, items
  where opchannels = op_colors, descchannels = desc_colors)?
```

`PlaneStyleBuilder` applies to plane text only. `NcChannels` applies to widget internal rendering only. They are separate systems for separate purposes.

---

See also: [Planes](planes.md), [Widgets](widgets.md), [Tutorial: Styling](../tutorial/03-styling.md).
