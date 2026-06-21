<!-- keywords: mulle-cg-image, image, texture, bitmap, drawable, CGImage, CGDrawable, CGDrawableOptions, sprite, PNG, load -->
# mulle-cg-image

Use this topic when loading bitmaps, drawing images/sprites, or working with `CGDrawable` options (flip, scale, repeat).

## Understand first

```bash
mulle-sde api apropos CGImage
mulle-sde api apropos CGDrawable
mulle-sde code search imageWithContentsOfFileUTF8String
mulle-sde code search drawRect
```

## Local references

- `src/CGImage.h`
- `src/CGContext+CGImage.h`
- `src/CGDrawable.h`

## Function cheatsheet

### Loading images

| Method | What it does |
|--------|-------------|
| `[CGImage imageWithContentsOfFileUTF8String:path textureFlags:0 context:ctx]` | Load from file |
| `[CGImage imageWithRGBABytes:bytes bitmapSize:size textureFlags:0 context:ctx]` | Create from pixels |
| `[CGImage imageWithBitmap:bitmap textureFlags:0 context:ctx]` | Create from bitmap struct |

### Context-side creation (preferred)

| Method | What it does |
|--------|-------------|
| `[context imageWithContentsOfFileUTF8String:path textureFlags:0 nameUTF8String:name resourceKey:key]` | Load with caching |

### Drawing images

| Method | What it does |
|--------|-------------|
| `[image drawRect:rect options:&options context:ctx]` | Draw with options |
| `[context drawImage:image inRect:rect]` | Simple draw |

### CGDrawableOptions

```objc
CGDrawableOptions   options;

options = CGDrawableOptionsMakeScaleToFit();
options.flags.flip = CGFlipVertically;
// also: .alpha, .rotation, .contentMode, .cornerInsets (bitmap only)
```

## Quick recipe: load and draw a sprite

```objc
CGImage   *sprite;

sprite = [context imageWithContentsOfFileUTF8String:"player.png"
                                       textureFlags:0
                                     nameUTF8String:"player"
                                        resourceKey:playerKey];

[sprite drawRect:CGRectMake( x, y, 64, 64)
         options:NULL
         context:context];
```
