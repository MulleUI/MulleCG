<!-- keywords: debugger, mulle-cg-image, resource, blank, stale, flipped, texture, chain -->
# mulle-cg-image

Use this when pixels are blank, stale, flipped, or only fail in image/texture paths.

## Local references

- `src/CGImage.h`
- `src/CGContext+CGImage.h`
- `src/CGContext+Texture.h`
- `src/CGDrawable.h`
- `test/10-first/cgframebuffer.m`

## Local workflow

1. Debug as one resource chain: image object/source pixels → texture/upload helper → render call.
2. If output is blank or stale (not geometrically wrong), stay in this cluster before reopening drawing code.
3. For drawable geometry bugs (wrong bounds, wrong scale), start from `mulle-sde api cat CGDrawable` and map the object state back to the first `CGContext` call that consumes it.

## Quirks

- `canvas` is always `{0, 0, size}` but `bounds` can differ for bitmaps vs vector drawables.
- The repo has stronger test coverage for render/resource code than for `CGDrawable` or `CGLayoutContext`. Report gaps explicitly.
