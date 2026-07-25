<!-- keywords: render, context, CGContext, CGPaint, CGGradient, CGImage, CGFramebuffer, CGDrawable, shader, font, text, lifecycle, beginRender, endRender, framebuffer, offscreen, paint, gradient, drawing, fill, stroke -->
# mulle-cg

Use this topic for the overall MulleCG 2D graphics library. Focused subtopics cover specific activities in more detail:

- **mulle-cg-drawing** — shapes, fills, strokes, pixel-perfect rectangles
- **mulle-cg-text** — fonts, text rendering, metrics, alignment
- **mulle-cg-paint** — colors, gradients, blended paints, animation
- **mulle-cg-image** — bitmaps, drawables, textures, loading files
- **mulle-cg-framebuffer** — offscreen rendering, caching, threading

## Understand first

```bash
mulle-sde api apropos CGContext
mulle-sde api apropos CGPaint
mulle-sde api apropos CGGradient
mulle-sde api apropos CGImage
mulle-sde api apropos CGFramebuffer
mulle-sde api apropos CGDrawable
mulle-sde code search beginRender
mulle-sde code search endRender
```

## Local references

- `README.md` — pixel-perfect drawing rules
- `asset/dox/TOC.md` — full API reference
- `src/CGContext.h` — render lifecycle
- `src/CGContext+Render.h` — render future/offscreen
- `src/CGContext+Drawing.h` — path, shape, font function tables
- `src/CGContext+DrawingConveniences.h` — high-level fill/stroke
- `src/CGPaint.h` — abstract paint base
- `src/CGGradient.h` — gradient paints
- `src/CGImage.h` — GPU texture images
- `src/CGFramebuffer.h` — offscreen render targets
- `src/CGDrawable.h` — drawable protocol (CGImage, CGFramebuffer)
- `src/CGContext+Shader.h` — shader management
- `src/CGContext+CGImage.h` — image creation on context
- `src/CGContext+CGFramebuffer.h` — framebuffer management
- `src/CGContext+ImageEffect.h` — shader-based image filters
- `src/CGTypes.h` — type definitions, enums, options structs
- `test/10-first/cgframebuffer.m`
- `test/10-first/paintleak.m`
- `test/40-gradient/brighten.m`
- `demo/main-cglayer-paint.m` — double-framebuffer double-buffering pattern

## API families overview

| Family | Root types | Entry points | When to use |
|--------|-----------|--------------|-------------|
| **Render** | `CGContext` | `beginRender:`/`endRender:`, `suspendRender`/`resumeRender` | Activating context, frame lifecycle, mixing OpenGL |
| **Drawing** | `CGContext+Drawing.h` | `CGContextFill*`, `CGContextStroke*`, `CGContextRect`, `CGContextCircle`, `CGContextBeginPath` | Immediate-mode path construction and fill/stroke |
| **Paint** | `CGPaint`, `CGGradient`, `CGBlendedPaint` | `+paintWithColor:`, `+gradientWithStartColor:endColor:`, `CGContextFillRectWithPaintable` | Abstracting colors, gradients, and animated blends |
| **Image** | `CGImage`, `CGSharedGPUTexture` | `+imageWithContentsOfFileUTF8String:`, `+imageWithRGBABytes:` | On-GPU texture loading, creation, cross-context sharing |
| **Framebuffer** | `CGFramebuffer` (aka `CGLayer`) | `+framebufferWithBitmapSize:`, `beginFBRenderWithBackgroundColor:` | Offscreen rendering, caching complex drawings |
| **Drawable** | `<CGDrawable>`, `<CGBitmapDrawable>` | `-drawRect:options:context:`, `-canvas`, `-bounds` | Polymorphic image/vector rendering protocol |
| **Text/Font** | `CGLayoutContext`, `CGFont` | `CGContextFontFace`, `CGContextDrawText`, `CGContextTextMetrics`, `CGContextTextBox` | Font selection, text layout, metrics, multi-line |
| **Shader** | `CGContext+Shader.h` | `+registerShaderSources:`, `-useShaderWithNameUTF8String:`, `-compileShaderWithShaderSources:` | Custom GPU shaders, image effects |

## Render-pass lifecycle

The basic shape is: activate the OS graphics context, render inside one `beginRender:`/`endRender` pair, then deactivate.

```objc
struct CGFrameInfo   info;

info = CGFrameInfoSFMake( canvas, framebufferSize, 1.0);

[window os_activateGraphicsContext];
{
   [context beginRender:&info];
   {
      // all drawing here
   }
   [context endRender];
}
[window os_deactivateGraphicsContext];
```

Rules:
- Frames cannot be nested.
- Backend access asserts current-thread ownership.
- If you mix raw OpenGL with MulleCG drawing, use `suspendRender`/`resumeRender`.
- `beginRender:` resets the save/restore stack.

## Drawing shapes

Use the convenience C functions in `CGContext+DrawingConveniences.h`:

```c
CGContextFillRectWithColor( context, rect, CGColorMakeRed());
CGContextStrokeRectWithColor( context, rect, strokeWidth, CGColorMakeBlack());
CGContextFillCircleWithColor( context, circle, CGColorMakeBlue());
CGContextStrokeLineWithColor( context, start, end, 2.0, CGColorMakeWhite());
```

For pixel-perfect borders, compute stroke and fill rects with `CGRectMakeStrokeRect` / `CGRectMakeFillRect` and the `CGRelation` enum (`CGInside`, `CGOutside`, `CGOverlap`). See `README.md` for the coordinate model.

## Working with paints

Create paints via factory methods, then draw via `CGContextFillRectWithPaintable` (see `mulle-cg-paint` for the full table):

```c
CGPaint   *paint;

paint = [CGPaint paintWithStartColor:CGColorMakeIndigo()
                            endColor:CGColorMakeOrange()
                            rotation:0.0];

CGContextFillRectWithPaintable( context, rect, paint);
```

## Loading and using images

Create CGImage objects on a context. They are GPU-bound and context-specific.

```c
CGImage   *image;

image = [CGImage imageWithContentsOfFileUTF8String:"sprite.png"
                                     textureFlags:0
                                          context:context];

[context drawImage:image inRect:dstRect];
```

For cross-context sharing, both contexts must have a matching shareID:

```c
CGImage   *shared;

shared = [sourceImage shareWithContext:otherContext
                           textureFlags:0];
```

## Offscreen rendering with CGFramebuffer

```c
CGFramebuffer   *fb;
struct CGFramebufferRenderInfo   memo;

fb = [CGFramebuffer framebufferWithBitmapSize:size
                                 textureFlags:0
                                      context:context];

[fb beginFBRenderWithBackgroundColor:CGColorMakeClear()
                    devicePixelRatio:1.0
                     layerRenderInfo:&memo];
{
   CGContextFillCircleWithColor( context, circle, color);
}
[fb endFBRender:&memo];

// Blit to screen
[context drawImage:fb inRect:dstRect];
```

## Text and fonts

```c
CGContextFontFace( context, "sans");
CGContextFontSize( context, 24.0);
CGContextDrawText( context, 50.0, 100.0, "Hello", 24.0, CGColorMakeWhite());
```

Use `CGContextTextBox` for multi-line text with line wrapping. Use `CGContextTextBreakLines` for manual line-break inspection. Query metrics with `CGContextTextMetrics`.

## Shaders

Shaders are registered globally and activated by name:

```c
struct CGShaderUTF8Sources   sources[] =
{
   { "myShader", vertSrc, fragSrc, NULL, NULL },
   { NULL, NULL, NULL, NULL, NULL }
};

[CGContext registerShaderSources:sources];

CGShaderID  shaderID = [context useShaderWithNameUTF8String:"myShader"];
```

## Verify / report

- `mulle-sde test run test/10-first/cgframebuffer.m` — framebuffer lifecycle
- `mulle-sde test run test/10-first/paintleak.m` — paint ownership
- `mulle-sde test run test/40-gradient/brighten.m` — gradient transforms
- Use focused subtopic tests for each family

## Quick debug hook: NVG call tracing flags

```bash
mulle-sde run --mulleui-trace 3 --mulleui-frames 4 demo
```

Or locally:

```objc
[pathContext setTraceFile:stderr];
// ... draw calls traced here
[pathContext setTraceFile:NULL];
```

## Dumping screenshots of rendered frames

```bash
mulle-sde -DUIDebuggingFlags=0x08000000 run --mulleui-frames 5 demo
```
