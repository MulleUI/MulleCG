<!-- keywords: mulle-cg-text, patterns, score, centered, label, multiline -->
# Patterns

## Draw text at a fixed position (one-shot)

```objc
CGContextFontFace( context, "sans");
CGContextDrawText( context, 50.0, 100.0, "Hello", 24.0, CGColorMakeWhite());
```

## Draw text at a fixed position

```objc
CGContextFontFace( context, "sans");
CGContextFontSize( context, 24.0);
CGContextTextColor( context, CGColorMakeWhite());
CGContextText( context, 50.0, 100.0, "Hello", NULL);
```

## Draw centered text in a rect

```objc
CGContextFontSize( context, 16.0);
CGContextCombinedTextAlignment( context, CGTextAlignCenter | CGTextAlignMiddle);
CGContextTextColor( context, CGColorMakeBlack());
CGContextText( context, CGRectGetMidX( rect), CGRectGetMidY( rect), "Label", NULL);
```

## Draw a game score

```objc
CGContextFontSize( context, 32.0);
CGContextCombinedTextAlignment( context, CGTextAlignCenter | CGTextAlignTop);
CGContextTextColor( context, CGColorMakeWhite());
CGContextFormat( context, windowWidth / 2.0, 20.0, "%d : %d", left, right);
```

## Keep font selection inside the render pass

```objc
[context beginRender:&info];
{
   CGFont   *font;

   font = [context fontWithNameUTF8String:"sans"];
   [context useFont:font];
   // draw text...
}
[context endRender];
// font is invalid here — do not retain it
```
