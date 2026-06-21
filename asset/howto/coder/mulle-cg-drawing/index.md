<!-- keywords: mulle-cg-drawing, drawing, fill, stroke, rect, circle, line, rounded, pixel-perfect, CGContextFillRectWithColor, CGContextStrokeRectWithColor, shapes -->
# mulle-cg-drawing

Use this topic when you need to draw shapes: rectangles, circles, lines, rounded rects. This is the "cheatsheet" for `CGContext+DrawingConveniences`.

## Understand first

```bash
mulle-sde api apropos DrawingConveniences
mulle-sde code search CGContextFill
mulle-sde code search CGContextStroke
```

## Local references

- `README.md` (pixel-perfect drawing rules)
- `src/CGContext+DrawingConveniences.h`
- `src/CGContext+Drawing.h`
- `src/CGPaint+DrawingConveniences.h` (paint-based fill/stroke)

## Function cheatsheet

### Fill operations

| Function | What it does |
|----------|-------------|
| `CGContextFillWithColor(ctx, color)` | Fill current path |
| `CGContextFillRectWithColor(ctx, rect, color)` | Fill rectangle |
| `CGContextFillRoundedRectWithColor(ctx, rect, cornerRadius, color)` | Fill rounded rect |
| `CGContextFillCircleWithColor(ctx, circle, color)` | Fill circle |
| `CGContextFillRectWithNVGpaint(ctx, rect, nvgpaint)` | Fill rect with raw nanovg paint (low-level) |
| `CGContextFillCircleWithNVGpaint(ctx, circle, nvgpaint)` | Fill circle with raw nanovg paint (low-level) |
| `CGContextFillRectWithPaintable(ctx, rect, paint)` | Fill rect with any `<CGPaintable>` (see mulle-cg-paint) |
| `CGContextFillCircleWithPaintable(ctx, circle, paint)` | Fill circle with any `<CGPaintable>` |

### Stroke operations

| Function | What it does |
|----------|-------------|
| `CGContextStrokeWithColor(ctx, strokeWidth, color)` | Stroke current path |
| `CGContextStrokeRectWithColor(ctx, rect, strokeWidth, color)` | Stroke rect |
| `CGContextStrokeRoundedRectWithColor(ctx, rect, cornerRadius, strokeWidth, color)` | Stroke rounded rect |
| `CGContextStrokeInsideOfRectWithColor(ctx, rect, strokeWidth, color)` | Stroke inside rect |
| `CGContextStrokeInsideOfRoundedRectWithColor(ctx, rect, cornerRadius, strokeWidth, color)` | Stroke inside rounded rect |
| `CGContextStrokeLineWithColor(ctx, start, end, strokeWidth, color)` | Stroke line |
| `CGContextStrokeLineHWithColor(ctx, point, width, strokeWidth, color)` | Horizontal line |
| `CGContextStrokeLineVWithColor(ctx, point, height, strokeWidth, color)` | Vertical line |

### Colors

```objc
CGColorMakeWhite()
CGColorMakeBlack()
CGColorMakeRed()
CGColorMakeGreen()
CGColorMakeBlue()
CGColorMakeCyan()
CGColorMakeYellow()
CGColorMakeIndigo()
CGColorMakeOrange()
CGColorMakeClear()
CGColorMakeWithRGBA( r, g, b, a)   // each 0.0–1.0
```
