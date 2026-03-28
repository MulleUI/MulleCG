# Path Contexts

## Overview

NanoVG has three context types:

| Type | Value | Purpose |
|------|-------|---------|
| `NVG_FULL_CONTEXT` | 0 | Normal render context — all operations |
| `NVG_PATH_CONTEXT` | 1 | Path building and precompilation only |
| `NVG_FONT_CONTEXT` | 2 | Font/text measurement only |

A **path context** (`CGContextPrecompilePath`) is a lightweight context with no
GPU backend. It exists solely to hold a path definition that can be reused
across many render frames via `CGContextCopyPath`.

Create one with:

```objc
CGContext *pathContext = [[CGContext createPathContext] retain];
```

## What works on a path context

**Path building** — all standard path ops:
```objc
CGContextBeginPath( pathContext);
CGContextMoveTo( pathContext, ...);
CGContextLineTo( pathContext, ...);
CGContextArc( pathContext, ...);
CGContextBezierTo( pathContext, ...);
CGContextClosePath( pathContext);
```

**Transform state** — save/restore and transforms:
```objc
CGContextSave( pathContext);
CGContextTranslate( pathContext, ...);
CGContextScale( pathContext, ...);
CGContextRotate( pathContext, ...);
CGContextRestore( pathContext);
```

**Precompilation** — tessellate arcs/beziers into line segments:
```objc
CGContextPrecompilePath( pathContext);  // only valid on path contexts
```

## What does NOT work on a path context

- Frame ops: `beginFrame`, `endFrame`, `flushFrame`
- Render ops: `CGContextFill`, `CGContextStroke`
- Style ops: `CGContextStrokeColor`, `CGContextStrokeWidth`, `CGContextFillColor`, etc.
- `CGContextCopyPath` — the **destination** must be a full render context

## CGContextCopyPath semantics

```objc
CGContextCopyPath( renderContext, pathContext);
```

Internally this calls `nvgCopyPath(dst, src)` which:

1. Calls `nvgBeginPath(dst)` — clears the destination's current path
2. Calls `nvg__appendCommands(dst, src->commands, src->ncommands)` — copies
   the raw commands and **applies the destination's current transform** to all
   coordinates at copy time
3. If the destination transform is **translation-only** AND `src->cache` is
   populated (i.e. `CGContextPrecompilePath` was called): copies the
   tessellated cache and translates the cached points — skips re-tessellation
4. If the destination has a non-translation transform (scale, rotate): always
   re-tessellates from raw commands

## CGContextPrecompilePath semantics

```objc
CGContextPrecompilePath( pathContext);
```

- **Only callable on a path context** — asserts otherwise
- Runs tessellation (`nvg__flattenPaths` + `nvg__analyzePaths`) — converts
  arcs and beziers into line segments, stores result in `path->cache`
- Makes subsequent `CGContextCopyPath` faster when the destination only
  translates (no scale/rotate)
- The tessellation is computed at the path context's **current transform** —
  build paths at identity transform for best portability

## Typical usage pattern

```objc
// --- Setup (once) ---
CGContext *pathContext = [[CGContext createPathContext] retain];

CGContextBeginPath( pathContext);
CGContextMoveTo( pathContext, CGPointMake( 25, 150));
// ... more path ops ...
CGContextClosePath( pathContext);

CGContextPrecompilePath( pathContext);  // optional but faster for translate-only reuse


// --- Per frame (in draw callback) ---
CGContextSave( context);
for( NSUInteger i = 0; i < STEPS; i++)
{
   CGContextTranslate( context, CGPointMake( stepX, 0));
   CGContextCopyPath( context, pathContext);   // copies + applies current translation
   CGContextStrokeColor( context, someColor);
   CGContextStrokeWidth( context, 3.0);
   CGContextStroke( context);
}
CGContextRestore( context);
```

## Known issue: nvgCopyPath corrupts source path commands

**Bug in mulle-nanovg**: `nvgCopyPath` is **destructive to the source**.

`nvg__appendCommands` transforms coordinate values **in-place** in the `vals`
array passed to it. When `nvgCopyPath` calls:

```c
nvg__appendCommands( ctx, path->commands, path->ncommands);
```

it passes `path->commands` directly as `vals`. The function then overwrites
the source path's command coordinates with the destination's current transform
applied. After the first `CGContextCopyPath`, the path context's `commands`
array has been corrupted — all coordinates have been transformed by the
destination's translation. On the second call the coordinates are wrong
(shifted by the accumulated translation), and on subsequent calls they drift
further off-screen.

**Why `CGContextPrecompilePath` works around it**: when the destination
transform is translation-only AND the cache is populated, `nvgCopyPath` uses
`nvg__copyPathCache` instead of `nvg__appendCommands` — reading from
`path->cache` (not `path->commands`), so the source is not corrupted.

**Fix applied in mulle-nanovg**: `nvg__appendCommands` now copies `vals` into
`ctx->commands` first, then transforms the destination buffer in-place.
The source (`vals`) is never modified. This is the correct fix — same
performance, no allocation, works for all callers including `nvgCopyPath`.

