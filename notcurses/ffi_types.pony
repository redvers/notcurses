// Opaque types for type-safe C pointers.
// Using struct (not primitive) avoids the risk of FFI accidentally
// passing the Pony singleton address instead of a C pointer.
//
// Public (no leading underscore) so other packages can use them in
// NullablePointer[NcNotcurses] etc.

struct NcNotcurses  // opaque: struct notcurses*
struct NcPlaneT     // opaque: struct ncplane*
struct NcReel       // opaque: struct ncreel*
struct NcProgbar    // opaque: struct ncprogbar*
struct NcTablet     // opaque: struct nctablet*
struct CFile        // opaque: FILE*
struct NcSelector       // opaque: struct ncselector*
struct NcMultiselector  // opaque: struct ncmultiselector*
struct NcReader         // opaque: struct ncreader*
