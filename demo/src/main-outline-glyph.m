#define _GNU_SOURCE

#import "import-private.h"

#include <string.h>
#include <ft2build.h>
#include <freetype/freetype.h>
#include <freetype/ftoutln.h>
#include <freetype/ftglyph.h>

#define CG_MAX_FONTIMAGES   4
#define CG_MAX_STATES       32

//#define FONT_NAME     "sans"
//#define GLYPH_0  '%'
//#define GLYPH_1  'Q'
//#define GLYPH_2  '$'

#define FONT_NAME     "icons"
#define GLYPH_0  0x270E  // pencil
#define GLYPH_1  0x2699  // coq
#define GLYPH_2  0x2708  // plane

#define SPACING  0

// !!! THIS ONLY WORKS WITH FREETYPE!!!

//#define DRAW_CONTOURS
//
// this is FT_Stroker_ParseOutline rewritten for nanovg. If you read some
// of the discussion on FT_Outline_Decompose, this seems to be easier and less
// error prone. It's based on freetype code (BSD license style:)
//
//                     The FreeType Project LICENSE
//                     ----------------------------
//
//                             2006-Jan-27
//
//                     Copyright 1996-2002, 2006 by
//           David Turner, Robert Wilhelm, and Werner Lemberg
//
//   This  license   was  inspired  by  the  BSD,   Artistic,  and  IJG
//   (Independent JPEG  Group) licenses, which  all encourage inclusion
//   and  use of  free  software in  commercial  and freeware  products
//   alike.  As a consequence, its main points are that:
//
//     o We don't promise that this software works. However, we will be
//       interested in any kind of bug reports. (`as is' distribution)
//
//     o You can  use this software for whatever you  want, in parts or
//       full form, without having to pay us. (`royalty-free' usage)
//
//     o You may not pretend that  you wrote this software.  If you use
//       it, or  only parts of it,  in a program,  you must acknowledge
//       somewhere  in  your  documentation  that  you  have  used  the
//       FreeType code. (`credits')
//
//   We  specifically  permit  and encourage  the  inclusion  of  this
//   software, with  or without modifications,  in commercial products.
//   We  disclaim  all warranties  covering  The  FreeType Project  and
//   assume no liability related to The FreeType Project.
//
struct MulleGlyphPathCallbacks
{
   void  (*move)( void *userinfo, CGPoint xy);
   void  (*line)( void *userinfo, CGPoint xy);
   void  (*quad)( void *userinfo, CGPoint c, CGPoint xy);
   void  (*bezier)( void *userinfo, CGPoint c1, CGPoint c2, CGPoint xy);
   void  (*begin)( void *userinfo);
   void  (*close)( void *userinfo);
   void  (*winding)( void *userinfo, CGPathFillStyle style);
};

static void   _CGContextMoveTo_cb( void *ctx, CGPoint p)                          { CGContextMoveTo( ctx, p); }
static void   _CGContextLineTo_cb( void *ctx, CGPoint p)                          { CGContextLineTo( ctx, p); }
static void   _CGContextQuadTo_cb( void *ctx, CGPoint c, CGPoint p)               { CGContextQuadTo( ctx, c, p); }
static void   _CGContextBezierTo_cb( void *ctx, CGPoint c1, CGPoint c2, CGPoint p){ CGContextBezierTo( ctx, c1, c2, p); }
static void   _CGContextClosePath_cb( void *ctx)                                  { CGContextClosePath( ctx); }
static void   _CGContextPathWinding_cb( void *ctx, CGPathFillStyle s)             { CGContextPathWinding( ctx, s); }

static inline void   MulleGlyphPathCallbacksInitCG( struct MulleGlyphPathCallbacks *callbacks)
{
   if( ! callbacks)
      return;

   MULLE_C_ASSERT( sizeof( void *) == sizeof( CGContext *));
   callbacks->move    = _CGContextMoveTo_cb;
   callbacks->line    = _CGContextLineTo_cb;
   callbacks->quad    = _CGContextQuadTo_cb;
   callbacks->bezier  = _CGContextBezierTo_cb;
   callbacks->close   = _CGContextClosePath_cb;
   callbacks->winding = _CGContextPathWinding_cb;
}
static void   _CGPathMoveTo_cb( void *p, CGPoint pt)                               { CGPathMoveTo( p, NULL, pt.x, pt.y); }
static void   _CGPathLineTo_cb( void *p, CGPoint pt)                               { CGPathAddLineTo( p, NULL, pt.x, pt.y); }
static void   _CGPathQuadTo_cb( void *p, CGPoint c, CGPoint pt)                    { CGPathAddQuadTo( p, NULL, c.x, c.y, pt.x, pt.y); }
static void   _CGPathBezierTo_cb( void *p, CGPoint c1, CGPoint c2, CGPoint pt)     { CGPathAddCurveTo( p, NULL, c1.x, c1.y, c2.x, c2.y, pt.x, pt.y); }
static void   _CGPathClosePath_cb( void *p)                                        { CGPathCloseSubpath( p); }
static void   _CGPathWinding_cb( void *p, CGPathFillStyle s)                       { CGPathSetSubpathFillStyle( p, s); }

static inline void   MulleGlyphPathCallbacksInitPath( struct MulleGlyphPathCallbacks *callbacks)
{
   if( ! callbacks)
      return;

   MULLE_C_ASSERT( sizeof( void *) == sizeof( CGPath *));
   callbacks->move    = _CGPathMoveTo_cb;
   callbacks->line    = _CGPathLineTo_cb;
   callbacks->quad    = _CGPathQuadTo_cb;
   callbacks->bezier  = _CGPathBezierTo_cb;
   callbacks->close   = _CGPathClosePath_cb;
   callbacks->winding = _CGPathWinding_cb;
}
static void   mulleFreetypeOutlineGlyphPath( FT_Outline *outline,
                                             int winding,
                                             struct MulleGlyphPathCallbacks *callbacks,
                                             void *userinfo)
{
   FT_Vector   v_last;
   FT_Vector   v_control;
   FT_Vector   v_start;

   FT_Vector   *point;
   FT_Vector   *limit;
   unsigned char  *tags;

   FT_Error    error;

   FT_Int      n;         /* index of contour in outline     */
   FT_Int      first;     /* index of first point in contour */
   FT_Int      last;      /* index of last point in contour  */

   FT_Int      tag;       /* current point's state           */
   int         isOpen;
   FT_Int      i;
   int64_t     signedArea;

   assert( outline);
   assert( outline->flags);
   assert( callbacks);

   isOpen = 0;
   last   = -1;
   for( n = 0; n < outline->n_contours; n++)
   {
      first = last + 1;
      last = outline->contours[n];

      /* skip empty points; we don't stroke these */
      if( last <= first)
         continue;

      limit     = outline->points + last;
      v_start   = outline->points[first];
      v_last    = outline->points[last];
      v_control = v_start;

      point     = outline->points + first;
      tags      = outline->tags + first;
      tag       = FT_CURVE_TAG(tags[0]);

      /* A contour cannot start with a cubic control point! */
      if( tag == FT_CURVE_TAG_CUBIC)
         abort();

      /* check first point to determine origin */
      if( tag == FT_CURVE_TAG_CONIC)
      {
         /* First point is conic control.  Yes, this happens. */
         if( FT_CURVE_TAG( outline->tags[last]) == FT_CURVE_TAG_ON)
         {
            /* start at last point if it is on the curve */
            v_start = v_last;
            limit--;
         }
         else
         {
            /* if both first and last points are conic, */
            /* start at their middle                    */
            v_start.x = (v_start.x + v_last.x) / 2;
            v_start.y = (v_start.y + v_last.y) / 2;
         }
         point--;
         tags--;
      }
      (*callbacks->move)( userinfo, CGPointMake( (float) v_start.x / 64.0f,
                                                 (float) v_start.y / 64.0f));
      isOpen = 1;

      while( point < limit)
      {
         point++;
         tags++;

         isOpen = 2;
         tag    = FT_CURVE_TAG( tags[0]);

         switch( tag)
         {
            case FT_CURVE_TAG_ON:  /* emit a single line_to */
            {
               FT_Vector vec;

               vec.x = point->x;
               vec.y = point->y;

               (*callbacks->line)( userinfo, CGPointMake( (float) vec.x / 64.0f,
                                                          (float) vec.y / 64.0f));
               continue;
            }

            case FT_CURVE_TAG_CONIC:  /* consume conic arcs */
               v_control.x = point->x;
               v_control.y = point->y;

            conic:
               if( point < limit)
               {
                  FT_Vector vec;
                  FT_Vector v_middle;

                  point++;
                  tags++;
                  tag = FT_CURVE_TAG( tags[0]);
                  vec = point[0];

                  if( tag == FT_CURVE_TAG_ON) {
                     (*callbacks->quad)( userinfo, CGPointMake( (float) v_control.x / 64.0f,
                                                               (float) v_control.y / 64.0f),
                                                   CGPointMake( (float) vec.x / 64.0f,
                                                               (float) vec.y / 64.0f));
                     isOpen = 2;
                     continue;
                  }

                  if( tag != FT_CURVE_TAG_CONIC)
                     abort();

                  v_middle.x = (v_control.x + vec.x) / 2;
                  v_middle.y = (v_control.y + vec.y) / 2;

                  (*callbacks->quad)( userinfo, CGPointMake( (float) v_control.x / 64.0f,
                                                             (float) v_control.y / 64.0f),
                                                CGPointMake( (float) v_middle.x / 64.0f,
                                                             (float) v_middle.y / 64.0f));

                  v_control = vec;
                  goto conic;
               }

               (*callbacks->quad)( userinfo, CGPointMake( (float) v_control.x / 64.0f,
                                                          (float) v_control.y / 64.0f),
                                             CGPointMake( (float) v_start.x / 64.0f,
                                                          (float) v_start.y / 64.0f));
               isOpen = 1;
               goto close;

               // The Cubic Bézier Curve
               // The cubic is the type of Bézier curve that most developers think
               // of when the subject of Bézier curves comes up.

            default:  /* FT_CURVE_TAG_CUBIC */
            {
               FT_Vector vec1, vec2;

               if( point + 1 > limit)
                  abort();
               if( FT_CURVE_TAG( tags[1]) != FT_CURVE_TAG_CUBIC)
                  abort();

               point += 2;
               tags  += 2;
               vec1  = point[ -2];
               vec2  = point[ -1];

               if( point <= limit)
               {
                  FT_Vector vec;

                  vec = point[0];

                  (*callbacks->bezier)( userinfo, CGPointMake( (float) vec1.x / 64.0f,
                                                               (float) vec1.y / 64.0f),
                                                  CGPointMake( (float) vec2.x / 64.0f,
                                                               (float) vec2.y / 64.0f),
                                                  CGPointMake( (float) vec.x / 64.0f,
                                                               (float) vec.y / 64.0f));
                  continue;
               }

               (*callbacks->bezier)( userinfo, CGPointMake( (float) vec1.x / 64.0f,
                                                            (float) vec1.y / 64.0f),
                                               CGPointMake( (float) vec2.x / 64.0f,
                                                            (float) vec2.y / 64.0f),
                                               CGPointMake( (float) v_start.x / 64.0f,
                                                            (float) v_start.y / 64.0f));
               isOpen = 1;
               goto close;
            }
         }
      }

   close:
      /* don't try to end the path if no segments have been generated */
      if( isOpen == 2)
      {
         (*callbacks->close)( userinfo);
      }

      if( winding)
      {
         signedArea = (outline->points[last].x * outline->points[first].y) -
                      (outline->points[first].x * outline->points[last].y);
         for (i = first; i < last; i++)
            signedArea += (outline->points[i].x * outline->points[i + 1].y) -
                          (outline->points[i + 1].x * outline->points[i].y);
         // signedArea /= 2.0;
         if (outline->flags & FT_OUTLINE_REVERSE_FILL)
            signedArea *= -1;
         (*callbacks->winding)( userinfo, signedArea > 0 ? CGPathFillStyleSolid : CGPathFillStyleHole);
      }
   }
}

enum MulleFreetypeGlyphPathOptions
{
   MVG_COMPUTE_WINDINGS     = 0x1,
   MVG_COMPUTE_BOUNDING_BOX = 0x2,
   MVG_TRANSLATE_X_TO_ZERO  = 0x4+0x2,  // always implies bounding box
   MVG_TRANSLATE_Y_TO_ZERO  = 0x8+0x2  // always implies bounding box
};
static CGRect  mulleFreetypeFaceGlyphPath( FT_Face face,
                                           int codepoint,
                                           float size,
                                           struct MulleGlyphPathCallbacks *callbacks,
                                           void *userinfo,
                                           unsigned int options)
{

   FT_GlyphSlot      slot;
   FT_Glyph          glyph;   // is a pointer
   FT_OutlineGlyph   outline_glyph;
   FT_Outline        *outline;
   FT_BBox           acbox;
   CGRect            rect;
   static FT_Matrix  flip_y_matrix = { 1 << 16, 0, 0, -1 * 65536 };
   FT_Vector         delta = { 0, 0 };

   assert( face);

   slot = face->glyph;

   // do this like nanovg does
   if( FT_Set_Pixel_Sizes( face, 0, size))
   {
      errno = EINVAL;
      return( CGRectZero);
   }

   if( FT_Load_Char( face, codepoint, FT_LOAD_NO_BITMAP))
   {
      errno = ENOENT;
      return( CGRectZero);
   }

   FT_Get_Glyph( slot, &glyph);

   outline_glyph = (FT_OutlineGlyph)glyph;
   outline       = &outline_glyph->outline;
   if( ! outline->flags)
   {
      errno = ENOEXEC;
      return( CGRectZero);
   }

   FT_Outline_Transform( outline, &flip_y_matrix);

   // the bounding box is now flipped
   if( options & MVG_COMPUTE_BOUNDING_BOX)
   {
      FT_Glyph_Get_CBox( glyph, FT_GLYPH_BBOX_GRIDFIT, &acbox);
      rect = CGRectMake( (float) acbox.xMin / 64.0f,
                         (float) acbox.yMin / 64.0f,
                         (float) (acbox.xMax - acbox.xMin) / 64.0f,
                         (float) (acbox.yMax - acbox.yMin) / 64.0f);
      rect = CGRectStandardize( rect);
      if( options & MVG_TRANSLATE_X_TO_ZERO)
      {
         delta.x = -acbox.xMin;
      }
      if( options & MVG_TRANSLATE_Y_TO_ZERO)
      {
         delta.y = -acbox.yMax;
      }
   }
   else
      rect.size = CGSizeMake( 0, size);

   FT_Outline_Translate( outline, delta.x, delta.y);

   rect.origin.x = 0;
   rect.origin.y = -rect.size.height;

   mulleFreetypeOutlineGlyphPath( outline, options & MVG_COMPUTE_WINDINGS, callbacks, userinfo);

   return( rect);
}
static void   _mvgPathAddGlyph( CGPath *path,
                                CGContext *context, // Converted from CGContext *context
                                int codepoint,
                                CGFloat size,
                                int options)
{
   CGRect                        rect;
   FT_Face                       face;
   struct MulleGlyphPathCallbacks   callbacks;

   face = (FT_Face) (intptr_t) CGContextGetFontHandle( context, -1);
   if( ! face)
   {
      fprintf( stderr, "No current font set\n");
      abort();
   }
   CGContextFontSize( context, size); // Converted from mvgFontSize

   MulleGlyphPathCallbacksInitPath( &callbacks);
   rect = mulleFreetypeFaceGlyphPath( face,
                                      codepoint,
                                      size,
                                      &callbacks,
                                      path,
                                      options);
   _CGPathSetBounds( path, rect);
}

static CGPath  *mvgCreateGlyphPath( CGContext *context, // Converted from CGContext *context
                                    int codepoint,
                                    CGFloat size,
                                    int options,
                                    struct mulle_allocator *allocator)
{
   CGPath   *path;

   path = CGPathCreate( allocator);
   _mvgPathAddGlyph( path, context, codepoint, size, options); // Updated function call
   return( path);
}
static CGFloat   fontSizes[ 3]    = { 32 * 5, 64 * 5, 48 * 5 };
static int       codePoints[ 3]   = { GLYPH_0, GLYPH_1, GLYPH_2 };
static CGFloat   strokeWidths[ 3] = {  1.0, 3.0, 2.0 };
static CGColor   colors[ 3]       = {
                                      { 1.0, 1.0, 1.0, 1.0 },
                                      { 1.0, 0.0, 0.0, 1.0 },
                                      { 0.0, 1.0, 0.5, 1.0 }
                                    };

#define X_OFFSET       10
#define Y_OFFSET       200
#define DRAW_HELPERS   YES
static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect             bbox;
   NSUInteger         i;
   CGPath             paths[ 3];
   BOOL               drawHelpers = DRAW_HELPERS;

   [context useFontWithNameUTF8String:FONT_NAME];

   for( i = 0; i < 3; i++)
   {
      _CGPathInit( &paths[ i], NULL);
      _mvgPathAddGlyph( &paths[ i], context, codePoints[ i], fontSizes[ i], MVG_COMPUTE_WINDINGS | MVG_TRANSLATE_X_TO_ZERO); // Updated function call
   }

   CGContextTranslate( context, CGPointMake( X_OFFSET, Y_OFFSET));

// just a little marker to see placement of baseline left
   if( drawHelpers)
   {
      CGContextBeginPath( context); // Converted from mvgBeginPath
      CGContextCircle( context, CACircleMakeWithCenterAndRadius( CGPointZero, 3)); // Converted from mvgCircle
      CGContextStrokeWidth( context, 0.75f); // Converted from mvgStrokeWidth
      CGContextStrokeColor( context, CGColorMakePowderBlue()); // Converted from mvgStrokeColor
      CGContextFillColor( context, CGColorMakeBlueViolet()); // Converted from mvgFillColor
      CGContextStroke( context); // Converted from mvgStroke
      CGContextFill( context); // Converted from mvgFill
   }

   // draw helper baseline
   if( drawHelpers)
   {
      CGContextStrokeLineHWithColor( context, CGPointMake( 0, 0), [layer canvas].size.width - X_OFFSET * 2.0, 0.75, CGColorMakeWhite()); // Converted from mvgStrokeLineHWithColor

      CGContextStrokeLineVWithColor( context, CGPointMake( 0, [layer canvas].size.height), -Y_OFFSET, 0.5, CGColorMakeWhite()); // Converted from mvgStrokeLineVWithColor
   }

   // fill 3 glyphs,

   for( i = 0; i < 3; i++)
   {
      CGContextBeginPath( context); // Converted from mvgBeginPath
      CGContextAddCGPath( context, &paths[ i]);
      CGContextFillColor( context, colors[ i]); // Converted from mvgFillColor
      CGContextFill( context); // Converted from mvgFill

      bbox = CGPathGetBounds( &paths[ i]);
      // draw helper lines for bbox
      if( drawHelpers)
      {
         CGContextStrokeRectWithColor( context, bbox,  0.5f, CGColorMakeWhite()); // Converted from mvgStrokeRectWithColor
      }

      // move to next char
      CGContextTranslate( context, CGPointMake( CGRectGetMaxX( bbox) + SPACING, 0));

      // draw vertical helper line
      if( drawHelpers)
      {
         CGContextStrokeLineVWithColor( context, CGPointMake( 0, -Y_OFFSET), [layer canvas].size.height, 0.5, CGColorMakeWhite()); // Converted from mvgStrokeLineVWithColor
      }
   }

   CGContextTranslate( context, CGPointMake( X_OFFSET * 2.0, 0));

   if( drawHelpers)
   {
      CGContextStrokeLineVWithColor( context, CGPointMake( 0, -Y_OFFSET), [layer canvas].size.height, 0.5, CGColorMakeWhite()); // Converted from mvgStrokeLineVWithColor
   }

   /* stroke, but reuse CGPaths here */

   for( i = 0; i < 3; i++)
   {
      CGContextBeginPath( context); // Converted from mvgBeginPath
      CGContextAddCGPath( context, &paths[ i]); // Converted from mvgAddCGPath
      CGContextStrokeColor( context, colors[ i]); // Converted from mvgStrokeColor
      CGContextStrokeWidth( context, strokeWidths[ i]); // Converted from mvgStrokeWidth
      CGContextStroke( context); // Converted from mvgStroke

      bbox = CGPathGetBounds( &paths[ i]);
      if( drawHelpers)
      {
         CGContextStrokeRectWithColor( context, bbox,  0.5f, CGColorMakeWhite()); // Converted from mvgStrokeRectWithColor
      }

      CGContextTranslate( context, CGPointMake( CGRectGetMaxX( bbox) + SPACING, 0));

      if( drawHelpers)
      {
         CGContextStrokeLineVWithColor( context, CGPointMake( 0, -Y_OFFSET), [layer canvas].size.height, 0.5, CGColorMakeWhite()); // Converted from mvgStrokeLineVWithColor
      }
   }

   for( i = 0; i < 3; i++)
      _CGPathDone( &paths[ i]);

   return( YES);
}
void   setupScene( UIWindow *window)
{
   UIView   *view;
   CGRect   frame;

   frame = [[window contentView] contentRect];

   view  = [UIView viewWithFrame:frame];
   [view setAutoresizingMask:UIViewAutoresizingScaleToFill];
   [view setDrawCallback:(CGGraphicsLayerDrawCallback_t *) drawStuff];
   [[window contentView] addSubview:view];
}
int   main( int argc, char *argv[])
{
   UIApplication   *app;
   UIWindow        *window;
   NSUInteger      styleMask;

   app = [UIApplication sharedInstance];

   @autoreleasepool
   {
      styleMask = UIWindowStyleMaskDefault;
      styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleResizable, YES);
      styleMask = UIWindowStyleMaskBySetting( styleMask, UIWindowStyleRetained, NO);

      window = [UIWindow windowWithFrame:CGRectMake( 0.0, 0.0, 1000, 600)
                         titleUTF8String:"Demo"
                               styleMask:styleMask];
      assert( window);
      [window setBackgroundColor:CGColorMakeBlack()];
      setupScene( window);

      [app addWindow:window];
   }
   return( [app runApp]);
}
//
//                           ,╓≤æKª╨╙╙▓█D"╙╙╙*╨¥W▄╓,
//                      ╓▄ª╙└╧▓        █           ⁿ▓▓ª╦w
//                  ╓#╜^*█⌐   `╕       █           ╓▌    `╙%w
//               ╓ΦΓ      █    ╙⌐     ,█,,,Φ      ╓▌         ╙¥▄
//            ,▄▀ █▄       █µ,╓╝,╓≤╗≡≡ª╨╨╨¥≡∞╗w╓,ª█,  ,       ]▄▀V,
//          ,Φ└   ║"▀▄     ,▄▀╨"                 "╙¥▓▓       ▄▀  º▄¥,
//        ,#▌Φ▓▄╓  Φ `█Q▄M╙                           ╙¥▄ ,▄▀ ╙▄⌐`  `Φ
//       ▄▀   `V,"▀▀¼╓╩└                                 ╙¥▓╗ ,       ╙▄
//      Φ       `¥═▄▀                            ╒          ▀▄          ▓
//    .▓         ╓▓]V▄H       ▓                 ,Å            ▀,         ▀
//    █      ,-ª▓╛  `██▀½      "▄  ,╓╓╓╓;╓▄▄▄▄╗▄█,             ╙▄         ▀
//   █  `██▄   ▓. - Φ█═.~     ,≤█▄▀-      `   █└"▀▀▀▀▄╓╓╓╓       ▌    ██▄, █
//  ║⌐  " ▀   ▓╨⌐   }▀`      ,█  `           █      .█▀▄▄███▄     ▌  ` ▀    ▌
//  ▌        ▐M A   '┴      ▌                ▀        ╙█▌████▌    ╙▄        ║⌐
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙███` `╙╙║█  ▐H        █
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █ "% ,▄▀ ║░╠K█═╣███^   ╛╓█▀      ▐█         ,╓╓═ª╙└   █      ╙█▄▐▌▓######▌╫
// █║▄▄▄█▄▄▄║H:  "╙▀███▄╓▄,█▌╓▄,,▄∩  ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▐M▄▀    "Φ█
// ║        !█▄▄████≤═^`╓█ █▌╓▀╦▄▀█   ╙█⌐               ╓█▌        ▓ `       █
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ╢"▄▄#▀▀╙╟█Ü███▀`▀█  ║██J█▄▌jH █    ██    ╙▀W▄;    ,██  `╙w,   █▄     ,╓ █
//   █╙     ▐███▌▀█w ▀█ ╠██████j▌║█▌   ▀██▄       `╙▓██▀w,     ╙╗█'`"▀█▀╙"`║`
//   ╙▌     Φ████████▄██ ███████████    ═██▀W▄,   ╓█▀└         ╓▀ "    ╙▄ ╓▀
//    ╙▄     ╙▀███╙█▄▐██▄,╙▀█████▄▀▄▀▄   ,█M╗ ▀▄██▀╙""*ⁿ═─≈-,,▄▌,        ▄▀
//     `▌╙µ,▄Φ▀x███▄██████████▀V███▀╙└ ,▄#▌████▀`"*«,      .█▀▄▀▄,      ▄╛
//       ▀Ö█  ;▓████████▄▄█▀▄╙W "V▄██▀▀│▄███▀└ ▀╦     "*═╥▄▀ ║,  ║▀▄  ,▓
//        ╙W▀ '█████╨▀▀█████████   "▀▀████└      ╙▄   ,▄▀'   `▀▀╣H ▐▀▄▀
//          ╙▄  ▀▀Γ╓▌  ▄▀ⁿ`╙▀███      ██▌         ╓█R▀▄A█        ▀▀▄▀
//            ╙W,Φ╙  ║█        ▄╙╙ª%≡╦██≤≤╗╗≡≡╜▀▀   ╣▌   █╕     ,▄▀
//              `▀▄M█┘        ║▀▌   ╫"    *Φ▄  █       Φ` ▀▌, ▄M╙
//                 "▀╦,       M ╙▌  ▀       `█W▐▌       wæQ▄▀╙
//                     ╙▀W╥,╓╣   ╙█║        ╫M  █    ,╓▄╝╙`
//
//                          ╙╙▀%▄▄▄▌,≤▄_▄≡,▐▓▓▄▄#ª▀"
