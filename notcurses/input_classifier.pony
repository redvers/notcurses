primitive InputClassifier
  """
  Converts a raw Ncinput struct into a typed InputEvent.
  """
  fun _event_type(evtype: I32): InputEventType =>
    if evtype == NcInputType.press() then InputPress
    elseif evtype == NcInputType.release() then InputRelease
    elseif evtype == NcInputType.repeat_input() then InputRepeat
    else InputPress  // default for unknown
    end

  fun _is_mouse(id: U32): Bool =>
    // NCKEY_BUTTON1 = 1115201, NCKEY_BUTTON11 = 1115211
    (id >= 1115201) and (id <= 1115211)

  fun _is_resize(id: U32): Bool =>
    id == 1115001  // NCKEY_RESIZE = 1115000 + 1

  fun classify(ni: Ncinput): InputEvent =>
    let id = ni.id
    let evtype = _event_type(ni.evtype)

    if _is_resize(id) then
      ResizeEvent
    elseif _is_mouse(id) then
      MouseEvent(ni.y, ni.x, id, ni.modifiers, evtype)
    elseif id != 0 then
      KeyEvent(id, ni.modifiers, evtype)
    else
      UnknownEvent(ni.id, ni.y, ni.x, ni.evtype, ni.modifiers)
    end
