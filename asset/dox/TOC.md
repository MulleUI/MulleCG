# MulleCG Library Documentation for AI
<!-- Keywords: graphics, rendering, nanovg, CoreGraphics, textures, fonts, OpenGL -->

## 1. Introduction & Purpose

MulleCG provides CoreGraphics-like functionality for MulleUI, wrapping the nanovg vector graphics library. It offers 2D rendering capabilities including paths, shapes, text, gradients, images, and textures, along with font and shader management. The library does not handle animation, layouting, windowing, or events—it focuses purely on drawing operations. MulleCG is designed for use with OpenGL/OpenGL ES backends and provides a context-based rendering model similar to Apple's CoreGraphics. It is a foundational graphics layer within the MulleUI ecosystem.

## 2. Key Concepts & Design Philosophy

### Graphics Context Model
MulleCG uses a **CGContext** as the central rendering object. The context maintains state (fonts, textures, shaders) and is tied to an OpenGL context and thread. Rendering occurs between `beginRender:` and `endRender` calls, with support for both onscreen and offscreen rendering via framebuffers.

### Coordinate System & Pixel-Perfect Drawing
The coordinate system addresses **spaces between pixels**, not pixels directly. The first pixel spans from 0 to 1. For pixel-perfect drawing:
- **Fill operations**: Use `CGRectMake(1, 1, 3, 1)` to fill 3 horizontal pixels
- **Stroke operations**: Must account for stroke width emanating perpendicular to the path. Use `CGRectMakeStrokeRect()` to adjust positioning
- **Combining stroke and fill**: Use `CGRectMakeFillRect()` with `CGInside`, `CGOutside`, or `CGOverlap` relations to avoid overdraw

### Resource Management
CGContext manages **GPU resources** (textures, fonts, shaders) with lifecycle tied to the context. Resources are not thread-safe by default and are bound to the active thread. Images and framebuffers must be created when the context is active. The library uses nanovg's texture IDs internally but wraps them in Objective-C objects (CGImage, CGFramebuffer).

### Paint Abstraction
**CGPaint** is an abstract base for fill/stroke styles, encompassing:
- Solid colors (via CGColor)
- Gradients (CGGradient: linear, radial, box)
- Images/textures (CGImage)

This allows uniform handling of different paint types in drawing APIs.

### nanovg Backend
MulleCG is tightly coupled to nanovg, using its path drawing, text rendering, and image handling. The library provides both direct nanovg-like APIs (e.g., `CGContextBeginFrame()`) and higher-level convenience functions (e.g., `CGContextFillRectWithColor()`).

## 3. Core API & Data Structures

### 3.1. `CGContext.h` - Main Rendering Context

#### `@interface CGContext : CGLayoutContext`
**Purpose:** The primary rendering context managing GPU state, fonts, textures, and shaders. Tied to an OpenGL context and thread.

**Key Properties:**
- `backend` (UIGraphicsBackend): The graphics backend in use (OpenGL version)
- `contextID` (NSUInteger): Debug identifier for the context
- `numberOfFrames` (NSUInteger): Frame counter
- `isRendering` (BOOL): Whether currently between beginRender/endRender
- `activeThread` (NSThread *): The thread owning this context
- `framebufferBits` (NSUInteger): Framebuffer configuration bits

**Lifecycle Functions:**
- `- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context shareID:(NSUInteger) shareID options:(UIGraphicsOptions) options` - Designated initializer

**Core Operations:**
- `- (void) beginRender:(struct CGFrameInfo *) info` - Begin a rendering frame
- `- (void) endRender` - End frame and flush commands
- `- (void) suspendRender` - Flush and clean state for intermixing OpenGL calls
- `- (void) resumeRender` - Resume after suspend
- `- (BOOL) isRendering` - Check if currently rendering

**State Management:**
- `CGContextSave(CGLayoutContext *)` - Push state onto stack
- `CGContextRestore(CGLayoutContext *)` - Pop state from stack
- `CGContextReset(CGContextBase *)` - Reset to defaults

**Inspection Functions:**
- `- (mulle_relativetime_t) secondsSinceFirstRender` - Elapsed time since first render
- `- (char *) backendUTF8String` - Get backend description
- `- (CGShaderID) activeShader` - Get current shader ID

**Helper Inline Functions:**
- `CGContextIsActiveInCurrentThread(CGContext *)` - Check thread ownership
- `CGContextGetNVGContext(CGContext *)` - Access underlying nanovg context (const return)
- `CGContextGetBackAndForthAnimationFactor(CGContext *, NSUInteger rate)` - Get animated factor oscillating 0→1→0
- `CGContextGetLinearAnimationFactor(CGContext *, NSUInteger rate)` - Get linear animated factor 0→1

**Backend Error Functions:**
- `CGContextCheckBackendError(CGContext *, char *)` - Check for OpenGL errors (debug only)
- `CGContextResetBackendError(CGContext *)` - Clear error state

### 3.2. `CGLayoutContext.h` - Font & Text Layout Base

#### `@interface CGLayoutContext : CGContextBase`
**Purpose:** Base class providing font management and text metrics for CGContext.

**Core Operations:**
- `- (BOOL) hasLoadedFont` - Check if any font loaded
- `- (BOOL) useFontWithNameUTF8String:(char *) name` - Select font by name
- `- (CGFloat) fontSizeThatFitsIntoSize:(CGSize) size` - Compute fitting font size
- `- (struct CGTextMetrics) visualTextMetrics` - Get current font metrics

**Properties:**
- `traceDrawCalls` (BOOL): Enable logging of draw operations (threadsafe)

### 3.3. `CGContextBase.h` - Context Foundation

#### `@interface CGContextBase : MulleObject`
**Purpose:** Base class managing nanovg context, resources, and thread ownership.

**Key Fields:**
- `_vg` (struct NVGcontext *): The underlying nanovg context
- `_resourceStorage` (struct MulleUIResourceStorage): Resource management
- `_atomicState` (mulle_atomic_pointer_t): Thread-safe state tracking

**Properties:**
- `OSWindow` (id): Associated OS window (readonly, threadsafe)
- `debuggingFlags` (NSUInteger): Debug configuration (threadsafe)
- `nameUTF8String` (char *): Context name for debugging
- `state` (NSUInteger): Context state bits (dynamic, threadsafe)

**Lifecycle Functions:**
- `- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context nameUTF8String:(char *) name`
- `- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context`

**Core Operations:**
- `- (NSThread *) activeThread` - Get owning thread (threadsafe)
- `- (struct NVGcontext *) nvgContext` - Access nanovg context safely

**Inline Accessors:**
- `CGContextBaseGetNVGContext(CGContextBase *)` - Direct nanovg context access

### 3.4. `CGPaint.h` - Abstract Paint Base

#### `@interface CGPaint : NSObject`
**Purpose:** Abstract base for all paint types (colors, gradients, images).

**Factory Methods:**
- `+ (CGPaint *) paintWithColor:(CGColor) color` - Create solid color paint
- `+ (CGPaint *) paintWithHexColor:(CGHexColor) color` - Create from hex color
- `+ (CGPaint *) paintWithStartColor:(CGColor) start endColor:(CGColor) end` - Create gradient
- `+ (CGPaint *) paintWithStartColor:(CGColor) start endColor:(CGColor) end rotation:(CARotation) rotation` - Rotated gradient

**Inspection Methods:**
- `- (CGColor) mainColor` - Primary color (gray for textures, middle for gradients)
- `- (CGColor) suggestedTextColor` - Recommended text color (white/black)
- `- (BOOL) isTexture` - Check if texture-based (default: YES)
- `- (BOOL) isGradient` - Check if gradient (default: NO)
- `- (BOOL) isMonochrome` - Check if single color
- `- (BOOL) isOpaque` - Check opacity
- `- (CGFloat) alpha` - Get alpha value (default: 1.0)
- `- (BOOL) needsBounds` - Whether bounds required (NO for mono colors)

**Transform Methods:**
- `- (CGPaint *) rotatedPaint:(CARotation) rotation` - Rotate gradient (self for mono)
- `- (CGFloat) overdraw` - Get stroke overdraw amount (default: 0)

**Image Accessors:**
- `- (CGImage *) image` - Get primary image
- `- (CGImage *) otherImage` - Get secondary image (for blended paints)

### 3.5. `CGGradient.h` - Gradient Paint

#### `@interface CGGradient : CGPaint`
**Purpose:** Gradient paint supporting linear, radial, and box gradients.

**Factory Methods:**
- `+ (instancetype) gradientWithStartColor:(CGColor) start endColor:(CGColor) end rotation:(CARotation) rotation` - Two-color gradient
- `+ (instancetype) gradientWithColors:(CGColor *) colors locations:(CGFloat *) locations count:(NSUInteger) count rotation:(CARotation) rotation` - Multi-stop gradient
- `+ (instancetype) linearGradientWithRect:(CGRect) rect startColor:(CGColor) start endColor:(CGColor) end rotation:(CARotation) rotation`
- `+ (instancetype) boxGradientWithRoundedRect:(CGRect) rect cornerRadius:(CGFloat) r color:(CGColor) color feather:(CGFloat) feather featherColor:(CGColor) fColor`
- `+ (instancetype) radialGradientWithCircle:(CACircle) circle color:(CGColor) outer innerRadius:(CGFloat) r innerColor:(CGColor) inner`

**Initializers:**
- `- (instancetype) initWithStartColor:(CGColor) start endColor:(CGColor) end rotation:(CARotation) rotation`
- `- (instancetype) initWithColors:(CGColor *) colors locations:(CGFloat *) locations count:(NSUInteger) count rotation:(CARotation) rotation`

**Transform Methods:**
- `- (CGGradient *) reversedGradient` - Flip gradient (180° rotation)
- `- (CGGradient *) rotatedGradient:(CARotation) rotation` - Rotate
- `- (CGGradient *) brightenedGradient:(CGFloat) brighten` - Increase brightness
- `- (CGGradient *) dimmedGradient:(CGFloat) dim` - Decrease brightness
- `- (CGGradient *) transparentGradient:(CGFloat) alpha` - Adjust alpha
- `- (CGGradient *) desaturatedGradient:(CGFloat) factor` - Desaturate (0.0-1.0)
- `- (CGGradient *) saturatedGradient:(CGFloat) factor` - Saturate
- `- (CGGradient *) gradientByChangingColorsWithFunction:(CGColor (*)(CGColor, void *)) f userInfo:(void *) info` - Custom transform

**Subclass Methods (for subclasses to implement):**
- `- (CGColor) startColor`, `- (CGColor) endColor`
- `- (CARotation) rotation`
- `- (NSUInteger) numberOfColors`
- `- (CGFloat) locationAtIndex:(NSUInteger) i`
- `- (CGColor) colorAtIndex:(NSUInteger) i`
- `- (void) getColors:(CGColor *) colors`
- `- (void) getLocations:(CGFloat *) locations`

**C Functions:**
- `CGGradientCreateWithRotation(CGColor start, CGColor end, CARotation rotation)` - C-style constructor
- `CGGradientCreate(CGColor start, CGColor end)` - C-style constructor (no rotation)

#### Gradient Subclasses

**`CGTwoColorGradient`** - Abstract base for two-color gradients
- `startColor`, `endColor` properties

**`CGLinearGradient`** - Linear gradient
- `startPoint`, `endPoint` properties

**`CGBoxGradient`** - Box gradient with rounded corners
- `rect`, `cornerRadius`, `feather` properties
- `featherColor`, `color` dynamic properties

**`CGRadialGradient`** - Radial gradient
- `circle`, `innerRadius` properties
- `outerColor`, `innerColor` dynamic properties

### 3.6. `CGImage.h` - Texture Image

#### `@interface CGSharedGPUTexture : NSObject <MulleObjCThreadSafe>`
**Purpose:** Thread-safe wrapper for OpenGL texture IDs for sharing across contexts.

**Properties:**
- `gpuTexture` (CGGPUTextureID): The OpenGL texture handle

**Lifecycle:**
- `- (instancetype) initWithGPUTexture:(CGGPUTextureID) gpuTexture`

#### `@interface CGImage : CGPaint <CGBitmapDrawable, CGContextResource>`
**Purpose:** Immutable GPU texture wrapper, tied to a CGContext. Lives as long as the context and cannot be used across contexts.

**Properties:**
- `textureID` (CGTextureID): nanovg texture ID (readonly)
- `textureFlags` (NSUInteger): Texture creation flags (readonly)
- `context` (CGContext *): Owning context (readonly)
- `bitmapSize` (CGPixelSize): Image dimensions (readonly)
- `sharedGPUTexture` (CGSharedGPUTexture *): Shared texture handle if context has shareID (readonly, retain)
- `debuggingFlags` (NSUInteger): Debug flags (readonly, threadsafe)
- `nameUTF8String` (char *): Debug name (readonly, threadsafe, set once)

**Factory Methods:**
- `+ (instancetype) imageWithTextureID:(CGTextureID) id bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags context:(CGContext *) ctx`
- `+ (instancetype) imageWithGPUTexture:(CGGPUTextureID) gpu bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags context:(CGContext *) ctx`
- `+ (instancetype) imageWithSharedGPUTexture:(CGSharedGPUTexture *) shared bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags context:(CGContext *) ctx`
- `+ (instancetype) imageWithContentsOfFileUTF8String:(char *) filename textureFlags:(NSUInteger) flags context:(CGContext *) ctx`
- `+ (instancetype) imageWithFileCData:(struct mulle_data) data textureFlags:(NSUInteger) flags context:(CGContext *) ctx`
- `+ (instancetype) imageWithRGBABytes:(void *) bytes bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags context:(CGContext *) ctx`
- `+ (instancetype) imageWithBitmap:(struct CGBitmap) bitmap textureFlags:(NSUInteger) flags context:(CGContext *) ctx`

**Initializers:**
- `- (instancetype) initWithTextureID:(CGTextureID) id bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`
- `- (instancetype) initWithGPUTexture:(CGGPUTextureID) gpu bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`
- `- (instancetype) initWithSharedGPUTexture:(CGSharedGPUTexture *) shared bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`
- `- (instancetype) initWithContentsOfFileUTF8String:(char *) filename textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`
- `- (instancetype) initWithFileCData:(struct mulle_data) data textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`
- `- (instancetype) initWithRGBABytes:(void *) bytes bitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`
- `- (instancetype) initWithBitmap:(struct CGBitmap) bitmap textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`

**Core Operations:**
- `- (id) copy` - Retain and return self
- `- (id) mutableCopy` - Create CGFramebuffer from image
- `- (struct CGBitmap) RGBABytesBitmap:(struct mulle_allocator *) allocator` - Read pixels back to CPU
- `- (BOOL) isMultiSample` - Check if multisample texture (threadsafe)
- `- (CGImage *) resolvedImage` - Get resolved image (aborts if multisample for CGImage)
- `- (instancetype) shareWithContext:(CGContext *) context textureFlags:(NSUInteger) flags` - Share with another context (threadsafe)

### 3.7. `CGFramebuffer.h` - Mutable Offscreen Texture

#### `@interface CGFramebuffer : CGImage <NSCopying, MulleObjCThreadUnsafe>`
**Purpose:** Mutable offscreen rendering target (framebuffer object). Unlike CGImage, can be drawn into. Used for caching complex drawings.

**Properties:**
- `gpuFramebuffer` (CGGPUFramebuffer *): The OpenGL FBO handle (readonly)
- `resolvedImage` (CGImage *): Resolved image if multisample (readonly, retain)
- `initializedFramebuffer` (BOOL): Whether framebuffer has been drawn to (assign)
- `alpha` (CGFloat): Framebuffer alpha (assign)

**Factory Methods:**
- `+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`
- `+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags context:(CGContext *) ctx`
- `+ (instancetype) framebufferWithBitmapSize:(CGPixelSize) size backgroundColor:(CGColor) color drawFunction:(CGFramebufferDrawFunction_t *) f userInfo:(void *) info nameUTF8String:(char *) name context:(CGContext *) ctx` - Convenience renderer

**Initializers:**
- `- (instancetype) initWithBitmapSize:(CGPixelSize) size textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`
- `- (instancetype) initWithImage:(CGImage *) image textureFlags:(NSUInteger) flags nameUTF8String:(char *) name context:(CGContext *) ctx`

**Render Operations:**
- `- (void) _beginFBRender:(struct CGFramebufferRenderInfo *) memo` - Begin internal render
- `- (void) _endFBRender:(struct CGFramebufferRenderInfo *) memo` - End internal render
- `- (void) beginFBRenderWithBackgroundColor:(CGColor) color devicePixelRatio:(CGFloat) ratio layerRenderInfo:(struct CGFramebufferRenderInfo *) memo` - Begin with clear
- `- (void) endFBRender:(struct CGFramebufferRenderInfo *) memo` - End render

**C Typedef:**
- `typedef CGFramebuffer CGLayer` - Legacy name for compatibility

**Function Pointer Type:**
- `typedef void CGFramebufferDrawFunction_t(CGContext *context, CGSize size, void *userinfo)` - Draw callback

### 3.8. `CGFont.h` - Font Handle

#### `@interface CGFont : NSObject`
**Purpose:** Lightweight font reference managed by CGContext. Only valid during rendering.

**Properties:**
- `nameUTF8String` (char *): Font name (nanovg name)
- `fontID` (CGFontID): nanovg font index

**Lifecycle:**
- `+ (instancetype) fontWithNameUTF8String:(char *) name fontID:(CGFontID) id`
- `- (instancetype) initWithNameUTF8String:(char *) name fontID:(CGFontID) id`

### 3.9. `CGTypes.h` - Type Definitions & Enums

#### Type Enums

**`CGContextType`** - Context configuration
- `CGContextTypeFull` (0): Full-featured context
- `CGContextTypePath` (1): Path-only context
- `CGContextTypeFont` (2): Font-only context

**`CGLineCap`** - Line ending styles
- `CGLineCapButt`, `CGLineCapRound`, `CGLineCapSquare`, `CGLineCapBevel`, `CGLineCapMiter`

**`CGCombinedTextAlign`** - Text alignment flags (bitwise)
- Horizontal: `CGTextAlignLeft`, `CGTextAlignCenter`, `CGTextAlignRight`
- Vertical: `CGTextAlignTop`, `CGTextAlignMiddle`, `CGTextAlignBottom`, `CGTextAlignBaseline`

**`CGCompositeOperation`** - Blend modes
- `CGCompositeOperationSourceOver`, `SourceIn`, `SourceOut`, `Atop`, `DestinationOver`, `DestinationIn`, `DestinationOut`, `DestinationAtop`, `Lighter`, `Copy`, `XOR`

**`CGImageFlags`** - Texture creation flags (bitwise)
- `CGImageFlagGenerateMipmaps`, `RepeatX`, `RepeatY`, `FlipY`, `Premultiplied`, `Nearest`, `MSAA`, `RBOLess`

**`CGTessellation`** - Path tessellation algorithms
- `CGTessellationSubdivision`: De Casteljau (default)
- `CGTessellationAFD`: Adaptive forward differencing

**`CGTextOptions`** - Text rendering options (bitwise)
- `CGTextOptionDefault`, `AlignVisually`, `AlignBaseline`, `NoClip`, `Fill`

**`CGRelation`** - Spatial relationship
- `CGInside`, `CGOutside`, `CGOverlap`

#### Helper Structs

**`struct CGPaintOptions`**
- `rotation` (CARotation): Paint rotation (default: 0.0)
- `smoothness` (CGFloat): Smoothness (default: 1.0)
- `alpha` (CGFloat): Alpha (default: 1.0)
- `textureFlags` (NSUInteger): Texture flags (default: 0)

**`struct CGFillOptions`** - Extends CGPaintOptions
- `paint` (struct CGPaintOptions)
- `relation` (CGRelation): Inside/outside/overlap (default: CGOverlap)
- `strokeWidth` (CGFloat): Stroke width for CGInside (default: 0.0)

**`struct CGStrokeOptions`** - Extends CGPaintOptions
- `paint` (struct CGPaintOptions)
- `relation` (CGRelation): Inside/outside/overlap (default: CGOverlap)

**`struct CGShadow`**
- `extrudes` (struct MulleEdgeInsets): Shadow offset
- `innerColor`, `outerColor` (CGColor): Shadow gradient colors
- `blur` (CGFloat): Blur amount
- `hole` (char): Whether to render hole

**`struct CGTextMetrics`** - Font metrics
- `ascender` (float): Baseline to top (≥0)
- `descender` (float): Baseline to bottom (≥0)
- `lineHeight` (float): Total height (≥ascender+descender)

#### Helper Functions

**Rectangle Adjustment:**
- `CGRectMakeStrokeRect(CGRect rect, CGFloat strokeWidth, CGRelation relation)` - Adjust rect for stroke positioning
- `CGRectMakeFillRect(CGRect strokeRect, CGFloat strokeWidth, CGRelation relation)` - Adjust rect for fill after stroke

**Shadow Construction:**
- `CGShadowMake(CGPoint offset, CGFloat blur, CGColor color)` - Create shadow

**Text Metrics:**
- `CGTextMetricsMake(float ascender, float descender, float lineHeight)` - Create metrics

**String Conversions (for debugging):**
- `CGContextTypeUTF8String(NSUInteger)`, `CGWindingUTF8String(NSUInteger)`, `CGLineCapUTF8String(NSUInteger)`, `CGCompositeOperationUTF8String(NSUInteger)`, `CGTessellationUTF8String(NSUInteger)`, `CGRelationUTF8String(NSUInteger)`

**Constants:**
- `CGPaintOptionsDefault`, `CGFillOptionsDefault`, `CGStrokeOptionsDefault`, `CGShadowDefaultValues`

### 3.10. `CGContext+Drawing.h` - Core Drawing Operations (nanovg)

#### Frame Management
- `CGContextBeginFrame(CGContext *, CGSize windowSize, CGFloat devicePixelRatio)` - Begin frame (resets state stack)
- `CGContextCancelFrame(CGContext *)` - Cancel frame
- `CGContextEndFrame(CGContext *)` - End frame and flush

#### State Management
- `CGContextSave(CGLayoutContext *)` - Push state
- `CGContextRestore(CGLayoutContext *)` - Pop state
- `CGContextReset(CGContextBase *)` - Reset to defaults

#### Composite Operations
- `CGContextGlobalCompositeOperation(CGContext *, NSInteger op)` - Set blend mode
- `CGContextGlobalCompositeBlendFunc(CGContext *, NSUInteger sfactor, NSUInteger dfactor)` - Custom blend
- `CGContextGlobalCompositeBlendFuncSeparate(CGContext *, NSUInteger srcRGB, NSUInteger dstRGB, NSUInteger srcAlpha, NSUInteger dstAlpha)` - Separate RGB/alpha blend

#### Paint Setup
- `CGContextStrokeColor(CGContext *, CGColor)` - Set stroke color
- `CGContextFillColor(CGContext *, CGColor)` - Set fill color
- `CGContextShapeAntiAlias(CGContext *, BOOL)` - Enable/disable antialiasing

*Note: Many more drawing functions defined in this header for paths, strokes, fills, text, transforms, scissors, etc. See header for full list.*

### 3.11. `CGContext+DrawingConveniences.h` - High-Level Drawing

#### Fill Operations
- `CGContextFillWithColor(CGContext *, CGColor)` - Fill current path
- `CGContextFillRectWithColor(CGContext *, CGRect, CGColor)` - Fill rect
- `CGContextFillRoundedRectWithColor(CGContext *, CGRect, CGFloat cornerRadius, CGColor)` - Fill rounded rect
- `CGContextFillCircleWithColor(CGContext *, CACircle, CGColor)` - Fill circle
- `CGContextFillRectWithNVGpaint(CGContext *, CGRect, NVGpaint)` - Fill rect with nanovg paint
- `CGContextFillCircleWithNVGpaint(CGContext *, CACircle, NVGpaint)` - Fill circle with nanovg paint

#### Stroke Operations
- `CGContextStrokeWithColor(CGContext *, CGFloat strokeWidth, CGColor)` - Stroke current path
- `CGContextStrokeRectWithColor(CGContext *, CGRect, CGFloat strokeWidth, CGColor)` - Stroke rect
- `CGContextStrokeRoundedRectWithColor(CGContext *, CGRect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor)` - Stroke rounded rect
- `CGContextStrokeInsideOfRectWithColor(CGContext *, CGRect, CGFloat strokeWidth, CGColor)` - Stroke inside rect
- `CGContextStrokeInsideOfRoundedRectWithColor(CGContext *, CGRect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor)` - Stroke inside rounded rect
- `CGContextStrokeLineWithColor(CGContext *, CGPoint start, CGPoint end, CGFloat strokeWidth, CGColor)` - Stroke line
- `CGContextStrokeLineHWithColor(CGContext *, CGPoint p, CGFloat w, CGFloat strokeWidth, CGColor)` - Stroke horizontal line
- `CGContextStrokeLineVWithColor(CGContext *, CGPoint p, CGFloat h, CGFloat strokeWidth, CGColor)` - Stroke vertical line

### 3.12. `CGContext+UIGraphicsDrawing.h` - Text & Icon Drawing

#### Text Rendering
- `CGContextDrawText(CGContext *, CGFloat x, CGFloat y, char *s, CGFloat fontSize, CGColor)` - Draw text at point
- `CGContextFontFace(CGLayoutContext *, char *fontname)` - Select font

#### Icon Rendering
- `CGContextDrawIconInRect(CGContext *, mulle_utf32_t icon, CGRect)` - Draw icon centered in rect

#### Protocol Methods (UIGraphicsDrawing)
- `- (void) drawAtPoint:(CGPoint) point textUTF8String:(char *) s fontNameUTF8String:(char *) fontName fontSize:(CGFloat) size hexColor:(CGHexColor) color` - Protocol method
- `- (void) drawIcon:(mulle_utf32_t) icon atPoint:(CGPoint) point` - Draw icon at point

### 3.13. `CGContext+Render.h` - Rendering Lifecycle

#### Render Loop
- `- (void) beginRender:(struct CGFrameInfo *) info` - Begin render pass
- `- (struct CGFrameInfo) bindRender:(struct CGFrameInfo *) info` - Bind framebuffer
- `- (void) endRender` - End render pass
- `- (CGFramebuffer *) _endRender` - Internal end (returns framebuffer without suspend)
- `- (BOOL) isRendering` - Check if currently rendering

#### Render State Management
- `- (void) suspendRender` - Flush and clean state for OpenGL intermixing
- `- (void) resumeRender` - Resume after suspend
- `- (void) flushRender` - Suspend + resume
- `- (void) changeRender:(struct CGFrameInfo *) info` - Change render target
- `- (void) reset` - Reset context state

#### Object Rendering
- `- (void) renderObjects:(struct mulle_pointerarray *) layers` - Render array of CGRenderObjects

#### Image/Texture Operations
- `- (void *) gpuTextureForImageID:(NSInteger) textureID` - Get OpenGL texture handle
- `- (CGImage *) resolveMultiSampleImage:(CGImage *) image` - Resolve MSAA texture
- `- (struct CGBitmap) readFramebufferBitmap:(CGPixelRect) rect framebufferBitmapType:(CGFramebufferBitmapType) type allocator:(struct mulle_allocator *) allocator` - Read framebuffer pixels
- `- (struct CGBitmap) RGBABytesBitmapOfImage:(CGImage *) image allocator:(struct mulle_allocator *) allocator` - Read image pixels

#### Class Methods
- `+ (BOOL) supportsAntiAliasing` - Check if antialiasing supported

#### Protocol
**`@protocol CGRenderObject`**
- `- (void) renderInContext:(CGContext *) context` - Render method

### 3.14. `CGContext+Texture.h` - Texture Management

*Note: This header manages texture creation, caching, and lifecycle. Details would include texture ID management, GPU texture wrapping, and context-texture association.*

### 3.15. `CGContext+CGImage.h` - Image Integration

*Note: This header provides methods for creating and managing CGImage objects within the context.*

### 3.16. `CGContext+CGFramebuffer.h` - Framebuffer Management

*Note: This header manages framebuffer binding, offscreen rendering setup, and framebuffer lifecycle.*

### 3.17. `CGContext+Shader.h` - Shader Operations

*Note: This header provides shader loading, compilation, and activation within the rendering pipeline.*

### 3.18. `CGContext+OpenGL.h` - OpenGL Backend Interface

*Note: This header provides direct OpenGL integration points for advanced rendering.*

## 4. Performance Characteristics

### Rendering
- **Path Drawing**: O(n) in path complexity. Tessellation (subdivision or AFD) converts Bézier curves to line segments
- **Text Rendering**: O(n) in string length. Uses freetype for glyph rasterization, cached in texture atlas
- **Texture Blitting**: O(1) GPU operation. Efficiently rendered via textured quads
- **Gradient Fills**: O(1) GPU operation. Implemented as texture lookups or shader programs

### Resource Management
- **Texture Caching**: CGContext caches textures by handle. O(1) lookup via hash map
- **Font Caching**: Font atlas updated on-demand. O(1) glyph lookup after rasterization
- **State Stack**: CGContextSave/Restore is O(1) stack push/pop

### Thread Safety
- **CGContext**: **Not thread-safe**. Each context is tied to a single thread (the OpenGL context owner)
- **CGImage/CGFramebuffer**: **Not thread-safe**. Bound to the owning context's thread
- **CGPaint/CGGradient**: **Immutable and thread-safe** (can be passed between threads)
- **CGSharedGPUTexture**: **Thread-safe** (atomic reference counting for texture sharing)
- **External Locking Required**: Use `os_activateGraphicsContext`/`os_deactivateGraphicsContext` when switching contexts

### Trade-offs
- **Memory vs. Speed**: Offscreen framebuffers (CGFramebuffer) cache complex drawings, trading GPU memory for rendering speed
- **Antialiasing**: Multisampling (MSAA) trades memory and resolve cost for quality
- **Texture Flags**: `RepeatX/Y` vs. clamping affects fill behavior. `Nearest` vs. linear filtering trades quality for speed

## 5. AI Usage Recommendations & Patterns

### Best Practices

1. **Always Activate Context Before Use**
   - Ensure the CGContext's thread matches `[NSThread currentThread]` before rendering
   - Use `CGContextIsActiveInCurrentThread()` for assertions

2. **Respect the Rendering Lifecycle**
   - All drawing **must** occur between `beginRender:` and `endRender`
   - `CGContextSave`/`CGContextRestore` stacks are reset by `beginRender:`, so keep state scope within a single render pass

3. **Use Factory Methods for Objects**
   - Prefer `[CGImage imageWith...]` over `[[CGImage alloc] initWith...]`
   - Prefer `[CGGradient gradientWith...]` over init methods
   - This follows mulle-objc conventions (no `autorelease` in this environment)

4. **Manage Resources Explicitly**
   - CGImage and CGFramebuffer are tied to their context. Do not use them after the context is destroyed
   - Use `shareWithContext:textureFlags:` to share images across contexts (if contexts have matching shareID)

5. **Pixel-Perfect Drawing**
   - For sharp rectangles, use `CGRectMakeStrokeRect()` and `CGRectMakeFillRect()` with appropriate `CGRelation`
   - Strokes emanate perpendicular; account for strokeWidth/2 on each side

6. **Prefer Higher-Level APIs**
   - Use `CGContextFillRectWithColor()` over manual `CGContextBeginPath()` → `CGContextRect()` → `CGContextFillColor()` → `CGContextFill()`
   - The convenience functions in `CGContext+DrawingConveniences.h` reduce errors

7. **Immutable Paints**
   - CGPaint, CGGradient, and CGImage are immutable. Use transform methods (e.g., `rotatedGradient:`) to derive new paints

8. **Avoid Retaining CGFont**
   - CGFont is ephemeral, managed by CGContext. Do not keep references beyond a render pass

### Common Pitfalls

1. **Do Not Access `_` Prefixed Fields**
   - Use accessors for `_vg`, `_context`, `_textureID`, etc. Direct access breaks encapsulation

2. **Do Not Mix CGImage Between Contexts**
   - CGImage is bound to its context. Using it in another context will crash. Use `shareWithContext:` for sharing

3. **Do Not Free nanovg Resources Directly**
   - Let CGContext manage texture/font/shader lifecycle. Manual `nvgDeleteImage()` calls will cause double-free

4. **Borrowed Pointers**
   - Some functions return non-retained pointers (e.g., `-[CGGradient colors]`). Do not free them

5. **Framebuffer Binding**
   - Do not call `_bindToContext`/`_unbindFromContext` directly. Use CGContext's framebuffer management methods

6. **BeginFrame Resets State**
   - `CGContextBeginFrame()` completely resets the save/restore stack. Do not rely on state set before beginFrame

7. **Gradient Limitations**
   - nanovg limits gradients to 2 color stops. For multi-stop gradients, composite multiple overlapping gradients

8. **Do Not Use Dot-Syntax**
   - This is Objective-C without modern syntax. Use `[object property]`, not `object.property`

### Idiomatic Usage

**Render Loop Pattern:**
```c
struct CGFrameInfo   info;

info.size            = CGSizeMake( windowWidth, windowHeight);
info.devicePixelRatio= 1.0;
info.clearColor      = CGColorMakeWhite();

[context beginRender:&info];
{
   CGContextSave( context);
   {
      // Your drawing code here
      CGContextFillRectWithColor( context, rect, CGColorMakeRed());
   }
   CGContextRestore( context);
}
[context endRender];
```

**Framebuffer Caching Pattern:**
```c
CGFramebuffer   *cache;

cache = [CGFramebuffer framebufferWithBitmapSize:size
                                    textureFlags:0
                                         context:context];

// Render into framebuffer
[cache beginFBRenderWithBackgroundColor:CGColorMakeClear()
                       devicePixelRatio:1.0
                        layerRenderInfo:&memo];
{
   // Draw complex content
   CGContextFillCircleWithColor( context, circle, color);
}
[cache endFBRender:&memo];

// Later, blit cache to screen (fast)
[context drawImage:cache inRect:dstRect];
```

**Gradient Drawing Pattern:**
```c
CGGradient   *gradient;

gradient = [CGGradient gradientWithStartColor:CGColorMakeBlack()
                                     endColor:CGColorMakeWhite()
                                     rotation:CAAngleRadiansN]; // Top→Down

[context fillRect:rect
        withPaint:gradient
          options:CGFillOptionsDefault];
```

## 6. Integration Examples

### Example 1: Creating a Context and Drawing a Rectangle

```c
#import <MulleCG/MulleCG.h>

// Assuming you have an OS graphics context (e.g., from MulleUIOS)
int   main( void)
{
   FakeOSContext    *osContext;
   CGContext        *context;
   struct CGFrameInfo   info;
   CGRect           rect;

   osContext = [FakeOSContext instance];
   context   = [[[CGContext alloc] initWithOSGraphicsContext:osContext
                                                     shareID:0
                                                     options:0] autorelease];

   // Setup frame
   info.size             = CGSizeMake( 800.0, 600.0);
   info.devicePixelRatio = 1.0;
   info.clearColor       = CGColorMakeBlack();

   [context beginRender:&info];
   {
      CGContextSave( context);
      {
         rect = CGRectMake( 100.0, 100.0, 200.0, 150.0);
         CGContextFillRectWithColor( context, rect, CGColorMakeRed());
      }
      CGContextRestore( context);
   }
   [context endRender];

   return( 0);
}
```

### Example 2: Drawing Text with a Font

```c
#import <MulleCG/MulleCG.h>

void   renderText( CGContext *context)
{
   CGPoint   position;

   CGContextSave( context);
   {
      // Select font (ensure loaded via context)
      CGContextFontFace( context, "sans");

      // Draw text
      position = CGPointMake( 50.0, 100.0);
      CGContextDrawText( context,
                         position.x,
                         position.y,
                         "Hello, MulleCG!",
                         24.0,
                         CGColorMakeWhite());
   }
   CGContextRestore( context);
}
```

### Example 3: Creating and Using a Gradient

```c
#import <MulleCG/MulleCG.h>

void   renderGradient( CGContext *context, CGRect rect)
{
   CGGradient   *gradient;

   gradient = [CGGradient gradientWithStartColor:CGColorMakeBlue()
                                        endColor:CGColorMakeGreen()
                                        rotation:0.0f]; // Left→Right

   CGContextSave( context);
   {
      [context fillRect:rect
              withPaint:gradient
                options:CGFillOptionsDefault];
   }
   CGContextRestore( context);
}
```

### Example 4: Offscreen Rendering with CGFramebuffer

```c
#import <MulleCG/MulleCG.h>

CGFramebuffer   *createCachedLayer( CGContext *context, CGSize size)
{
   CGFramebuffer              *framebuffer;
   struct CGFramebufferRenderInfo   memo;
   CGRect                     rect;

   framebuffer = [CGFramebuffer framebufferWithBitmapSize:CGPixelSizeMakeWithSize( size)
                                             textureFlags:0
                                           nameUTF8String:"CachedLayer"
                                                  context:context];

   [framebuffer beginFBRenderWithBackgroundColor:CGColorMakeClear()
                                devicePixelRatio:1.0
                                 layerRenderInfo:&memo];
   {
      // Draw into framebuffer
      rect = CGRectMake( 0.0, 0.0, size.width, size.height);
      CGContextFillRectWithColor( context, rect, CGColorMakeYellow());
   }
   [framebuffer endFBRender:&memo];

   return( framebuffer);
}

void   blitCachedLayer( CGContext *context, CGFramebuffer *framebuffer, CGRect dstRect)
{
   [context drawImage:framebuffer inRect:dstRect];
}
```

### Example 5: Creating an Image from File

```c
#import <MulleCG/MulleCG.h>

CGImage   *loadTexture( CGContext *context, char *filename)
{
   CGImage   *image;

   image = [CGImage imageWithContentsOfFileUTF8String:filename
                                         textureFlags:0
                                              context:context];

   if( ! image)
      mulle_fprintf( stderr, "Failed to load %s\n", filename);

   return( image);
}

void   drawTexture( CGContext *context, CGImage *image, CGRect rect)
{
   CGContextSave( context);
   {
      [context drawImage:image inRect:rect];
   }
   CGContextRestore( context);
}
```

### Example 6: Pixel-Perfect Bordered Rectangle

```c
#import <MulleCG/MulleCG.h>

void   drawBorderedRect( CGContext *context, CGRect rect, CGFloat strokeWidth)
{
   CGRect   strokeRect;
   CGRect   fillRect;

   // Adjust rect for stroke positioning (draw stroke inside)
   strokeRect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside);

   // Compute fill rect (inside stroke)
   fillRect = CGRectMakeFillRect( strokeRect, strokeWidth, CGInside);

   CGContextSave( context);
   {
      // Fill interior
      CGContextFillRectWithColor( context, fillRect, CGColorMakeWhite());

      // Stroke border
      CGContextStrokeRectWithColor( context, strokeRect, strokeWidth, CGColorMakeBlack());
   }
   CGContextRestore( context);
}
```

### Example 7: Using Animation Factors

```c
#import <MulleCG/MulleCG.h>

void   animateCircle( CGContext *context, CACircle circle)
{
   CGFloat   factor;
   CGFloat   radius;

   // Get oscillating factor (0→1→0 over 120 frames)
   factor = CGContextGetBackAndForthAnimationFactor( context, 120);

   // Animate radius
   radius             = circle.radius * (0.5 + 0.5 * factor);
   circle.radius      = radius;

   CGContextSave( context);
   {
      CGContextFillCircleWithColor( context, circle, CGColorMakeCyan());
   }
   CGContextRestore( context);
}
```

### Example 8: Sharing Textures Across Contexts

```c
#import <MulleCG/MulleCG.h>

CGImage   *shareTexture( CGImage *sourceImage, CGContext *targetContext)
{
   CGImage   *sharedImage;

   // Share texture with another context (contexts must have matching shareID)
   sharedImage = [sourceImage shareWithContext:targetContext
                                   textureFlags:[sourceImage textureFlags]];

   if( ! sharedImage)
      mulle_fprintf( stderr, "Failed to share texture\n");

   return( sharedImage);
}
```

## 7. Dependencies

MulleCG depends on the following mulle-sde libraries:

- **mulle-freetype** - FreeType font rendering engine wrapper
- **mulle-gfx** - Graphics foundation library (includes mulle-color)
- **MulleUIBase** - Objective-C wrappers for mulle-geometry and graphics primitives
- **mulle-objc-list** - Runtime information listing tool

Additionally, MulleCG incorporates:
- **mulle-nanovg** - Embedded nanovg vector graphics library (git submodule, not a standard dependency)

Transitive dependencies include:
- **mulle-geometry** - Geometric primitives (CGRect, CGPoint, etc.) via MulleUIBase
- **mulle-color** - Color handling (CGColor) via mulle-gfx
- **mulle-objc** - Objective-C runtime via MulleUIBase
- **OpenGL/OpenGL ES** - Graphics backend (system dependency)
