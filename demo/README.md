# demos


## MulleCG + MulleGLFW

### glfw-draw-simple

Just draws three bars of color. Can't get much simpler than that. If this
demo fails, something very basic is going wrong. The window is a basic GLFW
window. We need to subclass GLFWWindow actually to tie MulleCG and MulleGLFW
together.

![glfw-draw-simple](glfw-draw-simple.png)

[main-glfw-draw-simple.m](src/main-glfw-draw-simple.m)


## MulleCG + MulleUICore

From here on we use MulleUICore to demonstrate MulleCG features.

### draw-simple

This is glfw-draw-simple for MulleUICore. It's much, much less code. There is
no need for a UIWindow subclass. We don't need to implement
`-[CGContext setActive:]`. We don't have to bother with matching GLFW windows
hints with the required GLFW window hints.

![draw-simple](draw-simple.png)

[main-draw-simple.m](src/main-draw-simple.m)


### draw

This demo is actually very resource intensive. MulleCG (and nanovg) don't like
drawing many discrete lines. Notice the performance problems when resizing
(or not)

![draw](draw.png)

[main-draw.m](src/main-draw.m)


### cgimage

A very basic textured square. Pretty much the simplest texture example
possible.

![cgimage](cgimage.png)

[main-cgimage.m](src/main-cgimage.m)


### particles

![particles](particles.png)

[main-particles.m](src/main-particles.m)


### particlelayers

Same as particles, but uses a CALayer for each particle.

![particlelayers](particlelayers.png)

[main-particlelayers.m](src/main-particlelayers.m)

### colors

Colors demonstrate the several color models available.

![colors](colors.png)

[main-colors.m](src/main-colors.m)

### text

Small text demo with varying size of text.

![text](text.png)

[main-text.m](src/main-text.m)



## Build

This is a [mulle-sde](https://mulle-sde.github.io/) project.

It comes with its own virtual environment and list of dependencies.
To fetch and build everything say:

```
mulle-sde craft
```
