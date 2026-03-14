class val SelectorItem
  """
  An item in a selector widget. Each item has an option string (displayed in the selection list) and a description string (shown alongside it).
  """
  let option: String val
  let desc: String val

  new val create(option': String val, desc': String val) =>
    option = option'
    desc = desc'


class NotCursesSelector is InputWidget
  """
  A single-selection menu widget. Implements `InputWidget` — can be focused to receive keyboard input (arrow keys to navigate, Enter to confirm).

  Creates and manages its own child plane. Use `NcChannels.initializer()` or `NcChannels.set_fg_rgb8()` / `NcChannels.set_bg_rgb8()` to build the `opchannels` and `descchannels` color values.

  Call `destroy()` before `NotCurses.stop()` to prevent double-free.
  """
  var _ptr: NullablePointer[NcSelector] tag = NullablePointer[NcSelector].none()
  var _nc: NotCurses = NotCurses.none()
  var _items: Array[SelectorItem] = Array[SelectorItem]
  var _destroyed: Bool = false

  new none() =>
    None

  new create(nc: NotCurses, parent: NotCursesPlane, y: U32, x: U32,
    rows: U32, cols: U32, items: Array[SelectorItem] val,
    title: (String | None) = None,
    secondary: (String | None) = None,
    footer: (String | None) = None,
    defidx: U32 = 0,
    maxdisplay: U32 = 4,
    opchannels: U64 = 0,
    descchannels: U64 = 0)?
  =>
    _nc = nc

    // Build options (no items — add them after creation via additem)
    var opts = Ncselectoroptions
    match title
    | let s: String => opts.title = s.cstring()
    end
    match secondary
    | let s: String => opts.secondary = s.cstring()
    end
    match footer
    | let s: String => opts.footer = s.cstring()
    end
    opts.defidx = defidx
    opts.maxdisplay = maxdisplay
    opts.opchannels = opchannels
    opts.descchannels = descchannels

    // Create child plane
    let plane_opts = Ncplaneoptions(where
      y' = y.i32(), x' = x.i32(), rows' = rows, cols' = cols)
    let plane_result = NotCursesFFI.plane_create(parent.raw_ptr(),
      NullablePointer[Ncplaneoptions](plane_opts))
    if plane_result.is_none() then error end

    // Create selector widget
    let result = NotCursesFFI.selector_create(plane_result,
      NullablePointer[Ncselectoroptions](consume opts))
    if result.is_none() then
      NotCursesFFI.plane_destroy(plane_result)
      error
    end
    _ptr = result

    // Add items after creation via ncselector_additem
    for item in items.values() do
      try add_item(item.option, item.desc)? end
    end

  fun selected(): String val =>
    """Get the currently selected option string."""
    recover val
      let ptr = NotCursesFFI.selector_selected(_ptr)
      if ptr.is_null() then
        String
      else
        String.from_cstring(ptr).clone()
      end
    end

  fun ref add_item(option: String, desc: String)? =>
    """Add a new item to the selector."""
    var ci = Ncselectoritem
    ci.option = option.cstring()
    ci.desc = desc.cstring()
    if NotCursesFFI.selector_additem(_ptr,
      NullablePointer[Ncselectoritem](consume ci)) != 0 then error end
    _items.push(SelectorItem(option, desc))

  fun ref del_item(option: String)? =>
    """Remove an item by its option string."""
    if NotCursesFFI.selector_delitem(_ptr, option.cstring()) != 0 then
      error
    end
    var i: USize = 0
    while i < _items.size() do
      try
        if _items(i)?.option == option then
          _items.delete(i)?
          break
        end
      end
      i = i + 1
    end

  fun ref next_item(): String val =>
    """Navigate to the next item. Returns the newly selected option string."""
    recover val
      let ptr = NotCursesFFI.selector_nextitem(_ptr)
      if ptr.is_null() then
        String
      else
        String.from_cstring(ptr).clone()
      end
    end

  fun ref prev_item(): String val =>
    """Navigate to the previous item. Returns the newly selected option string."""
    recover val
      let ptr = NotCursesFFI.selector_previtem(_ptr)
      if ptr.is_null() then
        String
      else
        String.from_cstring(ptr).clone()
      end
    end

  fun ref _offer_input(ni: Ncinput): Bool =>
    NotCursesFFI.selector_offer_input(_ptr, NullablePointer[Ncinput](ni))

  fun ref destroy() =>
    """Destroy the selector and its child plane."""
    if not _destroyed then
      _destroyed = true
      _nc.unfocus_if(this)
      NotCursesFFI.selector_destroy(_ptr)
    end

  fun _final() =>
    if not _destroyed then
      NotCursesFFI.selector_destroy(_ptr)
    end
