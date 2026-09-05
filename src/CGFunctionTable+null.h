//
//  CGFunctionTable+null.h
//  MulleCG
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
// A drawing vtable whose entries do nothing (optionally tracing the call as a
// CGContext-level operation). Installed by CGNullContext so that the C drawing
// accessors (CGContextFN(ctx)->...) resolve to safe no-ops instead of NULL
// function pointers when there is no GPU backend.
//
#ifndef cgfunctiontable_null_h__
#define cgfunctiontable_null_h__

#include "CGFunctionTable.h"
#include "CGFontFunctionTable.h"

#include <stdio.h>


//
// When YES, each no-op drawing call is logged (as a CGContext-level call, not
// an nvg call). Off by default. Toggle via CGNullContextFunctionTableSetTrace().
//
MULLE_CG_GLOBAL
void   CGNullContextFunctionTableSetTrace( BOOL flag);
MULLE_CG_GLOBAL
BOOL   CGNullContextFunctionTableGetTrace( void);

//
// Sets the trace destination and enables/disables tracing (NULL disables).
// Returns the previous trace file. Used to implement -[CGNullContext setTraceFile:].
//
MULLE_CG_GLOBAL
FILE   *CGNullContextFunctionTableSetTraceFile( FILE *file);

MULLE_CG_GLOBAL
CGFunctionTable   CGNullContextFunctionTable;


//
// Overrides only the text *drawing* slots of a font function table with no-ops
// (textColor/textBackgroundColor/clearType/text/textBox/attributedText),
// leaving the measurement slots intact. Used by CGNullContext so text drawing
// through a font-only context does not assert.
//
MULLE_CG_GLOBAL
void   CGNullContextPatchFontFunctionTable( CGFontFunctionTable *table);

#endif
