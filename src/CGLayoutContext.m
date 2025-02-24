//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGLayoutContext.h"

#import "import-private.h"

#import "CGContext+OpenGL.h"
#import "CGLayoutContext+CGFont.h"
#import "_MulleCGBackend.h"


@implementation CGLayoutContext


- (id) init 
{
   self = [super init];
   if( self)
   {
      // if _vg is already set, then we are a subclass so don't
      // init as a real CGLayoutContext 
      if( ! _vg)
      {
         _nvgFlags = NVG_FONT_ONLY;
#ifdef DEBUG
         _nvgFlags |= NVG_DEBUG;
#endif
         [self _initializeNanoVG:_nvgFlags];
      }

      _defaultFontName = "sans";

      [self _initFontCache];
   }

   return( self);
}


- (void) dealloc
{
   [self _doneFontCache];
   [super dealloc];
}


- (void) mulleGainAccess
{
   [super mulleGainAccess];
   [self mulleGainAccessToFonts];
}


- (void) mulleRelinquishAccess
{
   [self mulleRelinquishAccessToFonts];
   [super mulleRelinquishAccess];
}


- (float) getTextBounds:(CGRect *) bounds
                   text:(char *) text
                 length:(NSUInteger) length
{
   return( mvgTextBounds( _vg, CGPointZero, text, length, bounds));
}


- (void) getTextVisualBounds:(CGRect *) visualBounds
                        text:(char *) text
                      length:(NSUInteger) length
{
   mvgTextVisualBounds( _vg, CGPointZero, text, length, visualBounds);
}


// TODO: whats the deal with UITextMetrix and MulleTextMetrics ?
//       needs fixing!!
- (void) getTextMetrics:(struct UITextMetrics *) metrics;
{
   if( ! metrics)
      return;

   nvgTextMetrics( _vg, &metrics->ascender,
                        &metrics->descender,
                        &metrics->lineHeight);
}


- (NSUInteger) getGlyphPositions:(struct UIGlyphPosition *) positions
                           count:(NSUInteger) count
                            text:(char *) text
                          length:(NSUInteger) length
{
   return( mvgTextGlyphPositions( _vg, CGPointZero,
                                       text,
                                       length,
                                       positions,
                                       count));
}



- (NSInteger) getTextRows:(struct UITextRow *) rows
                    count:(NSUInteger) count
                     text:(char *) text
                   length:(NSUInteger) length
            breakRowWidth:(CGFloat) breakRowWidth
{
   return( mvgTextBreakLines( _vg, text,
                                   length,
                                   breakRowWidth,
                                   rows,
                                   count));
}


- (void) setFontSize:(float) size
{
   nvgFontSize( _vg, size);
}


- (void) setTextAlign:(NSUInteger) align
{
   nvgTextAlign( _vg, align);
}


- (void) setTextLetterSpacing:(float) spacing;    // nvgTextLetterSpacing
{
   nvgTextLetterSpacing( _vg, spacing);
}


- (void) setTextLineHeight:(float) lineHeight    // nvgTextLineHeight
{
   nvgTextLineHeight( _vg, lineHeight);
}


- (BOOL) hasLoadedFont
{
   return( _hasLoadedFont);
}


- (void) useFontWithNameUTF8String:(char *) name
{
   CGFont   *font;

   font = [self fontWithNameUTF8String:name];
   if( font)
      [self useFont:font];
}


- (void) useDefaultFont
{
   CGFont   *font;

   font = [self defaultFont];
   assert( font);
   [self useFont:font];
}


- (CGFloat) fontSizeThatFitsIntoSize:(CGSize) size
{
   CGRect    fontBounds;
   CGRect    bounds;
   CGFloat   min;
   CGFloat   max;
   CGFloat   fontSize;
   char      *s;

   // default vert is larger
   min = size.width;
   max = size.height;
   if( min > max)
   {
      min = size.height;
      max = size.width;
   }
   min = floor( min);
   max = ceil( max);

   if( min < 1.0)
      return( 0.0);

   fontSize = roundf( size.height);

   [self setTextAlign:NVG_ALIGN_LEFT | NVG_ALIGN_TOP];

   while( fontSize > 1.0)
   {
      [self setFontSize:fontSize];  // calculate size for 32
      bounds = CGRectZero;
      s      = "|_yX`";
      do
      {
         [self getTextVisualBounds:&fontBounds
                              text:s
                            length:1];
         bounds = CGRectUnion( fontBounds, bounds);
         ++s;
      }
      while( *s);

      if( CGSizeContainsSize( size, bounds.size))
         return( fontSize);
      fontSize -= 0.5f;
   }

   return( 0.0);
}

@end
