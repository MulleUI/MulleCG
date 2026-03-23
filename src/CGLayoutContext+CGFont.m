//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CGLayoutContext+CGFont.h"

#import "import-private.h"

#import "CGFont.h"

#include <assert.h>


@implementation CGLayoutContext ( CGFont)

static struct mulle_container_keyvaluecallback   c_string_to_object_callback;

+ (void) load
{
   c_string_to_object_callback = (struct mulle_container_keyvaluecallback)
   {
      .keycallback   = mulle_container_keycallback_copied_cstring,
      .valuecallback = MulleObjCContainerRetainValueCallback
   };
}


- (void) _initFontCache
{
   _mulle_map_init( &_fontMap,
                    8,
                    &c_string_to_object_callback,
                    MulleObjCInstanceGetAllocator( self));
}


- (void) _doneFontCache
{
   _mulle_map_done( &_fontMap);
}


- (void) _resetFontCache
{
   mulle_map_reset( &_fontMap);
}


- (void) mulleGainAccessToFontsWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   char    *name;
   CGFont  *font;

   mulle_map_for( &_fontMap, name, font)
   {
      if( mulle_pointerset_insert( uniquing, self))
         [font mulleGainAccessWithUniquingSet:uniquing];
   }
}


- (void) mulleRelinquishAccessToFontsWithUniquingSet:(struct mulle_pointerset *) uniquing
{
   char    *name;
   CGFont  *font;

   mulle_map_for( &_fontMap, name, font)
   {
      if( mulle_pointerset_insert( uniquing, self))
         [font mulleRelinquishAccessWithUniquingSet:uniquing];
   }
}


- (CGFont *) fallbackFont
{
   return( nil);  // overridden by nanovg backend
}


- (CGFont *) fontWithNameUTF8String:(char *) s
{
   return( nil);  // overridden by nanovg backend
}

- (CGFont *) defaultFont
{
   return( [self fontWithNameUTF8String:NULL]);
}


- (void *) internalFontHandleOfFont:(CGFont *) font
{
   return( NULL);  // overridden by nanovg backend
}


- (void *) internalFontHandle
{
   return( NULL);  // overridden by nanovg backend
}

@end
