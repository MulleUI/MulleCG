//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGContext.h")
#  import "CGContext.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


// because this is CGTypes is a "C" header, and UITextAlignment is in "ObjC"
// we have this here
static inline CGCombinedTextAlign   UITextAlignmentToTextAlign( UITextAlignment alignment)
{
   switch( alignment)
   {
   default                    : return( CGTextAlignLeft   | CGTextAlignBaseline);
   case UITextAlignmentRight  : return( CGTextAlignRight  | CGTextAlignBaseline);
   case UITextAlignmentCenter : return( CGTextAlignCenter | CGTextAlignBaseline);
   }
}




//
// This is the UIGraphicsDrawing protocol. It probably would be better named
// UIGraphicsContextDrawing.Its used by UIPureWindow for blitting stuff
// and drawing simple debug graphics w/o knowledge about MulleCG
//

@interface CGContext( UIGraphicsDrawing) <UIGraphicsDrawing>

// this is not part of UIGraphicsDrawing
- (void) drawIcon:(mulle_utf32_t) icon
          atPoint:(CGPoint) rect;
@end




static inline void  CGContextDrawText( CGContext *self,
                                       CGFloat x,
                                       CGFloat y,
                                       char *s,
                                       CGFloat fontSize,
                                       CGColor color)
{
   [self drawAtPoint:CGPointMake( x, y)
     textUTF8String:s
  fontNameUTF8String:NULL
         fontSize:fontSize
         hexColor:CGHexColorMakeWithColor( color)];
}


static inline void   CGContextDrawIconInRect( CGContext *self,
                                              mulle_utf32_t icon,
                                              CGRect rect)
{
   [self drawIcon:icon
          atPoint:CGRectGetCenter( rect)];
}


// ###
// Functions that actually "value add" on top of the mvg/nanovg functions
// ###

// Sets the font face based on specified name.
static inline void   CGContextFontFace( CGLayoutContext *context, char *fontname)
{
    [context useFontWithNameUTF8String:fontname];
}
