//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CGLayoutContext+CGFont.h"

#import "import-private.h"

#import "CGFont.h"

#include <assert.h>

// prefixed with '_' so they don't show up as public headers

unsigned char   NotoSans_Regular_ttf[] =
#include "_NotoSans-Regular.ttf.inc"
;
#define s_NotoSans_Regular_ttf   (sizeof( NotoSans_Regular_ttf) - 1)


unsigned char   NotoSans_Bold_ttf[] =
#include "_NotoSans-Bold.ttf.inc"
;
#define s_NotoSans_Bold_ttf  (sizeof( NotoSans_Bold_ttf) - 1)


unsigned char   Noto_Emoji_ttf[] =
#include "_NotoEmoji-VariableFont_wght.ttf.inc"
;
#define s_Noto_Emoji_ttf   (sizeof( Noto_Emoji_ttf) - 1)


unsigned char   entypo_ttf[] =
#include "_entypo.ttf.inc"
;
#define s_entypo_ttf   (sizeof( entypo_ttf) - 1)


#define sans_font_ttf         NotoSans_Regular_ttf
#define s_sans_font_ttf       s_NotoSans_Regular_ttf

#define sans_bold_font_ttf    NotoSans_Bold_ttf
#define s_sans_bold_font_ttf  s_NotoSans_Bold_ttf

#define emoji_font_ttf        Noto_Emoji_ttf
#define s_emoji_font_ttf      s_Noto_Emoji_ttf

#define icons_font_ttf        entypo_ttf
#define s_icons_font_ttf      s_entypo_ttf



@implementation CGLayoutContext ( CGFont)

static struct mulle_container_keyvaluecallback   c_string_to_object_callback;

+ (void) load
{
   c_string_to_object_callback = (struct mulle_container_keyvaluecallback)
   {
      .keycallback   = mulle_container_keycallback_copied_cstring,
      .valuecallback = *MulleObjCContainerValueRetainCallback
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


//
// TODO: use hash table to keep track of names and avoid duplicate loads of
//       fonts
//
- (CGFont *) fallbackFont
{
   CGFont   *font;
   CGFontID fontID;

   font = mulle_map_get( &_fontMap, "fallback");
   if( font)
      return( font);

   fontID = mvgCreateFontMem( [self nvgContext],
                              "fallback",
                              emoji_font_ttf,
                              (int) s_emoji_font_ttf,
                              0);
   font   = [CGFont fontWithNameUTF8String:"fallback"
                                    fontID:fontID];

   mulle_map_insert( &_fontMap, "fallback", font);
   return( font);
}



- (CGFont *) fontWithNameUTF8String:(char *) s
{
   CGFont   *font;
   CGFont   *fallbackFont;
   CGFontID fontID;

   if( ! s)
      s = "sans";

   font = mulle_map_get( &_fontMap, s);
   if( font)
      return( font);

   fontID = -1;
   if( ! strcmp( s, "sans"))
   {
      fontID = mvgCreateFontMem( _vg,
                                 s,
                                 sans_font_ttf,
                                 (int) s_sans_font_ttf,
                                 0);
   }
   else
      if( ! strcmp( s, "sans-bold"))
      {
         fontID = mvgCreateFontMem( _vg,
                                    s,
                                    sans_bold_font_ttf,
                                    (int) s_sans_bold_font_ttf,
                                    0);
      }
      else
         if( ! strcmp( s, "icons"))
         {
            fontID = mvgCreateFontMem( _vg,
                                       s,
                                       icons_font_ttf,
                                       (int) s_icons_font_ttf,
                                       0);
         }

   if( fontID == -1)
      abort();

   fallbackFont = [self fallbackFont];
   if( fallbackFont)
      mvgAddFallbackFontId( _vg, fontID, [fallbackFont fontID]);

   font = [CGFont fontWithNameUTF8String:s
                                  fontID:fontID];
   assert( font);
   mulle_map_insert( &_fontMap, s, font);

   return( font);
}


- (CGFont *) defaultFont
{
   return( [self fontWithNameUTF8String:NULL]);
}


- (void) useFont:(CGFont *) font
{
   // TODO: maybe boobytrappe mvgFontFace to make it unusable as one must
   //       use [font nameUTF8String] to get the proper string...
   if( font)
      nvgFontFace( _vg, [font nameUTF8String]);
   else
      nvgFontFace( _vg, "sans");

   _hasLoadedFont = YES;
}


- (void *) internalFontHandleOfFont:(CGFont *) font
{
   if( ! font)
      return( NULL);
   return( nvgGetFontHandle( _vg, [font fontID]));
}


- (void *) internalFontHandle
{
   return( nvgGetFontHandle( _vg, -1));
}

@end
