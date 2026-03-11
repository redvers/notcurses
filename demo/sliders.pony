use "../notcurses"

class SlidersDemo is DemoRunner
  let _delay_ns: U64

  new create(delay_ns: U64) =>
    _delay_ns = delay_ns

  fun ref run(nc: Pointer[NcNotcurses]): I32 =>
    let chunks_vert: U32 = 6
    let chunks_horz: U32 = 12
    let moves: U32 = 20
    (let n, let maxy, let maxx) = NotCursesFFI.stddim_yx(nc)

    if (maxy < (chunks_vert * 2)) or (maxx < (chunks_horz * 2)) then
      return -1
    end
    var chunky = (maxy - 2) / chunks_vert
    var chunkx = (maxx - 2) / chunks_horz
    chunkx = chunkx - (chunkx % 2) // even width
    if chunky > (chunkx + 1) then chunky = chunkx + 1 end
    if chunkx > (chunky * 2) then chunkx = chunky * 2 end

    let wastey = ((maxy - 2) - (chunks_vert * chunky)) / 2
    let wastex = ((maxx - 2) - (chunks_horz * chunkx)) / 2
    let chunkcount = (chunks_vert * chunks_horz).usize()
    var chunks = Array[Pointer[NcPlaneT]](chunkcount)

    // Create all chunk planes
    var cy: U32 = 0
    while cy < chunks_vert do
      var cx: U32 = 0
      while cx < chunks_horz do
        let idx = ((cy * chunks_horz) + cx).usize()
        var nopts = Ncplaneoptions
        nopts.y = ((cy * chunky) + wastey + 1).i32()
        nopts.x = ((cx * chunkx) + wastex + 1).i32()
        nopts.rows = chunky
        nopts.cols = chunkx
        let chunk = NotCursesFFI.plane_create(n,
          NullablePointer[Ncplaneoptions](consume nopts))
        if chunk.is_null() then
          _cleanup(chunks)
          return -1
        end
        chunks.push(chunk)
        if _fill_chunk(nc, chunk, idx, chunks_horz) != 0 then
          _cleanup(chunks)
          return -1
        end
        cx = cx + 1
      end
      cy = cy + 1
    end

    // Draw bounding box
    NotCursesFFI.plane_cursor_move_yx(n, wastey.i32(), wastex.i32())
    var channels: U64 = 0
    channels = NcChannels.set_fg_rgb8(channels, 180, 80, 180)
    if NotCursesFFI.canutf8(nc) then
      NcPlaneFFI.rounded_box(n, 0, channels,
        (chunks_vert * chunky) + wastey + 1,
        (chunks_horz * chunkx) + wastex + 1, 0)
    else
      NcPlaneFFI.ascii_box(n, 0, channels,
        (chunks_vert * chunky) + wastey + 1,
        (chunks_horz * chunkx) + wastex + 1, 0)
    end
    _DemoUtil.render(nc)

    // Shuffle
    _DemoUtil.sleep_ns(_delay_ns)
    var si: USize = 0
    while si < 200 do
      let i0 = (@rand().usize()) % chunkcount
      var i1 = (@rand().usize()) % chunkcount
      while i1 == i0 do
        i1 = (@rand().usize()) % chunkcount
      end
      try
        (let y0, let x0) = NotCursesFFI.plane_yx(chunks(i0)?)
        (let y1, let x1) = NotCursesFFI.plane_yx(chunks(i1)?)
        NotCursesFFI.plane_move_yx(chunks(i0)?, y1, x1)
        NotCursesFFI.plane_move_yx(chunks(i1)?, y0, x0)
        let t = chunks(i0)?
        chunks(i0)? = chunks(i1)?
        chunks(i1)? = t
      end
      _DemoUtil.render(nc)
      si = si + 1
    end

    // Play sliding puzzle
    let ret = _play(nc, chunks, chunkcount, chunks_vert, chunks_horz, moves)
    _cleanup(chunks)
    ret

  fun ref _fill_chunk(nc: Pointer[NcNotcurses], n: Pointer[NcPlaneT],
    idx: USize, chunks_horz: U32): I32
  =>
    let hidx = (idx % chunks_horz.usize()).u32()
    let vidx = (idx / chunks_horz.usize()).u32()
    (let my, let mx) = NotCursesFFI.plane_dim_yx(n)
    var channels: U64 = 0
    let r = 64 + (hidx * 10)
    let b = 64 + (vidx * 30)
    let g = 225 - ((hidx + vidx) * 12)
    channels = NcChannels.set_fg_rgb8(channels, r, g, b)
    var ul: U32 = 0
    var ur: U32 = 0
    var ll: U32 = 0
    var lr: U32 = 0
    ul = NcChannel.set_rgb8(ul, r, g, b)
    lr = NcChannel.set_rgb8(lr, r, g, b)
    ur = NcChannel.set_rgb8(ur, g, b, r)
    ll = NcChannel.set_rgb8(ll, b, r, g)
    if NotCursesFFI.canutf8(nc) then
      if NotCursesFFI.plane_gradient2x1(n, -1, -1, 0, 0, ul, ur, ll, lr) <= 0 then
        return -1
      end
      NcPlaneFFI.double_box(n, 0, channels, my - 1, mx - 1, 0)
    else
      if NotCursesFFI.plane_gradient(n, -1, -1, 0, 0, " ".cpointer(), 0,
        ul.u64(), ur.u64(), ll.u64(), lr.u64()) <= 0
      then
        return -1
      end
      NcPlaneFFI.ascii_box(n, 0, channels, my - 1, mx - 1, 0)
    end
    if (mx >= 4) and (my >= 3) then
      let label: String val = (idx + 1).string()
      let padded: String val = if label.size() < 2 then "0" + label else label end
      NcPlaneFFI.putstr_yx(n, ((my - 1) / 2).i32(), ((mx - 1) / 2).i32(), padded)
    end
    0

  fun ref _play(nc: Pointer[NcNotcurses], chunks: Array[Pointer[NcPlaneT]],
    chunkcount: USize, chunks_vert: U32, chunks_horz: U32, max_moves: U32): I32
  =>
    let totalns = _delay_ns * 5
    let startns = _DemoUtil.clock_ns()
    let deadline_ns = startns + totalns
    let movens = totalns / max_moves.u64()
    var hole = (@rand().usize()) % chunkcount
    var holey: I32 = 0
    var holex: I32 = 0
    try
      (holey, holex) = NotCursesFFI.plane_yx(chunks(hole)?)
      NotCursesFFI.plane_destroy(chunks(hole)?)
      chunks(hole)? = Pointer[NcPlaneT]
    end
    var lastdir: I32 = -1
    var m: U32 = 0
    while m < max_moves do
      let now = _DemoUtil.clock_ns()
      if now >= deadline_ns then break end
      var mover: USize = chunkcount
      var direction: I32 = 0
      while mover == chunkcount do
        direction = @rand() % 4
        match direction
        | 3 => // up
          if (lastdir != 1) and (hole >= chunks_horz.usize()) then
            mover = hole - chunks_horz.usize()
          end
        | 2 => // right
          if (lastdir != 0) and ((hole % chunks_horz.usize()) < (chunks_horz.usize() - 1)) then
            mover = hole + 1
          end
        | 1 => // down
          if (lastdir != 3) and (hole < (chunkcount - chunks_horz.usize())) then
            mover = hole + chunks_horz.usize()
          end
        | 0 => // left
          if (lastdir != 2) and ((hole % chunks_horz.usize()) > 0) then
            mover = hole - 1
          end
        end
      end
      lastdir = direction
      try
        let err = _move_square(nc, chunks(mover)?, holey, holex, movens)
        holey = err._1
        holex = err._2
        if err._3 != 0 then return err._3 end
        chunks(hole)? = chunks(mover)?
        chunks(mover)? = Pointer[NcPlaneT]
        hole = mover
      end
      m = m + 1
    end
    0

  fun ref _move_square(nc: Pointer[NcNotcurses], chunk: Pointer[NcPlaneT],
    holey: I32, holex: I32, movens: U64): (I32, I32, I32)
  =>
    // Returns (new_holey, new_holex, error)
    (let newy', let newx') = NotCursesFFI.plane_yx(chunk)
    var newy = newy'
    var newx = newx'
    var dy = holey - newy
    var dx = holex - newx
    let units: U32 = if dy.abs() > dx.abs() then dy.abs() else dx.abs() end
    if units == 0 then return (newy, newx, 0) end
    let step_ns = movens / units.u64()
    dy = if dy < 0 then -1 elseif dy == 0 then 0 else 1 end
    dx = if dx < 0 then -1 elseif dx == 0 then 0 else 1 end
    var targy = newy
    var targx = newx
    var ui: U32 = 0
    while ui < units do
      targy = targy + dy
      targx = targx + dx
      NotCursesFFI.plane_move_yx(chunk, targy, targx)
      _DemoUtil.render(nc)
      _DemoUtil.sleep_ns(step_ns)
      ui = ui + 1
    end
    (newy, newx, 0)

  fun _cleanup(chunks: Array[Pointer[NcPlaneT]]) =>
    for chunk in chunks.values() do
      if not chunk.is_null() then
        NotCursesFFI.plane_destroy(chunk)
      end
    end
