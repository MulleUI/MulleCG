<!-- keywords: mulle-cg-framebuffer, framebuffer, offscreen, cache, CGFramebuffer, CGLayer, threading, acquire, recycle -->
# mulle-cg-framebuffer

Use this topic for offscreen rendering, caching expensive drawings in framebuffers, and threaded framebuffer handoff.

## Understand first

```bash
mulle-sde api apropos CGFramebuffer
mulle-sde code search beginFBRenderWithBackgroundColor
mulle-sde code search acquireRenderedFramebuffer
mulle-sde code search recycleAcquiredRenderedFramebuffer
```

## Local references

- `src/CGFramebuffer.h`
- `src/CGContext+CGFramebuffer.h`
- `demo/main-cglayer-paint.m`
- `demo/main-glfw-offscreen-threaded.m`
- `test/10-first/cgframebuffer.m`

## Function cheatsheet

### Creating framebuffers

| Method | What it does |
|--------|-------------|
| `[CGFramebuffer framebufferWithBitmapSize:size textureFlags:0 context:ctx]` | Basic creation |
| `[CGFramebuffer framebufferWithBitmapSize:size textureFlags:0 nameUTF8String:name context:ctx]` | Named (for debugging) |
| `[CGFramebuffer framebufferWithBitmapSize:size backgroundColor:c drawFunction:f userInfo:info nameUTF8String:name context:ctx]` | Create + immediate draw |

### Rendering into a framebuffer

| Method | What it does |
|--------|-------------|
| `[fb beginFBRenderWithBackgroundColor:color devicePixelRatio:1.0 layerRenderInfo:&memo]` | Begin offscreen render |
| `[fb endFBRender:&memo]` | End offscreen render |

### Drawing framebuffer to screen

| Method | What it does |
|--------|-------------|
| `[fb drawRect:rect options:NULL context:ctx]` | Blit to target rect |

### Threaded handoff (non-active thread)

| Method | Side | What it does |
|--------|------|-------------|
| `acquireRenderedFramebuffer` | Foreign thread | Get rendered FB |
| `recycleAcquiredRenderedFramebuffer:` | Foreign thread | Return FB for reuse |
| `provideRenderedFramebuffer:` | Active thread | Provide FB for foreign consumption |
| `recycleRenderedFramebuffer:` | Active thread | Recycle FB |

## Quick recipe: cache complex drawing

```objc
CGFramebuffer                    *cache;
struct CGFramebufferRenderInfo   memo;

cache = [CGFramebuffer framebufferWithBitmapSize:size
                                    textureFlags:0
                                         context:context];

[cache beginFBRenderWithBackgroundColor:CGColorMakeClear()
                       devicePixelRatio:1.0
                        layerRenderInfo:&memo];
{
   CGContextFillRoundedRectWithColor( context, rect, 8.0, CGColorMakeBlue());
   // ... more expensive drawing ...
}
[cache endFBRender:&memo];

// Later, blit cache (fast):
[cache drawRect:targetRect options:NULL context:context];
```
