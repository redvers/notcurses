

/*
  Source: /usr/include/x86_64-linux-gnu/bits/types.h:155
  Original Name: 
  Struct Size (bits):  64
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [ArrayType size=(0-1)]->[FundamentalType(int) size=32] -- UNSUPPORTED - FIXME: __val  
*/
struct Anon42
  var ___val: Pointer[I32] = Pointer[I32]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_tm.h:7
  Original Name: tm
  Struct Size (bits):  448
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: tm_sec  
     000032: [FundamentalType(int) size=32]: tm_min  
     000064: [FundamentalType(int) size=32]: tm_hour  
     000096: [FundamentalType(int) size=32]: tm_mday  
     000128: [FundamentalType(int) size=32]: tm_mon  
     000160: [FundamentalType(int) size=32]: tm_year  
     000192: [FundamentalType(int) size=32]: tm_wday  
     000224: [FundamentalType(int) size=32]: tm_yday  
     000256: [FundamentalType(int) size=32]: tm_isdst  
     000320: [FundamentalType(long int) size=64]: tm_gmtoff  
     000384: [PointerType size=64]->[FundamentalType(char) size=8]: tm_zone  
*/
struct Tm
  var _tm_sec: I32 = I32(0)
  var _tm_min: I32 = I32(0)
  var _tm_hour: I32 = I32(0)
  var _tm_mday: I32 = I32(0)
  var _tm_mon: I32 = I32(0)
  var _tm_year: I32 = I32(0)
  var _tm_wday: I32 = I32(0)
  var _tm_yday: I32 = I32(0)
  var _tm_isdst: I32 = I32(0)
  var _tm_gmtoff: I64 = I64(0)
  var _tm_zone: Pointer[U8] = Pointer[U8]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_timespec.h:11
  Original Name: timespec
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long int) size=64]: tv_sec  
     000064: [FundamentalType(long int) size=64]: tv_nsec  
*/
struct Timespec
  var _tv_sec: I64 = I64(0)
  var _tv_nsec: I64 = I64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_itimerspec.h:8
  Original Name: itimerspec
  Struct Size (bits):  256
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [Struct size=128,fid: f6]: it_interval  
     000128: [Struct size=128,fid: f6]: it_value  
*/
struct Itimerspec
  var _it_interval: Timespec = Timespec
  var _it_value: Timespec = Timespec


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/sigevent_t.h:22
  Original Name: sigevent
  Struct Size (bits):  512
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [UNION size=64] -- UNSUPPORTED FIXME: sigev_value  
     000064: [FundamentalType(int) size=32]: sigev_signo  
     000096: [FundamentalType(int) size=32]: sigev_notify  
     000128: [UNION size=384] -- UNSUPPORTED FIXME: _sigev_un  
*/
struct Sigevent
  var _sigev_value: None = None
  var _sigev_signo: I32 = I32(0)
  var _sigev_notify: I32 = I32(0)
  var __sigev_un: None = None


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/__locale_t.h:27
  Original Name: __locale_struct
  Struct Size (bits):  1856
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [ArrayType size=(0-12)]->[PointerType size=64]->[Struct size=,fid: f12] -- UNSUPPORTED - FIXME: __locales  
     000832: [PointerType size=64]->[FundamentalType(short unsigned int) size=16]: __ctype_b  
     000896: [PointerType size=64]->[FundamentalType(int) size=32]: __ctype_tolower  
     000960: [PointerType size=64]->[FundamentalType(int) size=32]: __ctype_toupper  
     001024: [ArrayType size=(0-12)]->[PointerType size=64]->[FundamentalType(char) size=8] -- UNSUPPORTED - FIXME: __names  
*/
struct Localestruct
  var ___locales: Pointer[NullablePointer[Localedata]] = Pointer[NullablePointer[Localedata]]
  var ___ctype_b: Pointer[U16] = Pointer[U16]
  var ___ctype_tolower: Pointer[I32] = Pointer[I32]
  var ___ctype_toupper: Pointer[I32] = Pointer[I32]
  var ___names: Pointer[String] = Pointer[String]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/__mbstate_t.h:13
  Original Name: 
  Struct Size (bits):  64
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: __count  
     000032: [UNION size=32] -- UNSUPPORTED FIXME: __value  
*/
struct Anon169
  var ___count: I32 = I32(0)
  var ___value: None = None


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h:49
  Original Name: _IO_FILE
  Struct Size (bits):  1728
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: _flags  
     000064: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_read_ptr  
     000128: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_read_end  
     000192: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_read_base  
     000256: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_write_base  
     000320: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_write_ptr  
     000384: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_write_end  
     000448: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_buf_base  
     000512: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_buf_end  
     000576: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_save_base  
     000640: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_backup_base  
     000704: [PointerType size=64]->[FundamentalType(char) size=8]: _IO_save_end  
     000768: [PointerType size=64]->[Struct size=,fid: f21]: _markers  
     000832: [PointerType size=64]->[Struct size=1728,fid: f21]: _chain  
     000896: [FundamentalType(int) size=32]: _fileno  
     000928: [FundamentalType(int) size=32]: _flags2  
     000960: [FundamentalType(long int) size=64]: _old_offset  
     001024: [FundamentalType(short unsigned int) size=16]: _cur_column  
     001040: [FundamentalType(signed char) size=8]: _vtable_offset  
     001048: [ArrayType size=(0-0)]->[FundamentalType(char) size=8] -- UNSUPPORTED - FIXME: _shortbuf  
     001088: [PointerType size=64]->[FundamentalType(void) size=0]: _lock  
     001152: [FundamentalType(long int) size=64]: _offset  
     001216: [PointerType size=64]->[Struct size=,fid: f21]: _codecvt  
     001280: [PointerType size=64]->[Struct size=,fid: f21]: _wide_data  
     001344: [PointerType size=64]->[Struct size=1728,fid: f21]: _freeres_list  
     001408: [PointerType size=64]->[FundamentalType(void) size=0]: _freeres_buf  
     001472: [FundamentalType(long unsigned int) size=64]: __pad5  
     001536: [FundamentalType(int) size=32]: _mode  
     001568: [ArrayType size=(0-19)]->[FundamentalType(char) size=8] -- UNSUPPORTED - FIXME: _unused2  
*/
struct IOFILE
  var __flags: I32 = I32(0)
  var __IO_read_ptr: Pointer[U8] = Pointer[U8]
  var __IO_read_end: Pointer[U8] = Pointer[U8]
  var __IO_read_base: Pointer[U8] = Pointer[U8]
  var __IO_write_base: Pointer[U8] = Pointer[U8]
  var __IO_write_ptr: Pointer[U8] = Pointer[U8]
  var __IO_write_end: Pointer[U8] = Pointer[U8]
  var __IO_buf_base: Pointer[U8] = Pointer[U8]
  var __IO_buf_end: Pointer[U8] = Pointer[U8]
  var __IO_save_base: Pointer[U8] = Pointer[U8]
  var __IO_backup_base: Pointer[U8] = Pointer[U8]
  var __IO_save_end: Pointer[U8] = Pointer[U8]
  var __markers: NullablePointer[IOmarker] = NullablePointer[IOmarker].none()
  var __chain: NullablePointer[IOFILE] = NullablePointer[IOFILE].none()
  var __fileno: I32 = I32(0)
  var __flags2: I32 = I32(0)
  var __old_offset: I64 = I64(0)
  var __cur_column: U16 = U16(0)
  var __vtable_offset: I8 = I8(0)
  var __shortbuf: Pointer[U8] = Pointer[U8]
  var __lock: Pointer[None] = Pointer[None]
  var __offset: I64 = I64(0)
  var __codecvt: NullablePointer[IOcodecvt] = NullablePointer[IOcodecvt].none()
  var __wide_data: NullablePointer[IOwidedata] = NullablePointer[IOwidedata].none()
  var __freeres_list: NullablePointer[IOFILE] = NullablePointer[IOFILE].none()
  var __freeres_buf: Pointer[None] = Pointer[None]
  var ___pad5: U64 = U64(0)
  var __mode: I32 = I32(0)
  var __unused2: Pointer[U8] = Pointer[U8]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/__fpos_t.h:10
  Original Name: _G_fpos_t
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long int) size=64]: __pos  
     000064: [Struct size=64,fid: f19]: __state  
*/
struct Gfpost
  var ___pos: I64 = I64(0)
  var ___state: Anon169 = Anon169


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/__fpos64_t.h:10
  Original Name: _G_fpos64_t
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long int) size=64]: __pos  
     000064: [Struct size=64,fid: f19]: __state  
*/
struct Gfpos64t
  var ___pos: I64 = I64(0)
  var ___state: Anon169 = Anon169


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h:36
  Original Name: _IO_marker
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct IOmarker


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h:37
  Original Name: _IO_codecvt
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct IOcodecvt


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_FILE.h:38
  Original Name: _IO_wide_data
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct IOwidedata


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/cookie_io_functions_t.h:55
  Original Name: _IO_cookie_io_functions_t
  Struct Size (bits):  256
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FunctionType] -- WRITE MANUALLY: read  
     000064: [PointerType size=64]->[FunctionType] -- WRITE MANUALLY: write  
     000128: [PointerType size=64]->[FunctionType] -- WRITE MANUALLY: seek  
     000192: [PointerType size=64]->[FunctionType] -- WRITE MANUALLY: close  
*/
struct IOcookieiofunctionst
  var _read: Pointer[None] = Pointer[None]
  var _write: Pointer[None] = Pointer[None]
  var _seek: Pointer[None] = Pointer[None]
  var _close: Pointer[None] = Pointer[None]


/*
  Source: /usr/include/stdlib.h:59
  Original Name: 
  Struct Size (bits):  64
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: quot  
     000032: [FundamentalType(int) size=32]: rem  
*/
struct Anon407
  var _quot: I32 = I32(0)
  var _rem: I32 = I32(0)


/*
  Source: /usr/include/stdlib.h:67
  Original Name: 
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long int) size=64]: quot  
     000064: [FundamentalType(long int) size=64]: rem  
*/
struct Anon409
  var _quot: I64 = I64(0)
  var _rem: I64 = I64(0)


/*
  Source: /usr/include/stdlib.h:77
  Original Name: 
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long long int) size=64]: quot  
     000064: [FundamentalType(long long int) size=64]: rem  
*/
struct Anon411
  var _quot: I64 = I64(0)
  var _rem: I64 = I64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/__sigset_t.h:5
  Original Name: 
  Struct Size (bits):  1024
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [ArrayType size=(0-15)]->[FundamentalType(long unsigned int) size=64] -- UNSUPPORTED - FIXME: __val  
*/
struct Anon463
  var ___val: Pointer[U64] = Pointer[U64]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_timeval.h:8
  Original Name: timeval
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long int) size=64]: tv_sec  
     000064: [FundamentalType(long int) size=64]: tv_usec  
*/
struct Timeval
  var _tv_sec: I64 = I64(0)
  var _tv_usec: I64 = I64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/sys/select.h:59
  Original Name: 
  Struct Size (bits):  1024
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [ArrayType size=(0-15)]->[FundamentalType(long int) size=64] -- UNSUPPORTED - FIXME: fds_bits  
*/
struct Anon468
  var _fds_bits: Pointer[I64] = Pointer[I64]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/thread-shared-types.h:51
  Original Name: __pthread_internal_list
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[Struct size=128,fid: f42]: __prev  
     000064: [PointerType size=64]->[Struct size=128,fid: f42]: __next  
*/
struct Pthreadinternallist
  var ___prev: NullablePointer[Pthreadinternallist] = NullablePointer[Pthreadinternallist].none()
  var ___next: NullablePointer[Pthreadinternallist] = NullablePointer[Pthreadinternallist].none()


/*
  Source: /usr/include/x86_64-linux-gnu/bits/thread-shared-types.h:57
  Original Name: __pthread_internal_slist
  Struct Size (bits):  64
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[Struct size=64,fid: f42]: __next  
*/
struct Pthreadinternalslist
  var ___next: NullablePointer[Pthreadinternalslist] = NullablePointer[Pthreadinternalslist].none()


/*
  Source: /usr/include/x86_64-linux-gnu/bits/struct_mutex.h:22
  Original Name: __pthread_mutex_s
  Struct Size (bits):  320
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: __lock  
     000032: [FundamentalType(unsigned int) size=32]: __count  
     000064: [FundamentalType(int) size=32]: __owner  
     000096: [FundamentalType(unsigned int) size=32]: __nusers  
     000128: [FundamentalType(int) size=32]: __kind  
     000160: [FundamentalType(short int) size=16]: __spins  
     000176: [FundamentalType(short int) size=16]: __elision  
     000192: [Struct size=128,fid: f42]: __list  
*/
struct Pthreadmutexs
  var ___lock: I32 = I32(0)
  var ___count: U32 = U32(0)
  var ___owner: I32 = I32(0)
  var ___nusers: U32 = U32(0)
  var ___kind: I32 = I32(0)
  var ___spins: I16 = I16(0)
  var ___elision: I16 = I16(0)
  var ___list: Pthreadinternallist = Pthreadinternallist


/*
  Source: /usr/include/x86_64-linux-gnu/bits/struct_rwlock.h:23
  Original Name: __pthread_rwlock_arch_t
  Struct Size (bits):  448
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: __readers  
     000032: [FundamentalType(unsigned int) size=32]: __writers  
     000064: [FundamentalType(unsigned int) size=32]: __wrphase_futex  
     000096: [FundamentalType(unsigned int) size=32]: __writers_futex  
     000128: [FundamentalType(unsigned int) size=32]: __pad3  
     000160: [FundamentalType(unsigned int) size=32]: __pad4  
     000192: [FundamentalType(int) size=32]: __cur_writer  
     000224: [FundamentalType(int) size=32]: __shared  
     000256: [FundamentalType(signed char) size=8]: __rwelision  
     000264: [ArrayType size=(0-6)]->[FundamentalType(unsigned char) size=8] -- UNSUPPORTED - FIXME: __pad1  
     000320: [FundamentalType(long unsigned int) size=64]: __pad2  
     000384: [FundamentalType(unsigned int) size=32]: __flags  
*/
struct Pthreadrwlockarcht
  var ___readers: U32 = U32(0)
  var ___writers: U32 = U32(0)
  var ___wrphase_futex: U32 = U32(0)
  var ___writers_futex: U32 = U32(0)
  var ___pad3: U32 = U32(0)
  var ___pad4: U32 = U32(0)
  var ___cur_writer: I32 = I32(0)
  var ___shared: I32 = I32(0)
  var ___rwelision: I8 = I8(0)
  var ___pad1: Pointer[U8] = Pointer[U8]
  var ___pad2: U64 = U64(0)
  var ___flags: U32 = U32(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/thread-shared-types.h:94
  Original Name: __pthread_cond_s
  Struct Size (bits):  384
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [UNION size=64] -- UNSUPPORTED FIXME: __wseq  
     000064: [UNION size=64] -- UNSUPPORTED FIXME: __g1_start  
     000128: [ArrayType size=(0-1)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: __g_refs  
     000192: [ArrayType size=(0-1)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: __g_size  
     000256: [FundamentalType(unsigned int) size=32]: __g1_orig_size  
     000288: [FundamentalType(unsigned int) size=32]: __wrefs  
     000320: [ArrayType size=(0-1)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: __g_signals  
*/
struct Pthreadconds
  var ___wseq: None = None
  var ___g1_start: None = None
  var ___g_refs: Pointer[U32] = Pointer[U32]
  var ___g_size: Pointer[U32] = Pointer[U32]
  var ___g1_orig_size: U32 = U32(0)
  var ___wrefs: U32 = U32(0)
  var ___g_signals: Pointer[U32] = Pointer[U32]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/thread-shared-types.h:108
  Original Name: 
  Struct Size (bits):  32
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: __data  
*/
struct Anon488
  var ___data: I32 = I32(0)


/*
  Source: /usr/include/stdlib.h:543
  Original Name: random_data
  Struct Size (bits):  384
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(int) size=32]: fptr  
     000064: [PointerType size=64]->[FundamentalType(int) size=32]: rptr  
     000128: [PointerType size=64]->[FundamentalType(int) size=32]: state  
     000192: [FundamentalType(int) size=32]: rand_type  
     000224: [FundamentalType(int) size=32]: rand_deg  
     000256: [FundamentalType(int) size=32]: rand_sep  
     000320: [PointerType size=64]->[FundamentalType(int) size=32]: end_ptr  
*/
struct Randomdata
  var _fptr: Pointer[I32] = Pointer[I32]
  var _rptr: Pointer[I32] = Pointer[I32]
  var _state: Pointer[I32] = Pointer[I32]
  var _rand_type: I32 = I32(0)
  var _rand_deg: I32 = I32(0)
  var _rand_sep: I32 = I32(0)
  var _end_ptr: Pointer[I32] = Pointer[I32]


/*
  Source: /usr/include/stdlib.h:610
  Original Name: drand48_data
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [ArrayType size=(0-2)]->[FundamentalType(short unsigned int) size=16] -- UNSUPPORTED - FIXME: __x  
     000048: [ArrayType size=(0-2)]->[FundamentalType(short unsigned int) size=16] -- UNSUPPORTED - FIXME: __old_x  
     000096: [FundamentalType(short unsigned int) size=16]: __c  
     000112: [FundamentalType(short unsigned int) size=16]: __init  
     000128: [FundamentalType(long long unsigned int) size=64]: __a  
*/
struct Drand48data
  var ___x: Pointer[U16] = Pointer[U16]
  var ___old_x: Pointer[U16] = Pointer[U16]
  var ___c: U16 = U16(0)
  var ___init: U16 = U16(0)
  var ___a: U64 = U64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:36
  Original Name: 
  Struct Size (bits):  1024
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: si_signo  
     000032: [FundamentalType(int) size=32]: si_errno  
     000064: [FundamentalType(int) size=32]: si_code  
     000096: [FundamentalType(int) size=32]: __pad0  
     000128: [UNION size=896] -- UNSUPPORTED FIXME: _sifields  
*/
struct Anon666
  var _si_signo: I32 = I32(0)
  var _si_errno: I32 = I32(0)
  var _si_code: I32 = I32(0)
  var ___pad0: I32 = I32(0)
  var __sifields: None = None


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigaction.h:27
  Original Name: sigaction
  Struct Size (bits):  1216
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [UNION size=64] -- UNSUPPORTED FIXME: __sigaction_handler  
     000064: [Struct size=1024,fid: f37]: sa_mask  
     001088: [FundamentalType(int) size=32]: sa_flags  
     001152: [PointerType size=64]->[FunctionType] -- WRITE MANUALLY: sa_restorer  
*/
struct Sigaction
  var ___sigaction_handler: None = None
  var _sa_mask: Anon463 = Anon463
  var _sa_flags: I32 = I32(0)
  var _sa_restorer: Pointer[None] = Pointer[None]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:31
  Original Name: _fpx_sw_bytes
  Struct Size (bits):  384
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: magic1  
     000032: [FundamentalType(unsigned int) size=32]: extended_size  
     000064: [FundamentalType(long unsigned int) size=64]: xstate_bv  
     000128: [FundamentalType(unsigned int) size=32]: xstate_size  
     000160: [ArrayType size=(0-6)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: __glibc_reserved1  
*/
struct Fpxswbytes
  var _magic1: U32 = U32(0)
  var _extended_size: U32 = U32(0)
  var _xstate_bv: U64 = U64(0)
  var _xstate_size: U32 = U32(0)
  var ___glibc_reserved1: Pointer[U32] = Pointer[U32]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:40
  Original Name: _fpreg
  Struct Size (bits):  80
  Struct Align (bits): 16

  Fields (Offset in bits):
     000000: [ArrayType size=(0-3)]->[FundamentalType(short unsigned int) size=16] -- UNSUPPORTED - FIXME: significand  
     000064: [FundamentalType(short unsigned int) size=16]: exponent  
*/
struct Fpreg
  var _significand: Pointer[U16] = Pointer[U16]
  var _exponent: U16 = U16(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:46
  Original Name: _fpxreg
  Struct Size (bits):  128
  Struct Align (bits): 16

  Fields (Offset in bits):
     000000: [ArrayType size=(0-3)]->[FundamentalType(short unsigned int) size=16] -- UNSUPPORTED - FIXME: significand  
     000064: [FundamentalType(short unsigned int) size=16]: exponent  
     000080: [ArrayType size=(0-2)]->[FundamentalType(short unsigned int) size=16] -- UNSUPPORTED - FIXME: __glibc_reserved1  
*/
struct Fpxreg
  var _significand: Pointer[U16] = Pointer[U16]
  var _exponent: U16 = U16(0)
  var ___glibc_reserved1: Pointer[U16] = Pointer[U16]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:53
  Original Name: _xmmreg
  Struct Size (bits):  128
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [ArrayType size=(0-3)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: element  
*/
struct Xmmreg
  var _element: Pointer[U32] = Pointer[U32]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:123
  Original Name: _fpstate
  Struct Size (bits):  4096
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(short unsigned int) size=16]: cwd  
     000016: [FundamentalType(short unsigned int) size=16]: swd  
     000032: [FundamentalType(short unsigned int) size=16]: ftw  
     000048: [FundamentalType(short unsigned int) size=16]: fop  
     000064: [FundamentalType(long unsigned int) size=64]: rip  
     000128: [FundamentalType(long unsigned int) size=64]: rdp  
     000192: [FundamentalType(unsigned int) size=32]: mxcsr  
     000224: [FundamentalType(unsigned int) size=32]: mxcr_mask  
     000256: [ArrayType size=(0-7)]->[Struct size=128,fid: f57] -- UNSUPPORTED - FIXME: _st  
     001280: [ArrayType size=(0-15)]->[Struct size=128,fid: f57] -- UNSUPPORTED - FIXME: _xmm  
     003328: [ArrayType size=(0-23)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: __glibc_reserved1  
*/
struct Fpstate
  var _cwd: U16 = U16(0)
  var _swd: U16 = U16(0)
  var _ftw: U16 = U16(0)
  var _fop: U16 = U16(0)
  var _rip: U64 = U64(0)
  var _rdp: U64 = U64(0)
  var _mxcsr: U32 = U32(0)
  var _mxcr_mask: U32 = U32(0)
  var __st: Pointer[Fpxreg] = Pointer[Fpxreg]
  var __xmm: Pointer[Xmmreg] = Pointer[Xmmreg]
  var ___glibc_reserved1: Pointer[U32] = Pointer[U32]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:139
  Original Name: sigcontext
  Struct Size (bits):  2048
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long unsigned int) size=64]: r8  
     000064: [FundamentalType(long unsigned int) size=64]: r9  
     000128: [FundamentalType(long unsigned int) size=64]: r10  
     000192: [FundamentalType(long unsigned int) size=64]: r11  
     000256: [FundamentalType(long unsigned int) size=64]: r12  
     000320: [FundamentalType(long unsigned int) size=64]: r13  
     000384: [FundamentalType(long unsigned int) size=64]: r14  
     000448: [FundamentalType(long unsigned int) size=64]: r15  
     000512: [FundamentalType(long unsigned int) size=64]: rdi  
     000576: [FundamentalType(long unsigned int) size=64]: rsi  
     000640: [FundamentalType(long unsigned int) size=64]: rbp  
     000704: [FundamentalType(long unsigned int) size=64]: rbx  
     000768: [FundamentalType(long unsigned int) size=64]: rdx  
     000832: [FundamentalType(long unsigned int) size=64]: rax  
     000896: [FundamentalType(long unsigned int) size=64]: rcx  
     000960: [FundamentalType(long unsigned int) size=64]: rsp  
     001024: [FundamentalType(long unsigned int) size=64]: rip  
     001088: [FundamentalType(long unsigned int) size=64]: eflags  
     001152: [FundamentalType(short unsigned int) size=16]: cs  
     001168: [FundamentalType(short unsigned int) size=16]: gs  
     001184: [FundamentalType(short unsigned int) size=16]: fs  
     001200: [FundamentalType(short unsigned int) size=16]: __pad0  
     001216: [FundamentalType(long unsigned int) size=64]: err  
     001280: [FundamentalType(long unsigned int) size=64]: trapno  
     001344: [FundamentalType(long unsigned int) size=64]: oldmask  
     001408: [FundamentalType(long unsigned int) size=64]: cr2  
     001472: [UNION size=64] -- UNSUPPORTED FIXME:   
     001536: [ArrayType size=(0-7)]->[FundamentalType(long unsigned int) size=64] -- UNSUPPORTED - FIXME: __reserved1  
*/
struct Sigcontext
  var _r8: U64 = U64(0)
  var _r9: U64 = U64(0)
  var _r10: U64 = U64(0)
  var _r11: U64 = U64(0)
  var _r12: U64 = U64(0)
  var _r13: U64 = U64(0)
  var _r14: U64 = U64(0)
  var _r15: U64 = U64(0)
  var _rdi: U64 = U64(0)
  var _rsi: U64 = U64(0)
  var _rbp: U64 = U64(0)
  var _rbx: U64 = U64(0)
  var _rdx: U64 = U64(0)
  var _rax: U64 = U64(0)
  var _rcx: U64 = U64(0)
  var _rsp: U64 = U64(0)
  var _rip: U64 = U64(0)
  var _eflags: U64 = U64(0)
  var _cs: U16 = U16(0)
  var _gs: U16 = U16(0)
  var _fs: U16 = U16(0)
  var ___pad0: U16 = U16(0)
  var _err: U64 = U64(0)
  var _trapno: U64 = U64(0)
  var _oldmask: U64 = U64(0)
  var _cr2: U64 = U64(0)
  var _: None = None
  var ___reserved1: Pointer[U64] = Pointer[U64]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:177
  Original Name: _xsave_hdr
  Struct Size (bits):  512
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long unsigned int) size=64]: xstate_bv  
     000064: [ArrayType size=(0-1)]->[FundamentalType(long unsigned int) size=64] -- UNSUPPORTED - FIXME: __glibc_reserved1  
     000192: [ArrayType size=(0-4)]->[FundamentalType(long unsigned int) size=64] -- UNSUPPORTED - FIXME: __glibc_reserved2  
*/
struct Xsavehdr
  var _xstate_bv: U64 = U64(0)
  var ___glibc_reserved1: Pointer[U64] = Pointer[U64]
  var ___glibc_reserved2: Pointer[U64] = Pointer[U64]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:184
  Original Name: _ymmh_state
  Struct Size (bits):  2048
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [ArrayType size=(0-63)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: ymmh_space  
*/
struct Ymmhstate
  var _ymmh_space: Pointer[U32] = Pointer[U32]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/sigcontext.h:189
  Original Name: _xstate
  Struct Size (bits):  6656
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [Struct size=4096,fid: f57]: fpstate  
     004096: [Struct size=512,fid: f57]: xstate_hdr  
     004608: [Struct size=2048,fid: f57]: ymmh  
*/
struct Xstate
  var _fpstate: Fpstate = Fpstate
  var _xstate_hdr: Xsavehdr = Xsavehdr
  var _ymmh: Ymmhstate = Ymmhstate


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/stack_t.h:26
  Original Name: 
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: ss_sp  
     000064: [FundamentalType(int) size=32]: ss_flags  
     000128: [FundamentalType(long unsigned int) size=64]: ss_size  
*/
struct Anon718
  var _ss_sp: Pointer[None] = Pointer[None]
  var _ss_flags: I32 = I32(0)
  var _ss_size: U64 = U64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/sys/ucontext.h:101
  Original Name: _libc_fpxreg
  Struct Size (bits):  128
  Struct Align (bits): 16

  Fields (Offset in bits):
     000000: [ArrayType size=(0-3)]->[FundamentalType(short unsigned int) size=16] -- UNSUPPORTED - FIXME: significand  
     000064: [FundamentalType(short unsigned int) size=16]: exponent  
     000080: [ArrayType size=(0-2)]->[FundamentalType(short unsigned int) size=16] -- UNSUPPORTED - FIXME: __glibc_reserved1  
*/
struct Libcfpxreg
  var _significand: Pointer[U16] = Pointer[U16]
  var _exponent: U16 = U16(0)
  var ___glibc_reserved1: Pointer[U16] = Pointer[U16]


/*
  Source: /usr/include/x86_64-linux-gnu/sys/ucontext.h:108
  Original Name: _libc_xmmreg
  Struct Size (bits):  128
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [ArrayType size=(0-3)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: element  
*/
struct Libcxmmreg
  var _element: Pointer[U32] = Pointer[U32]


/*
  Source: /usr/include/x86_64-linux-gnu/sys/ucontext.h:113
  Original Name: _libc_fpstate
  Struct Size (bits):  4096
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(short unsigned int) size=16]: cwd  
     000016: [FundamentalType(short unsigned int) size=16]: swd  
     000032: [FundamentalType(short unsigned int) size=16]: ftw  
     000048: [FundamentalType(short unsigned int) size=16]: fop  
     000064: [FundamentalType(long unsigned int) size=64]: rip  
     000128: [FundamentalType(long unsigned int) size=64]: rdp  
     000192: [FundamentalType(unsigned int) size=32]: mxcsr  
     000224: [FundamentalType(unsigned int) size=32]: mxcr_mask  
     000256: [ArrayType size=(0-7)]->[Struct size=128,fid: f59] -- UNSUPPORTED - FIXME: _st  
     001280: [ArrayType size=(0-15)]->[Struct size=128,fid: f59] -- UNSUPPORTED - FIXME: _xmm  
     003328: [ArrayType size=(0-23)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: __glibc_reserved1  
*/
struct Libcfpstate
  var _cwd: U16 = U16(0)
  var _swd: U16 = U16(0)
  var _ftw: U16 = U16(0)
  var _fop: U16 = U16(0)
  var _rip: U64 = U64(0)
  var _rdp: U64 = U64(0)
  var _mxcsr: U32 = U32(0)
  var _mxcr_mask: U32 = U32(0)
  var __st: Pointer[Libcfpxreg] = Pointer[Libcfpxreg]
  var __xmm: Pointer[Libcxmmreg] = Pointer[Libcxmmreg]
  var ___glibc_reserved1: Pointer[U32] = Pointer[U32]


/*
  Source: /usr/include/x86_64-linux-gnu/sys/ucontext.h:133
  Original Name: 
  Struct Size (bits):  2048
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [ArrayType size=(0-22)]->[FundamentalType(long long int) size=64] -- UNSUPPORTED - FIXME: gregs  
     001472: [PointerType size=64]->[Struct size=4096,fid: f59]: fpregs  
     001536: [ArrayType size=(0-7)]->[FundamentalType(long long unsigned int) size=64] -- UNSUPPORTED - FIXME: __reserved1  
*/
struct Anon726
  var _gregs: Pointer[I64] = Pointer[I64]
  var _fpregs: NullablePointer[Libcfpstate] = NullablePointer[Libcfpstate].none()
  var ___reserved1: Pointer[U64] = Pointer[U64]


/*
  Source: /usr/include/x86_64-linux-gnu/sys/ucontext.h:142
  Original Name: ucontext_t
  Struct Size (bits):  7744
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long unsigned int) size=64]: uc_flags  
     000064: [PointerType size=64]->[Struct size=7744,fid: f59]: uc_link  
     000128: [Struct size=192,fid: f58]: uc_stack  
     000320: [Struct size=2048,fid: f59]: uc_mcontext  
     002368: [Struct size=1024,fid: f37]: uc_sigmask  
     003392: [Struct size=4096,fid: f59]: __fpregs_mem  
     007488: [ArrayType size=(0-3)]->[FundamentalType(long long unsigned int) size=64] -- UNSUPPORTED - FIXME: __ssp  
*/
struct Ucontextt
  var _uc_flags: U64 = U64(0)
  var _uc_link: NullablePointer[Ucontextt] = NullablePointer[Ucontextt].none()
  var _uc_stack: Anon718 = Anon718
  var _uc_mcontext: Anon726 = Anon726
  var _uc_sigmask: Anon463 = Anon463
  var ___fpregs_mem: Libcfpstate = Libcfpstate
  var ___ssp: Pointer[U64] = Pointer[U64]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_sigstack.h:23
  Original Name: sigstack
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: ss_sp  
     000064: [FundamentalType(int) size=32]: ss_onstack  
*/
struct Sigstack
  var _ss_sp: Pointer[None] = Pointer[None]
  var _ss_onstack: I32 = I32(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_iovec.h:26
  Original Name: iovec
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: iov_base  
     000064: [FundamentalType(long unsigned int) size=64]: iov_len  
*/
struct Iovec
  var _iov_base: Pointer[None] = Pointer[None]
  var _iov_len: U64 = U64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/socket.h:183
  Original Name: sockaddr
  Struct Size (bits):  128
  Struct Align (bits): 16

  Fields (Offset in bits):
     000000: [FundamentalType(short unsigned int) size=16]: sa_family  
     000016: [ArrayType size=(0-13)]->[FundamentalType(char) size=8] -- UNSUPPORTED - FIXME: sa_data  
*/
struct Sockaddr
  var _sa_family: U16 = U16(0)
  var _sa_data: Pointer[U8] = Pointer[U8]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/socket.h:196
  Original Name: sockaddr_storage
  Struct Size (bits):  1024
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(short unsigned int) size=16]: ss_family  
     000016: [ArrayType size=(0-117)]->[FundamentalType(char) size=8] -- UNSUPPORTED - FIXME: __ss_padding  
     000960: [FundamentalType(long unsigned int) size=64]: __ss_align  
*/
struct Sockaddrstorage
  var _ss_family: U16 = U16(0)
  var ___ss_padding: Pointer[U8] = Pointer[U8]
  var ___ss_align: U64 = U64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/socket.h:262
  Original Name: msghdr
  Struct Size (bits):  448
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: msg_name  
     000064: [FundamentalType(unsigned int) size=32]: msg_namelen  
     000128: [PointerType size=64]->[Struct size=128,fid: f63]: msg_iov  
     000192: [FundamentalType(long unsigned int) size=64]: msg_iovlen  
     000256: [PointerType size=64]->[FundamentalType(void) size=0]: msg_control  
     000320: [FundamentalType(long unsigned int) size=64]: msg_controllen  
     000384: [FundamentalType(int) size=32]: msg_flags  
*/
struct Msghdr
  var _msg_name: Pointer[None] = Pointer[None]
  var _msg_namelen: U32 = U32(0)
  var _msg_iov: NullablePointer[Iovec] = NullablePointer[Iovec].none()
  var _msg_iovlen: U64 = U64(0)
  var _msg_control: Pointer[None] = Pointer[None]
  var _msg_controllen: U64 = U64(0)
  var _msg_flags: I32 = I32(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/socket.h:280
  Original Name: cmsghdr
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long unsigned int) size=64]: cmsg_len  
     000064: [FundamentalType(int) size=32]: cmsg_level  
     000096: [FundamentalType(int) size=32]: cmsg_type  
     000128: [ArrayType size=(0-)]->[FundamentalType(unsigned char) size=8] -- UNSUPPORTED - FIXME: __cmsg_data  
*/
struct Cmsghdr
  var _cmsg_len: U64 = U64(0)
  var _cmsg_level: I32 = I32(0)
  var _cmsg_type: I32 = I32(0)
  var ___cmsg_data: Pointer[U8] = Pointer[U8]


/*
  Source: /usr/include/linux/posix_types.h:25
  Original Name: 
  Struct Size (bits):  1024
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [ArrayType size=(0-15)]->[FundamentalType(long unsigned int) size=64] -- UNSUPPORTED - FIXME: fds_bits  
*/
struct Anon754
  var _fds_bits: Pointer[U64] = Pointer[U64]


/*
  Source: /usr/include/asm-generic/posix_types.h:79
  Original Name: 
  Struct Size (bits):  64
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [ArrayType size=(0-1)]->[FundamentalType(int) size=32] -- UNSUPPORTED - FIXME: val  
*/
struct Anon777
  var _val: Pointer[I32] = Pointer[I32]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/socket.h:396
  Original Name: linger
  Struct Size (bits):  64
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: l_onoff  
     000032: [FundamentalType(int) size=32]: l_linger  
*/
struct Linger
  var _l_onoff: I32 = I32(0)
  var _l_linger: I32 = I32(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/struct_osockaddr.h:6
  Original Name: osockaddr
  Struct Size (bits):  128
  Struct Align (bits): 16

  Fields (Offset in bits):
     000000: [FundamentalType(short unsigned int) size=16]: sa_family  
     000016: [ArrayType size=(0-13)]->[FundamentalType(unsigned char) size=8] -- UNSUPPORTED - FIXME: sa_data  
*/
struct Osockaddr
  var _sa_family: U16 = U16(0)
  var _sa_data: Pointer[U8] = Pointer[U8]


/*
  Source: /usr/include/netinet/in.h:31
  Original Name: in_addr
  Struct Size (bits):  32
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: s_addr  
*/
struct Inaddr
  var _s_addr: U32 = U32(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/in.h:145
  Original Name: ip_opts
  Struct Size (bits):  352
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [Struct size=32,fid: f72]: ip_dst  
     000032: [ArrayType size=(0-39)]->[FundamentalType(char) size=8] -- UNSUPPORTED - FIXME: ip_opts  
*/
struct Ipopts
  var _ip_dst: Inaddr = Inaddr
  var _ip_opts: Pointer[U8] = Pointer[U8]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/in.h:152
  Original Name: in_pktinfo
  Struct Size (bits):  96
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: ipi_ifindex  
     000032: [Struct size=32,fid: f72]: ipi_spec_dst  
     000064: [Struct size=32,fid: f72]: ipi_addr  
*/
struct Inpktinfo
  var _ipi_ifindex: I32 = I32(0)
  var _ipi_spec_dst: Inaddr = Inaddr
  var _ipi_addr: Inaddr = Inaddr


/*
  Source: /usr/include/netinet/in.h:221
  Original Name: in6_addr
  Struct Size (bits):  128
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [UNION size=128] -- UNSUPPORTED FIXME: __in6_u  
*/
struct In6addr
  var ___in6_u: None = None


/*
  Source: /usr/include/netinet/in.h:247
  Original Name: sockaddr_in
  Struct Size (bits):  128
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(short unsigned int) size=16]: sin_family  
     000016: [FundamentalType(short unsigned int) size=16]: sin_port  
     000032: [Struct size=32,fid: f72]: sin_addr  
     000064: [ArrayType size=(0-7)]->[FundamentalType(unsigned char) size=8] -- UNSUPPORTED - FIXME: sin_zero  
*/
struct Sockaddrin
  var _sin_family: U16 = U16(0)
  var _sin_port: U16 = U16(0)
  var _sin_addr: Inaddr = Inaddr
  var _sin_zero: Pointer[U8] = Pointer[U8]


/*
  Source: /usr/include/netinet/in.h:262
  Original Name: sockaddr_in6
  Struct Size (bits):  224
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(short unsigned int) size=16]: sin6_family  
     000016: [FundamentalType(short unsigned int) size=16]: sin6_port  
     000032: [FundamentalType(unsigned int) size=32]: sin6_flowinfo  
     000064: [Struct size=128,fid: f72]: sin6_addr  
     000192: [FundamentalType(unsigned int) size=32]: sin6_scope_id  
*/
struct Sockaddrin6
  var _sin6_family: U16 = U16(0)
  var _sin6_port: U16 = U16(0)
  var _sin6_flowinfo: U32 = U32(0)
  var _sin6_addr: In6addr = In6addr
  var _sin6_scope_id: U32 = U32(0)


/*
  Source: /usr/include/netinet/in.h:274
  Original Name: ip_mreq
  Struct Size (bits):  64
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [Struct size=32,fid: f72]: imr_multiaddr  
     000032: [Struct size=32,fid: f72]: imr_interface  
*/
struct Ipmreq
  var _imr_multiaddr: Inaddr = Inaddr
  var _imr_interface: Inaddr = Inaddr


/*
  Source: /usr/include/netinet/in.h:284
  Original Name: ip_mreqn
  Struct Size (bits):  96
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [Struct size=32,fid: f72]: imr_multiaddr  
     000032: [Struct size=32,fid: f72]: imr_address  
     000064: [FundamentalType(int) size=32]: imr_ifindex  
*/
struct Ipmreqn
  var _imr_multiaddr: Inaddr = Inaddr
  var _imr_address: Inaddr = Inaddr
  var _imr_ifindex: I32 = I32(0)


/*
  Source: /usr/include/netinet/in.h:296
  Original Name: ip_mreq_source
  Struct Size (bits):  96
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [Struct size=32,fid: f72]: imr_multiaddr  
     000032: [Struct size=32,fid: f72]: imr_interface  
     000064: [Struct size=32,fid: f72]: imr_sourceaddr  
*/
struct Ipmreqsource
  var _imr_multiaddr: Inaddr = Inaddr
  var _imr_interface: Inaddr = Inaddr
  var _imr_sourceaddr: Inaddr = Inaddr


/*
  Source: /usr/include/netinet/in.h:311
  Original Name: ipv6_mreq
  Struct Size (bits):  160
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [Struct size=128,fid: f72]: ipv6mr_multiaddr  
     000128: [FundamentalType(unsigned int) size=32]: ipv6mr_interface  
*/
struct Ipv6mreq
  var _ipv6mr_multiaddr: In6addr = In6addr
  var _ipv6mr_interface: U32 = U32(0)


/*
  Source: /usr/include/netinet/in.h:323
  Original Name: group_req
  Struct Size (bits):  1088
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: gr_interface  
     000064: [Struct size=1024,fid: f64]: gr_group  
*/
struct Groupreq
  var _gr_interface: U32 = U32(0)
  var _gr_group: Sockaddrstorage = Sockaddrstorage


/*
  Source: /usr/include/netinet/in.h:332
  Original Name: group_source_req
  Struct Size (bits):  2112
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: gsr_interface  
     000064: [Struct size=1024,fid: f64]: gsr_group  
     001088: [Struct size=1024,fid: f64]: gsr_source  
*/
struct Groupsourcereq
  var _gsr_interface: U32 = U32(0)
  var _gsr_group: Sockaddrstorage = Sockaddrstorage
  var _gsr_source: Sockaddrstorage = Sockaddrstorage


/*
  Source: /usr/include/netinet/in.h:346
  Original Name: ip_msfilter
  Struct Size (bits):  160
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [Struct size=32,fid: f72]: imsf_multiaddr  
     000032: [Struct size=32,fid: f72]: imsf_interface  
     000064: [FundamentalType(unsigned int) size=32]: imsf_fmode  
     000096: [FundamentalType(unsigned int) size=32]: imsf_numsrc  
     000128: [ArrayType size=(0-0)]->[Struct size=32,fid: f72] -- UNSUPPORTED - FIXME: imsf_slist  
*/
struct Ipmsfilter
  var _imsf_multiaddr: Inaddr = Inaddr
  var _imsf_interface: Inaddr = Inaddr
  var _imsf_fmode: U32 = U32(0)
  var _imsf_numsrc: U32 = U32(0)
  var _imsf_slist: Pointer[Inaddr] = Pointer[Inaddr]


/*
  Source: /usr/include/netinet/in.h:367
  Original Name: group_filter
  Struct Size (bits):  2176
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: gf_interface  
     000064: [Struct size=1024,fid: f64]: gf_group  
     001088: [FundamentalType(unsigned int) size=32]: gf_fmode  
     001120: [FundamentalType(unsigned int) size=32]: gf_numsrc  
     001152: [ArrayType size=(0-0)]->[Struct size=1024,fid: f64] -- UNSUPPORTED - FIXME: gf_slist  
*/
struct Groupfilter
  var _gf_interface: U32 = U32(0)
  var _gf_group: Sockaddrstorage = Sockaddrstorage
  var _gf_fmode: U32 = U32(0)
  var _gf_numsrc: U32 = U32(0)
  var _gf_slist: Pointer[Sockaddrstorage] = Pointer[Sockaddrstorage]


/*
  Source: /usr/include/notcurses/notcurses.h:44
  Original Name: notcurses
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Notcurses


/*
  Source: /usr/include/notcurses/notcurses.h:45
  Original Name: ncplane
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncplane


/*
  Source: /usr/include/notcurses/notcurses.h:46
  Original Name: ncvisual
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncvisual


/*
  Source: /usr/include/notcurses/notcurses.h:47
  Original Name: ncuplot
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncuplot


/*
  Source: /usr/include/notcurses/notcurses.h:48
  Original Name: ncdplot
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncdplot


/*
  Source: /usr/include/notcurses/notcurses.h:49
  Original Name: ncprogbar
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncprogbar


/*
  Source: /usr/include/notcurses/notcurses.h:50
  Original Name: ncfdplane
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncfdplane


/*
  Source: /usr/include/notcurses/notcurses.h:51
  Original Name: ncsubproc
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncsubproc


/*
  Source: /usr/include/notcurses/notcurses.h:52
  Original Name: ncselector
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncselector


/*
  Source: /usr/include/notcurses/notcurses.h:53
  Original Name: ncmultiselector
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncmultiselector


/*
  Source: /usr/include/notcurses/notcurses.h:54
  Original Name: ncreader
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncreader


/*
  Source: /usr/include/notcurses/notcurses.h:55
  Original Name: ncfadectx
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncfadectx


/*
  Source: /usr/include/notcurses/notcurses.h:56
  Original Name: nctablet
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Nctablet


/*
  Source: /usr/include/notcurses/notcurses.h:57
  Original Name: ncreel
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncreel


/*
  Source: /usr/include/notcurses/notcurses.h:58
  Original Name: nctab
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Nctab


/*
  Source: /usr/include/notcurses/notcurses.h:59
  Original Name: nctabbed
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Nctabbed


/*
  Source: /usr/include/notcurses/notcurses.h:60
  Original Name: ncdirect
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncdirect


/*
  Source: /usr/include/notcurses/notcurses.h:663
  Original Name: nccell
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: gcluster  
     000032: [FundamentalType(unsigned char) size=8]: gcluster_backstop  
     000040: [FundamentalType(unsigned char) size=8]: width  
     000048: [FundamentalType(short unsigned int) size=16]: stylemask  
     000064: [FundamentalType(long unsigned int) size=64]: channels  
*/
struct Nccell
  var _gcluster: U32 = U32(0)
  var _gcluster_backstop: U8 = U8(0)
  var _width: U8 = U8(0)
  var _stylemask: U16 = U16(0)
  var _channels: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:1043
  Original Name: notcurses_options
  Struct Size (bits):  320
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(char) size=8]: termtype  
     000064: [Enumeration size=32,fid: f75]: loglevel  
     000096: [FundamentalType(unsigned int) size=32]: margin_t  
     000128: [FundamentalType(unsigned int) size=32]: margin_r  
     000160: [FundamentalType(unsigned int) size=32]: margin_b  
     000192: [FundamentalType(unsigned int) size=32]: margin_l  
     000256: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Notcursesoptions
  var _termtype: Pointer[U8] = Pointer[U8]
  var _loglevel: I32 = I32(0)
  var _margin_t: U32 = U32(0)
  var _margin_r: U32 = U32(0)
  var _margin_b: U32 = U32(0)
  var _margin_l: U32 = U32(0)
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:1205
  Original Name: ncinput
  Struct Size (bits):  288
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: id  
     000032: [FundamentalType(int) size=32]: y  
     000064: [FundamentalType(int) size=32]: x  
     000096: [ArrayType size=(0-4)]->[FundamentalType(char) size=8] -- UNSUPPORTED - FIXME: utf8  
     000136: [FundamentalType(bool) size=8]: alt  
     000144: [FundamentalType(bool) size=8]: shift  
     000152: [FundamentalType(bool) size=8]: ctrl  
     000160: [Enumeration size=32,fid: f75]: evtype  
     000192: [FundamentalType(unsigned int) size=32]: modifiers  
     000224: [FundamentalType(int) size=32]: ypx  
     000256: [FundamentalType(int) size=32]: xpx  
*/
struct Ncinput
  var _id: U32 = U32(0)
  var _y: I32 = I32(0)
  var _x: I32 = I32(0)
  var _utf8: Pointer[U8] = Pointer[U8]
  var _alt: Bool = Bool
  var _shift: Bool = Bool
  var _ctrl: Bool = Bool
  var _evtype: I32 = I32(0)
  var _modifiers: U32 = U32(0)
  var _ypx: I32 = I32(0)
  var _xpx: I32 = I32(0)


/*
  Source: /usr/include/notcurses/notcurses.h:1462
  Original Name: ncplane_options
  Struct Size (bits):  448
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: y  
     000032: [FundamentalType(int) size=32]: x  
     000064: [FundamentalType(unsigned int) size=32]: rows  
     000096: [FundamentalType(unsigned int) size=32]: cols  
     000128: [PointerType size=64]->[FundamentalType(void) size=0]: userptr  
     000192: [PointerType size=64]->[FundamentalType(char) size=8]: name  
     000256: [PointerType size=64]->[FunctionType] -- WRITE MANUALLY: resizecb  
     000320: [FundamentalType(long unsigned int) size=64]: flags  
     000384: [FundamentalType(unsigned int) size=32]: margin_b  
     000416: [FundamentalType(unsigned int) size=32]: margin_r  
*/
struct Ncplaneoptions
  var _y: I32 = I32(0)
  var _x: I32 = I32(0)
  var _rows: U32 = U32(0)
  var _cols: U32 = U32(0)
  var _userptr: Pointer[None] = Pointer[None]
  var _name: Pointer[U8] = Pointer[U8]
  var _resizecb: Pointer[None] = Pointer[None]
  var _flags: U64 = U64(0)
  var _margin_b: U32 = U32(0)
  var _margin_r: U32 = U32(0)


/*
  Source: /usr/include/notcurses/notcurses.h:1582
  Original Name: ncpalette
  Struct Size (bits):  8192
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [ArrayType size=(0-255)]->[FundamentalType(unsigned int) size=32] -- UNSUPPORTED - FIXME: chans  
*/
struct Ncpalette
  var _chans: Pointer[U32] = Pointer[U32]


/*
  Source: /usr/include/notcurses/notcurses.h:1634
  Original Name: nccapabilities
  Struct Size (bits):  96
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: colors  
     000032: [FundamentalType(bool) size=8]: utf8  
     000040: [FundamentalType(bool) size=8]: rgb  
     000048: [FundamentalType(bool) size=8]: can_change_colors  
     000056: [FundamentalType(bool) size=8]: halfblocks  
     000064: [FundamentalType(bool) size=8]: quadrants  
     000072: [FundamentalType(bool) size=8]: sextants  
     000080: [FundamentalType(bool) size=8]: braille  
*/
struct Nccapabilities
  var _colors: U32 = U32(0)
  var _utf8: Bool = Bool
  var _rgb: Bool = Bool
  var _can_change_colors: Bool = Bool
  var _halfblocks: Bool = Bool
  var _quadrants: Bool = Bool
  var _sextants: Bool = Bool
  var _braille: Bool = Bool


/*
  Source: /usr/include/notcurses/notcurses.h:1772
  Original Name: ncstats
  Struct Size (bits):  2304
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long unsigned int) size=64]: renders  
     000064: [FundamentalType(long unsigned int) size=64]: writeouts  
     000128: [FundamentalType(long unsigned int) size=64]: failed_renders  
     000192: [FundamentalType(long unsigned int) size=64]: failed_writeouts  
     000256: [FundamentalType(long unsigned int) size=64]: raster_bytes  
     000320: [FundamentalType(long int) size=64]: raster_max_bytes  
     000384: [FundamentalType(long int) size=64]: raster_min_bytes  
     000448: [FundamentalType(long unsigned int) size=64]: render_ns  
     000512: [FundamentalType(long int) size=64]: render_max_ns  
     000576: [FundamentalType(long int) size=64]: render_min_ns  
     000640: [FundamentalType(long unsigned int) size=64]: raster_ns  
     000704: [FundamentalType(long int) size=64]: raster_max_ns  
     000768: [FundamentalType(long int) size=64]: raster_min_ns  
     000832: [FundamentalType(long unsigned int) size=64]: writeout_ns  
     000896: [FundamentalType(long int) size=64]: writeout_max_ns  
     000960: [FundamentalType(long int) size=64]: writeout_min_ns  
     001024: [FundamentalType(long unsigned int) size=64]: cellelisions  
     001088: [FundamentalType(long unsigned int) size=64]: cellemissions  
     001152: [FundamentalType(long unsigned int) size=64]: fgelisions  
     001216: [FundamentalType(long unsigned int) size=64]: fgemissions  
     001280: [FundamentalType(long unsigned int) size=64]: bgelisions  
     001344: [FundamentalType(long unsigned int) size=64]: bgemissions  
     001408: [FundamentalType(long unsigned int) size=64]: defaultelisions  
     001472: [FundamentalType(long unsigned int) size=64]: defaultemissions  
     001536: [FundamentalType(long unsigned int) size=64]: refreshes  
     001600: [FundamentalType(long unsigned int) size=64]: sprixelemissions  
     001664: [FundamentalType(long unsigned int) size=64]: sprixelelisions  
     001728: [FundamentalType(long unsigned int) size=64]: sprixelbytes  
     001792: [FundamentalType(long unsigned int) size=64]: appsync_updates  
     001856: [FundamentalType(long unsigned int) size=64]: input_errors  
     001920: [FundamentalType(long unsigned int) size=64]: input_events  
     001984: [FundamentalType(long unsigned int) size=64]: hpa_gratuitous  
     002048: [FundamentalType(long unsigned int) size=64]: cell_geo_changes  
     002112: [FundamentalType(long unsigned int) size=64]: pixel_geo_changes  
     002176: [FundamentalType(long unsigned int) size=64]: fbbytes  
     002240: [FundamentalType(unsigned int) size=32]: planes  
*/
struct Ncstats
  var _renders: U64 = U64(0)
  var _writeouts: U64 = U64(0)
  var _failed_renders: U64 = U64(0)
  var _failed_writeouts: U64 = U64(0)
  var _raster_bytes: U64 = U64(0)
  var _raster_max_bytes: I64 = I64(0)
  var _raster_min_bytes: I64 = I64(0)
  var _render_ns: U64 = U64(0)
  var _render_max_ns: I64 = I64(0)
  var _render_min_ns: I64 = I64(0)
  var _raster_ns: U64 = U64(0)
  var _raster_max_ns: I64 = I64(0)
  var _raster_min_ns: I64 = I64(0)
  var _writeout_ns: U64 = U64(0)
  var _writeout_max_ns: I64 = I64(0)
  var _writeout_min_ns: I64 = I64(0)
  var _cellelisions: U64 = U64(0)
  var _cellemissions: U64 = U64(0)
  var _fgelisions: U64 = U64(0)
  var _fgemissions: U64 = U64(0)
  var _bgelisions: U64 = U64(0)
  var _bgemissions: U64 = U64(0)
  var _defaultelisions: U64 = U64(0)
  var _defaultemissions: U64 = U64(0)
  var _refreshes: U64 = U64(0)
  var _sprixelemissions: U64 = U64(0)
  var _sprixelelisions: U64 = U64(0)
  var _sprixelbytes: U64 = U64(0)
  var _appsync_updates: U64 = U64(0)
  var _input_errors: U64 = U64(0)
  var _input_events: U64 = U64(0)
  var _hpa_gratuitous: U64 = U64(0)
  var _cell_geo_changes: U64 = U64(0)
  var _pixel_geo_changes: U64 = U64(0)
  var _fbbytes: U64 = U64(0)
  var _planes: U32 = U32(0)


/*
  Source: /usr/include/notcurses/notcurses.h:3324
  Original Name: ncvisual_options
  Struct Size (bits):  512
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[Struct size=,fid: f75]: n  
     000064: [Enumeration size=32,fid: f75]: scaling  
     000096: [FundamentalType(int) size=32]: y  
     000128: [FundamentalType(int) size=32]: x  
     000160: [FundamentalType(unsigned int) size=32]: begy  
     000192: [FundamentalType(unsigned int) size=32]: begx  
     000224: [FundamentalType(unsigned int) size=32]: leny  
     000256: [FundamentalType(unsigned int) size=32]: lenx  
     000288: [Enumeration size=32,fid: f75]: blitter  
     000320: [FundamentalType(long unsigned int) size=64]: flags  
     000384: [FundamentalType(unsigned int) size=32]: transcolor  
     000416: [FundamentalType(unsigned int) size=32]: pxoffy  
     000448: [FundamentalType(unsigned int) size=32]: pxoffx  
*/
struct Ncvisualoptions
  var _n: NullablePointer[Ncplane] = NullablePointer[Ncplane].none()
  var _scaling: I32 = I32(0)
  var _y: I32 = I32(0)
  var _x: I32 = I32(0)
  var _begy: U32 = U32(0)
  var _begx: U32 = U32(0)
  var _leny: U32 = U32(0)
  var _lenx: U32 = U32(0)
  var _blitter: I32 = I32(0)
  var _flags: U64 = U64(0)
  var _transcolor: U32 = U32(0)
  var _pxoffy: U32 = U32(0)
  var _pxoffx: U32 = U32(0)


/*
  Source: /usr/include/notcurses/notcurses.h:3376
  Original Name: ncvgeom
  Struct Size (bits):  544
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: pixy  
     000032: [FundamentalType(unsigned int) size=32]: pixx  
     000064: [FundamentalType(unsigned int) size=32]: cdimy  
     000096: [FundamentalType(unsigned int) size=32]: cdimx  
     000128: [FundamentalType(unsigned int) size=32]: rpixy  
     000160: [FundamentalType(unsigned int) size=32]: rpixx  
     000192: [FundamentalType(unsigned int) size=32]: rcelly  
     000224: [FundamentalType(unsigned int) size=32]: rcellx  
     000256: [FundamentalType(unsigned int) size=32]: scaley  
     000288: [FundamentalType(unsigned int) size=32]: scalex  
     000320: [FundamentalType(unsigned int) size=32]: begy  
     000352: [FundamentalType(unsigned int) size=32]: begx  
     000384: [FundamentalType(unsigned int) size=32]: leny  
     000416: [FundamentalType(unsigned int) size=32]: lenx  
     000448: [FundamentalType(unsigned int) size=32]: maxpixely  
     000480: [FundamentalType(unsigned int) size=32]: maxpixelx  
     000512: [Enumeration size=32,fid: f75]: blitter  
*/
struct Ncvgeom
  var _pixy: U32 = U32(0)
  var _pixx: U32 = U32(0)
  var _cdimy: U32 = U32(0)
  var _cdimx: U32 = U32(0)
  var _rpixy: U32 = U32(0)
  var _rpixx: U32 = U32(0)
  var _rcelly: U32 = U32(0)
  var _rcellx: U32 = U32(0)
  var _scaley: U32 = U32(0)
  var _scalex: U32 = U32(0)
  var _begy: U32 = U32(0)
  var _begx: U32 = U32(0)
  var _leny: U32 = U32(0)
  var _lenx: U32 = U32(0)
  var _maxpixely: U32 = U32(0)
  var _maxpixelx: U32 = U32(0)
  var _blitter: I32 = I32(0)


/*
  Source: /usr/include/notcurses/notcurses.h:3678
  Original Name: ncreel_options
  Struct Size (bits):  384
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: bordermask  
     000064: [FundamentalType(long unsigned int) size=64]: borderchan  
     000128: [FundamentalType(unsigned int) size=32]: tabletmask  
     000192: [FundamentalType(long unsigned int) size=64]: tabletchan  
     000256: [FundamentalType(long unsigned int) size=64]: focusedchan  
     000320: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncreeloptions
  var _bordermask: U32 = U32(0)
  var _borderchan: U64 = U64(0)
  var _tabletmask: U32 = U32(0)
  var _tabletchan: U64 = U64(0)
  var _focusedchan: U64 = U64(0)
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:3886
  Original Name: ncselector_item
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(char) size=8]: option  
     000064: [PointerType size=64]->[FundamentalType(char) size=8]: desc  
*/
struct Ncselectoritem
  var _option: Pointer[U8] = Pointer[U8]
  var _desc: Pointer[U8] = Pointer[U8]


/*
  Source: /usr/include/notcurses/notcurses.h:3891
  Original Name: ncselector_options
  Struct Size (bits):  704
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(char) size=8]: title  
     000064: [PointerType size=64]->[FundamentalType(char) size=8]: secondary  
     000128: [PointerType size=64]->[FundamentalType(char) size=8]: footer  
     000192: [PointerType size=64]->[Struct size=128,fid: f75]: items  
     000256: [FundamentalType(unsigned int) size=32]: defidx  
     000288: [FundamentalType(unsigned int) size=32]: maxdisplay  
     000320: [FundamentalType(long unsigned int) size=64]: opchannels  
     000384: [FundamentalType(long unsigned int) size=64]: descchannels  
     000448: [FundamentalType(long unsigned int) size=64]: titlechannels  
     000512: [FundamentalType(long unsigned int) size=64]: footchannels  
     000576: [FundamentalType(long unsigned int) size=64]: boxchannels  
     000640: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncselectoroptions
  var _title: Pointer[U8] = Pointer[U8]
  var _secondary: Pointer[U8] = Pointer[U8]
  var _footer: Pointer[U8] = Pointer[U8]
  var _items: NullablePointer[Ncselectoritem] = NullablePointer[Ncselectoritem].none()
  var _defidx: U32 = U32(0)
  var _maxdisplay: U32 = U32(0)
  var _opchannels: U64 = U64(0)
  var _descchannels: U64 = U64(0)
  var _titlechannels: U64 = U64(0)
  var _footchannels: U64 = U64(0)
  var _boxchannels: U64 = U64(0)
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:3946
  Original Name: ncmselector_item
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(char) size=8]: option  
     000064: [PointerType size=64]->[FundamentalType(char) size=8]: desc  
     000128: [FundamentalType(bool) size=8]: selected  
*/
struct Ncmselectoritem
  var _option: Pointer[U8] = Pointer[U8]
  var _desc: Pointer[U8] = Pointer[U8]
  var _selected: Bool = Bool


/*
  Source: /usr/include/notcurses/notcurses.h:3973
  Original Name: ncmultiselector_options
  Struct Size (bits):  704
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(char) size=8]: title  
     000064: [PointerType size=64]->[FundamentalType(char) size=8]: secondary  
     000128: [PointerType size=64]->[FundamentalType(char) size=8]: footer  
     000192: [PointerType size=64]->[Struct size=192,fid: f75]: items  
     000256: [FundamentalType(unsigned int) size=32]: maxdisplay  
     000320: [FundamentalType(long unsigned int) size=64]: opchannels  
     000384: [FundamentalType(long unsigned int) size=64]: descchannels  
     000448: [FundamentalType(long unsigned int) size=64]: titlechannels  
     000512: [FundamentalType(long unsigned int) size=64]: footchannels  
     000576: [FundamentalType(long unsigned int) size=64]: boxchannels  
     000640: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncmultiselectoroptions
  var _title: Pointer[U8] = Pointer[U8]
  var _secondary: Pointer[U8] = Pointer[U8]
  var _footer: Pointer[U8] = Pointer[U8]
  var _items: NullablePointer[Ncmselectoritem] = NullablePointer[Ncmselectoritem].none()
  var _maxdisplay: U32 = U32(0)
  var _opchannels: U64 = U64(0)
  var _descchannels: U64 = U64(0)
  var _titlechannels: U64 = U64(0)
  var _footchannels: U64 = U64(0)
  var _boxchannels: U64 = U64(0)
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4020
  Original Name: nctree_item
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: curry  
     000064: [PointerType size=64]->[Struct size=192,fid: f75]: subs  
     000128: [FundamentalType(unsigned int) size=32]: subcount  
*/
struct Nctreeitem
  var _curry: Pointer[None] = Pointer[None]
  var _subs: NullablePointer[Nctreeitem] = NullablePointer[Nctreeitem].none()
  var _subcount: U32 = U32(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4026
  Original Name: nctree_options
  Struct Size (bits):  320
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[Struct size=192,fid: f75]: items  
     000064: [FundamentalType(unsigned int) size=32]: count  
     000128: [PointerType size=64]->[FunctionType] -- WRITE MANUALLY: nctreecb  
     000192: [FundamentalType(int) size=32]: indentcols  
     000256: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Nctreeoptions
  var _items: NullablePointer[Nctreeitem] = NullablePointer[Nctreeitem].none()
  var _count: U32 = U32(0)
  var _nctreecb: Pointer[None] = Pointer[None]
  var _indentcols: I32 = I32(0)
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4036
  Original Name: nctree
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Nctree


/*
  Source: /usr/include/notcurses/notcurses.h:4094
  Original Name: ncmenu_item
  Struct Size (bits):  384
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(char) size=8]: desc  
     000064: [Struct size=288,fid: f75]: shortcut  
*/
struct Ncmenuitem
  var _desc: Pointer[U8] = Pointer[U8]
  var _shortcut: Ncinput = Ncinput


/*
  Source: /usr/include/notcurses/notcurses.h:4099
  Original Name: ncmenu_section
  Struct Size (bits):  512
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(char) size=8]: name  
     000064: [FundamentalType(int) size=32]: itemcount  
     000128: [PointerType size=64]->[Struct size=384,fid: f75]: items  
     000192: [Struct size=288,fid: f75]: shortcut  
*/
struct Ncmenusection
  var _name: Pointer[U8] = Pointer[U8]
  var _itemcount: I32 = I32(0)
  var _items: NullablePointer[Ncmenuitem] = NullablePointer[Ncmenuitem].none()
  var _shortcut: Ncinput = Ncinput


/*
  Source: /usr/include/notcurses/notcurses.h:4109
  Original Name: ncmenu_options
  Struct Size (bits):  320
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[Struct size=512,fid: f75]: sections  
     000064: [FundamentalType(int) size=32]: sectioncount  
     000128: [FundamentalType(long unsigned int) size=64]: headerchannels  
     000192: [FundamentalType(long unsigned int) size=64]: sectionchannels  
     000256: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncmenuoptions
  var _sections: NullablePointer[Ncmenusection] = NullablePointer[Ncmenusection].none()
  var _sectioncount: I32 = I32(0)
  var _headerchannels: U64 = U64(0)
  var _sectionchannels: U64 = U64(0)
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4118
  Original Name: ncmenu
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Ncmenu


/*
  Source: /usr/include/notcurses/notcurses.h:4184
  Original Name: ncprogbar_options
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: ulchannel  
     000032: [FundamentalType(unsigned int) size=32]: urchannel  
     000064: [FundamentalType(unsigned int) size=32]: blchannel  
     000096: [FundamentalType(unsigned int) size=32]: brchannel  
     000128: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncprogbaroptions
  var _ulchannel: U32 = U32(0)
  var _urchannel: U32 = U32(0)
  var _blchannel: U32 = U32(0)
  var _brchannel: U32 = U32(0)
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4218
  Original Name: nctabbed_options
  Struct Size (bits):  320
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long unsigned int) size=64]: selchan  
     000064: [FundamentalType(long unsigned int) size=64]: hdrchan  
     000128: [FundamentalType(long unsigned int) size=64]: sepchan  
     000192: [PointerType size=64]->[FundamentalType(char) size=8]: separator  
     000256: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Nctabbedoptions
  var _selchan: U64 = U64(0)
  var _hdrchan: U64 = U64(0)
  var _sepchan: U64 = U64(0)
  var _separator: Pointer[U8] = Pointer[U8]
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4466
  Original Name: ncplot_options
  Struct Size (bits):  384
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long unsigned int) size=64]: maxchannels  
     000064: [FundamentalType(long unsigned int) size=64]: minchannels  
     000128: [FundamentalType(short unsigned int) size=16]: legendstyle  
     000160: [Enumeration size=32,fid: f75]: gridtype  
     000192: [FundamentalType(int) size=32]: rangex  
     000256: [PointerType size=64]->[FundamentalType(char) size=8]: title  
     000320: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncplotoptions
  var _maxchannels: U64 = U64(0)
  var _minchannels: U64 = U64(0)
  var _legendstyle: U16 = U16(0)
  var _gridtype: I32 = I32(0)
  var _rangex: I32 = I32(0)
  var _title: Pointer[U8] = Pointer[U8]
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4533
  Original Name: ncfdplane_options
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: curry  
     000064: [FundamentalType(bool) size=8]: follow  
     000128: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncfdplaneoptions
  var _curry: Pointer[None] = Pointer[None]
  var _follow: Bool = Bool
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4550
  Original Name: ncsubproc_options
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: curry  
     000064: [FundamentalType(long unsigned int) size=64]: restart_period  
     000128: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncsubprocoptions
  var _curry: Pointer[None] = Pointer[None]
  var _restart_period: U64 = U64(0)
  var _flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:4597
  Original Name: ncreader_options
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long unsigned int) size=64]: tchannels  
     000064: [FundamentalType(unsigned int) size=32]: tattrword  
     000128: [FundamentalType(long unsigned int) size=64]: flags  
*/
struct Ncreaderoptions
  var _tchannels: U64 = U64(0)
  var _tattrword: U32 = U32(0)
  var _flags: U64 = U64(0)


/*
  Source: <builtin>:0
  Original Name: __NSConstantString_tag
  Struct Size (bits):  256
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(int) size=32]: isa  
     000064: [FundamentalType(int) size=32]: flags  
     000128: [PointerType size=64]->[FundamentalType(char) size=8]: str  
     000192: [FundamentalType(long int) size=64]: length  
*/
struct NSConstantStringtag
  var _isa: Pointer[I32] = Pointer[I32]
  var _flags: I32 = I32(0)
  var _str: Pointer[U8] = Pointer[U8]
  var _length: I64 = I64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/atomic_wide_counter.h:28
  Original Name: 
  Struct Size (bits):  64
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: __low  
     000032: [FundamentalType(unsigned int) size=32]: __high  
*/
struct Anon1609
  var ___low: U32 = U32(0)
  var ___high: U32 = U32(0)


/*
  Source: <builtin>:0
  Original Name: __va_list_tag
  Struct Size (bits):  192
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: gp_offset  
     000032: [FundamentalType(unsigned int) size=32]: fp_offset  
     000064: [PointerType size=64]->[FundamentalType(void) size=0]: overflow_arg_area  
     000128: [PointerType size=64]->[FundamentalType(void) size=0]: reg_save_area  
*/
struct Valisttag
  var _gp_offset: U32 = U32(0)
  var _fp_offset: U32 = U32(0)
  var _overflow_arg_area: Pointer[None] = Pointer[None]
  var _reg_save_area: Pointer[None] = Pointer[None]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/sigevent_t.h:36
  Original Name: 
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FunctionType] -- WRITE MANUALLY: _function  
     000064: [PointerType size=64]->[UNION size=448] -- UNSUPPORTED FIXME: _attribute  
*/
struct Anon2203
  var __function: Pointer[None] = Pointer[None]
  var __attribute: Pointer[None] = Pointer[None]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:56
  Original Name: 
  Struct Size (bits):  64
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: si_pid  
     000032: [FundamentalType(unsigned int) size=32]: si_uid  
*/
struct Anon2253
  var _si_pid: I32 = I32(0)
  var _si_uid: U32 = U32(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:63
  Original Name: 
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: si_tid  
     000032: [FundamentalType(int) size=32]: si_overrun  
     000064: [UNION size=64] -- UNSUPPORTED FIXME: si_sigval  
*/
struct Anon2255
  var _si_tid: I32 = I32(0)
  var _si_overrun: I32 = I32(0)
  var _si_sigval: None = None


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:71
  Original Name: 
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: si_pid  
     000032: [FundamentalType(unsigned int) size=32]: si_uid  
     000064: [UNION size=64] -- UNSUPPORTED FIXME: si_sigval  
*/
struct Anon2257
  var _si_pid: I32 = I32(0)
  var _si_uid: U32 = U32(0)
  var _si_sigval: None = None


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:79
  Original Name: 
  Struct Size (bits):  256
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(int) size=32]: si_pid  
     000032: [FundamentalType(unsigned int) size=32]: si_uid  
     000064: [FundamentalType(int) size=32]: si_status  
     000128: [FundamentalType(long int) size=64]: si_utime  
     000192: [FundamentalType(long int) size=64]: si_stime  
*/
struct Anon2259
  var _si_pid: I32 = I32(0)
  var _si_uid: U32 = U32(0)
  var _si_status: I32 = I32(0)
  var _si_utime: I64 = I64(0)
  var _si_stime: I64 = I64(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:89
  Original Name: 
  Struct Size (bits):  256
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: si_addr  
     000064: [FundamentalType(short int) size=16]: si_addr_lsb  
     000128: [UNION size=128] -- UNSUPPORTED FIXME: _bounds  
*/
struct Anon2261
  var _si_addr: Pointer[None] = Pointer[None]
  var _si_addr_lsb: I16 = I16(0)
  var __bounds: None = None


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:108
  Original Name: 
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [FundamentalType(long int) size=64]: si_band  
     000064: [FundamentalType(int) size=32]: si_fd  
*/
struct Anon2263
  var _si_band: I64 = I64(0)
  var _si_fd: I32 = I32(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:116
  Original Name: 
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: _call_addr  
     000064: [FundamentalType(int) size=32]: _syscall  
     000096: [FundamentalType(unsigned int) size=32]: _arch  
*/
struct Anon2265
  var __call_addr: Pointer[None] = Pointer[None]
  var __syscall: I32 = I32(0)
  var __arch: U32 = U32(0)


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/siginfo_t.h:97
  Original Name: 
  Struct Size (bits):  128
  Struct Align (bits): 64

  Fields (Offset in bits):
     000000: [PointerType size=64]->[FundamentalType(void) size=0]: _lower  
     000064: [PointerType size=64]->[FundamentalType(void) size=0]: _upper  
*/
struct Anon2415
  var __lower: Pointer[None] = Pointer[None]
  var __upper: Pointer[None] = Pointer[None]


/*
  Source: /usr/include/x86_64-linux-gnu/bits/types/__locale_t.h:30
  Original Name: __locale_data
  Struct Size (bits):  
  Struct Align (bits): 

  Fields (Offset in bits):
*/
struct Localedata
