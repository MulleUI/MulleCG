<!-- keywords: mulle-cg-paint, paint, color, gradient, CGPaint, CGGradient, CGBlendedPaint, CGImagePaint, animation, interpolation -->
# mulle-cg-paint

Use this topic when working with colors, gradients, blended paints, or paint-based animation.

## Understand first

```bash
mulle-sde api apropos CGPaint
mulle-sde api apropos CGGradient
mulle-sde code search paintWithPaint:
mulle-sde code search brightenedGradient
```

## Local references

- `src/CGPaint.h`
- `src/CGGradient.h`
- `src/CGImagePaint.h`
- `src/CGBlendedPaint.h`
- `demo/src/main-custom-paint.m`
- `test/10-first/paintleak.m`
- `test/40-gradient/brighten.m`

## Function cheatsheet

### Creating paints

| Factory | What it does |
|---------|-------------|
| `[CGPaint paintWithColor:color]` | Solid color paint |
| `[CGPaint paintWithStartColor:s endColor:e]` | Two-color gradient |
| `[CGPaint paintWithStartColor:s endColor:e rotation:r]` | Rotated gradient |
| `[CGGradient linearGradientWithRect:r startColor:s endColor:e rotation:r]` | Linear gradient in rect |
| `[CGGradient boxGradientWithRoundedRect:r cornerRadius:cr color:c feather:f featherColor:fc]` | Box gradient |
| `[CGGradient radialGradientWithCircle:c color:outer innerRadius:r innerColor:inner]` | Radial gradient |

### Transforming paints

| Method | What it does |
|--------|-------------|
| `[gradient brightenedGradient:0.2]` | Brighten |
| `[gradient dimmedGradient:0.2]` | Dim |
| `[gradient reversedGradient]` | Flip (180° rotation) |
| `[gradient rotatedGradient:rotation]` | Rotate |
| `[gradient transparentGradient:alpha]` | Adjust alpha |
| `[gradient desaturatedGradient:factor]` | Desaturate (0–1) |
| `[gradient saturatedGradient:factor]` | Saturate |

### Animating between paints

| Method | What it does |
|--------|-------------|
| `[CGPaint paintWithPaint:a otherPaint:b blend:factor rotation:r]` | Interpolate two paints |
| `[CGBlendedPaint ...]` | Alpha-only blend between paints |

## Drawing with paints

Paints are applied via **C functions** (not ObjC methods on CGContext). Any object conforming to `<CGPaintable>` works — that includes `CGPaint`, `CGGradient`, `CGBlendedPaint`, `CGImagePaint`.

### Fill with paint

| Function | Signature |
|----------|-----------|
| `CGContextFillRectWithPaintable` | `(CGContext *ctx, CGRect rect, id <CGPaintable> paint)` |
| `CGContextFillRoundedRectWithPaintable` | `(CGContext *ctx, CGRect rect, CGFloat cornerRadius, id <CGPaintable> paint)` |
| `CGContextFillRoundedRectVaryingWithPaintable` | `(CGContext *ctx, CGRect rect, MulleCornerInsets corners, id <CGPaintable> paint)` |
| `CGContextFillCircleWithPaintable` | `(CGContext *ctx, CACircle circle, id <CGPaintable> paint)` |
| `CGContextFillLineWithPaintable` | `(CGContext *ctx, CGPoint start, CGPoint end, id <CGPaintable> paint)` |

### Stroke with paint

| Function | Signature |
|----------|-----------|
| `CGContextStrokeRectWithPaintable` | `(CGContext *ctx, CGRect rect, CGFloat strokeWidth, id <CGPaintable> paint)` |
| `CGContextStrokeRoundedRectWithPaintable` | `(CGContext *ctx, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, id <CGPaintable> paint)` |
| `CGContextStrokeRoundedRectVaryingWithPaintable` | `(CGContext *ctx, CGRect rect, MulleCornerInsets corners, CGFloat strokeWidth, id <CGPaintable> paint)` |
| `CGContextStrokeCircleWithPaintable` | `(CGContext *ctx, CACircle circle, CGFloat strokeWidth, id <CGPaintable> paint)` |
| `CGContextStrokeLineWithPaintable` | `(CGContext *ctx, CGPoint start, CGPoint end, CGFloat strokeWidth, id <CGPaintable> paint)` |
| `CGContextStrokeLineHWithPaintable` | `(CGContext *ctx, CGPoint point, CGFloat width, CGFloat strokeWidth, id <CGPaintable> paint)` |
| `CGContextStrokeLineVWithPaintable` | `(CGContext *ctx, CGPoint start, CGFloat height, CGFloat strokeWidth, id <CGPaintable> paint)` |

### Low-level direct gradient functions (bypass paint objects)

| Function | What it does |
|----------|-------------|
| `CGContextFillGradientColors(ctx, rect, startColor, endColor, rotation)` | Two-color gradient fill in rect |
| `CGContextFillLinearGradient(ctx, start, startColor, end, endColor)` | Linear gradient between two points |
| `CGContextFillBoxGradient(ctx, rect, cornerRadius, color, feather, featherColor)` | Box gradient fill |
| `CGContextFillRadialGradient(ctx, circle, color, innerRadius, innerColor)` | Radial gradient fill |

Header: `src/CGPaint+DrawingConveniences.h` (paintable), `src/CGPaint+Drawing.h` (direct gradients).

### Complete example

```c
CGPaint   *paint;

paint = [CGPaint paintWithStartColor:CGColorMakeIndigo()
                            endColor:CGColorMakeOrange()
                            rotation:0.0];

// Fill a rect with the paint — this is a C function, not a method
CGContextFillRectWithPaintable( context, rect, paint);

// Or use the direct gradient shortcut (no paint object needed)
CGContextFillGradientColors( context, rect,
                             CGColorMakeIndigo(),
                             CGColorMakeOrange(),
                             0.0);
```

## Verify / report

- `mulle-sde test run test/10-first/paintleak.m` — paint ownership
- `mulle-sde test run test/40-gradient/brighten.m` — gradient transforms
