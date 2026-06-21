<!-- keywords: mulle-cg-text, text, font, CGFont, CGLayoutContext, CGContextText, CGContextFormat, score, label, metrics, alignment -->
# mulle-cg-text

Use this topic when you need to render text: score displays, labels, formatted strings, or when you need text metrics/alignment.

## Understand first

```bash
mulle-sde api apropos CGFont
mulle-sde api apropos CGLayoutContext
mulle-sde code search CGContextText
mulle-sde code search CGContextFormat
mulle-sde code search fontWithNameUTF8String
```

## Local references

- `src/CGLayoutContext.h`
- `src/CGLayoutContext+CGFont.h`
- `src/CGFont.h`
- `src/CGContext+Drawing.h` (text functions)
- `src/CGContext+DrawingConveniences.h`
- `src/CGContext+UIGraphicsDrawing.h`

## Function cheatsheet

### Drawing text

| Function | What it does |
|----------|-------------|
| `CGContextText(ctx, x, y, "string", NULL)` | Draw text at point |
| `CGContextFormat(ctx, x, y, format, ...)` | Draw formatted text (printf-style) |
| `CGContextFormatInRect(ctx, rect, format, ...)` | Draw formatted text clipped to rect |
| `CGContextDrawText(ctx, x, y, "string", fontSize, color)` | Draw text with size and color in one call |

### Font selection and sizing

| Function | What it does |
|----------|-------------|
| `[context useFontWithNameUTF8String:"sans"]` | Select font by name |
| `CGContextFontSize(ctx, 16.0)` | Set font size |
| `CGContextFontFace(ctx, "sans")` | Select font (C function) |
| `[context fontSizeThatFitsIntoSize:size]` | Compute font size to fit area |

### Alignment

| Function | What it does |
|----------|-------------|
| `CGContextCombinedTextAlignment(ctx, flags)` | Set horizontal + vertical alignment |

Alignment flags (combine with `|`):
- Horizontal: `CGTextAlignLeft`, `CGTextAlignCenter`, `CGTextAlignRight`
- Vertical: `CGTextAlignTop`, `CGTextAlignMiddle`, `CGTextAlignBottom`, `CGTextAlignBaseline`

### Metrics

| Function | What it does |
|----------|-------------|
| `[context visualTextMetrics]` | Get ascender, descender, lineHeight |
| `CGContextTextBoundsInfo(ctx, ...)` | Get text bounding box |

## Quick recipe: draw a centered score

```objc
CGFont   *font;

font = [context fontWithNameUTF8String:"sans"];
[context useFont:font];

CGContextFontSize( context, 32.0);
CGContextCombinedTextAlignment( context, CGTextAlignCenter | CGTextAlignMiddle);
CGContextTextColor( context, CGColorMakeWhite());
CGContextFormat( context, CGRectGetMidX( rect), CGRectGetMidY( rect), "%d - %d", scoreLeft, scoreRight);
```
