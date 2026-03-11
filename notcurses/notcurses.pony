class NotCurses
  var ptr: Pointer[NcNotcurses] tag = Pointer[NcNotcurses]
  var enclosing: (NotCursesActor | None)

  new none() =>
    enclosing = None

  new create(enc: NotCursesActor ref,
    termtype: (String | None) = None,
    loglevel: I32 = 0,
    margin_t: U32 = 0,
    margin_r: U32 = 0,
    margin_b: U32 = 0,
    margin_l: U32 = 0,
    flags: U64 = NcOption.suppress_banners()
  )? =>
    let options: Notcursesoptions = Notcursesoptions
    match termtype
    | let x: String => options.termtype = x.cstring()
    | let x: None   => options.termtype = Pointer[U8]
    end
    options.loglevel = loglevel
    options.margin_t = margin_t
    options.margin_r = margin_r
    options.margin_b = margin_b
    options.margin_l = margin_l
    options.flags = flags
    enclosing = enc

    ptr = NotCursesFFI.core_init(
      NullablePointer[Notcursesoptions](options), Pointer[CFile]
    )

    if (ptr.is_null()) then error end
    (enclosing as NotCursesActor)._initiate()

  fun stdplane(): NotCursesPlane =>
    NotCursesPlane.from_ptr(NotCursesFFI.stdplane(ptr))

  fun dim_yx(): (U32, U32) =>
    NotCursesFFI.term_dim_yx(ptr)

  fun render(): I32 =>
    """
    Renders and Rasterizes the default pile.
    """
    NotCursesFFI.render(ptr)

  fun can_true_color(): Bool =>
    NotCursesFFI.cantruecolor(ptr)

  fun can_utf8(): Bool =>
    NotCursesFFI.canutf8(ptr)





  fun stop(): I32 =>
    NotCursesFFI.stop(ptr)

