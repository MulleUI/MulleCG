<!-- keywords: mulle-cg-drawing, quirks, coordinates, antialiasing, stroke -->
# Quirks

- Coordinates address the space between pixels. The first pixel spans 0 to 1. `CGRectMake(0, 0, 1, 1)` fills exactly one pixel.
- Strokes emanate perpendicular to the path. A strokeWidth of 1 covers half a pixel on each side of the line center.
- AntiAliasing only kicks in when geometry doesn't align to pixel boundaries. Use integer coordinates and `CGRectGetStrokeRect`/`CGRectGetFillRect` to stay pixel-perfect.
- `CGContextStrokeRectWithColor` strokes centered on the rect edges. Use `CGContextStrokeInsideOfRectWithColor` to keep the stroke fully inside.

## Fill/stroke state and convenience functions

The CGContext carries a current fill paint and a current stroke paint. These are **last-write-wins** — there is no composition or stacking.

- `CGContextSetFillLinearGradient(...)` sets the fill paint to a gradient.
- `CGContextFillColor(ctx, color)` sets the fill paint to a solid color, **replacing** any gradient.
- `CGContextFill(ctx)` draws the current path using whatever fill paint was last set.

**The `*WithColor` convenience functions reset fill state.** They call `CGContextFillColor` internally, so a previously set gradient is gone:

```c
// WRONG: gradient is replaced by red before the fill happens
CGContextSetFillLinearGradient( ctx, start, end, blue, white);
CGContextFillRoundedRectWithColor( ctx, wingRect, 4.0, red);  // fills solid red

// RIGHT: gradient fill, then solid color for a different shape
CGContextSetFillLinearGradient( ctx, start, end, blue, white);
CGContextBeginPath( ctx);
CGContextRect( ctx, bodyRect);
CGContextFill( ctx);                    // uses the gradient

CGContextFillRectWithColor( ctx, wingRect, red);  // now solid red
```

Rule: if you want gradient fills, use `CGContextSetFill*Gradient` + path + bare `CGContextFill()`. Do NOT mix with `*WithColor` convenience functions on the same shape.
