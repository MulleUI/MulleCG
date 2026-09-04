# MulleCG Library Documentation for AI
<!-- Keywords: graphics, rendering, nanovg, CoreGraphics, textures, fonts, shader -->

## 1. Introduction & Purpose

MulleCG provides CoreGraphics-like 2D rendering functionality for MulleUI, wrapping the nanovg vector graphics library. It offers path drawing, shape filling/stroking, text rendering, gradients, images, textures, framebuffers, shaders, font management, and shader-based image effects. The library uses a vtable-based backend dispatch architecture (`CGFunctionTable`, `CGFontFunctionTable`, `CGBackendFunctionTable`) decoupling drawing operations from any specific backend implementation (nanovg + OpenGL provided by MulleCGNanovgGL). MulleCG does not handle animation, layouting, windowing, or events — it focuses purely on drawing. It is a foundational graphics layer within the MulleUI ecosystem.

## 2. Key Concepts & Design Philosophy

### Vtable Backend Dispatch (New Architecture)
Drawing operations are dispatched through function pointer tables (`CGFunctionTable` for draw ops, `CGFontFunctionTable` for font/text ops, `CGBackendFunctionTable` for framebuffer ops) rather than calling nanovg directly. This decouples MulleCG from any specific rendering backend and enables future backends (Vulkan, Metal, etc.). The vtable is embedded in `struct CGBackend` which lives directly in `CGContext` (`_cgBackend` ivar). Inline functions in `CGContext+Drawing.h` use `@defs(CGContext)` to reach the vtable.

### Graphics Context Model
**CGContext** is the central rendering object. The context maintains state (fonts, textures, shaders, framebuffers) and is tied to an OpenGL context and thread. Rendering occurs between `beginRender:` and `endRender` calls, with support for both onscreen and offscreen rendering via framebuffers. `CGContextBase` manages thread ownership and resources. `CGLayoutContext` adds font management. `CGContext` adds full drawing capabilities.

### Split Save/Restore (Font vs. Draw)
`CGContextSave` saves both font and draw state separately. `CGLayoutContextSave`/`CGLayoutContextRestore` operate only on font state. This allows contexts that only do font layout (no drawing) to use a lightweight font-only backend.

### Coordinate System & Pixel-Perfect Drawing
The coordinate system addresses **spaces between pixels**, not pixels directly. For pixel-perfect drawing:
- **Fill operations**: Use `CGRectMake(1, 1, 3, 1)` to fill 3 horizontal pixels
- **Stroke operations**: Account for stroke width emanating perpendicular to the path
- **Combining stroke and fill**: Use `CGRectMakeStrokeRect()` and `CGRectMakeFillRect()` with `CGInside`, `CGOutside`, or `CGOverlap` relations

### Paint Abstraction
**CGPaint** is an abstract base for fill/stroke styles, encompassing solid colors, gradients (`CGGradient` and subclasses), images/textures (`CGImage`), blended paints (`CGBlendedPaint`), and image paints (`CGImagePaint`). This allows uniform handling of different paint types. Paints are immutable (except `CGFramebuffer`). Transform methods return new paint instances.

### Resource Management
CGContext manages **GPU resources** (textures, fonts, shaders, framebuffers) with lifecycle tied to the context. Resources are not thread-safe by default and are bound to the active thread. The `CGContextResource` protocol (`didRemoveFromContext:`) tracks resource cleanup.

## 3. Core API & Data Structures

### 3.1. `CGBackend.h` — Backend Dispatch Foundation

**`struct CGBackend`** — Embedded in `CGContext._cgBackend`. Contains:
- `context` (void *): Opaque backend context (e.g., `NVGcontext *`)
- `devicePointer` (void *): D3D11/Vulkan/Metal device (nil for OpenGL)
- `flags` (NSUInteger): Backend creation flags
- `functions` (struct CGFunctionTable): Drawing vtable — embedded, no pointer indirection
- `backendFunctions` (struct CGBackendFunctionTable): Framebuffer vtable — embedded

### 3.2. `CGFunctionTable.h` — Drawing Backend Vtable

**`struct CGFunctionTable`** — Function pointers for all drawing operations. The nanovg implementation lives in MulleCGNanovgGL.

**State management:** `save(vg)`, `restore(vg)`, `reset(vg)`

**Frame management:** `beginFrame(vg, windowSize, devicePixelRatio)`, `cancelFrame(vg)`, `endFrame(vg)`

**Composite operations:** `globalCompositeOperation(vg, op)`, `globalCompositeBlendFunc(vg, sfactor, dfactor)`, `globalCompositeBlendFuncSeparate(vg, srcRGB, dstRGB, srcAlpha, dstAlpha)`

**Transform operations:** `resetTransform(vg)`, `transform(vg, xform)`, `currentTransform(vg)`, `translate(vg, p)`, `rotate(vg, rotation)`, `scale(vg, v)`, `skewX(vg, angle)`, `skewY(vg, angle)`

**Image operations:** `createImage(vg, filename, textureFlags)`, `createImageMem(vg, textureFlags, data, ndata)`, `createImageRGBA(vg, w, h, textureFlags, data)`, `updateImage(vg, image, data)`, `imageSize(vg, image)`, `deleteImage(vg, image)`

**Scissor:** `scissor(vg, rect)`, `intersectScissor(vg, rect)`, `resetScissor(vg)`

**Render style:** `shapeAntiAlias(vg, enable)`, `bezierTessellation(vg, mode)`, `strokeColor(vg, color)`, `fillColor(vg, color)`, `miterLimit(vg, limit)`, `strokeWidth(vg, size)`, `lineCap(vg, cap)`, `lineJoin(vg, join)`, `globalAlpha(vg, alpha)`

**Path operations:** `beginPath(vg)`, `moveTo(vg, point)`, `lineTo(vg, point)`, `bezierTo(vg, control1, control2, point)`, `quadTo(vg, control, point)`, `arcTo(vg, tangent1, tangent2, radius)`, `closePath(vg)`, `pathWinding(vg, style)`

**Shape operations:** `rect(vg, rect)`, `roundedRect(vg, rect, r)`, `roundedRectVarying(vg, rect, insets)`, `ellipse(vg, center, rx, ry)`, `arc(vg, circle, angle, rotation)`, `arcRadians(vg, circle, radians1, radians2, dir)`, `fill(vg)`, `stroke(vg)`, `addCGPath(vg, path)`, `copyPath(vg, src_vg)`, `precompilePath(vg)`

**Paint style:** `setFillLinearGradient(vg, start, end, startColor, endColor)`, `setStrokeLinearGradient(...)`, `setFillBoxGradient(vg, rect, cornerRadius, color, feather, featherColor)`, `setStrokeBoxGradient(...)`, `setFillRadialGradient(vg, circle, outerColor, innerRadius, innerColor)`, `setStrokeRadialGradient(...)`, `setFillImagePattern(vg, textureID, rect, rotation, alpha)`, `setStrokeImagePattern(...)`

**Debug:** `trace(vg, fp)`, `traceComment(vg, comment)`

### 3.3. `CGFontFunctionTable.h` — Font/Text Backend Vtable

**`struct CGFontFunctionTable`** — Function pointers for font and text operations.

**State:** `save(vg)`, `restore(vg)`, `reset(vg)`

**Font management:** `createFont(vg, name, filename)`, `createFontMem(vg, name, data, length, freeData)`, `findFont(vg, name)`, `addFallbackFontId(vg, baseFont, fallbackFont)`, `addFallbackFont(vg, baseFont, fallbackFont)`, `resetFallbackFontsId(vg, baseFont)`, `resetFallbackFonts(vg, baseFont)`

**Text style:** `fontSize(vg, size)`, `fontBlur(vg, blur)`, `textLetterSpacing(vg, spacing)`, `textLineHeight(vg, lineHeight)`, `textAlign(vg, align)`, `fontFaceId(vg, fontID)`, `fontFace(vg, fontname)`, `textColor(vg, color)`, `textBackgroundColor(vg, color)`, `clearType(vg, enable)`

**Text drawing/measurement:** `text(vg, point, s, length)`, `textBox(vg, point, breakRowWidth, s, length)`, `textBounds(vg, point, s, length)`, `textVisualBounds(vg, point, s, length)`, `textBoxBounds(vg, point, s, length, breakRowWidth, bbox)`, `textGlyphPositions(vg, point, s, length, positions, maxPositions)`, `textBreakLines(vg, s, length, breakRowWidth, rows, maxRows, textRowSize)`, `textMetrics(vg)`, `getFontHandle(vg, font)`

**Attributed text:** `attributedText(vg, point, s, length, attributes, nAttributes)`

### 3.4. `CGBackendFunctionTable.h` — Framebuffer Backend Vtable

**`struct CGBackendFunctionTable`**
- `createFramebuffer(ctx, w, h, imageFlags)`
- `deleteFramebuffer(ctx, fb)`
- `bindFramebuffer(ctx, fb)` — NULL unbinds to default
- `bindDrawFramebuffer(ctx, fb)` — NULL unbinds
- `framebufferTextureID(ctx, fb)` — extract nanovg texture ID from framebuffer

### 3.5. `CGContext+Drawing.h` — Drawing Operations (vtable-dispatched)

All functions below are `static inline` and dispatch through the vtable via `@defs(CGContext)`. Helper macros:

```c
#define CGContextVG(ctx)   (((struct{ @defs(CGContext); } *)(ctx))->_cgBackend.context)
#define CGContextFN(ctx)   (&((struct{ @defs(CGContext); } *)(ctx))->_cgBackend.functions)
#define CGContextBFN(ctx)  (&((struct{ @defs(CGContext); } *)(ctx))->_cgBackend.backendFunctions)
#define CGContextFontVG(ctx)  (((struct{ @defs(CGLayoutContext); } *)(ctx))->_fontContext)
#define CGContextFontFN(ctx)  (&((struct{ @defs(CGLayoutContext); } *)(ctx))->_fontFunctions)
```

#### Frame Management
```c
void CGContextBeginFrame(CGContext *context, CGSize windowSize, CGFloat devicePixelRatio)
void CGContextCancelFrame(CGContext *context)
void CGContextEndFrame(CGContext *context)
```

#### Split State Management
```c
void CGLayoutContextSave(CGLayoutContext *context)      // font state only
void CGLayoutContextRestore(CGLayoutContext *context)   // font state only
void CGLayoutContextReset(CGLayoutContext *context)     // font state only
void CGContextSave(CGContext *context)                   // font + draw state
void CGContextRestore(CGContext *context)                // font + draw state
void CGContextReset(CGContext *context)                  // font + draw state
```

#### Render Style
```c
void CGContextShapeAntiAlias(CGContext *context, BOOL enable)
void CGContextBezierTessellation(CGContext *context, CGTessellation mode)
void CGContextStrokeColor(CGContext *context, CGColor color)
void CGContextFillColor(CGContext *context, CGColor color)
void CGContextMiterLimit(CGContext *context, CGFloat limit)
void CGContextStrokeWidth(CGContext *context, CGFloat size)
void CGContextLineCap(CGContext *context, NSInteger cap)
void CGContextLineJoin(CGContext *context, NSInteger join)
void CGContextGlobalAlpha(CGContext *context, CGFloat alpha)
```

#### Composite Operations
```c
void CGContextGlobalCompositeOperation(CGContext *context, NSInteger op)
void CGContextGlobalCompositeBlendFunc(CGContext *context, NSUInteger sfactor, NSUInteger dfactor)
void CGContextGlobalCompositeBlendFuncSeparate(CGContext *context, NSUInteger srcRGB, NSUInteger dstRGB, NSUInteger srcAlpha, NSUInteger dstAlpha)
```

#### Transform Operations
```c
void CGContextResetTransform(CGLayoutContext *context)
void CGContextTransform(CGLayoutContext *context, CGAffineTransform *xform)
void CGContextTranslate(CGContext *context, CGPoint p)
void CGContextRotate(CGContext *context, CARotation rotation)
void CGContextScale(CGContext *context, CGVector v)
void CGContextSkewX(CGContext *context, CAAngle angle)
void CGContextSkewY(CGContext *context, CAAngle angle)
CGAffineTransform CGContextCurrentTransform(CGContext *context)
```

#### Scissor Operations
```c
void CGContextScissor(CGContext *context, CGRect rect)
void CGContextIntersectScissor(CGContext *context, CGRect rect)
void CGContextResetScissor(CGContext *context)
```

#### Image/Texture Operations
```c
CGTextureID CGContextCreateImage(CGContext *context, char *filename, NSUInteger textureFlags)
CGTextureID CGContextCreateImageMem(CGContext *context, NSInteger textureFlags, void *data, size_t ndata)
CGTextureID CGContextCreateImageRGBA(CGContext *context, struct CGPixelSize size, NSUInteger textureFlags, void *data)
void CGContextUpdateImage(CGContext *context, CGTextureID image, void *data)
CGPixelSize CGContextImageSize(CGContext *context, CGTextureID image)
void CGContextDeleteImage(CGContext *context, CGTextureID image)
```

#### Path Operations
```c
void CGContextBeginPath(CGContext *context)
void CGContextMoveTo(CGContext *context, CGPoint point)
void CGContextLineTo(CGContext *context, CGPoint point)
void CGContextBezierTo(CGContext *context, CGPoint control1, CGPoint control2, CGPoint point)
void CGContextQuadTo(CGContext *context, CGPoint control, CGPoint point)
void CGContextArcTo(CGContext *context, CGPoint tangent1, CGPoint tangent2, CGFloat radius)
void CGContextClosePath(CGContext *context)
void CGContextPathWinding(CGContext *context, CGPathFillStyle style)
void CGContextArc(CGContext *context, CACircle circle, CAAngle angle, CARotation rotation)
void CGContextArcFromAngleToAngle(CGContext *context, CACircle circle, CAAngle startAngle, CAAngle endAngle, CARotationDirection dir)
void CGContextArcRadians(CGContext *context, CACircle circle, CGFloat radians1, CGFloat radians2, CARotationDirection dir)
```

#### Shape Operations
```c
void CGContextRect(CGContext *context, CGRect rect)
void CGContextRoundedRect(CGContext *context, CGRect rect, CGFloat r)
void CGContextRoundedRectVarying(CGContext *context, CGRect rect, struct MulleCornerInsets insets)
void CGContextEllipse(CGContext *context, CGPoint center, CGFloat rx, CGFloat ry)
void CGContextCircle(CGContext *context, CACircle circle)         // convenience inline -> ellipse
void CGContextFill(CGContext *context)
void CGContextStroke(CGContext *context)
```

#### Advanced Path Operations
```c
void CGContextAddCGPath(CGContext *context, CGPathRef path)
void CGContextCopyPath(CGContext *context, CGContext *src)
void CGContextPrecompilePath(CGContext *context)
```

#### Gradient & Image Pattern Setters
```c
void CGContextSetFillLinearGradient(CGContext *context, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor)
void CGContextSetStrokeLinearGradient(CGContext *context, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor)
void CGContextSetFillBoxGradient(CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor)
void CGContextSetStrokeBoxGradient(CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor)
void CGContextSetFillRadialGradient(CGContext *context, CACircle circle, CGColor outerColor, CGFloat innerRadius, CGColor innerColor)
void CGContextSetStrokeRadialGradient(CGContext *context, CACircle circle, CGColor outerColor, CGFloat innerRadius, CGColor innerColor)
void CGContextSetFillImagePattern(CGContext *context, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha)
void CGContextSetStrokeImagePattern(CGContext *context, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha)
```

#### Font Operations (vtable-dispatched via CGLayoutContext)
```c
CGFontID CGContextCreateFont(CGLayoutContext *context, char *name, char *filename)
CGFontID CGContextCreateFontMem(CGLayoutContext *context, char *name, void *data, size_t length, BOOL freeData)
CGFontID CGContextFindFont(CGLayoutContext *context, char *name)
CGFontID CGContextAddFallbackFontId(CGLayoutContext *context, CGFontID baseFont, CGFontID fallbackFont)
CGFontID CGContextAddFallbackFont(CGLayoutContext *context, char *baseFont, char *fallbackFont)
void CGContextResetFallbackFontsId(CGLayoutContext *context, NSInteger baseFont)
void CGContextResetFallbackFonts(CGLayoutContext *context, char *baseFont)
void CGContextFontSize(CGLayoutContext *context, CGFloat size)
void CGContextFontBlur(CGLayoutContext *context, CGFloat blur)
void CGContextTextLetterSpacing(CGLayoutContext *context, CGFloat spacing)
void CGContextTextLineHeight(CGLayoutContext *context, CGFloat lineHeight)
void CGContextCombinedTextAlignment(CGLayoutContext *context, CGCombinedTextAlign align)
void CGContextTextAlignment(CGLayoutContext *context, UITextAlignment alignment)
void CGContextFontFaceId(CGLayoutContext *context, CGFontID fontID)
void CGContextClearType(CGLayoutContext *context, BOOL enable)
void CGContextTextColor(CGLayoutContext *context, CGColor color)
void CGContextTextBackgroundColor(CGLayoutContext *context, CGColor color)
```

#### Text Drawing & Measurement
```c
CGFloat CGContextText(CGContext *context, CGPoint point, char *s, size_t length)
void CGContextTextBox(CGContext *context, CGPoint point, CGFloat breakRowWidth, char *s, size_t length)
CGFloat CGContextAttributedText(CGContext *context, CGPoint point, char *s, size_t length, struct CGTextAttribute *attributes, int nAttributes)
CGTextBoundsInfo CGContextTextBoundsInfo(CGLayoutContext *context, CGPoint point, char *s, size_t length)
CGRect CGContextTextVisualBounds(CGLayoutContext *context, CGPoint point, char *s, size_t length)
CGRect CGContextTextBoxBounds(CGLayoutContext *context, CGPoint point, char *s, size_t length, CGFloat breakRowWidth)
NSUInteger CGContextTextGlyphPositions(CGLayoutContext *context, CGPoint point, char *s, size_t length, struct UIGlyphPosition *positions, NSInteger maxPositions)
NSUInteger CGContextTextBreakLines(CGLayoutContext *context, char *s, size_t length, CGFloat breakRowWidth, struct UITextRow *rows, NSInteger maxRows, size_t UITextRowSize)
CGTextMetrics CGContextTextMetrics(CGLayoutContext *context)
void *CGContextGetFontHandle(CGLayoutContext *context, int font)
```

#### Trace/Debug
```c
void _CGContextTrace(CGContext *context, FILE *fp)
void _CGContextTraceComment(CGContext *context, char *format, ...)
// Macro wrappers (only active in DEBUG or CG_CONTEXT_TRACE_ENABLED):
#define CGContextTrace(context, fp)
#define CGContextTraceComment(context, format, ...)
```

#### CGContextDo Macro
```c
#define CGContextDo(context)   // save context, run block, restore context
```

### 3.6. `CGContextBase.h` — Context Foundation

#### `@interface CGContextBase : MulleObject <MulleUIResourceMap, MulleUINamedObject>`

**Properties:**
- `OSWindow` (id, readonly, threadsafe)
- `debuggingFlags` (NSUInteger, readonly, threadsafe)
- `nameUTF8String` (char *, readonly, threadsafe)
- `state` (NSUInteger, dynamic, threadsafe)

**Initializers:**
```objc
- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context nameUTF8String:(char *) name
- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
```

**Core Operations:**
```objc
- (NSThread *) activeThread  MULLE_OBJC_THREADSAFE_METHOD
- (void *) backendContext
+ (void) setDebuggingFlags:(NSUInteger) flag  MULLE_OBJC_THREADSAFE_METHOD
+ (NSUInteger) debuggingFlags                 MULLE_OBJC_THREADSAFE_METHOD
```

**Future Category (backend init/done):**
```objc
- (void) _initGraphicsBackend
- (void) _doneGraphicsBackend
- (void) _initFontBackend
- (void) _doneFontBackend
```

**Inline Accessors:**
```c
void *CGContextBaseGetBackendContext(CGContextBase *self)
void *_CGContextBaseGetBackendContext(CGContextBase *self)
```

### 3.7. `CGLayoutContext.h` — Font & Text Layout Base

#### `@interface CGLayoutContext : CGContextBase <UILayoutContext>`

Ivars: `_fontContext` (void *), `_fontFunctions` (struct CGFontFunctionTable), `_fontMap`, `_ownsFontContext` (BOOL), `_hasLoadedFont` (BOOL), `_defaultFontName` (char *)

**Properties:**
- `traceDrawCalls` (BOOL, threadsafe) — enable logging of draw operations

**Core Operations:**
```objc
- (BOOL) hasLoadedFont
- (BOOL) useFontWithNameUTF8String:(char *) name
- (CGFloat) fontSizeThatFitsIntoSize:(CGSize) size
- (struct CGTextMetrics) visualTextMetrics
```

### 3.8. `CGContext.h` — Main Rendering Context

#### `@interface CGContext : CGLayoutContext`

**Protocols:** `CGContextResource` — `- (void) didRemoveFromContext:(CGContext *) context`

**Key Ivars:** `_cgBackend` (struct CGBackend), `_currentFrameInfo`, `_currentFramebuffer`, `_viewport` (CGPixelRect), `_gpuTextureMap`, `_shaderMap`, `_deletedTextureIDs`, `_deletedGPUFramebuffers`, `_isRendering` (BOOL), `_isFreshLayer` (BOOL), `_activeShader` (CGShaderID), `_firstRenderTimeStamp`, `_atomicInitializedFramebuffer`, `_renderFramebuffer` (CGFramebuffer *)

**Framebuffer Types:**
```c
typedef NS_ENUM(NSUInteger, CGContextFramebufferType)
// CGContextDefaultFramebuffer, CGContextLayerFramebuffer, CGContextOpenGLFramebuffer
// CGContextDefaultMultiSampleFramebuffer, CGContextLayerMultiSampleFramebuffer, CGContextOpenGLMultiSampleFramebuffer
```

**Properties:**
- `shareID` (BOOL, assign, readonly)
- `rendersOffScreen` (BOOL, assign)
- `framebufferBits` (NSUInteger, assign)
- `backend` (UIGraphicsBackend, assign, readonly)
- `contextID` (NSUInteger, readonly)
- `numberOfFrames` (NSUInteger, assign)
- `inputState` (struct UIInputState, assign)
- `initializedFramebuffer` (BOOL, dynamic, threadsafe)

**Initializers (designated):**
```objc
- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context nameUTF8String:(char *) nameUTF8String shareID:(NSUInteger) shareID options:(UIGraphicsOptions) options
- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context shareID:(NSUInteger) shareID options:(UIGraphicsOptions) options
```

**Core Operations:**
```objc
+ (char *) backendUTF8String
- (char *) backendUTF8String
- (void) getCurrentFrameInfo:(struct CGFrameInfo *) info
- (struct CGFrameInfo *) currentFrameInfo
- (NSUInteger) numberOfFrames
- (mulle_relativetime_t) secondsSinceFirstRender
- (CGFloat) alpha
- (CGShaderID) activeShader
- (CGPoint) mouseLocation
- (NSUInteger) keyModifiers
- (NSUInteger) buttonStates
- (struct UIKeyStates) keyStates
- (CGFloat) fontScale
- (FILE *) setTraceFile:(FILE *) file
```

**Inline Helpers:**
```c
BOOL CGContextIsActiveInCurrentThread(CGContextRef self)
void *CGContextGetBackendContext(CGContextRef self)
void *_CGContextGetBackendContext(CGContextRef self)
struct CGFunctionTable *_CGContextGetFunctionTable(CGContextRef self)
float CGContextGetBackAndForthAnimationFactor(CGContext *context, NSUInteger rate)
float CGContextGetLinearAnimationFactor(CGContext *context, NSUInteger rate)
```

### 3.9. `CGContext+Render.h` — Rendering Lifecycle

#### `@protocol CGRenderObject`
```objc
- (void) renderInContext:(CGContext *) context
```

#### Render Pass
```objc
- (void) renderObjects:(struct mulle_pointerarray *) layers
- (void) beginRender:(struct CGFrameInfo *) info
- (struct CGFrameInfo) bindRender:(struct CGFrameInfo *) info
- (void) endRender
- (CGFramebuffer *) _endRender
- (BOOL) isRendering
```

#### Render Future (provided by nanovg backend)
```objc
+ (BOOL) supportsAntiAliasing
- (void) setViewport:(CGPixelRect) rect
- (CGPixelRect) viewport
- (void) suspendRender
- (void) flushRender
- (void) resumeRender
- (void) changeRender:(struct CGFrameInfo *) info
- (void) reset
- (void *) gpuTextureForImageID:(NSInteger) textureID
- (struct CGBitmap) readFramebufferBitmap:(CGPixelRect) rect framebufferBitmapType:(CGFramebufferBitmapType) type allocator:(struct mulle_allocator *) allocator
- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image allocator:(struct mulle_allocator *) allocator
```

#### MultiSample
```objc
- (CGImage *) resolveMultiSampleImage:(CGImage *) image
```

### 3.10. `CGContext+DrawingConveniences.h` — High-Level Drawing

Convenience C functions building on `CGContext+Drawing.h`:

```c
void CGContextFillWithColor(CGContext *, CGColor)
void CGContextFillRectWithColor(CGContext *, CGRect, CGColor)
void CGContextFillRoundedRectWithColor(CGContext *, CGRect, CGFloat cornerRadius, CGColor)
void CGContextFillCircleWithColor(CGContext *, CACircle, CGColor)
void CGContextFillCircleWithGradientColors(CGContext *, CACircle, CGColor outerColor, CGColor innerColor)
void CGContextStrokeWithColor(CGContext *, CGFloat strokeWidth, CGColor)
void CGContextStrokeRectWithColor(CGContext *, CGRect, CGFloat strokeWidth, CGColor)
void CGContextStrokeRoundedRectWithColor(CGContext *, CGRect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor)
void CGContextStrokeInsideOfRectWithColor(CGContext *, CGRect, CGFloat strokeWidth, CGColor)
void CGContextStrokeInsideOfRoundedRectWithColor(CGContext *, CGRect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor)
void CGContextStrokeLineWithColor(CGContext *, CGPoint start, CGPoint end, CGFloat strokeWidth, CGColor)
void CGContextStrokeLineHWithColor(CGContext *, CGPoint p, CGFloat w, CGFloat strokeWidth, CGColor)
void CGContextStrokeLineVWithColor(CGContext *, CGPoint p, CGFloat h, CGFloat strokeWidth, CGColor)
void CGContextStrokeCircleWithColor(CGContext *, CACircle circle, CGFloat strokeWidth, CGColor)
void CGContextStrokeCircleWithGradientColors(CGContext *, CACircle, CGColor outerColor, CGColor innerColor, CGFloat strokeWidth)
void CGContextFillRoundedShadow(CGContext *, CGRect rect, CGFloat cornerRadius, struct CGShadow *shadow)
void CGContextFormatInRect(CGContext *, CGRect rect, CGContentMode contentMode, CGTextOptions options, char *format, ...)
void CGContextFormat(CGContext *, CGPoint point, char *format, ...)
CGPoint CGContextTLAdjustmentForVisualBounds(CGLayoutContext *, char *s, size_t length, int alignment, CGTextOptions options)
void CGContextTextInRect(CGContext *, char *s, size_t length, CGRect rect, CGContentMode contentMode, CGTextOptions options)
struct CGTextBoundsInfo CGContextTextBoundsOptions(CGContext *, char *s, size_t length, CGRect rect, CGContentMode contentMode, CGTextOptions options)
void CGContextExtendedAlignedText(CGContext *, char *s, size_t length, CGPoint origin, int alignment, CGTextOptions options)
```

### 3.11. `CGContext+UIGraphicsDrawing.h` — Text & Icon Drawing

```objc
@interface CGContext( UIGraphicsDrawing) <UIGraphicsDrawing>
- (void) drawIcon:(mulle_utf32_t) icon atPoint:(CGPoint) point
```

Inline helpers:
```c
void CGContextDrawText(CGContext *self, CGFloat x, CGFloat y, char *s, CGFloat fontSize, CGColor color)
void CGContextDrawIconInRect(CGContext *self, mulle_utf32_t icon, CGRect rect)
void CGContextFontFace(CGLayoutContext *context, char *fontname)
```

### 3.12. `CGContext+Texture.h` — Texture Management

```c
typedef void *CGGPUTextureID
typedef void CGGPUFramebuffer
```

```objc
@interface CGContext( TextureFuture) <MulleObjCFuture>
- (CGTextureID) textureIDWithRGBABytes:(void *) bytes bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) textureFlags
- (CGTextureID) textureIDWithFileCData:(struct mulle_data) fileCData textureFlags:(NSUInteger) textureFlags
- (CGTextureID) textureIDWithContentsOfFileUTF8String:(char *) filename textureFlags:(NSUInteger) textureFlags
- (CGTextureID) textureIDWithGPUTexture:(CGGPUTextureID) gpuTexture bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) textureFlags
- (void) deleteTextureID:(CGTextureID) textureID
- (void) forgetTextureID:(CGTextureID) textureID
- (void) deleteGPUFramebuffer:(CGGPUFramebuffer *) gpuFramebuffer
- (CGGPUTextureID) gpuTextureForTextureID:(CGTextureID) textureID
- (void) setRGBABytes:(void *) bytes forTextureID:(CGTextureID) textureID
- (CGPixelSize) bitmapSizeForTextureID:(CGTextureID) textureID
```

### 3.13. `CGContext+CGImage.h` — Image Creation Within Context

```objc
@interface CGContext( CGImage)
- (CGImage *) imageWithRGBABytes:(void *) bytes bitmapSize:(CGPixelSize) bitmapSize textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String resourceKey:(MulleUIResourceStorageKey_t) resourceKey
- (CGImage *) imageWithBitmap:(struct CGBitmap) bitmap textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String resourceKey:(MulleUIResourceStorageKey_t) resourceKey
- (CGImage *) imageWithContentsOfFileUTF8String:(char *) filename textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String resourceKey:(MulleUIResourceStorageKey_t) resourceKey
- (CGImage *) imageWithFileCData:(struct mulle_data) fileCData textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String resourceKey:(MulleUIResourceStorageKey_t) resourceKey
```

### 3.14. `CGContext+Shader.h` — Shader Management

```objc
@interface CGContext( Shader)
- (CGShaderID) useShaderWithNameUTF8String:(char *) name
- (void) deleteShaderWithNameUTF8String:(char *) name
- (void) deleteShaders
- (CGShaderID) compileShaderWithShaderSources:(struct CGShaderUTF8Sources *) source
- (CGShaderID) compileShaderWithNameUTF8String:(char *) name
- (CGShaderID) shaderWithNameUTF8String:(char *) name       // compiles on demand
- (CGShaderID) _shaderWithNameUTF8String:(char *) name      // no compile on demand
- (void) useShader:(CGShaderID) shaderID
- (void) deleteShader:(CGShaderID) shaderID
+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources
+ (void) registerShaderSources:(struct CGShaderUTF8Sources *) sources forNameUTF8String:(char *) nameUTF8String
- (struct CGShaderUTF8Sources *) registeredShaderSourcesForNameUTF8String:(char *) nameUTF8String
```

### 3.15. `CGContext+ImageEffect.h` — Shader-Based Image Effects

```c
typedef void CGShaderSetupCallback(CGShaderID shader, void *userInfo)

enum CGUniformType { CGUniformTypeFloat, CGUniformTypeVec2, CGUniformTypeVec4, CGUniformTypeInt }

struct CGUniform {
    char *name;
    enum CGUniformType type;
    union { float floatValue; float vec2[2]; float vec4[4]; int intValue; };
}
```

```objc
@interface CGContext( ImageEffectFuture) <MulleObjCFuture>
- (CGImage *) imageByRenderingImage:(CGImage *) image withShader:(CGShaderID) shader uniforms:(struct CGUniform *) uniforms count:(NSUInteger) count
- (CGImage *) imageByRenderingImage:(CGImage *) image withShader:(CGShaderID) shader setupCallback:(CGShaderSetupCallback *) setup userInfo:(void *) info
```

### 3.16. `CGContext+CGFramebuffer.h` — Framebuffer Management

```objc
@interface CGContext( CGFramebuffer)
- (struct CGContextFramebuffer) bindFramebuffer:(struct CGContextFramebuffer) fb
- (struct CGContextFramebuffer) currentFramebuffer
- (void) clearFramebuffer
- (void) clearFramebufferWithHexColor:(NSUInteger) color
- (void) clearFramebufferWithColor:(CGColor) color
- (BOOL) needsFramebufferClear
- (CGFramebuffer *) framebufferWithSize:(CGPixelSize) size textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String
- (id) acquireRenderedFramebuffer              MULLE_OBJC_THREADSAFE_METHOD
- (void) recycleAcquiredRenderedFramebuffer:(id) layer  MULLE_OBJC_THREADSAFE_METHOD
- (id) repossessRenderedFramebuffer
- (void) provideRenderedFramebuffer:(CGFramebuffer *) framebuffer
- (void) recycleRenderedFramebuffer:(CGFramebuffer *) framebuffer
- (void) queueRenderedFramebufferForDeletion:(CGFramebuffer *) framebuffer  MULLE_OBJC_THREADSAFE_METHOD
- (void) deleteRenderedFramebuffers
```

```c
CGPixelSize CGContextBitmapSizeOfFramebuffer(CGContext *self, struct CGContextFramebuffer fb)
```

### 3.17. `CGPaint.h` — Abstract Paint Base

#### `@interface CGPaint : NSObject <MulleObjCValueProtocols>`

**Factory Methods:**
```objc
+ (CGPaint *) paintWithColor:(CGColor) color
+ (CGPaint *) paintWithHexColor:(CGHexColor) color
+ (CGPaint *) paintWithStartColor:(CGColor) startColor endColor:(CGColor) endColor
+ (CGPaint *) paintWithStartColor:(CGColor) startColor endColor:(CGColor) endColor rotation:(CARotation) rotation
+ (instancetype) paintWithPaint:(CGPaint *) paint otherPaint:(CGPaint *) otherPaint blend:(CGFloat) blend rotation:(CARotation) rotation   // from CGBlendedPaint category
+ (instancetype) paintWithImage:(CGImage *) image rotation:(CARotation) rotation alpha:(CGFloat) alpha                                    // from CGImagePaint category
```

**Inspection:**
```objc
- (CGColor) mainColor
- (CGColor) suggestedTextColor
- (BOOL) isTexture        // default: YES
- (BOOL) isGradient       // default: NO
- (BOOL) isMonochrome
- (BOOL) isOpaque
- (CGFloat) alpha         // default: 1.0
- (BOOL) needsBounds      // mono color: NO
```

**Transform Methods (return new paint; mono colors return self):**
```objc
- (CGPaint *) brightenedPaint:(CGFloat) brighten
- (CGPaint *) desaturatedPaint:(CGFloat) factor
- (CGPaint *) dimmedPaint:(CGFloat) dim
- (CGPaint *) reversedPaint
- (CGPaint *) rotatedPaint:(CARotation) rotation
- (CGPaint *) saturatedPaint:(CGFloat) factor
- (CGPaint *) transparentPaint:(CGFloat) alpha
```

**Misc:**
```objc
- (CGFloat) overdraw
- (CGImage *) image
- (CGImage *) otherImage
```

**Subclasses category:**
```objc
@property( readonly) CARotation rotation
```

### 3.18. `CGGradient.h` — Gradient Paint

#### `@interface CGGradient : CGPaint <MulleObjCClassCluster, NSCopying, MulleObjCValueProtocols>`

```objc
@property( readonly) CARotation rotation
```

**Factory Methods:**
```objc
+ (instancetype) gradientWithStartColor:(CGColor) startColor endColor:(CGColor) endColor rotation:(CARotation) rotation
+ (instancetype) gradientWithColors:(CGColor *) colors locations:(CGFloat *) locations count:(NSUInteger) count rotation:(CARotation) rotation
+ (instancetype) gradientWithStartColor:(CGColor) startColor endColor:(CGColor) endColor  // default rotation
+ (instancetype) gradientWithColors:(CGColor *) colors locations:(CGFloat *) locations count:(NSUInteger) count  // default rotation
```

**Initializers:**
```objc
- (instancetype) initWithStartColor:(CGColor) startColor endColor:(CGColor) endColor rotation:(CARotation) rotation
- (instancetype) initWithColors:(CGColor *) colors locations:(CGFloat *) locations count:(NSUInteger) count rotation:(CARotation) rotation
- (instancetype) initWithStartColor:(CGColor) startColor endColor:(CGColor) endColor
- (instancetype) initWithColors:(CGColor *) colors locations:(CGFloat *) locations count:(NSUInteger) count
```

**Transform:**
```objc
- (CGGradient *) gradientByChangingColorsWithFunction:(CGColor (*)(CGColor, void *)) f userInfo:(void *) userInfo
- (BOOL) __isCGGradient MULLE_OBJC_THREADSAFE_METHOD
```

**C Functions:**
```c
CGGradient *CGGradientCreateWithRotation(CGColor startColor, CGColor endColor, CARotation rotation)
CGGradient *CGGradientCreate(CGColor startColor, CGColor endColor)  // inline, rotation=0
```

**Subclass Methods:**
```objc
- (CGColor) startColor; - (CGColor) endColor; - (CARotation) rotation
- (NSUInteger) numberOfColors
- (CGFloat) locationAtIndex:(NSUInteger) i
- (CGColor) colorAtIndex:(NSUInteger) i
- (void) getColors:(CGColor *) colors
- (void) getLocations:(CGFloat *) locations
```

#### Subclass Convenience Factory Methods

```objc
@interface CGGradient( CGGradientSubclasses)
+ (instancetype) linearGradientWithStartPoint:(CGPoint) startPoint startColor:(CGColor) startColor endPoint:(CGPoint) endPoint endColor:(CGColor) endColor
+ (instancetype) linearGradientWithRect:(CGRect) rect startColor:(CGColor) startColor endColor:(CGColor) endColor rotation:(CARotation) rotation
+ (instancetype) boxGradientWithRoundedRect:(CGRect) rect cornerRadius:(CGFloat) cornerRadius color:(CGColor) color feather:(CGFloat) feather featherColor:(CGColor) endColor
+ (instancetype) radialGradientWithCircle:(CACircle) circle color:(CGColor) outerColor innerRadius:(CGFloat) innerRadius innerColor:(CGColor) innerColor
+ (instancetype) radialGradientWithRect:(CGRect) circle color:(CGColor) outerColor innerRadius:(CGFloat) innerRadius innerColor:(CGColor) innerColor
```

#### Gradient Subclasses

- **`CGTwoColorGradient : CGGradient`** — Abstract. Properties: `startColor`, `endColor`
- **`CGLinearGradient : CGTwoColorGradient`** — Properties: `startPoint`, `endPoint`
- **`CGBoxGradient : CGTwoColorGradient`** — Properties: `rect`, `cornerRadius`, `feather`; dynamic: `featherColor`, `color`
- **`CGRadialGradient : CGTwoColorGradient`** — Properties: `circle`, `innerRadius`; dynamic: `outerColor`, `innerColor`

### 3.19. `CGImagePaint.h` — Rotated/Alpha Image Paint

```objc
@interface CGImagePaint : CGPaint
@property( readonly, retain) CGImage *image
@property( readonly) CGFloat alpha
@property( readonly) CARotation rotation
@property( readonly) CGFloat saturation
@property( readonly) CGFloat brightness

- (instancetype) initWithImage:(CGImage *) image rotation:(CARotation) rotation alpha:(CGFloat) alpha
- (instancetype) initWithImage:(CGImage *) image rotation:(CARotation) rotation alpha:(CGFloat) alpha saturation:(CGFloat) saturation brightness:(CGFloat) brightness
- (CGImage *) processedImage  // from CGPaintable category
```

### 3.20. `CGBlendedPaint.h` — Blended Two-Paint Interpolation

```objc
typedef NS_ENUM(NSUInteger, CGBlendedPaintBlendStyle) { CGBlendedPaintBlendAlpha = 0 }

@interface CGBlendedPaint : CGPaint
@property( readonly) CGPaint *paint
@property( readonly) CGPaint *otherPaint
@property( readonly) CGFloat blend                    // 0.0 → paint, 1.0 → otherPaint
@property( readonly) CARotation rotation

- (instancetype) initWithPaint:(CGPaint *) paint otherPaint:(CGPaint *) otherPaint blend:(CGFloat) blend rotation:(CARotation) rotation
```

### 3.21. `CGImage.h` — Texture Image

**Helper:**
```c
char *CGTextureUTF8String(NSUInteger textureFlags)
```

#### `@interface CGSharedGPUTexture : NSObject <MulleObjCThreadSafe>`
Thread-safe wrapper for OpenGL texture IDs (used for cross-context sharing).
```objc
@property( readonly, assign) CGGPUTextureID gpuTexture
- (instancetype) initWithGPUTexture:(CGGPUTextureID) gpuTexture
```

#### `@interface CGImage : CGPaint <CGBitmapDrawable, CGContextResource, MulleUINamedObject>`

**Properties:**
```objc
@property( readonly, assign) CGTextureID textureID
@property( readonly, assign) NSUInteger textureFlags
@property( readonly, assign) CGContext *context
@property( readonly, assign) CGPixelSize bitmapSize
@property( readonly, retain) CGSharedGPUTexture *sharedGPUTexture
@property( readonly, assign) NSUInteger debuggingFlags   MULLE_OBJC_THREADSAFE_PROPERTY
@property( readonly) char *nameUTF8String                 MULLE_OBJC_THREADSAFE_PROPERTY
```

**Factory Methods:**
```objc
+ (instancetype) imageWithTextureID:(CGTextureID) textureID bitmapSize:(CGPixelSize) bitmapSize textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
+ (instancetype) imageWithGPUTexture:(CGGPUTextureID) gpuTexture bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
+ (instancetype) imageWithSharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
+ (instancetype) imageWithContentsOfFileUTF8String:(char *) filename textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
+ (instancetype) imageWithFileCData:(struct mulle_data) fileCData textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
+ (instancetype) imageWithRGBABytes:(void *) bytes bitmapSize:(CGPixelSize) bitmapSize textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
+ (instancetype) imageWithBitmap:(struct CGBitmap) bitmap textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
```

**Initializers (most with nameUTF8String variant and shorter variant):**
```objc
- (instancetype) initWithTextureID:(CGTextureID) textureID bitmapSize:(CGPixelSize) bitmapSize textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
- (instancetype) initWithGPUTexture:(CGGPUTextureID) gpuTexture bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
- (instancetype) initWithSharedGPUTexture:(CGSharedGPUTexture *) sharedGPUTexture bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
- (instancetype) initWithContentsOfFileUTF8String:(char *) filename textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
- (instancetype) initWithContentsOfFileUTF8String:(char *) filename textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
- (instancetype) initWithFileCData:(struct mulle_data) fileCData textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
- (instancetype) initWithRGBABytes:(void *) bytes bitmapSize:(CGPixelSize) bitmapSize textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
- (instancetype) initWithRGBABytes:(void *) bytes bitmapSize:(CGPixelSize) bitmapSize textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
- (instancetype) initWithBitmap:(struct CGBitmap) bitmap textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
- (instancetype) initWithBitmap:(struct CGBitmap) bitmap textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
```

**Core Operations:**
```objc
- (id) copy          // retains if CGImage
- (id) mutableCopy   // creates CGFramebuffer
- (BOOL) isMultiSample   MULLE_OBJC_THREADSAFE_METHOD
- (CGImage *) resolvedImage
- (instancetype) shareWithContext:(CGContext *) context textureFlags:(NSUInteger) textureFlags  MULLE_OBJC_THREADSAFE_METHOD
```

**Future Category:**
```objc
- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator
```

### 3.22. `CGFramebuffer.h` — Mutable Offscreen Texture

#### `@interface CGFramebuffer : CGImage <NSCopying, MulleObjCThreadUnsafe>`

**Properties:**
```objc
@property( readonly, assign) CGGPUFramebuffer *gpuFramebuffer
@property( readonly, retain) CGImage *resolvedImage
@property( assign, getter=isInitializedFramebuffer) BOOL initializedFramebuffer
```

**Factory Methods:**
```objc
+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) bitmapSize textureFlags:(NSUInteger) textureFlags context:(CGContext *) context
+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size backgroundColor:(CGColor) color drawFunction:(CGFramebufferDrawFunction_t *) drawFunction userInfo:(void *) userInfo nameUTF8String:(char *) nameUTF8String context:(CGContext *) context
```

**Render Operations (CGLayerRender category):**
```objc
struct CGFramebufferRenderInfo { struct CGContextFramebuffer framebuffer; struct CGFrameInfo frameInfo; }
typedef void CGFramebufferDrawFunction_t(CGContext *context, CGSize size, void *userinfo)

- (void) _beginFBRender:(struct CGFramebufferRenderInfo *) memo
- (void) _endFBRender:(struct CGFramebufferRenderInfo *) memo
- (void) beginFBRenderWithBackgroundColor:(CGColor) color devicePixelRatio:(CGFloat) ratio layerRenderInfo:(struct CGFramebufferRenderInfo *) memo
- (void) endFBRender:(struct CGFramebufferRenderInfo *) memo
```

**Legacy Alias:**
```c
typedef CGFramebuffer CGLayer
```

### 3.23. `CGFont.h` — Font Handle

#### `@interface CGFont : NSObject`
Ephemeral font reference managed by CGContext. Only valid during rendering.
```objc
@property( assign) char *nameUTF8String
@property( assign) CGFontID fontID

+ (instancetype) fontWithNameUTF8String:(char *) name fontID:(CGFontID) fontID
- (instancetype) initWithNameUTF8String:(char *) name fontID:(CGFontID) fontID
```

### 3.24. `CGPaintable.h` — Paintable Protocol

```objc
@mixin CGPaintable
@optional
- (void) fillWithBounds:(CGRect) rect options:(struct CGFillOptions *) options context:(CGContext *) context
- (void) strokeWithBounds:(CGRect) bounds strokeWidth:(CGFloat) strokeWidth options:(struct CGStrokeOptions *) options context:(CGContext *) context
- (CGImage *) image
- (CGImage *) otherImage

@interface CGPaint( CGPaintable) <CGPaintable>

void CGContextFillPaintableOptions(CGContext *context, id <CGPaintable> paint, CGRect bounds, CGFillOptions *options)
void CGContextStrokePaintableOptions(CGContext *context, id <CGPaintable> paint, CGRect bounds, CGFloat strokeWidth, CGStrokeOptions *options)
void CGContextFillPaintable(CGContext *context, id <CGPaintable> paint)              // inline
void CGContextStrokePaintable(CGContext *context, id <CGPaintable> paint, CGFloat strokeWidth)  // inline
```

### 3.25. `CGPaint+Drawing.h` — Gradient & Image Drawing Functions

```c
void CGContextFillLinearGradient(CGContext *, CGPoint start, CGColor startColor, CGPoint end, CGColor endColor)
void CGContextStrokeLinearGradient(CGContext *, CGPoint start, CGColor startColor, CGPoint end, CGColor endColor, CGFloat strokeWidth)
void CGContextFillBoxGradient(CGContext *, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor)
void CGContextStrokeBoxGradient(CGContext *, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor, CGFloat strokeWidth)
void CGContextFillRadialGradient(CGContext *, CACircle circle, CGColor color, CGFloat innerRadius, CGColor innerColor)
void CGContextStrokeRadialGradient(CGContext *, CACircle circle, CGColor color, CGFloat innerRadius, CGColor innerColor, CGFloat strokeWidth)
void CGContextFillGradientColors(CGContext *, CGRect rect, CGColor startColor, CGColor endColor, CGFloat colorRotation)
void CGContextStrokeGradientColors(CGContext *, CGRect rect, CGColor startColor, CGColor endColor, CGFloat colorRotation, CGFloat strokeWidth)
void CGContextFillImageOptions(CGContext *, CGImage *image, CGRect rect, CGFillOptions *options)
void CGContextStrokeImageOptions(CGContext *, CGImage *image, CGRect rect, CGFloat strokeWidth, CGStrokeOptions *options)
void CGContextFillImage(CGContext *, CGImage *image)       // inline
void CGContextStrokeImage(CGContext *, CGImage *image, CGFloat strokeWidth)  // inline
void CGContextDrawBitmapDrawableInRect(CGContext *, id <CGBitmapDrawable> drawable, CGRect rect, CGRect patternRect, CGDrawableOptions *options)
```

### 3.26. `CGDrawable.h` — Drawable Protocol & Options

**Enums:**
```c
typedef NS_ENUM(NSUInteger, CGFlip)    { CGFlipNone, CGFlipHorizontally, CGFlipVertically, CGFlipBoth }
typedef NS_ENUM(NSUInteger, CGRepeat)  { CGRepeatAsIs, CGRepeatHorizontally, CGRepeatVertically, CGRepeatBoth, CGRepeatNone }
```

**Struct:**
```c
struct CGDrawableOptions { CGFloat alpha; MulleCornerInsets cornerInsets; CARotation rotation; CGFloat scale; struct { unsigned int flip:3; unsigned int repeat:3; unsigned int contentMode:4; unsigned int textureOverreach:1; } flags; }
```

**Protocols:**
```objc
@protocol CGDrawable
- (CGSize) size
- (void) drawRect:(CGRect) rect options:(CGDrawableOptions *) options context:(CGContext *) context
- (CGRect) canvas; - (CGRect) bounds; - (BOOL) isRepeating

@mixin CGBitmapDrawable <CGDrawable>
- (CGImage *) cgImageWithContext:(CGContext *) context textureFlags:(NSUInteger) textureFlags
- (struct CGBitmapInfo) bitmapInfo
// plus optional: bitmapSize, drawRect:fromRect:options:context:, bytes, textureFlags

@mixin CGVectorDrawable <CGDrawable>
// optional: canvas, bounds, isRepeating
```

### 3.27. `CGTypes.h` — Type Definitions & Enums

#### Context & Rendering Types
```c
typedef NS_ENUM(NSUInteger, CGContextType)   { CGContextTypeFull=0, CGContextTypePath=1, CGContextTypeFont=2 }
typedef NS_ENUM(NSUInteger, CGLineCap)       { CGLineCapButt, CGLineCapRound, CGLineCapSquare, CGLineCapBevel, CGLineCapMiter }
typedef NS_ENUM(NSUInteger, CGTessellation)  { CGTessellationSubdivision, CGTessellationAFD }
typedef NS_ENUM(NSUInteger, CGRelation)      { CGInside, CGOutside, CGOverlap }
```

#### Text Alignment
```c
typedef NS_OPTIONS(NSUInteger, CGCombinedTextAlign)
// Horizontal: CGTextAlignLeft(1<<0), CGTextAlignCenter(1<<1), CGTextAlignRight(1<<2)
// Vertical:  CGTextAlignTop(1<<3), CGTextAlignMiddle(1<<4), CGTextAlignBottom(1<<5), CGTextAlignBaseline(1<<6)
int CGTextAlignIsValid(CGCombinedTextAlign align)
```

#### Blend & Composite
```c
typedef NS_OPTIONS(NSUInteger, CGBlendFactor)
// CGBlendFactorZero, One, SrcColor, OneMinusSrcColor, DstColor, OneMinusDstColor, SrcAlpha, OneMinusSrcAlpha, DstAlpha, OneMinusDstAlpha, SrcAlphaSaturate

typedef NS_ENUM(NSUInteger, CGCompositeOperation)
// CGCompositeOperationSourceOver, SourceIn, SourceOut, Atop, DestinationOver, DestinationIn, DestinationOut, DestinationAtop, Lighter, Copy, XOR
```

#### Texture & Image Flags
```c
typedef NS_OPTIONS(NSUInteger, CGImageFlags)
// CGImageFlagGenerateMipmaps(1<<0), RepeatX(1<<1), RepeatY(1<<2), FlipY(1<<3), Premultiplied(1<<4), Nearest(1<<5), MSAA(1<<6), RBOLess(1<<7)

typedef NS_OPTIONS(NSUInteger, CGTextureFlags)
// CGTextureRepeatX(1<<1), CGTextureRepeatY(1<<2), CGTextureFlipY(1<<3)
```

#### Text Options & Attribute
```c
typedef NS_ENUM(NSUInteger, CGTextOptions) { CGTextOptionDefault=0, AlignVisually=0x1, AlignBaseline=0x2, NoClip=0x4, Fill=0x8 }

typedef struct CGTextAttribute {
    NSUInteger offset;     // byte offset past end of this run
    CGColor textColor, backgroundColor;
    CGFontID fontId;       // -1 = inherit
    CGFloat fontSize;      // <=0 = inherit
    CGFloat yOffset;       // 0=baseline, <0=up (superscript)
} CGTextAttribute
```

#### Metrics & Bounds
```c
typedef struct CGTextMetrics { float ascender, descender, lineHeight, lineGap }
CGTextMetrics CGTextMetricsMake(float ascender, float descender, float lineHeight)

typedef struct CGTextBoundsInfo { CGRect bounds; float size }
CGTextBoundsInfo CGTextBoundsInfoMake(CGRect rect, float size)

char *CGTextMetricsUTF8String(CGTextMetrics metrics)
```

#### Shadow
```c
struct CGShadow { struct MulleEdgeInsets extrudes; CGColor innerColor, outerColor; CGFloat blur; char hole }
struct CGShadow CGShadowMake(CGPoint offset, CGFloat blur, CGColor color)
#define CGShadowDefaultValues ...
```

#### Resource IDs
```c
typedef NSInteger CGTextureID    // 0 = invalid
typedef NSInteger CGFontID       // -1 = invalid
typedef NSUInteger CGShaderID    // 0 = invalid
#define CGTextureIDInvalid  0
#define CGFontIDInvalid    -1
```

#### Paint/Fill/Stroke Options
```c
struct CGPaintOptions   { CARotation rotation; CGFloat smoothness, alpha; NSUInteger textureFlags }
struct CGStrokeOptions  { struct CGPaintOptions paint; CGRelation relation }
struct CGFillOptions    { struct CGPaintOptions paint; CGRelation relation; CGFloat strokeWidth }

#define CGPaintOptionsDefault ...
#define CGFillOptionsDefault ...
#define CGStrokeOptionsDefault ...

CGFillOptions   CGFillOptionsMake(CARotation, CGFloat, CGFloat, NSUInteger, CGRelation, CGFloat)
CGFillOptions   CGFillOptionsMakeWithRotation(CARotation)
CGFillOptions   CGFillOptionsMakeWithAlpha(CGFloat)
CGFillOptions   CGFillOptionsMakeWithRotationAndAlpha(CARotation, CGFloat)
CGStrokeOptions CGStrokeOptionsMake(CARotation, CGFloat, CGFloat, NSUInteger, CGRelation)
CGStrokeOptions CGStrokeOptionsMakeWithRotation(CARotation)
CGStrokeOptions CGStrokeOptionsMakeWithAlpha(CGFloat)
CGStrokeOptions CGStrokeOptionsMakeWithRotationAndAlpha(CARotation, CGFloat)
```

#### Rectangle Adjustment
```c
CGRect CGRectMakeStrokeRect(CGRect rect, CGFloat strokeWidth, CGRelation relation)
CGRect CGRectMakeFillRect(CGRect strokeRect, CGFloat strokeWidth, CGRelation relation)
```

#### Font Size Rounding
```c
CGFloat mvgRoundedFontSize(CGFloat size)
```

#### String Conversions (all `static inline`, for debugging)
```c
char *CGContextTypeUTF8String(NSUInteger)
char *CGWindingUTF8String(NSUInteger)
char *CGLineCapUTF8String(NSUInteger)
char *CGCompositeOperationUTF8String(NSUInteger)
char *CGTessellationUTF8String(NSUInteger)
char *CGRelationUTF8String(NSUInteger)
```

### 3.28. `UIColor.h`, `CGColor+UTF8String.h`, `CGColor+MulleObjC.h` — Color Conveniences

Color conveniences and debug helpers (see headers for details).

## 4. Performance Characteristics

### Rendering
- **Path Drawing**: O(n) in path complexity. Tessellation (subdivision or AFD) converts Bézier curves to line segments
- **Text Rendering**: O(n) in string length. Uses freetype for glyph rasterization, cached in texture atlas
- **Texture Blitting**: O(1) GPU operation. Efficiently rendered via textured quads
- **Gradient Fills**: O(1) GPU operation. Implemented as texture lookups or shader programs

### Vtable Dispatch
- **Zero indirection**: Function tables are embedded in structs, not pointed-to. Inline accessors use `@defs(CGContext)` for direct struct offset access
- **Split backend**: Font operations dispatch through `CGFontFunctionTable` independently from draw operations through `CGFunctionTable`, enabling font-only contexts without drawing overhead

### Resource Management
- **Texture Caching**: CGContext caches textures by handle. O(1) lookup via hash map
- **Font Caching**: Font atlas updated on-demand. O(1) glyph lookup after rasterization
- **State Stack**: CGContextSave/Restore is O(1) stack push/pop (split between font and draw stacks)

### Thread Safety
- **CGContext/CGContextBase/CGLayoutContext**: Not thread-safe. Each context is tied to a single thread
- **CGImage/CGFramebuffer**: Not thread-safe. Bound to the owning context's thread
- **CGPaint/CGGradient/CGImagePaint/CGBlendedPaint**: Immutable and thread-safe
- **CGSharedGPUTexture**: Thread-safe (atomic reference counting)

### Trade-offs
- **Memory vs. Speed**: Offscreen framebuffers (CGFramebuffer) cache complex drawings, trading GPU memory for rendering speed
- **Antialiasing**: MSAA trades memory and resolve cost for quality
- **Texture Flags**: RepeatX/Y affects fill behavior. Nearest vs. linear filtering trades quality for speed

## 5. AI Usage Recommendations & Patterns

### Best Practices

1. **Always Activate Context Before Use** — Use `CGContextIsActiveInCurrentThread()` for assertions

2. **Respect the Rendering Lifecycle** — All drawing must occur between beginRender/endRender. State stacks reset within each render pass

3. **Use Factory Methods** — Prefer `[CGImage imageWith...]` over `[[CGImage alloc] initWith...]`. Use `[CGGradient gradientWith...]` over init methods. Follow mulle-objc conventions (no alloc/init without autorelease)

4. **Manage Resources Explicitly** — CGImage and CGFramebuffer are tied to their context. Use `shareWithContext:textureFlags:` for cross-context sharing (if contexts have matching shareID)

5. **Pixel-Perfect Drawing** — Use `CGRectMakeStrokeRect()` and `CGRectMakeFillRect()` with appropriate `CGRelation`

6. **Prefer Higher-Level APIs** — Use `CGContextFillRectWithColor()` over manual path building. Convenience functions in `CGContext+DrawingConveniences.h` reduce errors

7. **Immutable Paints** — CGPaint, CGGradient, CGImagePaint, and CGImage are immutable. Use transform methods (e.g., `rotatedPaint:`) to derive new instances

8. **Do Not Retain CGFont** — CGFont is ephemeral, managed by CGContext

9. **Use CGContextDo Macro** — `CGContextDo(context) { ... }` for automatic save/restore scoping

10. **Backend Agnostic** — Use the public inline functions in `CGContext+Drawing.h` rather than accessing the vtable or `_vg` directly. This ensures compatibility with future backends

### Common Pitfalls

1. **Do Not Access `_` Prefixed Fields** — Use accessors; direct access breaks encapsulation and vtable dispatch

2. **Do Not Mix CGImage Between Contexts** — Use `shareWithContext:` for sharing

3. **Do Not Free nanovg Resources Directly** — Let CGContext manage texture/font/shader lifecycle

4. **Borrowed Pointers** — Some functions return non-retained pointers (e.g., `-[CGGradient colors]`). Do not free them

5. **BeginFrame Resets State** — `CGContextBeginFrame()` resets the save/restore stack. Do not rely on state set before beginFrame

6. **Gradient Limitations** — nanovg limits gradients to 2 color stops. For multi-stop gradients, composite multiple overlapping gradients

7. **No Dot-Syntax in Obj-C** — Use `[object property]`, not `object.property`

8. **Font vs. Draw Save/Restore** — `CGLayoutContextSave` only saves font state. Use `CGContextSave` for full save

### Idiomatic Usage

**Render Loop Pattern:**
```c
struct CGFrameInfo   info;

info.size             = CGSizeMake( windowWidth, windowHeight);
info.devicePixelRatio = 1.0;
info.clearColor       = CGColorMakeWhite();

[context beginRender:&info];
{
   CGContextSave( context);
   {
      CGContextFillRectWithColor( context, rect, CGColorMakeRed());
   }
   CGContextRestore( context);
}
[context endRender];
```

**CGContextDo Scoping:**
```c
[context beginRender:&info];
CGContextDo( context)
{
   CGContextFillRectWithColor( context, rect, color);
}
[context endRender];
```

**Framebuffer Caching Pattern:**
```c
CGFramebuffer   *cache;

cache = [CGFramebuffer framebufferWithBitmapSize:size textureFlags:0 context:context];
[cache beginFBRenderWithBackgroundColor:CGColorMakeClear() devicePixelRatio:1.0 layerRenderInfo:&memo];
{
   CGContextFillCircleWithColor( context, circle, color);
}
[cache endFBRender:&memo];
// Later: blit cache with [context drawImage:cache inRect:dstRect]
```

**Gradient Drawing:**
```c
CGGradient   *gradient;

gradient = [CGGradient gradientWithStartColor:CGColorMakeBlack() endColor:CGColorMakeWhite() rotation:CAAngleRadiansN];
CGContextDo( context)
{
   [gradient fillWithBounds:rect options:NULL context:context];
}
```

**Animation Factors:**
```c
CGFloat   factor;
factor = CGContextGetBackAndForthAnimationFactor( context, 120);  // 0→1→0 over 120 frames
// or
factor = CGContextGetLinearAnimationFactor( context, 60);          // 0→1 over 60 frames
```

## 6. Integration Examples

### Example 1: Creating a Context and Drawing a Rectangle
```c
static void   drawRect( CGContext *context, CGRect rect)
{
   CGContextDo( context)
   {
      CGContextFillRectWithColor( context, rect, CGColorMakeRed());
   }
}
```

### Example 2: Drawing Text with a Font
```c
static void   drawText( CGContext *context, CGPoint p, char *s)
{
   CGContextDo( context)
   {
      CGContextFontFace( context, "sans");
      CGContextDrawText( context, p.x, p.y, s, 24.0, CGColorMakeWhite());
   }
}
```

### Example 3: Creating and Using a Gradient
```c
static void   drawGradient( CGContext *context, CGRect rect)
{
   CGGradient   *gradient;

   gradient = [CGGradient gradientWithStartColor:CGColorMakeBlue() endColor:CGColorMakeGreen() rotation:0.0f];
   CGContextDo( context)
   {
      [gradient fillWithBounds:rect options:NULL context:context];
   }
}
```

### Example 4: Offscreen Rendering with CGFramebuffer
```c
static CGFramebuffer   *createCachedLayer( CGContext *context, CGPixelSize size)
{
   CGFramebuffer                  *framebuffer;
   struct CGFramebufferRenderInfo   memo;

   framebuffer = [CGFramebuffer framebufferWithBitmapSize:size textureFlags:0 nameUTF8String:"cached" context:context];
   [framebuffer beginFBRenderWithBackgroundColor:CGColorMakeClear() devicePixelRatio:1.0 layerRenderInfo:&memo];
   {
      CGContextFillRectWithColor( context, CGRectMake( 0.0, 0.0, size.width, size.height), CGColorMakeYellow());
   }
   [framebuffer endFBRender:&memo];
   return( framebuffer);
}
```

### Example 5: Creating an Image from File
```c
static CGImage   *loadTexture( CGContext *context, char *filename)
{
   CGImage   *image;
   image = [CGImage imageWithContentsOfFileUTF8String:filename textureFlags:0 context:context];
   return( image);
}
```

### Example 6: Pixel-Perfect Bordered Rectangle
```c
static void   drawBorderedRect( CGContext *context, CGRect rect, CGFloat strokeWidth)
{
   CGRect   strokeRect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);
   CGRect   fillRect   = CGRectMakeFillRect( strokeRect, strokeWidth, CGInside);

   CGContextDo( context)
   {
      CGContextFillRectWithColor( context, fillRect, CGColorMakeWhite());
      CGContextStrokeRectWithColor( context, strokeRect, strokeWidth, CGColorMakeBlack());
   }
}
```

### Example 7: Sharing Textures Across Contexts
```c
static CGImage   *shareTexture( CGImage *sourceImage, CGContext *targetContext)
{
   return( [sourceImage shareWithContext:targetContext textureFlags:[sourceImage textureFlags]]);
}
```

### Example 8: Shader-Based Image Effect
```c
static void   applyEffect( CGContext *context, CGImage *image, CGShaderID shader)
{
   struct CGUniform   uniforms[1] = { { "time", CGUniformTypeFloat, .floatValue = 1.5f } };
   CGImage            *result;

   result = [context imageByRenderingImage:image withShader:shader uniforms:uniforms count:1];
   CGContextDo( context)
   {
      CGContextFillImage( context, result);
   }
}
```

## 7. Dependencies

Direct mulle-sde library dependencies (from `.mulle/etc/sourcetree/config`):

- **MulleUIBase** — Objective-C wrappers for mulle-geometry and graphics primitives (CGColor, CGRect, CGPoint, etc.)

Build-time tool dependencies:
- **mulle-objc-list** — Runtime information listing tool (no-header, no-link)

Additionally, MulleCG incorporates:
- **mulle-nanovg** — Embedded nanovg vector graphics library (git submodule, not a standard dependency)

Transitive dependencies (via MulleUIBase):
- **mulle-gfx** — Graphics foundation library (includes mulle-color)
- **mulle-freetype** — FreeType font rendering engine wrapper
- **mulle-geometry** — Geometric primitives
- **mulle-color** — Color handling
- **mulle-objc** — Objective-C runtime
- **OpenGL/OpenGL ES** — Graphics backend (system dependency)
