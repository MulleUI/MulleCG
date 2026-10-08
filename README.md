# MulleCG

#### Part of [MulleUI](https://github.com/MulleUI) — UIKit-shaped modular GUI libraries for mulle-objc.

MulleCG is the abstract drawing API of MulleUI. It provides `CGContext`,
`CGPaint`, `CGGradient`, `CGImage`, `CGFont`, `CGFramebuffer` and
`CGLayoutContext` — the classes you draw with. Drawing is delegated to a
pluggable `CGBackend`, so the actual rendering
happens with a concrete backend library.

MulleCG does no animation or layouting, no windowing and does not handle
events. It is the drawing layer only: the window that provides the frame loop
and the concrete backend selection come from
[MulleUIOS](//github.com/MulleUI/MulleUIOS).

> #### Note
>
> Both MulleCA and MulleCG pull in the CGColor typedef. For that reason, if
> you have MulleCA and MulleCG in your project, ensure that MulleCG is before
> MulleCA in your dependency list. MulleGraphics will have the proper order
> but MulleUICore will include MulleCA, so also have MulleGraphics before
> MulleUICore.



| Release Version                                       | Release Notes  | AI Documentation
|-------------------------------------------------------|----------------|---------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag/MulleUI/MulleCG.svg) [![Build Status](https://github.com/MulleUI/MulleCG/workflows/CI/badge.svg)](//github.com/MulleUI/MulleCG/actions) | [RELEASENOTES](RELEASENOTES.md) | [DeepWiki for MulleCG](https://deepwiki.com/MulleUI/MulleCG)




## Documentation & Guides

* [API Summary](asset/dox/api/toc)
* [Coder Guide](asset/howto/coder/mulle-cg)
* [Debugger Guide](asset/howto/debugger/mulle-cg)
* [Verifier Guide](asset/howto/verifier/mulle-cg)

## Usage

Here is a complete draw callback. A window ([MulleUIWindow](//github.com/MulleUI/MulleUIWindow))
creates the layer and the `CGContext` for you and calls your callback once per
frame. You just draw:

``` objc
#import <MulleCG/MulleCG.h>
#import <MulleGraphics/MulleGraphics.h>   // CGGraphicsLayer
#import <mulle-color/mulle-color.h>       // CGColorMake*

static BOOL   draw( CGGraphicsLayer *layer, CGContext *context)
{
   CGPaint   *paint;
   CGRect    rect;

   rect = CGRectMake( 20.0, 20.0, 160.0, 60.0);

   // fill a rounded rectangle with a solid color paint
   paint = [CGPaint paintWithColor:CGColorMakeSkyBlue()];
   CGContextFillRoundedRectWithPaintable( context, rect, 8.0, paint);

   // stroke the same rectangle from the inside
   CGContextStrokeRoundedRectWithPaintable( context, rect, 8.0, 2.0, paint);

   // fill a rectangle with a linear gradient paint
   paint = [CGPaint paintWithStartColor:CGColorMakeLightSkyBlue()
                               endColor:CGColorMakeTransparent()];
   CGContextFillRectWithPaintable( context, CGRectMake( 20.0, 100.0, 160.0, 40.0), paint);

   // draw some text; a length of 0 means "use strlen"
   CGContextFontSize( context, 14.0);
   CGContextTextColor( context, CGColorMakeWhite());
   CGContextText( context, CGPointMake( 30.0, 40.0), "Hello MulleCG", 0);

   return( NO);
}
```

The color constructors come from [mulle-color](//github.com/mulle-gfx/mulle-color),
rectangles and points from [mulle-geometry](//github.com/MulleUI/mulle-geometry);
both are pulled in by MulleCG. See the
[MulleUIWindow demos](//github.com/MulleUI/MulleUIWindow) for the window setup
that feeds `draw:` its `CGContext`.

`demo/main-cglayer-paint.m` is a larger example that renders into offscreen
`CGFramebuffer`s, composites them and swaps layers.

## Build the demo

The `demo/` folder is a [mulle-sde](//github.com/mulle-sde) project:

``` sh
cd demo
mulle-sde craft
```

## Concepts

### Drawing and font management are separate

MulleCG splits rendering into two concerns. Each has its own opaque context
and its own function table, but both live in the same object:

* **Drawing** — `CGContext` owns the draw backend, a `CGBackend` struct made
  of an opaque context plus two embedded vtables: `CGFunctionTable` (paths,
  fill, stroke, transforms, scissor, textures, blending) and
  `CGBackendFunctionTable` (framebuffers). Calls like `CGContextFill`,
  `CGContextRect` and `CGContextBeginFrame` dispatch through them.
* **Font management** — `CGLayoutContext`, the superclass of `CGContext`,
  owns `_fontContext` and a `CGFontFunctionTable` (createFont, findFont,
  fallback fonts, fontSize, textAlign, text, textBox, textMetrics, glyph
  positions, line breaking). All `CGContext*Font*`, `CGContextText*` and
  `CGLayoutContext*` calls dispatch through it.

The two opaque contexts may be the same object — with the nanovg backend
`_fontContext == _cgBackend.context` — or completely different. That is why
`CGContextSave`/`CGContextRestore` push two state stacks, one for drawing and
one for fonts. Text is measured and shaped through the font table and then
rendered through the draw table.

### Backends

MulleCG is backend-agnostic. A concrete backend fills the function tables of
a `CGBackend` and hands you a `CGContext` bound to its graphics context:

* `MulleCGNanovg` — nanovg on OpenGL/OpenGLES
* `MulleCGCairo` — a cairo backend (experimental - not released)
* `MulleCGSkia` — a Skia backend (experimental - not released)

### The object model

* `CGContext` — drawing state and command stream
* `CGPaint` — what you fill and stroke with: solid color, gradient
  (`CGGradient`, linear/radial/box), image (`CGImagePaint`), blended
  (`CGBlendedPaint`)
* `CGImage` — a texture you can draw with and draw into (and itself a
  `CGPaint`)
* `CGFont`, `CGLayoutContext` — text, glyphs and measurement
* `CGFramebuffer` — an offscreen render target


## How to draw pixel perfect rectangles

### The coordinate system

In the end you want to light up pixels on the display and everything else is
just there to help you do that. With that in mind it may come up a surprise,
that with rectangle drawing you can't address individual pixels with a x/y
coordinate (say 10,20). What you are addressing is the space between the pixels.
So the very first pixel, spans the space from 0 to 1 in the horizontal and
vertical directions.

![A pixel](pixel.svg)

### A rectangle

A rectangle is a `CGRect` from
[mulle-geometry](//github.com/MulleUI/mulle-geometry). In the following we
only consider standardized rects, i.e. with positive width and height.

There are two drawing operations in MulleCG: `fill` and `stroke`, and they
are quite different.

### Fill Operation

If you want to fill three pixels in a horizontal line with a color, you create
a CGRectMake( 1, 1, 3, 1):

![Filling three](fill.svg)

AntiAliasing will not come into play here, as we are hitting "pixels" exactly.


### Stroke Operation

You can also achieve this lighting of pixels by drawing a line. The stroke
emanates perpendicular to the line. So to light a single pixel, you
use a strokeWidth of one and stroke right through the center of the pixel.

To cover our three pixels either use a horizontal line going from
CGPointMake( 1.0, 1.5) to CGPointMake( 4.0, 1.5) with a `strokeWidth` of 1.
Or it's a vertical line going from `CGPointMake( 2.5, 1)` to
`CGPointMake( 2.5, 2)`  with a `strokeWidth` of 3.


![Stroke three](stroke.svg)

This unfortunately means that you need to keep the direction of the stroke
in mind, to properly place the stroke center for pixel accurate drawing.
With this in mind, if you can fill, don't stroke.


### Combining stroke and fill

So lets cut right to the chase. Often you want to draw a rectangle with a
border around it (and maybe some text in the middle).
Some layout mechanism has provided you with a CGRect where to draw it.

That rectangle a priori is a fill rectangle. To draw a border without overdraw
inside this rectangle, calculate the appropriate stroke rectangle:
`strokeRect = CGRectMakeStrokeRect( rect, strokeWidth, CGInside)`.

> #### Note
>
> Instead of `CGInside`, you can also use `CGOutside` to draw a border around
> the rectangle or `CGOverlap` which is basically a nop operation and will make
> half the border drawn on the inside and half on the outside.

Now to compute the rectangle to fill this stroked rectangle use
`CGRectMakeFillRect( strokeRect, strokeWidth, CGInside)`.

> #### Note
>
> Instead of `CGInside` you can also use `CGOverlap` to cover the same space.
> `CGOutside` is not really useful here.


## Paints

Everything you fill or stroke with is a `CGPaint`:

| Kind | Class | Example |
|------|-------|---------|
| Solid color | `CGPaint` | `[CGPaint paintWithColor:CGColorMakeSkyBlue()]` |
| Linear gradient | `CGGradient` | `[CGPaint paintWithStartColor:… endColor:…]` |
| Image | `CGImagePaint` | `[[CGImagePaint alloc] initWithImage:image]` |
| Blended | `CGBlendedPaint` | `[paint paintWithPaint:other blend:0.5]` |

The gradient constructors also come in a `rotation:` variant. A paint can be
further transformed: `brightenedPaint:`, `dimmedPaint:`, `saturatedPaint:`,
`desaturatedPaint:`, `transparentPaint:`, `rotatedPaint:`, `reversedPaint`.

Paint a shape with the `CGContext*WithPaintable:` conveniences:

``` objc
CGContextFillRectWithPaintable( context, rect, paint);
CGContextStrokeRectWithPaintable( context, rect, 2.0, paint);
CGContextFillRoundedRectWithPaintable( context, rect, 8.0, paint);
CGContextStrokeRoundedRectWithPaintable( context, rect, 8.0, 2.0, paint);
CGContextFillCircleWithPaintable( context, circle, paint);
CGContextStrokeCircleWithPaintable( context, circle, 2.0, paint);
CGContextFillLineWithPaintable( context, start, end, paint);
CGContextStrokeLineWithPaintable( context, start, end, 2.0, paint);
```

Or set the fill style directly and draw:

``` objc
CGContextSetFillLinearGradient( context, start, end, startColor, endColor);
CGContextSetFillBoxGradient( context, rect, cornerRadius, color, feather, featherColor);
CGContextSetFillRadialGradient( context, circle, outerColor, innerRadius, innerColor);
CGContextFill( context);
```

`CGImage` is itself a `CGPaint`, so you can fill a shape with the contents of
an image — or of a `CGFramebuffer`.


### You are here

![Overview](overview.dot.svg)





## Add





### Add MulleCG as a cmake subproject

In your code include its header:

``` c
#include <MulleCG/MulleCG.h>
```

Add MulleCG and dependencies as git submodules and link against
them:

``` bash
git submodule add -f --branch * --name "mintomic" \
                            "clib:mulle-concurrent/mintomic@*" \
                            "stash/mintomic"
git submodule add -f --branch * --name "dlfcn-win32" \
                            "clib:mulle-core/dlfcn-win32@*" \
                            "stash/dlfcn-win32"
git submodule add -f --branch * --name "src/mulle-aba" \
                            "clib:mulle-concurrent/mulle-aba@*" \
                            "stash/src/mulle-aba"
git submodule add -f --branch * --name "src/mulle-allocator" \
                            "clib:mulle-c/mulle-allocator@*" \
                            "stash/src/mulle-allocator"
git submodule add -f --branch * --name "src/mulle-buffer" \
                            "clib:mulle-c/mulle-buffer@*" \
                            "stash/src/mulle-buffer"
git submodule add -f --branch * --name "src/mulle-c11" \
                            "clib:mulle-c/mulle-c11@*" \
                            "stash/src/mulle-c11"
git submodule add -f --branch * --name "src/mulle-concurrent" \
                            "clib:mulle-concurrent/mulle-concurrent@*" \
                            "stash/src/mulle-concurrent"
git submodule add -f --branch * --name "src/mulle-container-debug" \
                            "clib:mulle-c/mulle-container-debug@*" \
                            "stash/src/mulle-container-debug"
git submodule add -f --branch * --name "src/mulle-container" \
                            "clib:mulle-c/mulle-container@*" \
                            "stash/src/mulle-container"
git submodule add -f --branch * --name "src/mulle-data" \
                            "clib:mulle-c/mulle-data@*" \
                            "stash/src/mulle-data"
git submodule add -f --branch * --name "src/mulle-dlfcn" \
                            "clib:mulle-core/mulle-dlfcn@*" \
                            "stash/src/mulle-dlfcn"
git submodule add -f --branch * --name "src/mulle-dtostr" \
                            "clib:mulle-core/mulle-dtostr@*" \
                            "stash/src/mulle-dtostr"
git submodule add -f --branch * --name "src/mulle-fifo" \
                            "clib:mulle-concurrent/mulle-fifo@*" \
                            "stash/src/mulle-fifo"
git submodule add -f --branch * --name "src/mulle-fprintf" \
                            "clib:mulle-core/mulle-fprintf@*" \
                            "stash/src/mulle-fprintf"
git submodule add -f --branch * --name "src/mulle-http" \
                            "clib:mulle-c/mulle-http@*" \
                            "stash/src/mulle-http"
git submodule add -f --branch * --name "src/mulle-linkedlist" \
                            "clib:mulle-concurrent/mulle-linkedlist@*" \
                            "stash/src/mulle-linkedlist"
git submodule add -f --branch * --name "src/mulle-mmap" \
                            "clib:mulle-core/mulle-mmap@*" \
                            "stash/src/mulle-mmap"
git submodule add -f --branch * --name "src/mulle-multififo" \
                            "clib:mulle-concurrent/mulle-multififo@*" \
                            "stash/src/mulle-multififo"
git submodule add -f --branch * --name "src/mulle-rbtree" \
                            "clib:mulle-c/mulle-rbtree@*" \
                            "stash/src/mulle-rbtree"
git submodule add -f --branch * --name "src/mulle-rbtree-debug" \
                            "clib:mulle-core/mulle-rbtree-debug@*" \
                            "stash/src/mulle-rbtree-debug"
git submodule add -f --branch * --name "src/mulle-regex" \
                            "clib:mulle-c/mulle-regex@*" \
                            "stash/src/mulle-regex"
git submodule add -f --branch * --name "src/mulle-slug" \
                            "clib:mulle-c/mulle-slug@*" \
                            "stash/src/mulle-slug"
git submodule add -f --branch * --name "src/mulle-sprintf" \
                            "clib:mulle-core/mulle-sprintf@*" \
                            "stash/src/mulle-sprintf"
git submodule add -f --branch * --name "src/mulle-storage" \
                            "clib:mulle-c/mulle-storage@*" \
                            "stash/src/mulle-storage"
git submodule add -f --branch * --name "src/mulle-thread" \
                            "clib:mulle-concurrent/mulle-thread@*" \
                            "stash/src/mulle-thread"
git submodule add -f --branch * --name "src/mulle-time" \
                            "clib:mulle-core/mulle-time@*" \
                            "stash/src/mulle-time"
git submodule add -f --branch * --name "src/mulle-unicode" \
                            "clib:mulle-c/mulle-unicode@*" \
                            "stash/src/mulle-unicode"
git submodule add -f --branch * --name "src/mulle-url" \
                            "clib:mulle-c/mulle-url@*" \
                            "stash/src/mulle-url"
git submodule add -f --branch * --name "src/mulle-utf" \
                            "clib:mulle-c/mulle-utf@*" \
                            "stash/src/mulle-utf"
git submodule add -f --branch * --name "src/mulle-vararg" \
                            "clib:mulle-c/mulle-vararg@*" \
                            "stash/src/mulle-vararg"
git submodule add -f --name "stdthreads" \
                            "" \
                            "stash/stdthreads"
git submodule add -f --name "pthread" \
                            "" \
                            "stash/pthread"
git submodule add -f --name "src/mulle-spawn" \
                            "clib:mulle-core/mulle-spawn@*" \
                            "stash/src/mulle-spawn"
git submodule add -f --name "src/mulle-socket" \
                            "clib:mulle-core/mulle-socket@*" \
                            "stash/src/mulle-socket"
git submodule add -f --name "ws2_32" \
                            "" \
                            "stash/ws2_32"
git submodule add -f --name "mulle-core" \
                            "https://github.com/mulle-core/mulle-core.git" \
                            "stash/mulle-core"
git submodule add -f --name "zlib" \
                            "https://github.com/madler/zlib.git" \
                            "stash/zlib"
git submodule add -f --name "src/mulle-bitmap" \
                            "clib:mulle-gfx/mulle-bitmap" \
                            "stash/src/mulle-bitmap"
git submodule add -f --name "src/mulle-frame" \
                            "clib:mulle-gfx/mulle-frame" \
                            "stash/src/mulle-frame"
git submodule add -f --name "src/mulle-geometry" \
                            "clib:mulle-gfx/mulle-geometry" \
                            "stash/src/mulle-geometry"
git submodule add -f --name "src/mulle-layout" \
                            "clib:mulle-gfx/mulle-layout" \
                            "stash/src/mulle-layout"
git submodule add -f --name "src/mulle-quadtree" \
                            "clib:mulle-gfx/mulle-quadtree" \
                            "stash/src/mulle-quadtree"
git submodule add -f --name "src/mulle-fparray" \
                            "clib:mulle-gfx/mulle-fparray" \
                            "stash/src/mulle-fparray"
git submodule add -f --name "src/mulle-hexcolor" \
                            "clib:mulle-c/mulle-hexcolor" \
                            "stash/src/mulle-hexcolor"
git submodule add -f --branch * --name "src/mulle-path" \
                            "clib:mulle-gfx/mulle-path@*" \
                            "stash/src/mulle-path"
git submodule add -f --branch * --name "src/mulle-color" \
                            "clib:mulle-gfx/mulle-color@*" \
                            "stash/src/mulle-color"
git submodule add -f --name "math" \
                            "" \
                            "stash/math"
git submodule add -f --name "z" \
                            "" \
                            "stash/z"
git submodule add -f --name "mulle-gfx" \
                            "https://github.com/mulle-gfx/mulle-gfx.git" \
                            "stash/mulle-gfx"
git submodule add -f --name "craftinfo/libbacktrace-craftinfo" \
                            "" \
                            "stash/craftinfo/libbacktrace-craftinfo"
git submodule add -f --name "libbacktrace" \
                            "https://github.com/mulle-core/libbacktrace.git" \
                            "stash/libbacktrace"
git submodule add -f --branch * --name "src/mulle-atinit" \
                            "clib:mulle-core/mulle-atinit@*" \
                            "stash/src/mulle-atinit"
git submodule add -f --branch * --name "src/mulle-atexit" \
                            "clib:mulle-core/mulle-atexit@*" \
                            "stash/src/mulle-atexit"
git submodule add -f --branch * --name "src/mulle-stacktrace" \
                            "clib:mulle-core/mulle-stacktrace@*" \
                            "stash/src/mulle-stacktrace"
git submodule add -f --name "mulle-core-all-load" \
                            "https://github.com/mulle-core/mulle-core-all-load.git" \
                            "stash/mulle-core-all-load"
git submodule add -f --name "mulle-objc-runtime" \
                            "https://github.com/mulle-objc/mulle-objc-runtime.git" \
                            "stash/mulle-objc-runtime"
git submodule add -f --name "mulle-objc-debug" \
                            "https://github.com/mulle-objc/mulle-objc-debug.git" \
                            "stash/mulle-objc-debug"
git submodule add -f --name "mulle-objc-cc" \
                            "https://github.com/mulle-cc/mulle-objc-cc.git" \
                            "stash/mulle-objc-cc"
git submodule add -f --name "MulleObjC" \
                            "https://github.com/mulle-objc/MulleObjC.git" \
                            "stash/MulleObjC"
git submodule add -f --name "MulleUIBase" \
                            "https://github.com/MulleUI/MulleUIBase.git" \
                            "stash/MulleUIBase"
git submodule add -f --name "mulle-objc-tools" \
                            "https://github.com/mulle-objc/mulle-objc-tools.git" \
                            "stash/mulle-objc-tools"
git submodule add -f --name "m" \
                            "m" \
                            "stash/m"
git submodule add -f --name "MulleCG" \
                        "https://github.com/MulleUI/MulleCG" \
                        "stash/MulleCG"
git submodule update --init --recursive
```

``` cmake
include_directories( SYSTEM "${CMAKE_BINARY_DIR}/include")

add_subdirectory( stash/mintomic)
add_subdirectory( stash/dlfcn-win32)
add_subdirectory( stash/src/mulle-aba)
add_subdirectory( stash/src/mulle-allocator)
add_subdirectory( stash/src/mulle-buffer)
add_subdirectory( stash/src/mulle-c11)
add_subdirectory( stash/src/mulle-concurrent)
add_subdirectory( stash/src/mulle-container-debug)
add_subdirectory( stash/src/mulle-container)
add_subdirectory( stash/src/mulle-data)
add_subdirectory( stash/src/mulle-dlfcn)
add_subdirectory( stash/src/mulle-dtostr)
add_subdirectory( stash/src/mulle-fifo)
add_subdirectory( stash/src/mulle-fprintf)
add_subdirectory( stash/src/mulle-http)
add_subdirectory( stash/src/mulle-linkedlist)
add_subdirectory( stash/src/mulle-mmap)
add_subdirectory( stash/src/mulle-multififo)
add_subdirectory( stash/src/mulle-rbtree)
add_subdirectory( stash/src/mulle-rbtree-debug)
add_subdirectory( stash/src/mulle-regex)
add_subdirectory( stash/src/mulle-slug)
add_subdirectory( stash/src/mulle-sprintf)
add_subdirectory( stash/src/mulle-storage)
add_subdirectory( stash/src/mulle-thread)
add_subdirectory( stash/src/mulle-time)
add_subdirectory( stash/src/mulle-unicode)
add_subdirectory( stash/src/mulle-url)
add_subdirectory( stash/src/mulle-utf)
add_subdirectory( stash/src/mulle-vararg)
add_subdirectory( stash/stdthreads)
add_subdirectory( stash/pthread)
add_subdirectory( stash/src/mulle-spawn)
add_subdirectory( stash/src/mulle-socket)
add_subdirectory( stash/ws2_32)
add_subdirectory( stash/mulle-core)
add_subdirectory( stash/zlib)
add_subdirectory( stash/src/mulle-bitmap)
add_subdirectory( stash/src/mulle-frame)
add_subdirectory( stash/src/mulle-geometry)
add_subdirectory( stash/src/mulle-layout)
add_subdirectory( stash/src/mulle-quadtree)
add_subdirectory( stash/src/mulle-fparray)
add_subdirectory( stash/src/mulle-hexcolor)
add_subdirectory( stash/src/mulle-path)
add_subdirectory( stash/src/mulle-color)
add_subdirectory( stash/math)
add_subdirectory( stash/z)
add_subdirectory( stash/mulle-gfx)
add_subdirectory( stash/craftinfo/libbacktrace-craftinfo)
add_subdirectory( stash/libbacktrace)
add_subdirectory( stash/src/mulle-atinit)
add_subdirectory( stash/src/mulle-atexit)
add_subdirectory( stash/src/mulle-stacktrace)
add_subdirectory( stash/mulle-core-all-load)
add_subdirectory( stash/mulle-objc-runtime)
add_subdirectory( stash/mulle-objc-debug)
add_subdirectory( stash/mulle-objc-cc)
add_subdirectory( stash/MulleObjC)
add_subdirectory( stash/MulleUIBase)
add_subdirectory( stash/mulle-objc-tools)
add_subdirectory( stash/m)
add_subdirectory( stash/MulleCG)

target_link_libraries( ${PROJECT_NAME} PUBLIC mintomic)
target_link_libraries( ${PROJECT_NAME} PUBLIC dlfcn-win32)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-aba)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-allocator)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-buffer)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-c11)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-concurrent)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-container-debug)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-container)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-data)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-dlfcn)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-dtostr)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-fifo)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-fprintf)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-http)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-linkedlist)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-mmap)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-multififo)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-rbtree)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-rbtree-debug)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-regex)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-slug)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-sprintf)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-storage)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-thread)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-time)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-unicode)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-url)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-utf)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-vararg)
target_link_libraries( ${PROJECT_NAME} PUBLIC stdthreads)
target_link_libraries( ${PROJECT_NAME} PUBLIC pthread)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-spawn)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-socket)
target_link_libraries( ${PROJECT_NAME} PUBLIC ws2_32)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-core)
target_link_libraries( ${PROJECT_NAME} PUBLIC zlib)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-bitmap)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-frame)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-geometry)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-layout)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-quadtree)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-fparray)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-hexcolor)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-path)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-color)
target_link_libraries( ${PROJECT_NAME} PUBLIC math)
target_link_libraries( ${PROJECT_NAME} PUBLIC z)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-gfx)
target_link_libraries( ${PROJECT_NAME} PUBLIC craftinfo/libbacktrace-craftinfo)
target_link_libraries( ${PROJECT_NAME} PUBLIC libbacktrace)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-atinit)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-atexit)
target_link_libraries( ${PROJECT_NAME} PUBLIC src/mulle-stacktrace)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-core-all-load)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-runtime)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-debug)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-cc)
target_link_libraries( ${PROJECT_NAME} PUBLIC MulleObjC)
target_link_libraries( ${PROJECT_NAME} PUBLIC MulleUIBase)
target_link_libraries( ${PROJECT_NAME} PUBLIC mulle-objc-tools)
target_link_libraries( ${PROJECT_NAME} PUBLIC m)
target_link_libraries( ${PROJECT_NAME} PUBLIC MulleCG)
```

Or let [mulle-sde](//github.com/mulle-sde) do it:

``` sh
mulle-sde add github:MulleUI/MulleCG
```

## Install

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleCG and all dependencies:

``` sh
mulle-sde install --prefix /usr/local \
   https://github.com/MulleUI/MulleCG/archive/latest.tar.gz
```

### Legacy Installation

Install the requirements:

| Requirements                                 | Description
|----------------------------------------------|-----------------------
| [MulleUIBase](https://github.com/MulleUI/MulleUIBase)             | Part of [MulleUI](https://github.com/MulleUI) — UIKit-shaped modular GUI libraries for mulle-objc.
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list)             | 📒 Lists mulle-objc runtime information contained in executables.

Download the latest [tar](https://github.com/MulleUI/MulleCG/archive/refs/tags/latest.tar.gz) or [zip](https://github.com/MulleUI/MulleCG/archive/refs/tags/latest.zip) archive and unpack it.

Install **MulleCG** into `/usr/local` with [cmake](https://cmake.org):

``` sh
PREFIX_DIR="/usr/local"
cmake -B build                               \
      -DMULLE_SDK_PATH="${PREFIX_DIR}"       \
      -DCMAKE_INSTALL_PREFIX="${PREFIX_DIR}" \
      -DCMAKE_PREFIX_PATH="${PREFIX_DIR}"    \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```


## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK  



