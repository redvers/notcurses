use "../../notcurses"
use "random"
use "time"

class iso SlidersDemo is TimerNotify
  let _main: Main tag
  let _nc: Pointer[NcNotcurses] tag
  let _delay_ns: U64
  var _rand: Rand
  var _n: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _chunks: Array[Pointer[NcPlaneT] tag]
  let _chunks_vert: U32 = 6
  let _chunks_horz: U32 = 12
  let _max_moves: U32 = 20
  var _chunkcount: USize = 0
  var _phase: U32 = 0  // 0=shuffle, 1=play
  var _si: USize = 0   // shuffle index
  // Play state
  var _play_m: U32 = 0
  var _play_moving: Bool = false
  var _play_chunk: Pointer[NcPlaneT] tag = Pointer[NcPlaneT]
  var _play_targy: I32 = 0
  var _play_targx: I32 = 0
  var _play_dy: I32 = 0
  var _play_dx: I32 = 0
  var _play_ui: U32 = 0
  var _play_units: U32 = 0
  var _play_newy: I32 = 0
  var _play_newx: I32 = 0
  var _play_mover: USize = 0
  var _hole: USize = 0
  var _holey: I32 = 0
  var _holex: I32 = 0
  var _lastdir: I32 = -1
  var _play_deadline_ns: U64 = 0
  var _play_step_ns: U64 = 0
  var _play_last_step_ns: U64 = 0
  var _ret: I32 = 0
  var _done: Bool = false

  new iso create(main: Main tag, nc: Pointer[NcNotcurses] tag, delay_ns: U64) =>
    _main = main
    _nc = nc
    _delay_ns = delay_ns
    _rand = Rand(Time.nanos())
    _chunks = Array[Pointer[NcPlaneT] tag]

    (let n, let maxy, let maxx) = NotCursesFFI.stddim_yx(nc)
    _n = n

    if (maxy < (_chunks_vert * 2)) or (maxx < (_chunks_horz * 2)) then
      _ret = -1
      _done = true
      return
    end
    var chunky = (maxy - 2) / _chunks_vert
    var chunkx = (maxx - 2) / _chunks_horz
    chunkx = chunkx - (chunkx % 2)
    if chunky > (chunkx + 1) then chunky = chunkx + 1 end
    if chunkx > (chunky * 2) then chunkx = chunky * 2 end

    let wastey = ((maxy - 2) - (_chunks_vert * chunky)) / 2
    let wastex = ((maxx - 2) - (_chunks_horz * chunkx)) / 2
    _chunkcount = (_chunks_vert * _chunks_horz).usize()
    _chunks = Array[Pointer[NcPlaneT] tag](_chunkcount)

    // Create all chunk planes
    var cy: U32 = 0
    while cy < _chunks_vert do
      var cx: U32 = 0
      while cx < _chunks_horz do
        let idx = ((cy * _chunks_horz) + cx).usize()
        var nopts = Ncplaneoptions
        nopts.y = ((cy * chunky) + wastey + 1).i32()
        nopts.x = ((cx * chunkx) + wastex + 1).i32()
        nopts.rows = chunky
        nopts.cols = chunkx
        let chunk = NotCursesFFI.plane_create(n,
          NullablePointer[Ncplaneoptions](consume nopts))
        if chunk.is_null() then
          _cleanup(_chunks)
          _ret = -1
          _done = true
          return
        end
        _chunks.push(chunk)
        if _fill_chunk(nc, chunk, idx, _chunks_horz) != 0 then
          _cleanup(_chunks)
          _ret = -1
          _done = true
          return
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
        (_chunks_vert * chunky) + wastey + 1,
        (_chunks_horz * chunkx) + wastex + 1, 0)
    else
      NcPlaneFFI.ascii_box(n, 0, channels,
        (_chunks_vert * chunky) + wastey + 1,
        (_chunks_horz * chunkx) + wastex + 1, 0)
    end
    _DemoUtil.render(nc)

  fun ref apply(timer: Timer, count: U64): Bool =>
    if _done then return false end

    match _phase
    | 0 => _do_shuffle()
    | 1 => _do_play()
    end
    _ret == 0

  fun ref cancel(timer: Timer) =>
    _cleanup(_chunks)
    _main.demo_finished(_ret)

  fun ref _do_shuffle() =>
    if _si >= 200 then
      // Transition to play phase
      _phase = 1
      _init_play()
      return
    end
    let i0 = _rand.int[USize](_chunkcount)
    var i1 = _rand.int[USize](_chunkcount)
    while i1 == i0 do
      i1 = _rand.int[USize](_chunkcount)
    end
    try
      (let y0, let x0) = NotCursesFFI.plane_yx(_chunks(i0)?)
      (let y1, let x1) = NotCursesFFI.plane_yx(_chunks(i1)?)
      NotCursesFFI.plane_move_yx(_chunks(i0)?, y1, x1)
      NotCursesFFI.plane_move_yx(_chunks(i1)?, y0, x0)
      let t = _chunks(i0)?
      _chunks(i0)? = _chunks(i1)?
      _chunks(i1)? = t
    end
    _DemoUtil.render(_nc)
    _si = _si + 1

  fun ref _init_play() =>
    let totalns = _delay_ns * 5
    _play_deadline_ns = Time.nanos() + totalns
    let movens = totalns / _max_moves.u64()
    _hole = _rand.int[USize](_chunkcount)
    try
      (_holey, _holex) = NotCursesFFI.plane_yx(_chunks(_hole)?)
      NotCursesFFI.plane_destroy(_chunks(_hole)?)
      _chunks(_hole)? = Pointer[NcPlaneT]
    end
    _play_m = 0
    _play_moving = false
    _lastdir = -1
    // Approximate step timing
    _play_step_ns = movens / 10

  fun ref _do_play() =>
    if _play_moving then
      // Check timing
      let now = Time.nanos()
      if now < (_play_last_step_ns + _play_step_ns) then return end

      _play_targy = _play_targy + _play_dy
      _play_targx = _play_targx + _play_dx
      NotCursesFFI.plane_move_yx(_play_chunk, _play_targy, _play_targx)
      _DemoUtil.render(_nc)
      _play_last_step_ns = now
      _play_ui = _play_ui + 1
      if _play_ui >= _play_units then
        // Move complete
        try
          _chunks(_hole)? = _chunks(_play_mover)?
          _chunks(_play_mover)? = Pointer[NcPlaneT]
          _hole = _play_mover
        end
        (_holey, _holex) = (_play_newy, _play_newx)
        _play_moving = false
        _play_m = _play_m + 1
      end
      return
    end

    // Start next move
    if (_play_m >= _max_moves) or (Time.nanos() >= _play_deadline_ns) then
      _ret = 0
      _done = true
      return
    end

    // Find a valid mover
    var mover: USize = _chunkcount
    var direction: I32 = 0
    while mover == _chunkcount do
      direction = _rand.int[U32](4).i32()
      match direction
      | 3 =>
        if (_lastdir != 1) and (_hole >= _chunks_horz.usize()) then
          mover = _hole - _chunks_horz.usize()
        end
      | 2 =>
        if (_lastdir != 0) and ((_hole % _chunks_horz.usize()) < (_chunks_horz.usize() - 1)) then
          mover = _hole + 1
        end
      | 1 =>
        if (_lastdir != 3) and (_hole < (_chunkcount - _chunks_horz.usize())) then
          mover = _hole + _chunks_horz.usize()
        end
      | 0 =>
        if (_lastdir != 2) and ((_hole % _chunks_horz.usize()) > 0) then
          mover = _hole - 1
        end
      end
    end
    _lastdir = direction
    _play_mover = mover

    try
      _play_chunk = _chunks(mover)?
      (let newy, let newx) = NotCursesFFI.plane_yx(_play_chunk)
      _play_newy = newy
      _play_newx = newx
      var dy = _holey - newy
      var dx = _holex - newx
      _play_units = if dy.abs() > dx.abs() then dy.abs() else dx.abs() end
      if _play_units == 0 then
        _play_m = _play_m + 1
        return
      end
      let totalns = _delay_ns * 5
      let movens = totalns / _max_moves.u64()
      _play_step_ns = movens / _play_units.u64()
      _play_dy = if dy < 0 then -1 elseif dy == 0 then 0 else 1 end
      _play_dx = if dx < 0 then -1 elseif dx == 0 then 0 else 1 end
      _play_targy = newy
      _play_targx = newx
      _play_ui = 0
      _play_moving = true
      _play_last_step_ns = Time.nanos()
    end

  fun ref _fill_chunk(nc: Pointer[NcNotcurses] tag, n: Pointer[NcPlaneT] tag,
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

  fun _cleanup(chunks: Array[Pointer[NcPlaneT] tag]) =>
    for chunk in chunks.values() do
      if not chunk.is_null() then
        NotCursesFFI.plane_destroy(chunk)
      end
    end
