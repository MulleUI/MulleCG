<!-- keywords: mulle-cg-framebuffer, patterns, ping-pong, threaded, offscreen -->
# Patterns

## Ping-pong framebuffer reuse

See `demo/main-cglayer-paint.m` for framebuffer ping-pong with alpha decay/accumulation.

## Threaded offscreen rendering

See `demo/main-glfw-offscreen-threaded.m`:

```objc
// Render thread:
[context setRendersOffScreen:YES];
// ... render into framebuffer ...
[context provideRenderedFramebuffer:fb];

// Display thread:
CGFramebuffer   *acquired = [context acquireRenderedFramebuffer];
[acquired drawRect:screenRect options:NULL context:displayContext];
[context recycleAcquiredRenderedFramebuffer:acquired];
```

## Use framebuffers when drawing is reused across frames

If a complex drawing (many shapes, gradients, text) is rendered identically every frame, render it once into a framebuffer and blit the result. This trades GPU memory for render time.
