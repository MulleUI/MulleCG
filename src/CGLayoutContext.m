//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
// Abstract CGLayoutContext — nanovg implementation is in MulleCGNanoVG
//
#import "CGLayoutContext.h"

#import "import-private.h"

#import "CGLayoutContext+CGFont.h"


@implementation CGLayoutContext

mulle_thread_mutex_t   CGLayoutContextFreeTypeLock;

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
   [self _initFontCache];
   return( self);
}


- (void) dealloc
{
   [self _doneFontCache];
   [super dealloc];
}


- (void) mulleGainAccessWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   [self mulleGainAccessToFontsWithUniquingSet:uniquing];
}


- (void) mulleRelinquishAccessWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   [self mulleRelinquishAccessToFontsWithUniquingSet:uniquing];
}


- (void) setFontSize:(float) size                          { MULLE_C_UNUSED( size); }
- (void) setTextAlignment:(UITextAlignment) align          { MULLE_C_UNUSED( align); }
- (void) setCombinedTextAlignment:(NSUInteger) align       { MULLE_C_UNUSED( align); }
- (void) setTextLetterSpacing:(float) spacing              { MULLE_C_UNUSED( spacing); }
- (void) setTextLineHeight:(float) lineHeight              { MULLE_C_UNUSED( lineHeight); }
- (void) setLineBreakMode:(NSLineBreakMode) mode           {}

- (BOOL) hasLoadedFont                                     { return( NO); }
- (void) useDefaultFont                                    {}

- (CGFloat) fontSizeThatFitsIntoSize:(CGSize) size         { MULLE_C_UNUSED( size); return( 0); }
- (BOOL) useFontWithNameUTF8String:(char *) name           { MULLE_C_UNUSED( name); return( NO); }

- (CGTextMetrics) visualTextMetricsOfUTF8Characters:(char *) s
                                             length:(NSUInteger) length
                                               blur:(CGFloat) blur
                                              scale:(CGFloat) scale
{
   MULLE_C_UNUSED( s);
   MULLE_C_UNUSED( length);
   MULLE_C_UNUSED( blur);
   MULLE_C_UNUSED( scale);
   return( (CGTextMetrics){ 0 });
}

- (CGTextMetrics) visualTextMetrics    { return( (CGTextMetrics){ 0 }); }
- (CGTextMetrics) textMetrics          { return( (CGTextMetrics){ 0 }); }

- (float) getTextBounds:(CGRect *) bounds
                   text:(char *) text
                 length:(NSUInteger) length              { MULLE_C_UNUSED( bounds); MULLE_C_UNUSED( text); MULLE_C_UNUSED( length); return( 0); }

- (CGRect) visualBoundsOfText:(char *) text
                        length:(NSUInteger) length       { MULLE_C_UNUSED( text); MULLE_C_UNUSED( length); return( CGRectZero); }

- (NSUInteger) getGlyphPositions:(struct UIGlyphPosition *) positions
                           count:(NSUInteger) count
                            text:(char *) text
                          length:(NSUInteger) length
{
   MULLE_C_UNUSED( positions);
   MULLE_C_UNUSED( count);
   MULLE_C_UNUSED( text);
   MULLE_C_UNUSED( length);
   return( 0);
}

- (NSInteger) getTextRows:(struct UITextRow *) rows
                    count:(NSUInteger) count
              textRowSize:(size_t) textRowSize
                     text:(char *) text
                   length:(NSUInteger) length
            breakRowWidth:(CGFloat) breakRowWidth
{
   MULLE_C_UNUSED( rows);
   MULLE_C_UNUSED( count);
   MULLE_C_UNUSED( textRowSize);
   MULLE_C_UNUSED( text);
   MULLE_C_UNUSED( length);
   MULLE_C_UNUSED( breakRowWidth);
   return( 0);
}

- (CGRect) boundsOfTextRows:(struct UITextRow *) rows
                      count:(NSUInteger) count
{
   MULLE_C_UNUSED( rows);
   MULLE_C_UNUSED( count);
   return( CGRectZero);
}

- (void *) pushGraphicsState                               { return( NULL); }
- (void) popGraphicsState:(void *) state                   {}

@end
