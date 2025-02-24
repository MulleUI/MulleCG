# MulleCG

#### 💫 MulleCG Coregraphics for MulleUI


# 💫 MulleCG

💫 MulleCG Coregraphics for MulleUI

MulleCG adds `nanovg` to MulleUI. It provides CGContext which uses a nanovg
context to do drawing. The CGContext manages textures, fonts and shaders.
Does not do any animation or layouting. Does not do windowing. Does not
handle events.


> #### Note
>
> Typedefs CGColor! For that reason, if you
> have MulleCA and MulleCG in your project, ensure that MulleCG is before
> MulleCA in your dependency list. MulleGraphics will have the proper order
> but MulleUICore will include MulleCA, so also have MulleGraphics before
> MulleUICore.



```
TODO: dFdx not supported by OpenGLES2 (steal from shader compiler or
wherever)
```



| Release Version                                       | Release Notes
|-------------------------------------------------------|--------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag/MulleUI/MulleCG.svg) [![Build Status](https://github.com/MulleUI/MulleCG/workflows/CI/badge.svg)](//github.com/MulleUI/MulleCG/actions) | [RELEASENOTES](RELEASENOTES.md) |





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

The representation of a rectangle in MulleCG is `CGRect` (from [mulle-geometry]()).
A CGRect has a x,y coordinate and a height and a width. Though you could have
a negative height and/or width you can easily transform such a CGRect into
a standardized CGRect with positive height and width, just my negative that
axis and moving the point (`CGRectStandardize`). So for the further discussion
a rect is always standardized and has positive width and height.

There are two operations in MulleCG, they are the "fill" and the "stroke",
they are very different.

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
border around it (and maybe some text in the middle a.k.a.).
Some layout mechanism has provided you with a CGRect where to draw it.

That rectangle a priori is a fill rectangle. To draw a border without overdraw
inside this rectangle, calculate the appropriate stroke rectangle:
`strokeRect = CGRectGetStrokeRect( rect, strokeWidth, CGInside)`.

> #### Note
>
> Instead of `CGInside`, you can also use `CGOutside` to draw a border around
> the rectangle or `CGCover` which is basically a nop operation and will make
> the half the border drawn on the inside and half the border on the inside.

Now to compute the rectangle to fill this stroked rectangle use
`CGRectGetFillRect( strokeRect, strokeWidth, CGInside)`.

> ### Note
>
> Instead of `CGInside` you can also use `CGCover` to cover the same space.
> `CGOutside` is not really useful here.


### You are here

![Overview](overview.dot.svg)





## Add

Use [mulle-sde](//github.com/mulle-sde) to add MulleCG to your project:

``` sh
mulle-sde add github:MulleUI/MulleCG
```

To only add the sources of MulleCG with dependency
sources use [clib](https://github.com/clibs/clib):


``` sh
clib install --out src/MulleUI MulleUI/MulleCG
```

Add `-isystem src/MulleUI` to your `CFLAGS` and compile all the sources that were downloaded with your project.


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
| [freetype](https://github.com/MulleUI/freetype)             | 
| [mulle-gfx](https://github.com/mulle-gfx/mulle-gfx)             | 
| [MulleUIBase](https://github.com/MulleUI/MulleUIBase)             | 💺 MulleUIBase adds Objective-C to mulle-geometry and friends
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list)             | 📒 Lists mulle-objc runtime information contained in executables.

Download the latest [tar](https://github.com/MulleUI/MulleCG/archive/refs/tags/latest.tar.gz) or [zip](https://github.com/MulleUI/MulleCG/archive/refs/tags/latest.zip) archive and unpack it.

Install **MulleCG** into `/usr/local` with [cmake](https://cmake.org):

``` sh
cmake -B build \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DCMAKE_PREFIX_PATH=/usr/local \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```


## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK  



