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
  var gcluster: U32 = U32(0)
  var gcluster_backstop: U8 = U8(0)
  var width: U8 = U8(0)
  var stylemask: U16 = U16(0)
  var channels: U64 = U64(0)


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
     000224: [padding 32 bits for U64 alignment]
     000256: [FundamentalType(long unsigned int) size=64]: flags
*/
struct Notcursesoptions
  var termtype: Pointer[U8] = Pointer[U8]
  var loglevel: I32 = I32(0)
  var margin_t: U32 = U32(0)
  var margin_r: U32 = U32(0)
  var margin_b: U32 = U32(0)
  var margin_l: U32 = U32(0)
  var _padding0: U32 = U32(0)
  var flags: U64 = U64(0)


/*
  Source: /usr/include/notcurses/notcurses.h:1205
  Original Name: ncinput
  Struct Size (bits):  288
  Struct Align (bits): 32

  Fields (Offset in bits):
     000000: [FundamentalType(unsigned int) size=32]: id
     000032: [FundamentalType(int) size=32]: y
     000064: [FundamentalType(int) size=32]: x
     000096: [ArrayType size=(0-4)]->[FundamentalType(char) size=8]
     000136: [FundamentalType(bool) size=8]: alt
     000144: [FundamentalType(bool) size=8]: shift
     000152: [FundamentalType(bool) size=8]: ctrl
     000160: [Enumeration size=32,fid: f75]: evtype
     000192: [FundamentalType(unsigned int) size=32]: modifiers
     000224: [FundamentalType(int) size=32]: ypx
     000256: [FundamentalType(int) size=32]: xpx
*/
struct Ncinput
  var id: U32 = U32(0)
  var y: I32 = I32(0)
  var x: I32 = I32(0)
  var utf80: U8 = U8(0)
  var utf81: U8 = U8(0)
  var utf82: U8 = U8(0)
  var utf83: U8 = U8(0)
  var utf84: U8 = U8(0)
  var alt: U8 = U8(0)
  var shift: U8 = U8(0)
  var ctrl: U8 = U8(0)
  var evtype: I32 = I32(0)
  var modifiers: U32 = U32(0)
  var ypx: I32 = I32(0)
  var xpx: I32 = I32(0)


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
  var y: I32 = I32(0)
  var x: I32 = I32(0)
  var rows: U32 = U32(0)
  var cols: U32 = U32(0)
  var userptr: Pointer[None] = Pointer[None]
  var name: Pointer[U8] = Pointer[U8]
  var resizecb: Pointer[None] = Pointer[None]
  var flags: U64 = U64(0)
  var margin_b: U32 = U32(0)
  var margin_r: U32 = U32(0)


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
  var colors: U32 = U32(0)
  var utf8: U8 = U8(0)
  var rgb: U8 = U8(0)
  var can_change_colors: U8 = U8(0)
  var halfblocks: U8 = U8(0)
  var quadrants: U8 = U8(0)
  var sextants: U8 = U8(0)
  var braille: U8 = U8(0)
