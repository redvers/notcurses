use "../notcurses"
use @nanosleep[I32](req: Pointer[None] tag, rem: Pointer[None] tag)
use @srand[None](seed: U32)
use @rand[I32]()
use @clock_gettime[I32](clk: I32, ts: Pointer[None] tag)

interface DemoRunner
  fun ref run(nc: Pointer[NcNotcurses]): I32

actor Main
  let _env: Env

  new create(env: Env) =>
    _env = env
    let demos: Array[String val] val = [
      "qrcode"; "grid"; "highcon"; "sliders"; "animate"; "uniblock"
      "whiteout"; "reel"
    ]
    // Parse args: demo names to run, or "all"
    var selected: Array[String val] iso = recover iso Array[String val] end
    var delay_ns: U64 = 500_000_000 // 0.5s default
    var i: USize = 1
    let args = env.args
    while i < args.size() do
      try
        let arg = args(i)?
        if arg == "-d" then
          i = i + 1
          let d = args(i)?
          // Parse as float seconds
          delay_ns = (d.f64()? * 1_000_000_000).u64()
        elseif arg == "all" then
          for d in demos.values() do
            selected.push(d)
          end
        else
          selected.push(arg)
        end
      end
      i = i + 1
    end
    if selected.size() == 0 then
      for d in demos.values() do
        selected.push(d)
      end
    end

    // Seed RNG
    var ts: (I64, I64) = (0, 0)
    @clock_gettime(I32(1), addressof ts) // CLOCK_MONOTONIC
    @srand(ts._2.u32())

    // Init notcurses
    var opts = Notcursesoptions
    opts.flags = NcOption.suppress_banners()
    let nc = NotCursesFFI.core_init(
      NullablePointer[Notcursesoptions](consume opts), Pointer[CFile])
    if nc.is_null() then
      env.err.print("Failed to initialize notcurses")
      env.exitcode(1)
      return
    end

    let selected_val: Array[String val] val = consume selected
    var ret: I32 = 0
    for name in selected_val.values() do
      if ret != 0 then break end
      let runner: (DemoRunner | None) = match name
      | "qrcode" => QrcodeDemo(delay_ns)
      | "grid" => GridDemo(delay_ns)
      | "highcon" => HighconDemo(delay_ns)
      | "sliders" => SlidersDemo(delay_ns)
      | "animate" => AnimateDemo(delay_ns)
      | "uniblock" => UniblockDemo(delay_ns)
      | "whiteout" => WhiteoutDemo(delay_ns)
      | "reel" => ReelDemo(delay_ns)
      else
        env.err.print("Unknown demo: " + name)
        None
      end
      match runner
      | let r: DemoRunner =>
        ret = r.run(nc)
        if ret != 0 then
          env.err.print("Demo '" + name + "' failed: " + ret.string())
        end
      end
    end

    NotCursesFFI.stop(nc)
    if ret != 0 then
      env.exitcode(1)
    end

primitive _DemoUtil
  fun render(nc: Pointer[NcNotcurses]): I32 =>
    NotCursesFFI.render(nc)

  fun sleep_ns(ns: U64) =>
    var ts: (I64, I64) = ((ns / 1_000_000_000).i64(),
      (ns % 1_000_000_000).i64())
    @nanosleep(addressof ts, Pointer[None])

  fun clock_ns(): U64 =>
    var ts: (I64, I64) = (0, 0)
    @clock_gettime(I32(1), addressof ts) // CLOCK_MONOTONIC
    (ts._1.u64() * 1_000_000_000) + ts._2.u64()
