primitive NcReaderOption
  """
  Option flags for `NotCursesReader`. Combine with bitwise OR.
  """
  fun horscroll(): U64 =>
    """Enable horizontal scrolling when text exceeds the visible width."""
    0x0001
  fun verscroll(): U64 =>
    """Enable vertical scrolling for multi-line input."""
    0x0002
  fun nocmdkeys(): U64 =>
    """Disable command key interpretation (Ctrl+A, etc.)."""
    0x0004
  fun cursor(): U64 =>
    """Show the cursor in the reader widget."""
    0x0008


class NotCursesReader is InputWidget
  """
  A text input widget. Implements `InputWidget` — can be focused to receive keyboard input. Characters are typed into the reader; Escape and Enter are filtered out and not consumed (they pass through to `input_received`).

  Retrieve the entered text with `contents()`. Clear with `clear()`.

  Call `destroy()` before `NotCurses.stop()` to prevent double-free.
  """
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
    """Get the current text content of the reader."""
    // reader_contents returns malloc'd memory that must be freed
    recover val
      let ptr = NotCursesFFI.reader_contents(_ptr)
      if ptr.is_null() then
        String
      else
        let s = String.from_cstring(ptr).clone()
        @free(ptr)
        s
      end
    end

  fun ref clear()? =>
    """Clear all text from the reader."""
    if NotCursesFFI.reader_clear(_ptr) != 0 then error end

  fun ref _offer_input(ni: Ncinput): Bool =>
    // Let Escape and Enter fall through — ncreader consumes Escape but
    // doesn't use it, and the C reader is single-line only.
    if ni.id == 27 then return false end      // Escape
    if ni.id == 1115121 then return false end  // NCKEY_ENTER
    NotCursesFFI.reader_offer_input(_ptr, NullablePointer[Ncinput](ni))

  fun ref destroy() =>
    """Destroy the reader and its child plane."""
    if not _destroyed then
      _destroyed = true
      _nc.unfocus_if(this)
      NotCursesFFI.reader_destroy(_ptr)
    end

  fun _final() =>
    if not _destroyed then
      NotCursesFFI.reader_destroy(_ptr)
    end
