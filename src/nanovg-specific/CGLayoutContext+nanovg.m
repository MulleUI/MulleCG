//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGLayoutContext.h"

#import "import-private.h"

#import "CGContext+OpenGL.h"
#import "CGContext+nanovg.h"
#import "CGContext+Drawing.h"
#import "CGLayoutContext+CGFont.h"
#import "_MulleCGBackend.h"


@implementation CGLayoutContext( nanovg)

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

// just for a stupid compiler warning

CGFont  *CGLayoutContextUseFontWithNameUTF8String( CGLayoutContext *self, char *name)
{
   CGFont   *font;
   char     *face;

   font = [self fontWithNameUTF8String:name];

   // do not use CGContextFontFace, because it "uses" us
   assert( self->_defaultFontName);
   face = font ? name : self->_defaultFontName;
   nvgFontFace( CGLayoutContextGetNVGContext( self), face);
   return( font);
}




- (CGFont *) fontWithCData:(struct mulle_data) data
        fontNameUTF8String:(char *) name
{
   CGFont    *font;
   CGFontID  fontID;

   assert( name);

   font = mulle_map_get( &_fontMap, name);
   if( font)
      return( font);

   fontID = mvgCreateFontMem( _vg, name, data.bytes, (int) data.length, 0);
   if( fontID == -1)
      return( nil);

   font = [CGFont fontWithNameUTF8String:name
                                  fontID:fontID];

   mulle_map_insert( &_fontMap, name, font);
   return( font);
}


- (CGFont *) fontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                             fontNameUTF8String:(char *) name
{
   CGFont     *font;
   CGFontID   fontID;

   assert( filename);
   assert( name);

   font = mulle_map_get( &_fontMap, name);
   if( font)
      return( font);

   fontID = mvgCreateFont( _vg, name, filename);
   if( fontID == -1)
      return( nil);

   font = [CGFont fontWithNameUTF8String:name
                                  fontID:fontID];
   mulle_map_insert( &_fontMap, name, font);
   return( font);
}


- (void) useFont:(CGFont *) font
{
   char     *face;

   // TODO: maybe boobytrappe mvgFontFace to make it unusable as one must
   //       use [font nameUTF8String] to get the proper string...
   assert( self->_defaultFontName);
   face = font ? [font nameUTF8String] : self->_defaultFontName;

   nvgFontFace( _vg, face);
   _hasLoadedFont = YES;
}

@end
