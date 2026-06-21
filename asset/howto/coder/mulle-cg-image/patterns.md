<!-- keywords: mulle-cg-image, patterns, cache, resourceKey, share -->
# Patterns

## Use context-side image creation with stable resourceKey

Let the context own GPU image creation and caching:

```objc
CGImage   *image;

image = [context imageWithContentsOfFileUTF8String:"bg.png"
                                      textureFlags:0
                                    nameUTF8String:"background"
                                       resourceKey:bgKey];
```

Reuse a stable `resourceKey` when the same bitmap should map to one cached `CGImage`.

## Draw with drawable options

```objc
CGDrawableOptions   options;

options = CGDrawableOptionsMakeScaleToFit();
options.flags.flip = CGFlipVertically;

[image drawRect:rect
        options:&options
        context:context];
```

## Share textures across contexts

Contexts must have matching `shareID`:

```objc
CGImage   *shared;

shared = [sourceImage shareWithContext:targetContext
                          textureFlags:[sourceImage textureFlags]];
```
