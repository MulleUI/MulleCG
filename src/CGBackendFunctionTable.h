//
// CGBackendFunctionTable.h
// MulleCG
//
// Vtable for backend framebuffer operations (mnvg* layer).
// The nanovg implementation is in MulleCGNanoVG/CGBackendFunctionTable+nanovg.m.
//
#ifndef cgbackendfunctiontable_h__
#define cgbackendfunctiontable_h__

#include <stddef.h>

typedef struct CGBackendFunctionTable
{
   // Framebuffer lifecycle (maps to mnvg*)
   void *  (*createFramebuffer)( void *ctx, int w, int h, int imageFlags);
   void    (*deleteFramebuffer)( void *ctx, void *fb);
   void    (*bindFramebuffer)( void *ctx, void *fb);      // NULL = unbind to default
   void    (*bindDrawFramebuffer)( void *ctx, void *fb);  // NULL = unbind

   // Extract nanovg texture ID from framebuffer (avoids NVGLUframebuffer->image access)
   int     (*framebufferTextureID)( void *ctx, void *fb);

} CGBackendFunctionTable;

#endif
