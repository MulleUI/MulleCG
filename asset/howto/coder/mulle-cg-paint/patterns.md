<!-- keywords: mulle-cg-paint, patterns, value, animation, derive -->
# Patterns

## Treat paints as immutable values

Create or derive a paint, then hand it to a C drawing function. Never mutate in place.

```objc
CGPaint   *paint;
CGPaint   *hoverPaint;
CGPaint   *animatedPaint;

paint         = [CGPaint paintWithStartColor:CGColorMakeIndigo()
                                    endColor:CGColorMakeOrange()
                                    rotation:0.0];
hoverPaint    = [(CGGradient *) paint brightenedGradient:0.2];
animatedPaint = [CGPaint paintWithPaint:paint
                             otherPaint:hoverPaint
                                  blend:factor
                               rotation:0.0];

// Apply via C function — NOT an ObjC method on CGContext
CGContextFillRectWithPaintable( context, rect, animatedPaint);
CGContextStrokeRectWithPaintable( context, rect, 2.0, paint);
```

## Animate between two paints

Use `CGBlendedPaint` or `paintWithPaint:otherPaint:blend:rotation:` for interpolation. The public blend style is alpha-only.

## Extend the paint family

For custom paint behavior, subclass `CGPaint` and compose existing paints instead of forking draw-call code. See `demo/src/main-custom-paint.m`.

## Use CGImagePaint only when the image IS the fill

If you just need to place or rotate a bitmap in a rect, use the `CGDrawable` path (see `mulle-cg-image` topic) instead of `CGImagePaint`.
