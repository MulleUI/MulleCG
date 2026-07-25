<!-- keywords: quirks, CGContext, gradient, image, framebuffer, font, shader, thread, coordinates, state, multisample, paint, immutable -->
# Quirks

## Render-pass ownership

- `src/CGContext.h`: frames cannot be nested. One `beginRender:`/`endRender` pair per frame.
- Backend access asserts current-thread ownership. Activate the graphics context before touching render state or GPU-backed objects.
- `beginRender:` resets the entire save/restore stack. Do not rely on state set before `beginRender:`.
- If you mix raw backend work with MulleCG drawing, use `suspendRender`/`resumeRender`; do not assume nanovg/OpenGL state survives arbitrary interleaving.

## Coordinate system

- Coordinates address the space between pixels, not pixel centers. The first pixel spans 0 to 1. For crisp borders, compute stroke/fill rects instead of guessing half-pixel offsets.
- Strokes emanate perpendicular to the path. A `strokeWidth` of 1 covers half a pixel on each side. `CGContextStrokeRectWithColor` strokes centered on the rect edges; use `CGContextStrokeInsideOfRectWithColor` to keep the stroke fully inside.
- AntiAliasing only kicks in when geometry doesn't align to pixel boundaries. Use integer coordinates and `CGRectMakeStrokeRect`/`CGRectMakeFillRect` with `CGInside` for pixel-perfect results.

## Context is split across categories

- Drawing, render, image, framebuffer, shader, and texture entry points are intentionally split across separate `src/CGContext+*.h` headers. Do not assume one header shows the whole surface.
- The convenience functions in `CGContext+DrawingConveniences.h` (`*WithColor`) internally call `CGContextFillColor`/`CGContextStrokeColor`, **replacing** any previously set gradient paint. If you need a gradient fill, use the `CGContextSetFill*Gradient` path functions with bare `CGContextFill()` — do not mix with `*WithColor` on the same shape.

## Gradient two-color limit

- `CGGradient.h`: nanovg effectively limits gradients to **2 color stops**. The API accepts multi-stop arrays (`gradientWithColors:locations:count:`), but the backend truncates. For richer ramps, stack overlapping shapes or concentric circles with a small overlap to avoid artifacts.
- `CGBoxGradient` and `CGRadialGradient` are geometry-bound and cannot be rotated. Use `CGLinearGradient` for rotated gradients.

## Paint immutability

- All `CGPaint` subclasses are **immutable** (except `CGFramebuffer`, which is a mutable `CGImage`). Use transform methods (`rotatedPaint:`, `brightenedPaint:`, `reversedPaint`) to derive new paints instead of mutating.
- `CGBlendedPaint` exists for animation/interpolation between two paints via alpha blending. It is not a general mutable container.
- Paints are value-like. Do not transfer them with `mulleGainAccess`/`mulleRelinquishAccess`.
- Non-mono paints **need bounds** passed to fill/stroke. A solid-color paint succeeds without bounds; a gradient or image paint will fail silently.

## CGImage context binding

- `CGImage.h`: CGImage lives in its owning graphics context. You **cannot** use a CGImage by pointer in a different context. The image data is on the GPU; the nanovg texture ID is context-specific.
- Create CGImages only when a context is active (i.e., inside a render pass or during initialization).
- You can keep a CGImage between render passes on the **same** context. When the context finalizes, all its CGImages become invalid.
- `CGImage` is a subclass of `CGPaint`, so it can be used directly as a paint for fill/stroke operations.
- Multisample images (`CGImageFlagMSAA`) **cannot be used as paint**. Call `-resolvedImage` first to get a usable copy, or use `CGFramebuffer` for multisample and then resolve.

## CGFont is ephemeral

- `CGFont` is a lightweight font reference managed by CGContext. Do not retain references across render passes. The font atlas is internal; the `CGFontID` is valid only while the context is alive.
- Use `useFontWithNameUTF8String:` for font switching, not raw `CGFont` objects.

## CGFramebuffer threading

- `CGFramebuffer.h`: `acquireRenderedFramebuffer` and `recycleAcquiredRenderedFramebuffer:` are for the **non-active-thread** side. `provideRenderedFramebuffer:` and `recycleRenderedFramebuffer:` are **active-thread-only**.
- Once a rendered framebuffer is acquired, keep it until drawing is complete. Recycling immediately allows reuse and overwrite.
- Framebuffer creation is not for the middle of the main render pass. Build/cache them before or after.
- Do not call `_bindToContext` or `_unbindFromContext` directly; use the context's framebuffer management APIs (`bindFramebuffer:`, etc.).

## Shader management

- `CGContext+Shader.h`: Shader sources are registered **globally** via `+registerShaderSources:`. Use `-useShaderWithNameUTF8String:` to activate a registered shader by name. The context compiles shaders on demand.
- If compilation fails, the shader ID is 0 (invalid). There is no per-frame shader teardown; the context manages the lifecycle.
- Image effects (`CGContext+ImageEffect.h`) render an image through a custom shader via `imageByRenderingImage:withShader:uniforms:count:`.

## Texture flags

- `CGImageFlags` / `CGTextureFlags` control GPU texture behavior: `RepeatX`/`RepeatY` for tiling, `FlipY` for Y-flip, `Premultiplied` for premultiplied alpha, `Nearest` for nearest-neighbor interpolation, `GenerateMipmaps` for mipmap chains, `MSAA` for multisample framebuffers.
- `CGImageFlagMSAA` is only meaningful with `nvgluCreateFramebuffer`. `CGImageFlagRBOLess` is a convenience for framebuffer creation.

## Animation factors

- `CGContext` provides inline animation helpers: `CGContextGetBackAndForthAnimationFactor(context, rate)` oscillates 0→1→0 over `rate` frames (min 4). `CGContextGetLinearAnimationFactor(context, rate)` moves 0→1 over `rate` frames (min 2). Both use `numberOfFrames` internally and apply a cubic ease.

## Options struct defaults

- `CGPaintOptionsDefault` gives `alpha=1.0`, `smoothness=1.0`, `rotation=0.0`. `CGFillOptionsDefault` adds `relation=CGOverlap`. `CGStrokeOptionsDefault` mirrors fill options struct layout.
- `CGDrawableOptionsDefault` gives `alpha=1.0`, `scale=CGScaleNone`, `flip=CGFlipNone`, `repeat=CGRepeatAsIs`, `contentMode=CGContentModeCenterPoint`.

## Font size rounding

- nanovg works at 1/10-pixel resolution; FreeType at 1/64. Use `mvgRoundedFontSize(size)` to round fractional font sizes, avoiding unexpected glyph positioning.

## No dot-syntax

- This is mulle-objc without modern syntax. Use `[context property]` not `context.property`, and `[context setProperty:value]` not `context.property = value`.
