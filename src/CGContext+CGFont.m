//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CGContext+CGFont.h"

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



@implementation CGContext ( CGFont)

static struct mulle_container_keyvaluecallback   c_string_to_object_callback;

+ (void) load
{
   c_string_to_object_callback = (struct mulle_container_keyvaluecallback)
   {
      .keycallback   = mulle_container_keycallback_copied_cstring,
      .valuecallback = *MulleObjCContainerValueRetainCallback
   };
}


- (CGFloat) fontScale
{
   return( _currentFrameInfo.window.UIScale.dx * 1.35); // Still true ????
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


- (void) addFontWithCData:(struct mulle_data) data
       fontNameUTF8String:(char *) name
{
   CGFont   *font;
   int      fontIndex;

   assert( ! mulle_map_get( &_fontMap, name));

   fontIndex = nvgCreateFontMem( _vg, name, data.bytes, (int) data.length, 0);
   font      = [CGFont fontWithNameUTF8String:name
                                 fontIndex:fontIndex];

   mulle_map_insert( &_fontMap, name, font);
}


- (void) addFontWithContentsOfFileWithFileRepresentationString:(char *) filename
                                            fontNameUTF8String:(char *) name
{
   CGFont   *font;
   int      fontIndex;

   assert( ! mulle_map_get( &_fontMap, name));

   fontIndex = nvgCreateFont( _vg, name, filename);
   font      = [CGFont fontWithNameUTF8String:name
                                 fontIndex:fontIndex];

   mulle_map_insert( &_fontMap, name, font);
}


//
// TODO: use hash table to keep track of names and avoid duplicate loads of
//       fonts
//
- (CGFont *) fallbackFont
{
   CGFont   *font;
   int      fontIndex;

   font = mulle_map_get( &_fontMap, "fallback");
   if( font)
      return( font);

   fontIndex = nvgCreateFontMem( [self nvgContext],
                                 "fallback",
                                 emoji_font_ttf,
                                 (int) s_emoji_font_ttf,
                                 0);
   font      = [CGFont fontWithNameUTF8String:"fallback"
                          fontIndex:fontIndex];

   mulle_map_insert( &_fontMap, "fallback", font);
   return( font);
}


- (CGFont *) fontWithNameUTF8String:(char *) s
{
   CGFont   *font;
   CGFont   *fallbackFont;
   int       fontIndex;

   font = mulle_map_get( &_fontMap, s);
   if( font)
      return( font);

   fontIndex = -1;
   if( ! strcmp( s, "sans"))
   {
      fontIndex = nvgCreateFontMem( _vg,
                                    s,
                                    sans_font_ttf,
                                    (int) s_sans_font_ttf,
                                    0);
   }
   else
      if( ! strcmp( s, "sans-bold"))
      {
         fontIndex = nvgCreateFontMem( _vg,
                                       s,
                                       sans_bold_font_ttf,
                                       (int) s_sans_bold_font_ttf,
                                       0);
      }
      else
         if( ! strcmp( s, "icons"))
         {
            fontIndex = nvgCreateFontMem( _vg,
                                          s,
                                          icons_font_ttf,
                                          (int) s_icons_font_ttf,
                                          0);
         }

   if( fontIndex == -1)
      abort();

   fallbackFont = [self fallbackFont];
   if( fallbackFont)
      nvgAddFallbackFontId( _vg, fontIndex, [fallbackFont fontIndex]);

   font = [CGFont fontWithNameUTF8String:s
                            fontIndex:fontIndex];
   assert( font);
   mulle_map_insert( &_fontMap, s, font);

   return( font);
}


- (void) setFont:(CGFont *) font
{
   assert( [self isActive]);

   if( font)
      nvgFontFace( _vg, [font nameUTF8String]);
   else
      nvgFontFace( _vg, "sans");
}


- (void) useFontWithNameUTF8String:(char *) name
{
   CGFont   *font;

   assert( [self isActive]);

   font = [self fontWithNameUTF8String:name];
   if( font)
      nvgFontFace( _vg, name);
}

@end
