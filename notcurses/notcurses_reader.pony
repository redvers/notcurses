primitive NcReaderOption
  fun horscroll(): U64 => 0x0001
  fun verscroll(): U64 => 0x0002
  fun nocmdkeys(): U64 => 0x0004
  fun cursor(): U64 => 0x0008


class NotCursesReader is InputWidget
  var _ptr: NullablePointer[NcReader] tag = NullablePointer[NcReader].none()
  var _nc: NotCurses = NotCurses.none()
  var _destroyed: Bool = false

  new none() =>
    None

  new create(nc: NotCurses, parent: NotCursesPlane, y: U32, x: U32,
    rows: U32, cols: U32, flags: U64 = 0)?
  =>
    _nc = nc

    var opts = Ncreaderoptions
    opts.flags = flags

    // Create child plane
    let plane_opts = Ncplaneoptions(where
      y' = y.i32(), x' = x.i32(), rows' = rows, cols' = cols)
    let plane_result = NotCursesFFI.plane_create(parent.raw_ptr(),
      NullablePointer[Ncplaneoptions](plane_opts))
    if plane_result.is_none() then error end

    // Create reader widget
    let result = NotCursesFFI.reader_create(plane_result,
      NullablePointer[Ncreaderoptions](consume opts))
    if result.is_none() then
      NotCursesFFI.plane_destroy(plane_result)
      error
    end
    _ptr = result

  fun ref contents(): String val =>
    // reader_contents returns malloc'd memory that must be freed
    recover val
      let ptr = @ncreader_contents(_ptr)
      if ptr.is_null() then
        String
      else
        let s = String.from_cstring(ptr).clone()
        @free(ptr)
        s
      end
    end

  fun ref clear()? =>
    if NotCursesFFI.reader_clear(_ptr) != 0 then error end

  fun ref _offer_input(ni: Ncinput): Bool =>
    NotCursesFFI.reader_offer_input(_ptr, NullablePointer[Ncinput](ni))

  fun ref destroy() =>
    if not _destroyed then
      _destroyed = true
      _nc.unfocus_if(this)
      NotCursesFFI.reader_destroy(_ptr)
    end

  fun _final() =>
    if not _destroyed then
      NotCursesFFI.reader_destroy(_ptr)
    end
