# 💫 MulleCG

💫 MulleCG Coregraphics for MulleUI



### You are here

```
  .-----------------------------------------.
  | MulleUIFoundation                       |
  '-----------------------------------------'
  .-----------------------------------------.
  | MulleUIViews                            |
  '-----------------------------------------'
  .-----------------. .---------------------.
  | MulleUIImage    | | MulleUICore         |
  '-----------------' '--------------.------.
  .--------------------------------. | glfw |
  | MulleGraphics                  | | X11  |
  '--------------------------------' '------'
  .=================.
  | MulleCG         |
  '================='
  | nanovg   |
  | freetype |
  | harfbuzz |        .------------.
  |          |        | MulleCA    |
  '----------'        '------------'
  .--------------------------------.
  | MulleLayout                    |
  '--------------------------------'

```

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
necessarily provide a needed hb-ft.h header. freetype expects `<hb.h>` in the
`include` root not in `<harfbuzz/hb.h>` where it resides. It's a complete
clusterfuck.

What I do for development is gross:

```
sudo apt-get install libharfbuzz-dev    # has hb-ft.h
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