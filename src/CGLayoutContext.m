//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGLayoutContext.h"

#import "import-private.h"

#import "CGLayoutContext+CGFont.h"
#import "CGContext+Drawing.h"
#import "CGContext+DebugPrivate.h"


@implementation CGLayoutContext

MULLE_CG_GLOBAL_VAR mulle_thread_mutex_t   CGLayoutContextFreeTypeLock;

+ (void) initialize
{
   if( MulleObjCClassGetID( self) != @selector( CGLayoutContext))
      return;
   mulle_thread_mutex_init( &CGLayoutContextFreeTypeLock);
}


+ (void) deinitialize
{
   if( MulleObjCClassGetID( self) != @selector( CGLayoutContext))
      return;
   mulle_thread_mutex_done( &CGLayoutContextFreeTypeLock);
}



- (instancetype) init
{
   CGLayoutContext  *context;

   // _initBackend is called in initWithOSGraphicsContext:nameUTF8String:
   context = [self initWithOSGraphicsContext:nil
                              nameUTF8String:NULL];

   // do this as a layoutContext wont get a beginFrame and then we could
   // not save graphicsState
   CGContextSave( context);
   CGContextReset( context);
   return( context);
}


- (instancetype) initWithOSGraphicsContext:(id <UIOSGraphicsContext>) os_context
                            nameUTF8String:(char *) name
{
   self = [super initWithOSGraphicsContext:os_context
                            nameUTF8String:name];

   // TODO: this is surely the wrong place, move it to MulleCGNanovgD311
#ifdef MULLE_CG_BACKEND_D3D11
   if( [context respondsToSelector:@selector( backendDevicePointer)])
      _backendDevicePointer = [(id) context backendDevicePointer];
#endif

   [self _initFontCache];
   return( self);
}


- (void) dealloc
{
   [self _doneBackend];

   [self _doneFontCache];
   [super dealloc];
}



- (void) mulleGainAccessWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   assert( mulle_pointerset_get( uniquing, self) == self);

   [super mulleGainAccessWithUniquingSet:uniquing];
   [self mulleGainAccessToFontsWithUniquingSet:uniquing];
}


- (void) mulleRelinquishAccessWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   assert( mulle_pointerset_get( uniquing, self) == self);

   [self mulleRelinquishAccessToFontsWithUniquingSet:uniquing];
   [super mulleRelinquishAccessWithUniquingSet:uniquing];
}


- (void) setFontSize:(float) size
{
   CGContextFontSize( self, size);
}

- (void) setTextAlignment:(UITextAlignment) align
{
   CGContextTextAlignment( self, align);
}

- (void) setCombinedTextAlignment:(NSUInteger) align
{
   CGContextCombinedTextAlignment( self, align);
}

- (void) setTextLetterSpacing:(float) spacing
{
   CGContextTextLetterSpacing( self, spacing);
}

- (void) setTextLineHeight:(float) lineHeight
{
   CGContextTextLineHeight( self, lineHeight);
}

- (void) setLineBreakMode:(NSLineBreakMode) mode
{
   // currently nvg is always in word wrapping mode
}

- (BOOL) hasLoadedFont
{
   return( _hasLoadedFont);
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

   [self setCombinedTextAlignment:CGTextAlignLeft | CGTextAlignTop];

   while( fontSize > 1.0)
   {
      [self setFontSize:fontSize];  // calculate size for 32
      bounds = CGRectZero;
      s      = extreme_chars;
      do
      {
         fontBounds = [self visualBoundsOfText:s
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

- (BOOL) useFontWithNameUTF8String:(char *) name
{
   CGFont   *font;

   font = CGLayoutContextUseFontWithNameUTF8String( self, name);
   return( font ? YES : NO);
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
- (CGTextMetrics) visualTextMetricsOfUTF8Characters:(char *) s
                                             length:(NSUInteger) length
                                               blur:(CGFloat) blur
                                              scale:(CGFloat) scale
{
   CGRect          bounds;
   CGRect          rect;
   CGTextMetrics   metrics = { 0 };
   NSUInteger      i, n;

   if( ! s)
      return( metrics);

   bounds = CGRectZero;
   CGContextSave( self);
   {
      // we can not do scaled conversion
      // nvgResetTransform( _vg);
      CGContextCombinedTextAlignment( self, CGTextAlignLeft | CGTextAlignBaseline);
      // MEMO: text alignment is used

      mulle_alloca_do( positions, struct UIGlyphPosition, length)
      {
         n = CGContextTextGlyphPositions( self,
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
   CGContextRestore( self);

   metrics.lineHeight = bounds.size.height;
   metrics.ascender   = fabsf( -bounds.origin.y);
   metrics.descender  = fabsf( metrics.lineHeight - metrics.ascender);

   return( metrics);
}

- (CGTextMetrics) visualTextMetrics
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
- (CGTextMetrics) textMetrics
{
   return( CGContextTextMetrics( self));
}

- (float) getTextBounds:(CGRect *) bounds
                   text:(char *) text
                 length:(NSUInteger) length
{
   CGTextBoundsInfo   info;

   info = CGContextTextBoundsInfo( self, CGPointZero, text, length);
   if( bounds)
      *bounds = info.bounds;
   return( info.size);
}

- (CGRect) visualBoundsOfText:(char *) text
                       length:(NSUInteger) length
{
   return( CGContextTextVisualBounds( self, CGPointZero, text, length));
}

- (NSUInteger) getGlyphPositions:(struct UIGlyphPosition *) positions
                           count:(NSUInteger) count
                            text:(char *) text
                          length:(NSUInteger) length
{
   return( CGContextTextGlyphPositions( self, CGPointZero,
                                              text,
                                              length,
                                              positions,
                                              count));
}

// TODO: rename to maxCount or so
- (NSInteger) getTextRows:(struct UITextRow *) rows
                    count:(NSUInteger) count
              textRowSize:(size_t) textRowSize
                     text:(char *) text
                   length:(NSUInteger) length
            breakRowWidth:(CGFloat) breakRowWidth
{
   //assert( mode == NSLineBreakByWordWrapping);

   return( CGContextTextBreakLines( self, text,
                                          length,
                                          breakRowWidth,
                                          rows,
                                          count,
                                          textRowSize));
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
   struct CGTextMetrics  metrics;

   if( ! rows || ! count)
      return( CGRectZero);

   metrics = CGContextTextMetrics( self);

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

- (void *) pushGraphicsState
{
   CGContextSave( self);
   return( NULL);
}

- (void) popGraphicsState:(void *) state
{
   assert( state == NULL); // i mean come on...
   CGContextRestore( self);
}

@end


CGFont  *CGLayoutContextUseFontWithNameUTF8String( CGLayoutContext *self, char *name)
{
   CGFont   *font;

   font = [self fontWithNameUTF8String:name];
   if( font)
      [self useFont:font];
   else
      _CGContextRenderLog( self, "Font %s is unknown\n", name);
   return( font);
}
