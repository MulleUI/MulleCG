<!-- keywords: mulle-cg-drawing, patterns, pixel-perfect, stroke, fill, border, CGRectGetStrokeRect, CGRectGetFillRect -->
# Patterns

## Pixel-perfect bordered rectangle

The most common pattern: a filled rect with a border drawn inside.

```objc
CGRect   strokeRect;
CGRect   fillRect;

// Compute stroke rect (border inside the given rect)
strokeRect = CGRectGetStrokeRect( rect, strokeWidth, CGInside);

// Compute fill rect (area inside the border)
fillRect = CGRectGetFillRect( strokeRect, strokeWidth, CGInside);

// Draw
CGContextFillRectWithColor( context, fillRect, backgroundColor);
CGContextStrokeInsideOfRectWithColor( context, strokeRect, strokeWidth, borderColor);
```

Relations:
- `CGInside` — border drawn inside the rect
- `CGOutside` — border drawn outside the rect
- `CGCover` — half inside, half outside (nop on stroke rect)

## Fill three pixels horizontally

```objc
// Fills pixels at column 1, 2, 3 in row 1
CGContextFillRectWithColor( context, CGRectMake( 1, 1, 3, 1), color);
```

## Stroke to cover same pixels

Stroke goes perpendicular to the line. Center the stroke through pixel centers:

```objc
// Horizontal line through pixel centers
CGContextStrokeLineWithColor( context,
                              CGPointMake( 1.0, 1.5),
                              CGPointMake( 4.0, 1.5),
                              1.0,
                              color);
```

## Simple filled rounded rect

```objc
CGContextFillRoundedRectWithColor( context, rect, 8.0, color);
```

## Prefer fill over stroke

If you can achieve the same result with a fill, prefer it — no half-pixel offset math needed.
