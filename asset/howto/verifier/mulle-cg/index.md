<!-- keywords: CGContext, CGFramebuffer, CGImage, CGPaint, trace draw calls, active thread, offscreen, UIDebuggingFlags, CGContextDebuggingFlags, CGImageDebuggingFlags -->
# mulle-cg

Use this when user code renders blank, stale, or wrong-colored output and you need to decide whether the fault is in render-pass setup, offscreen resource handoff, image ownership, or paint math.

## Understand first

```bash
mulle-sde api apropos CGContext
mulle-sde api cat CGContext
mulle-sde api cat CGFramebuffer
mulle-sde api cat CGImage
mulle-sde code search UIDebuggingFlags
mulle-sde code search setTraceFile
```

## Local references

- `README.md`
- `asset/dox/TOC.md`
- `src/CGContext.h`
- `src/CGContextBase.h`
- `src/CGLayoutContext.h`
- `src/CGContext+Render.h`
- `src/CGContext+CGFramebuffer.h`
- `src/CGImage.h`
- `src/CGPaint.h`
- `src/CGGradient.h`
- `src/CGColor+UTF8String.h`
- `demo/main-glfw-offscreen-threaded.m`
- `test/10-first/cgframebuffer.m`
- `test/10-first/paintleak.m`
- `test/40-gradient/brighten.m`
- `test/40-gradient/dim.m`

## Where to look first

| Symptom | Start here |
| --- | --- |
| Blank frame, partial frame, or frame-start assert | `CGContext` lifecycle: active OS graphics context, exactly one `beginRender:`/`endRender`, no nested frames, current thread owns the context |
| Offscreen output is stale, missing, or only breaks in retained/threaded mode | `CGFramebuffer` handoff: `acquireRenderedFramebuffer` / `recycleAcquiredRenderedFramebuffer` and the pattern in `demo/main-glfw-offscreen-threaded.m` |
| Texture works in one place but not after reuse | `CGImage` ownership: creation requires an active context; the image can survive across frames but not across unrelated contexts unless shared explicitly |
| Geometry is correct but color/gradient output is wrong | `CGPaint` / `CGGradient`; swap in a flat color first, then compare against `test/40-gradient/brighten.m` and `test/40-gradient/dim.m` |

## Local diagnostics

- `CGContextBase` reads `CGContextDebuggingFlags` first and falls back to `UIDebuggingFlags`.
- `0x04000000` enables draw-call tracing during `beginRender:` / `endRender`.
- `0x08000000` dumps rendered offscreen framebuffers to PNG files.
- `setTraceFile:` is the least noisy tracer because it scopes logging to one context.
- `traceDrawCalls` on `CGLayoutContext` is useful when order matters more than final pixels.
- `CGColorUTF8String()` and `CGTextMetricsUTF8String()` are the local stringifiers worth using in logs.

```objc
[context setTraceFile:stderr];
// draw the suspect pass
[context setTraceFile:NULL];
```

## Primary local workflow

1. Verify lifecycle first. `beginRender:` asserts current-thread ownership and rejects nested frames, so blank output plus an assert usually means context activation or render-pass misuse before any paint bug.
2. If the bug involves offscreen or threaded drawing, keep `CGFramebuffer` ownership rules in view: `acquireRenderedFramebuffer` is for the non-active side, and the acquired framebuffer must stay alive until the consuming draw finishes.
3. If the bug involves images, treat it as a context/resource problem before a geometry problem. `CGImage` objects are created with an active context, keep their `context`, and cannot be reused by pointer in another context.
4. If only colors are wrong, keep the same geometry and replace the paint with a flat color. `test/10-first/paintleak.m` is only a lifetime canary; `test/40-gradient/brighten.m` and `dim.m` are the better local references for color behavior.
5. If a gradient mismatch looks like a missing stop, remember that `src/CGGradient.h` documents a nanovg limitation: the API shape allows more stops, but the backend currently behaves like a two-color gradient.

## Verify / report

- Record which flags were active: `CGContextDebuggingFlags`, `UIDebuggingFlags`, and if relevant `CGImageDebuggingFlags`.
- Note whether the failure reproduces with a flat color, with offscreen rendering disabled, or only after image/framebuffer reuse.
- Include whether `CGContextIsActiveInCurrentThread` or the `beginRender:` assertions fired.
- For image/resource reports, include the owning context, whether sharing was expected, and any `nameUTF8String` labels you supplied to contexts or images.
