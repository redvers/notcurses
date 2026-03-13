class val SelectorItem
  let option: String val
  let desc: String val

  new val create(option': String val, desc': String val) =>
    option = option'
    desc = desc'


class NotCursesSelector is InputWidget
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
    maxdisplay: U32 = 4)?
  =>
    _nc = nc

    // Build C item array
    let c_items = Array[Ncselectoritem](items.size())
    for item in items.values() do
      let ci = Ncselectoritem
      ci.option = item.option.cstring()
      ci.desc = item.desc.cstring()
      c_items.push(consume ci)
      _items.push(SelectorItem(item.option, item.desc))
    end

    // Build options
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
    opts.items = c_items.cpointer()
    opts.defidx = defidx
    opts.maxdisplay = maxdisplay

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

  fun selected(): String val =>
    recover val
      let ptr = @ncselector_selected(_ptr)
      if ptr.is_null() then
        String
      else
        String.from_cstring(ptr).clone()
      end
    end

  fun ref add_item(option: String, desc: String)? =>
    var ci = Ncselectoritem
    ci.option = option.cstring()
    ci.desc = desc.cstring()
    if NotCursesFFI.selector_additem(_ptr,
      NullablePointer[Ncselectoritem](consume ci)) != 0 then error end
    _items.push(SelectorItem(option, desc))

  fun ref del_item(option: String)? =>
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
    recover val
      let ptr = @ncselector_nextitem(_ptr)
      if ptr.is_null() then
        String
      else
        String.from_cstring(ptr).clone()
      end
    end

  fun ref prev_item(): String val =>
    recover val
      let ptr = @ncselector_previtem(_ptr)
      if ptr.is_null() then
        String
      else
        String.from_cstring(ptr).clone()
      end
    end

  fun ref _offer_input(ni: Ncinput): Bool =>
    NotCursesFFI.selector_offer_input(_ptr, NullablePointer[Ncinput](ni))

  fun ref destroy() =>
    if not _destroyed then
      _destroyed = true
      _nc.unfocus_if(this)
      NotCursesFFI.selector_destroy(_ptr)
    end

  fun _final() =>
    if not _destroyed then
      NotCursesFFI.selector_destroy(_ptr)
    end
