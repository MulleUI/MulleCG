//
// CGBackend.h
// MulleCG
//
// Backend struct embedded directly in CGContextBase (zero indirection).
// context is at offset 0 for backward compatibility with existing casts.
//
#ifndef cgbackend_h__
#define cgbackend_h__

#include "CGFunctionTable.h"
#include "CGBackendFunctionTable.h"

struct CGBackend
{
   void                           *context;           // opaque backend context (e.g. NVGcontext *)
   struct CGFunctionTable         functions;          // drawing vtable — embedded, no pointer indirection
   struct CGBackendFunctionTable  backendFunctions;   // framebuffer vtable — embedded
};

#endif
