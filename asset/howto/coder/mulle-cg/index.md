<!-- keywords: mulle-cg, CGContext, render, beginRender, endRender, activateGraphicsContext, CGFrameInfo, suspendRender, resumeRender, nvg, nanovg, trace draw calls, UIDebuggingFlags, CGContextDebuggingFlags -->
# mulle-cg

Use this topic for render-pass lifecycle and context activation. For specific drawing activities, see the focused subtopics:

- **mulle-cg-drawing** — shapes, fills, strokes, pixel-perfect rectangles
- **mulle-cg-text** — fonts, text rendering, metrics, alignment
- **mulle-cg-paint** — colors, gradients, blended paints, animation
- **mulle-cg-image** — bitmaps, drawables, textures, loading files
- **mulle-cg-framebuffer** — offscreen rendering, caching, threading

## Understand first

```bash
mulle-sde api apropos CGContext
mulle-sde code search beginRender
mulle-sde code search endRender
mulle-sde code search suspendRender
```

## Local references

- `README.md`
- `asset/dox/TOC.md`
- `src/CGContext.h`
- `src/CGContext+Render.h`
- `src/CGContextBase.h`

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

## Verify / report

Use focused subtopic tests. For render lifecycle specifically, check that `beginRender:`/`endRender` brackets all draw calls and that the OS graphics context is activated.

## Quick debug hook: NVG call tracing flags

You can trace backend drawing. This example runs the app for four frames and
starts tracing at frame 3:

```bash
mulle-sde run --mulleui-trace 3 --mulleui-frames 4 demo
```

This sets `UIGraphicsContextTraceDrawCalls` (`0x04000000`) via
`UIDebuggingFlags`/`CGContextDebuggingFlags`, so `CGContext+Render`
enables `CGContextTrace(...)` around render passes.

If you only need one layer/context, prefer local tracing:

```objc
[pathContext setTraceFile:stderr];

// trace only pathContext calls here
[pathContext setTraceFile:NULL];
```

`setTraceFile:` keeps tracing scoped and avoids global trace noise.


## Dumping screenshots of rendered frames


This will create 5 PNGs, one each for every rendered frame:

```bash
mulle-sde -DUIDebuggingFlags=0x08000000 run --mulleui-frames 5 demo
```

