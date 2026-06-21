<!-- keywords: debugger, mulle-cg-framebuffer, offscreen, threaded, lifecycle, acquire, recycle -->
# mulle-cg-framebuffer

Use this when offscreen rendering fails: blank framebuffers, stale content, or threading-related regressions.

## Local references

- `src/CGFramebuffer.h`
- `src/CGContext+CGFramebuffer.h`
- `demo/main-glfw-offscreen-threaded.m`
- `demo/main-cglayer-paint.m`
- `test/10-first/cgframebuffer.m`

## Local workflow

1. Reproduce with `test/10-first/cgframebuffer.m` first (minimal, no UI noise).
2. Move to `demo/main-glfw-offscreen-threaded.m` only after the offscreen case is stable.
3. If the bug only exists in the threaded demo, keep thread ownership and resource timing on the suspect list — it's usually about backend/thread/resource ordering, not path construction.

## Quirks

- `test/10-first/cgframebuffer.m` is not a rendering test — it verifies object lifetime only, not framebuffer contents or acquire/recycle flow.
- `demo/main-glfw-offscreen-threaded.m` adds backend/thread pressure. Bugs exclusive to it are usually about resource timing.
- `_bindToContext`/`_unbindFromContext` failures usually mean the higher-level framebuffer path is being bypassed.
