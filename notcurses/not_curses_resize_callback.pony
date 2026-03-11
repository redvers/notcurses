trait tag NotCursesResizeCallback
  fun tag _resize_callback() => on_resize()
  fun tag on_resize()

actor NullResizeCallback is NotCursesResizeCallback
  be on_resize() => None

class ResizeCallbackWrapper
  var cb: NotCursesResizeCallback
  new create(x: NotCursesResizeCallback) => cb = x
