//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGLayoutContext.h"

#import "import-private.h"

#import "CGContext+OpenGL.h"
#import "CGLayoutContext+CGFont.h"
#import "_MulleCGBackend.h"


@implementation CGLayoutContext


- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) context
                            nameUTF8String:(char *) nameUTF8String
{
   self = [super initWithOSGraphicsContext:context
                            nameUTF8String:nameUTF8String];
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


- (instancetype) init
{
   return( [self initWithOSGraphicsContext:nil
                            nameUTF8String:NULL]);
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

//
//
//

- (void) setFontSize:(float) size
{
   nvgFontSize( _vg, size);
}


- (void) setTextAlign:(NSUInteger) align
{
   nvgTextAlign( _vg, align);
}


- (void) setTextLetterSpacing:(float) spacing
{
   nvgTextLetterSpacing( _vg, spacing);
}


- (void) setTextLineHeight:(float) lineHeight
{
   nvgTextLineHeight( _vg, lineHeight);
}


- (void) setLineBreakMode:(NSLineBreakMode) mode
{
   // currently nvg is always in word wrapping mode
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

static char   extreme_chars[] = { '|', '_', 'y', ';', 'X', '`' };


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
      s      = extreme_chars;
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


//
// So long story.  nanovg asks freetype font, gimme a glyph of '|' for
// fontSize: 10. freetype gives you a pixmap of say 5/11 back. This will
// create overdraw. This is supposedly intentional by the font designer,
// who is expecting enough space. Either you give it (leave say 2 pixels
// on top and below is maybe not needed because there will be some spacing)
// or you really calculate how much space is needed.
//
// This function estimates this by using some typically outside char boxes.
//
- (struct UITextMetrics) visualTextMetricsOfUTF8Characters:(char *) s
                                                    length:(NSUInteger) length
                                                      blur:(CGFloat) blur
                                                     scale:(CGFloat) scale
{
   CGRect                 bounds;
   CGRect                 rect;
   struct UITextMetrics   metrics = { 0 };
   NSUInteger             i, n;

   if( ! s)
      return( metrics);

   bounds = CGRectZero;
   nvgSave( _vg);
   {
      // we can not do scaled conversion
      //nvgResetTransform( _vg);
      nvgTextAlign( _vg, NVG_ALIGN_LEFT | NVG_ALIGN_BASELINE);
      // MEMO: text alignment is used

      mulle_alloca_do( positions, struct UIGlyphPosition, length)
      {
         n = mvgTextGlyphPositions( _vg,
                                    CGPointZero,
                                    s,
                                    length,
                                    positions,
                                    length);
         for( i = 0; i < n; i++)
         {
            rect   = UIGlyphPositionGetVisualBoundsWithBlurAndScale( &positions[ i], blur, scale);
            bounds = CGRectUnion( bounds, rect);
         }
      }
   }
   nvgRestore( _vg);

   metrics.ascender   = -bounds.origin.y;
   metrics.descender  = -(bounds.size.height - metrics.ascender);
   metrics.lineHeight = bounds.size.height;

   return( metrics);
}


- (struct UITextMetrics) visualTextMetrics
{
   return( [self visualTextMetricsOfUTF8Characters:extreme_chars
                                            length:sizeof( extreme_chars)
                                              blur:0.0
                                             scale:1.0]);
}


// TODO: whats the deal with UITextMetrix and MulleTextMetrics ?
//       needs fixing!!
//
// The text metrics are direct from the font library. They are somewhat useless
// because nvg internally, only works with the integer pixel values that are
// used to index the atlas.
//
- (struct UITextMetrics) textMetrics
{
   struct UITextMetrics   metrics;

   nvgTextMetrics( _vg, &metrics.ascender,
                        &metrics.descender,
                        &metrics.lineHeight);
   return( metrics);
}


//
//
//

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
   //assert( mode == NSLineBreakByWordWrapping);

   return( mvgTextBreakLines( _vg, text,
                                   length,
                                   breakRowWidth,
                                   rows,
                                   count));
}


//
// calculate the row bounds for all rows
//
- (CGRect) boundsOfTextRows:(struct UITextRow *) rows
                      count:(NSUInteger) count
{
   struct UITextRow      *p;
   struct UITextRow      *sentinel;
   CGRect                rect;
   struct UITextMetrics  metrics;

   if( ! rows || ! count)
      return( CGRectZero);

   nvgTextMetrics( _vg, &metrics.ascender,
                        &metrics.descender,
                        &metrics.lineHeight);

   // usually nanovg leaves a one pixel border around everything
   // so we pre-adjust our line height and y as well
   rect     = CGRectMake( -1.0f, 0.0f, 0, 0.0f);
   sentinel = &rows[ count];

   for( p = rows; p < sentinel; p++)
   {
      if( rect.origin.x > p->minx)
         rect.origin.x = p->minx;
      if( CGRectGetMaxX( rect) < p->maxx)
         rect = CGRectBySettingMaxX( rect, p->maxx);
      rect.size.height += metrics.lineHeight;
   }

   // observed -2.5 to -1.0 for rect.orgin.x

   return( rect);
}

@end
