<!-- keywords: mulle-cg, quirks, CGContext, render, thread, coordinates -->
# Quirks

## Render-pass ownership

- `src/CGContext.h`: frames cannot be nested. One `beginRender:`/`endRender` pair per frame.
- `src/CGContext.h`: backend access asserts current-thread ownership. Activate the graphics context before touching render state or GPU-backed objects.
- `src/CGContext+Render.h`: if you mix raw backend work with MulleCG drawing, use `suspendRender`/`resumeRender`; do not assume nanovg/OpenGL state survives arbitrary interleaving.

## Coordinate system

- `README.md`: coordinates address the space between pixels, not pixel centers. The first pixel spans 0 to 1. For crisp borders, compute stroke/fill rects instead of guessing half-pixel offsets.

## Context is split across categories

- Drawing, render, image, framebuffer, shader, and texture entry points are intentionally split across separate `src/CGContext+*.h` headers. Do not assume one header shows the whole surface.
