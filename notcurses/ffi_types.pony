// Opaque types for type-safe C pointers.
// Using struct (not primitive) avoids the risk of FFI accidentally
// passing the Pony singleton address instead of a C pointer.

struct _NcNotcurses  // opaque: struct notcurses*
struct _NcPlane      // opaque: struct ncplane*
struct _File         // opaque: FILE*
