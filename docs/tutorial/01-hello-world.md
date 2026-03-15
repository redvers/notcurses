# Tutorial 1: Hello World

In this tutorial you will build a minimal TUI application that displays text on the terminal and quits when you press 'q'. This establishes the core pattern every notcurses Pony application follows.

## Prerequisites

Install the notcurses core library. On Debian/Ubuntu:

```sh
sudo apt install libnotcurses-core-dev
```

Add the notcurses Pony package as a dependency using corral:

```sh
corral add github.com/redvers/notcurses.git
corral fetch
```

Verify the library is linkable by building one of the bundled examples before proceeding.

## The Complete Program

Create a file `main.pony` with the following content:

```pony
use "notcurses"

actor Main
  new create(env: Env) =>
    HelloApp(env)

actor HelloApp is NotCursesActor
  var _env: Env
  var _nc: NotCurses = NotCurses.none()

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
      std.output().putstr("Hello from notcurses! Press 'q' to quit.")?
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

Build and run:

```sh
corral run -- ponyc -o build && ./build/hello
```

You should see your message on a blank terminal. Press 'q' to exit cleanly back to your shell.

## How It Works

### The Actor and Trait

```pony
actor HelloApp is NotCursesActor
```

Your TUI application is a Pony actor that implements the `NotCursesActor` trait. The trait defines the contract between your application and the notcurses library: it tells the library how to call back into your actor for initialization and input delivery.

Pony actors execute one behavior at a time, which serializes all terminal access without locks. This is why `NotCurses` is embedded inside your actor rather than passed around -- see [Architecture](../concepts/architecture.md) for the full rationale.

### Field Initialization with `none()`

```pony
var _nc: NotCurses = NotCurses.none()
```

Pony requires every field to have a value before the constructor returns. Since `NotCurses(this)?` is partial (it can fail), you cannot assign it directly without handling the error path. The `none()` constructor creates a safe, inert default. You then assign the real value inside a `try` block:

```pony
new create(env: Env) =>
  _env = env
  try
    _nc = NotCurses(this)?
  else
    env.out.print("Failed to initialize notcurses")
  end
```

This pattern extends to every field that holds a plane, widget, or other object that cannot be created until later. You will see it throughout the tutorial series.

### Why `_initiate()`, Not the Constructor

```pony
be _initiate() =>
  try
    let std = _nc.stdplane()
    std.output().putstr("Hello from notcurses! Press 'q' to quit.")?
    _nc.render()?
  end
```

`_initiate()` is a behavior, not a function. It runs asynchronously after `NotCurses(this)?` completes. By the time `_initiate()` executes, the terminal is fully initialized and the input polling timer is already running.

Do all setup work here: create planes, configure styles, write initial content, and call `render()`. Do not do terminal work in the constructor -- the terminal is not ready during construction.

### The Standard Plane

`_nc.stdplane()` returns the standard plane, which covers the entire terminal. It is the root of the plane hierarchy. You use it to draw background content, borders, or as a parent for child planes. You cannot destroy it -- it is destroyed automatically when `_nc.stop()` is called.

### Rendering

`_nc.render()?` pushes all accumulated plane content to the terminal screen. Nothing you write to a plane is visible until you render. Call it once after completing all updates for a frame.

### Input Handling

```pony
be input_received(event: InputEvent) =>
  match event
  | let k: KeyEvent =>
    if k.codepoint == 'q' then
      try _nc.stop()? end
    end
  end
```

The library polls for input on a timer (every 10ms by default). When input arrives, it is classified into typed events and delivered to your `input_received()` behavior. Pattern match on the `InputEvent` union to handle different event types.

Pony character literals like `'q'` work directly in equality comparisons with `U32` values. Note that `'q'.u32()` method calls do not work in match case patterns — but simple comparisons with `==` are fine.

### Shutting Down

`_nc.stop()?` cancels the input polling timer and restores the terminal to its original state. After this call, the process can print to stdout normally. The `_exit()` behavior is available for any post-TUI cleanup, though this example has nothing to clean up.

### The `_notcurses()` Function

```pony
fun ref _notcurses(): NotCurses => _nc
```

This one-liner is required by the `NotCursesActor` trait. The input polling system calls it internally to access the embedded `NotCurses` instance. You do not call it yourself.

## Error Handling

In `_initiate()` and `input_received()`, the `try...end` blocks swallow errors silently. For a quick demo this is fine, but in a real application you should handle failures:

```pony
be _initiate() =>
  try
    let std = _nc.stdplane()
    std.output().putstr("Hello from notcurses!")?
    _nc.render()?
  else
    try _nc.stop()? end
    _env.out.print("Setup failed")
  end
```

The general pattern for fatal errors: stop notcurses to restore the terminal, then report the error to stdout.

## The Lifecycle Sequence

To summarize the full lifecycle:

1. **Constructor** -- `NotCurses.none()` initializes the field. `NotCurses(this)?` initializes the terminal and starts input polling. `_initiate()` is queued.
2. **`_initiate()`** -- create planes, apply styles, write content, render.
3. **Input loop** -- the polling timer delivers events to `input_received()`.
4. **`stop()`** -- called from your input handler. Restores the terminal.
5. **Post-TUI** -- call `_exit()` if needed for cleanup.

---

Next: [Planes and Layout](02-planes-and-layout.md) -- divide the terminal into regions with child planes.

See also: [Architecture](../concepts/architecture.md).
