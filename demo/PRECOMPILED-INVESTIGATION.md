# precompiled demo — investigation notes

## Status

The demo runs without crashing. The spiral shows correctly when run with `-c`
(no path caching, direct draw). With caching enabled (default), the spiral
shows on the first frame then disappears.

## What was fixed

- `createPathContext` now returns a proper `CGContext *` wrapping a
  `NVG_PATH_ONLY` NVG context, instead of crashing with a raw `NVGcontext *`
  cast to `CGContext *`.
- Added `CGContextCopyPath(dst, src)` to `CGContext+Drawing.h` and wired it
  through `CGFunctionTable` → `nvgCopyPath`.
- Added `UIGraphicsPathOnly` option and `_initAsPathContext` init.
- Added `CGContextSave`/`CGContextRestore` around the translation loop to
  prevent accumulated transforms across frames.

## Remaining issue: cached path shows once then goes black

### What the trace shows

- `drawSplitRectWithHole(pathContext, ...)` correctly calls `nvgBeginPath`,
  `nvgMoveTo`, `nvgLineTo`, `nvgArc` on the path NVG context — commands are
  stored.
- `nvgCopyPath(render_vg, path_vg)` is called 200 times per frame with the
  correct path context pointer.
- `nvgCopyPath` internally calls `nvgBeginPath` on the render context, then
  `nvg__appendCommands` (not traced), then the caller does `nvgStroke`.
- No geometry (`nvgMoveTo` etc.) appears in the render context trace after
  `nvgCopyPath`, suggesting `nvg__appendCommands` copies zero commands.

### Hypothesis

The path context's `ncommands` may be 0 at the time `nvgCopyPath` reads it,
even though commands were stored earlier. Possible causes:

1. **Thread safety**: the draw callback runs on `UIWindowThread`. If the path
   context is built on a different thread and `ncommg` is read before the
   write is visible, commands appear empty. Unlikely since it works on frame 1.

2. **nvgPrecompilePath not called**: `nvgCopyPath` can copy either raw commands
   or cached tessellation. Without `nvgPrecompilePath`, only raw commands are
   copied. The raw copy path (`nvg__appendCommands`) should work — but if
   `path->ncommands` is somehow 0 on the second read, nothing is copied.
   Calling `nvgPrecompilePath(CGContextVG(pathContext))` after building the
   path may fix this (not yet tested due to missing header exposure).

3. **NVG_PATH_ONLY context limitation**: the path-only context may have
   restrictions on `nvg__appendCommands` that aren't documented.

### Next steps to try

```objc
// After drawSplitRectWithHole(pathContext, ...):
// Need nvgPrecompilePath exposed — add to CGFunctionTable or call directly
// via CGContextGetNVGContext(pathContext) with nanovg.h included.
nvgPrecompilePath( CGContextGetNVGContext( pathContext));
```

Or alternatively, expose `precompilePath` in `CGFunctionTable` and add a
`CGContextPrecompilePath(context)` inline to `CGContext+Drawing.h`.

## Debug artifacts to remove before committing

`main-precompiled.m` currently has debug `fprintf`, `setTraceFile:` calls and
the `nvgPrecompilePath` stub. Clean these up once the issue is resolved.
