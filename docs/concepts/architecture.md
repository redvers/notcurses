# Architecture

This page explains how the three layers of the notcurses Pony binding fit together, and why the design is the way it is.

## Three Layers

The library has three layers. You work primarily with the middle one.

**FFI primitives** (`NotCursesFFI`, `NcPlaneFFI`) are package-internal C bindings. They declare the raw FFI calls to `libnotcurses-core` and reimplement inline C header functions that cannot be linked directly. You never call these. They are the mechanism, not the API.

**Wrapper classes** (`NotCurses`, `NotCursesPlane`, widget classes) are the Pony-native API. They own C pointers, manage lifetime, route input, and expose operations through a safe interface. This is what you use.

**Your actor** hosts everything. A Pony actor that implements `NotCursesActor` embeds `NotCurses` directly, sets up planes and widgets in `_initiate()`, and handles input in `input_received()`. The actor is where your application logic lives.

## Why Embedding

`NotCurses` is a `ref` class, not an actor. It must live inside your actor, embedded as a field — not passed around, not shared.

This is a direct consequence of Pony's reference capability system. A `ref` value has a single mutable owner. You cannot send it across actor boundaries (that would require `iso`), and you cannot share it immutably (that would require `val`, which forbids mutation). Neither fits: you need ongoing mutable access to the terminal throughout your actor's life.

By embedding `NotCurses` inside your actor, every call to render, every input poll, every plane operation runs in the context of a single actor behavior. Pony actors execute one behavior at a time. This serializes all terminal access without locks, by design.

## The `NotCursesActor` Trait

Pony has no class inheritance. `NotCursesActor` is a trait — a named set of methods your actor promises to provide. The library uses this trait to call back into your actor from the polling timer.

The trait defines four required methods:

**`fun ref _notcurses(): NotCurses`** — returns the embedded `NotCurses` instance. Called internally by the input polling system (`_poll_input` behavior) to access the terminal. You implement this as a one-liner: `fun ref _notcurses(): NotCurses => _nc`.

**`be _initiate()`** — called by `NotCurses.create()` as a behavior (not synchronously). By the time it runs, the terminal is fully initialized and the input timer is running. Do all setup here: create planes, create widgets, do the initial render. Do not do setup work in your actor's constructor — the terminal is not ready yet.

**`be input_received(event: InputEvent)`** — called for each input event that is not consumed by a focused widget. Pattern match on the `InputEvent` union to handle key events, mouse events, and resize events. See [Input](input.md) for details.

**`be _exit()`** — a user-provided cleanup hook. The library does not call it automatically. Call it from your own code after `stop()` if you need to perform post-TUI cleanup (e.g., printing a result to stdout). You can leave it as `None` if you have nothing to do.

## The `none()` Constructor Pattern

Pony requires every field to be initialized before the constructor returns. Since `NotCurses.create()` is partial (it can fail), you cannot simply write:

```pony
actor MyApp is NotCursesActor
  var _nc: NotCurses

  new create(env: Env) =>
    _nc = NotCurses(this)?  // error: field not initialized before potential error
```

The solution is the `none()` constructor pattern. Both `NotCurses` and `NotCursesPlane` provide a `none()` constructor that creates a safe, inert default value. Initialize fields with `none()`, then assign the real value in a `try` block:

```pony
actor MyApp is NotCursesActor
  var _nc: NotCurses = NotCurses.none()

  new create(env: Env) =>
    try
      _nc = NotCurses(this)?
    else
      env.out.print("Failed to initialize notcurses")
    end
```

This pattern extends to any field that holds a widget or plane that cannot be created until `_initiate()` runs:

```pony
actor MyApp is NotCursesActor
  var _nc: NotCurses = NotCurses.none()
  var _content: NotCursesPlane = NotCursesPlane.none()
  var _sel: NotCursesSelector = NotCursesSelector.none()
```

## Lifecycle

The full lifecycle of a TUI application:

1. **Constructor** — `NotCurses.none()` initializes fields. `NotCurses(this)?` initializes the terminal and starts the input polling timer. `_initiate()` is queued as a behavior.

2. **`_initiate()` behavior** — runs after construction completes. Create planes, widgets, apply styles, call `_nc.render()?` to show the initial frame.

3. **Input loop** — the polling timer fires every 10ms (by default). Each tick calls `_poll_input()` on your actor, which calls `_poll_and_route()`. Input events are dispatched to the focused widget or your `input_received()` behavior.

4. **`stop()`** — called from your input handler when the user quits. Cancels the polling timer, restores the terminal. Call `widget.destroy()` on all widgets before calling `stop()`.

5. **Terminal restored** — the process can print to stdout normally again. Call `_exit()` if you have post-TUI work to do.

---

See also: [Planes](planes.md), [Input](input.md), [Tutorial: Hello World](../tutorial/01-hello-world.md).
