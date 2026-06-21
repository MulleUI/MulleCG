<!-- keywords: debugger, mulle-cg, CGContext, render, backend, blank, categories, nvg, nanovg, trace draw calls, tracedrawcalls, UIDebuggingFlags, CGContextDebuggingFlags -->
# mulle-cg

Use this when a rendering bug could live in the render-pass lifecycle or backend dispatch. For family-specific debugging, see:

- **mulle-cg-paint** — color/gradient bugs, separating geometry from paint
- **mulle-cg-image** — resource chain debugging, blank/stale pixels
- **mulle-cg-framebuffer** — offscreen vs threaded repros, lifecycle traps

## Understand first

```bash
mulle-sde api apropos CGContext
mulle-sde api cat CGContext
mulle-sde code search beginRender
```

## Local references

- `src/CGContext.h`
- `src/CGContext+Render.h`
- `src/CGBackend.h`
- `src/CGBackendFunctionTable.h`

## Local workflow

1. Reproduce with the smallest existing demo or test first.
2. Decide whether the bug is on the driver side (`CGContext` categories) or the object/resource side (paint, image, framebuffer).
3. If the same public call sequence works in one repro but fails in another, suspect backend callback wiring or resource handling.

## Quirks

- Context behavior is split across categories. A blank frame can be a resource/upload bug even when the draw call is correct.
- `CGBackend.h` and `CGBackendFunctionTable.h` are part of the debugging story, not implementation trivia.
- `traceDrawCalls` on `CGLayoutContext` exists for draw-call tracing when order matters more than pixels.

## NVG call tracing with `UIDebuggingFlags`

- `CGContextBase` reads `CGContextDebuggingFlags` first and falls back to `UIDebuggingFlags` in `+initialize` (`src/CGContextBase.m`).
- Draw-call tracing is enabled by `CGContextDebugTraceDrawCalls` (`src/CGContext+DebugPrivate.h`), which maps to `UIGraphicsContextTraceDrawCalls = 0x04000000`.
- `beginRender:`/`endRender` in `src/CGContext+Render.m` call `CGContextTrace(...)` while that bit is set, producing NVG call tracing.

Example:

```bash
mulle-sde -DUIDebuggingFlags=0x04000000 run --mulleui-frames 1 demo
```

Equivalent explicit context-only switch:

```bash
mulle-sde -DCGContextDebuggingFlags=0x04000000 run --mulleui-frames 1 demo
```

For narrow tracing, you can enable tracing on just one context/layer with `setTraceFile:`:

```objc
[pathContext setTraceFile:stderr];   // trace only this layer/context
// ... draw calls for this layer ...
[pathContext setTraceFile:NULL];     // disable again
```

- This is often less noisy than global `UIDebuggingFlags` tracing.
- See `demo/src/main-precompiled.m` (`pathContext`) and `demo/src/main-grid.m` (`context`) for local examples.
