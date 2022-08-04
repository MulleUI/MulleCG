# 💫 MulleCG

💫 MulleCG Coregraphics for MulleUI


```
TODO: dFdx not supported by OpenGLES2 (steal from shader compiler or
wherever)
```

Provides CGContext which uses a nanoVG context to do drawing.
Manages textures, fonts and shaders.

> #### Note
>
> Typedefs CGColor! For that reason, if you
> have MulleCA and MulleCG in your project, ensure that MulleCG is before
> MulleCA in your dependency list. MulleGraphics will have the proper order
> but MulleUICore will include MulleCA, so also have MulleGraphics before
> MulleUICore.

Does not do any animation or layouting. Does not do Windowing. Does not
handle events.

## Backends

Currently MulleCG defines which backend is going to be used in
[_MulleCGBackend.h](src/_MulleCGBackend.h). This value can be overridden at
compile time. In your project, you can set this as

```
mulle-sde craftinfo set MulleCG OTHER_CFLAGS "-DMULLE_CG_GLVERSION=2" # choose OpenGLES2
```

> #### Note
>
> MulleGLFW provides OpenGL (Vulkan) etc. MulleCG brings nanovg into the picture,
> which resides on top of OpenGL. MulleCG/nanovg doesnt depend on MulleGLFW though,
> so that in the future there might be a MulleSDL and MulleCG doesn't have to
> change for it.


### You are here

![Overview](overview.dot.svg)



## Dependencies

### Debian

```
apt-get install libharfbuzz-dev
apt-get install libgl-dev
apt-get install libxrandr-dev
apt-get install libxinerama-dev
apt-get install libxcursor-dev
apt-get install libxi-dev
apt-get install libglu-dev # ??? conflict with freeglut possible
sudo apt-get install libxxf86vm-dev
```



## Harfbuzz

Needs ugly hacks for harfbuzz/freetype.

Both seem to have a circular dependency on each other. harfbuzz does not
necessarily provide a needed `hb-ft.h` header. freetype expects `<hb.h>` in the
`include` root not in `<harfbuzz/hb.h>` where it resides. It's a complete
clusterfuck.

What I do for development is gross:

``` sh
apt install libgles2-mesa-dev # also for GLES3 headers!
    # has hb-ft.h
cd /usr/local/include
for i in /usr/include/harfbuzz/*.h
do
   sudo ln -s "$i"
done
```



## Attribution

The code contains a lot of code from :

```
Copyright (c) 2006-2007 Christopher J. W. Lloyd
Copyright (c) Microsoft. All rights reserved.
```