trait tag NotCursesResizeCallback
  """
  Trait for handling plane resize events.

  Implement `on_resize()` to respond when a plane is resized. Pass an instance wrapped in `ResizeCallbackWrapper` to `Ncplaneoptions` via the `userptr` field. Use `NullResizeCallback` when no resize handling is needed (the default).
  """
  fun tag _resize_callback() => on_resize()
  fun tag on_resize()
    """Called when the plane is resized. Override to handle resize events."""

actor NullResizeCallback is NotCursesResizeCallback
  """No-op resize callback. Used as the default when no resize handling is needed."""
  be on_resize() => None

class ResizeCallbackWrapper
  """Wraps a `NotCursesResizeCallback` for passing to `Ncplaneoptions.userptr`."""
  var cb: NotCursesResizeCallback
  new create(x: NotCursesResizeCallback) => cb = x
