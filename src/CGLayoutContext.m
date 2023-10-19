//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGLayoutContext.h"

#import "import-private.h"

#import "CGContext+OpenGL.h"
#import "CGLayoutContext+CGFont.h"
#import "_MulleCGBackend.h"


@implementation CGLayoutContext


static struct
{
   mulle_thread_mutex_t   _freeTypeLock;
} Self;



+ (void) initialize
{
   if( MulleObjCClassGetID( self) != @selector( CGLayoutContext))
      return;

   mulle_thread_mutex_init( &Self._freeTypeLock);
}



+ (void) deinitialize
{
   if( MulleObjCClassGetID( self) != @selector( CGLayoutContext))
      return;

   mulle_thread_mutex_done( &Self._freeTypeLock);
}



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


- (float) getTextBounds:(CGRect *) bounds
                   text:(char *) text
                 length:(NSUInteger) length
{
   char    *end;
   float   values[ 4];
   float   extent;

   assert( text);

   end = &text[ length == (NSUInteger) -1 ? strlen( text) : length];

   extent = nvgTextBounds( _vg, 0.0f, 0.0f, text, end, bounds ? values : NULL);
   if( bounds)
      *bounds = CGRectMake( values[ 0],
                            values[ 1],
                            values[ 2] - values[ 0],
                            values[ 3] - values[ 1]);
   return( extent);
}


- (void) getTextVisualBounds:(CGRect *) visualBounds
                        text:(char *) text
                      length:(NSUInteger) length
{
   char    *end;
   float   bounds[ 6];

   if( ! visualBounds)
      return;

   assert( text);

   end = &text[ length == (NSUInteger) -1 ? strlen( text) : length];

   nvgTextVisualBounds( _vg, 0.0f, 0.0f, text, end, bounds);
   *visualBounds = CGRectMake( bounds[ 0],
                               bounds[ 1],
                               bounds[ 2] - bounds[ 0],
                               bounds[ 3] - bounds[ 1]);
}


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
   char   *end;
   int    n;

   assert( text);

   end = &text[ length == (NSUInteger) -1 ? strlen( text) : length];

   n   = nvgTextGlyphPositions( _vg, 0.0f, 0.0f,
                                     text, end,
                                     (NVGglyphPosition *) positions,
                                     (int) count);
   return( n);
}



- (NSInteger) getTextRows:(struct UITextRow *) rows
                    count:(NSUInteger) count
                     text:(char *) text
                   length:(NSUInteger) length
            breakRowWidth:(CGFloat) breakRowWidth
{
   char   *end;
   int    n;

   end = &text[ length == (NSUInteger) -1 ? strlen( text) : length];
   n   = nvgTextBreakLines( _vg,
                            text, end,
                            breakRowWidth,
                            (NVGtextRow *) rows,
                            (int) count);
//   MulleUICLog( "%.*s: %g (%d of %td)",
//                  (int) (end - text),
//                  text,
//                  breakRowWidth,
//                  n,
//                  count);
   return( n);
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

@end
