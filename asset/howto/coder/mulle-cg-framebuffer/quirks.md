<!-- keywords: mulle-cg-framebuffer, quirks, lifecycle, bind, mid-pass -->
# Quirks

- Framebuffer creation is not for the middle of the main render pass. Build/cache them before or after, then render into them explicitly.
- Do not call `_bindToContext` or `_unbindFromContext` directly; use context framebuffer APIs.
- `acquireRenderedFramebuffer` and `recycleAcquiredRenderedFramebuffer:` are for the non-active-thread side. `provideRenderedFramebuffer:` and `recycleRenderedFramebuffer:` are active-thread-only.
- Once a rendered framebuffer is acquired, keep it until drawing is complete; recycling allows immediate reuse and overwrite.
- `CGFramebuffer` used to be called `CGLayer`, but it is not a CALayer equivalent; it is a mutable GPU-backed render target.
