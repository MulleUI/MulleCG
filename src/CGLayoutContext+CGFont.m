//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CGLayoutContext+CGFont.h"

#import "import-private.h"

#import "CGFont.h"
#import "CGContext+Drawing.h"

#include <assert.h>

// prefixed with '_' so they don't show up as public headers

unsigned char   NotoSans_ttf[] =
#include "_NotoSans-VariableFont_wdth,wght.ttf.inc"
;
#define s_NotoSans_ttf   (sizeof( NotoSans_ttf) - 1)

unsigned char   NotoSans_Italic_ttf[] =
#include "_NotoSans-Italic-VariableFont_wdth,wght.ttf.inc"
;
#define s_NotoSans_Italic_ttf   (sizeof( NotoSans_Italic_ttf) - 1)

unsigned char   Noto_Symbols_ttf[] =
#include "_NotoSansSymbols-VariableFont_wght.ttf.inc"
;
#define s_Noto_Symbols_ttf   (sizeof( Noto_Symbols_ttf) - 1)


unsigned char   Noto_Symbols2_ttf[] =
#include "_NotoSansSymbols2-Regular.ttf.inc"
;
#define s_Noto_Symbols2_ttf   (sizeof( Noto_Symbols2_ttf) - 1)


unsigned char   Noto_Emoji_ttf[] =
#include "_NotoEmoji-VariableFont_wght.ttf.inc"
;
#define s_Noto_Emoji_ttf   (sizeof( Noto_Emoji_ttf) - 1)


unsigned char   entypo_ttf[] =
#include "_entypo.ttf.inc"
;
#define s_entypo_ttf   (sizeof( entypo_ttf) - 1)


unsigned char   NotoSansMono_Regular_ttf[] =
#include "_NotoSansMono-Regular.ttf.inc"
;
#define s_NotoSansMono_Regular_ttf   (sizeof( NotoSansMono_Regular_ttf) - 1)


#define sans_font_ttf             NotoSans_ttf
#define s_sans_font_ttf           s_NotoSans_ttf

// as above, freetype should weight it
#define sans_bold_font_ttf        NotoSans_ttf
#define s_sans_bold_font_ttf      s_NotoSans_ttf  

#define sans_italic_font_ttf      NotoSans_Italic_ttf
#define s_sans_italic_font_ttf    s_NotoSans_Italic_ttf

#define symbols_font_ttf          Noto_Symbols_ttf
#define s_symbols_font_ttf        s_Noto_Symbols_ttf

#define symbols2_font_ttf         Noto_Symbols2_ttf
#define s_symbols2_font_ttf       s_Noto_Symbols2_ttf

#define emoji_font_ttf            Noto_Emoji_ttf
#define s_emoji_font_ttf          s_Noto_Emoji_ttf

#define icons_font_ttf            entypo_ttf
#define s_icons_font_ttf          s_entypo_ttf

#define mono_font_ttf             NotoSansMono_Regular_ttf
#define s_mono_font_ttf           s_NotoSansMono_Regular_ttf



static struct 
{
   char                *name;
   struct mulle_data   data;
} 
font_by_name[] = 
{
   { .name = "sans",        { .bytes = sans_font_ttf,        .length =  s_sans_font_ttf }},
   { .name = "sans-bold",   { .bytes = sans_bold_font_ttf,   .length =  s_sans_bold_font_ttf }},
   { .name = "sans-italic", { .bytes = sans_italic_font_ttf, .length =  s_sans_italic_font_ttf }},
   { .name = "mono",        { .bytes = mono_font_ttf,        .length =  s_mono_font_ttf }},
   { .name = "symbols",     { .bytes = symbols_font_ttf,     .length =  s_symbols_font_ttf }},
   { .name = "symbols2",    { .bytes = symbols2_font_ttf,    .length =  s_symbols2_font_ttf }},
   { .name = "icons",       { .bytes = icons_font_ttf,       .length =  s_icons_font_ttf }},
};


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

   fontID = CGContextCreateFontMem( self,
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
   CGFont       *font;
   CGFont       *fallbackFont;
   CGFontID     fontID;
   NSUInteger   i, n;

   if( ! s)
      s = _defaultFontName;

   font = mulle_map_get( &_fontMap, s);
   if( font)
      return( font);

   fontID = -1;
   n      = sizeof( font_by_name) / sizeof( font_by_name[ 0]);

   for( i = 0; i < n; i++)
   {
      if( ! strcmp( font_by_name[ i].name, s))
      {
         fontID = CGContextCreateFontMem( self,
                                          s,
                                          font_by_name[ i].data.bytes,
                                          (int) font_by_name[ i].data.length,
                                          0);
         break;
      }
   }

   if( fontID == -1)
      return( nil);

   fallbackFont = [self fallbackFont];
   if( fallbackFont)
      CGContextAddFallbackFontId( self, fontID, [fallbackFont fontID]);

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


- (void *) internalFontHandleOfFont:(CGFont *) font
{
   if( ! font)
      return( NULL);
   return( CGContextGetFontHandle( self, [font fontID]));
}


- (void *) internalFontHandle
{
   return( CGContextGetFontHandle( self, -1));
}

@end
