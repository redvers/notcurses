use "../notcurses"

class QrcodeDemo is DemoRunner
  let _delay_ns: U64

  new create(delay_ns: U64) =>
    _delay_ns = delay_ns

  fun ref run(nc: Pointer[NcNotcurses]): I32 =>
    if not NotCursesFFI.canutf8(nc) then return 0 end

    (let stdn, let dimy, let dimx) = NotCursesFFI.stddim_yx(nc)
    NotCursesFFI.plane_erase(stdn)

    let n = NotCursesFFI.plane_dup(stdn, Pointer[None])
    if n.is_null() then return -1 end

    var data: Array[U8] iso = recover iso Array[U8].init(0, 128) end
    var i: I32 = 0
    while i < 1024 do
      NotCursesFFI.plane_erase(n)
      let len = (@rand() % 128).usize() + 1

      // Fill with random data
      var done: USize = 0
      while done < len do
        let r = @rand()
        try data(done)? = r.u8() end
        done = done + 1
      end

      NotCursesFFI.plane_home(n)
      NotCursesFFI.plane_home(n)
      (let qlen, let y, let x) = NotCursesFFI.plane_qrcode(n, dimy, dimx,
        data.cpointer(), len)
      if qlen > 0 then
        NotCursesFFI.plane_move_yx(n,
          ((dimy - y) / 2).i32(),
          ((dimx - x) / 2).i32())
        NotCursesFFI.plane_home(n)
        NotCursesFFI.plane_set_fg_rgb8(n,
          (@rand() % 255).u32() + 1,
          (@rand() % 255).u32() + 1,
          (@rand() % 255).u32() + 1)
        let ret = _DemoUtil.render(nc)
        if ret != 0 then
          NotCursesFFI.plane_destroy(n)
          return ret
        end
      end
      i = i + 1
    end
    NotCursesFFI.plane_mergedown_simple(n, stdn)
    NotCursesFFI.plane_destroy(n)
    0
