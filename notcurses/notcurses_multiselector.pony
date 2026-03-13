class val MultiselectorItem
  let option: String val
  let desc: String val
  let selected: Bool

  new val create(option': String val, desc': String val,
    selected': Bool = false)
  =>
    option = option'
    desc = desc'
    selected = selected'


class NotCursesMultiselector is InputWidget
  var _ptr: NullablePointer[NcMultiselector] tag =
    NullablePointer[NcMultiselector].none()
  var _nc: NotCurses = NotCurses.none()
  var _items: Array[MultiselectorItem] val =
    recover val Array[MultiselectorItem] end
  var _destroyed: Bool = false

  new none() =>
    None

  new create(nc: NotCurses, parent: NotCursesPlane, y: U32, x: U32,
    rows: U32, cols: U32, items: Array[MultiselectorItem] val,
    title: (String | None) = None,
    secondary: (String | None) = None,
    footer: (String | None) = None,
    maxdisplay: U32 = 4)?
  =>
    _nc = nc
    _items = items

    // Build C item array
    let c_items = Array[Ncmselectoritem](items.size())
    for item in items.values() do
      let ci = Ncmselectoritem
      ci.option = item.option.cstring()
      ci.desc = item.desc.cstring()
      ci.selected = item.selected
      c_items.push(consume ci)
    end

    // Build options
    var opts = Ncmultiselectoroptions
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
    opts.maxdisplay = maxdisplay

    // Create child plane
    let plane_opts = Ncplaneoptions(where
      y' = y.i32(), x' = x.i32(), rows' = rows, cols' = cols)
    let plane_result = NotCursesFFI.plane_create(parent.raw_ptr(),
      NullablePointer[Ncplaneoptions](plane_opts))
    if plane_result.is_none() then error end

    // Create multiselector widget
    let result = NotCursesFFI.multiselector_create(plane_result,
      NullablePointer[Ncmultiselectoroptions](consume opts))
    if result.is_none() then
      NotCursesFFI.plane_destroy(plane_result)
      error
    end
    _ptr = result

  fun ref selected(count: U32): Array[Bool] =>
    let arr = Array[Bool].init(false, count.usize())
    @ncmultiselector_selected(_ptr, arr.cpointer(), count)
    arr

  fun ref _offer_input(ni: Ncinput): Bool =>
    NotCursesFFI.multiselector_offer_input(_ptr, NullablePointer[Ncinput](ni))

  fun ref destroy() =>
    if not _destroyed then
      _destroyed = true
      _nc.unfocus_if(this)
      NotCursesFFI.multiselector_destroy(_ptr)
    end

  fun _final() =>
    if not _destroyed then
      NotCursesFFI.multiselector_destroy(_ptr)
    end
