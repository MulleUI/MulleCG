//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#ifndef cgtypes_h__
#define cgtypes_h__

#include "include.h"


typedef NS_ENUM( NSUInteger, CGContextType)
{
   CGContextTypeFull = 0,
   CGContextTypePath = 1,
   CGContextTypeFont = 2
};


typedef NS_ENUM( NSUInteger, CGLineCap)
{
   CGLineCapButt,
   CGLineCapRound,
   CGLineCapSquare,
   CGLineCapBevel,
   CGLineCapMiter
};


// Ventral (instead of left)
// Central (replacing center).
// Dorsal (instead of right)
// Cranial (instead of top)
// Medial (instead of middle)
// Caudal

typedef NS_OPTIONS( NSUInteger, CGCombinedTextAlign)
{
   // Horizontal align
   CGTextAlignLeft    = 1<<0,   // Default, align text horizontally to left
   CGTextAlignCenter  = 1<<1,   // Align text horizontally to center
   CGTextAlignRight   = 1<<2,   // Align text horizontally to right

   // Vertical align
   CGTextAlignTop      = 1<<3,   // Align text vertically to top
   CGTextAlignMiddle   = 1<<4,   // Align text vertically to middle
   CGTextAlignBottom   = 1<<5,   // Align text vertically to bottom
   CGTextAlignBaseline = 1<<6   // Default, align text vertically to baseline

   // MEMO: needed cleanup:
   // add these: UITextAlignmentBoundsMiddle,      // only for single line
   //            UITextAlignmentVisualMiddle,
   // then remove UITextTypes (or move to UITextTypes)
};



static inline int   CGTextAlignIsValid( CGCombinedTextAlign align)
{
   NSUInteger   halign;
   NSUInteger   valign;

   // 0 would be same as CGTextAlignLeft (due to code), but we dont like it
   halign = align & (CGTextAlignLeft|CGTextAlignCenter|CGTextAlignRight);
   if( mulle_c_popcount( halign) != 1)
      return( 0);

   // 0 is same as CGTextAlignBaseline (due to code), but we dont like it
   valign = align & (CGTextAlignTop|CGTextAlignMiddle|CGTextAlignBottom|CGTextAlignBaseline);
   if( mulle_c_popcount( valign) != 1)
      return( 0);

   return( align == (halign | valign));
}


typedef NS_OPTIONS(NSUInteger, CGBlendFactor)
{
   CGBlendFactorZero              = 1<<0,
   CGBlendFactorOne               = 1<<1,
   CGBlendFactorSrcColor          = 1<<2,
   CGBlendFactorOneMinusSrcColor  = 1<<3,
   CGBlendFactorDstColor          = 1<<4,
   CGBlendFactorOneMinusDstColor  = 1<<5,
   CGBlendFactorSrcAlpha          = 1<<6,
   CGBlendFactorOneMinusSrcAlpha  = 1<<7,
   CGBlendFactorDstAlpha          = 1<<8,
   CGBlendFactorOneMinusDstAlpha  = 1<<9,
   CGBlendFactorSrcAlphaSaturate  = 1<<10
};


typedef NS_ENUM(NSUInteger, CGCompositeOperation)
{
   CGCompositeOperationSourceOver,
   CGCompositeOperationSourceIn,
   CGCompositeOperationSourceOut,
   CGCompositeOperationAtop,
   CGCompositeOperationDestinationOver,
   CGCompositeOperationDestinationIn,
   CGCompositeOperationDestinationOut,
   CGCompositeOperationDestinationAtop,
   CGCompositeOperationLighter,
   CGCompositeOperationCopy,
   CGCompositeOperationXOR
};


typedef NS_OPTIONS(NSUInteger, CGImageFlags)
{
   CGImageFlagGenerateMipmaps   = 1<<0,   // Generate mipmaps during creation of the image
   CGImageFlagRepeatX           = 1<<1,   // Repeat image in X direction
   CGImageFlagRepeatY           = 1<<2,   // Repeat image in Y direction
   CGImageFlagFlipY             = 1<<3,   // Flips (inverses) image in Y direction when rendered
   CGImageFlagPremultiplied     = 1<<4,   // Image data has premultiplied alpha
   CGImageFlagNearest           = 1<<5,   // Image interpolation is Nearest instead Linear
   CGImageFlagMSAA              = 1<<6,   // Only usable with nvgluCreateFramebuffer
   CGImageFlagRBOLess           = 1<<7    // Convenience for framebuffer creation
   // CGImageFlagNoDelete       = 1<<16   // (defined elsewhere)
};


typedef NS_ENUM(NSUInteger, CGTessellation)
{
   CGTessellationSubdivision,      // De Casteljau subdivision. Default.
   CGTessellationAFD               // Adaptive forward differencing. Try this algorithm for better tessellation performance.
};


typedef NS_ENUM( NSUInteger, CGTextOptions)
{
   CGTextOptionDefault       = 0x0,
   CGTextOptionAlignVisually = 0x1,
   CGTextOptionAlignBaseline = 0x2,
   CGTextOptionNoClip        = 0x4,
   CGTextOptionFill          = 0x8
};


// #define RENDER_DEBUG


typedef NS_ENUM( NSUInteger, CGRelation)
{
   CGInside,
   CGOutside,
   CGOverlap
};


// Backend-neutral texture flags (values match NVG_IMAGE_* in nanovg)
typedef NS_OPTIONS( NSUInteger, CGTextureFlags)
{
   CGTextureRepeatX = 1<<1,
   CGTextureRepeatY = 1<<2,
   CGTextureFlipY   = 1<<3,
};


// CGContextType string conversion functions
static inline char   *_CGContextTypeUTF8String( NSUInteger value)
{
   switch( value)
   {
   case CGContextTypeFull : return( "Full");
   case CGContextTypePath : return( "Path");
   case CGContextTypeFont : return( "Font");
   }
   return( NULL);
}

static inline char   *CGContextTypeUTF8String( NSUInteger value)
{
   char   *s;

   s = _CGContextTypeUTF8String( value);
   return( s ? s : "???");
}

// CARotationDirection string conversion functions
static inline char   *_CGWindingUTF8String( NSUInteger value)
{
   switch( value)
   {
   case CARotationDirectionCounterClockWise : return( "CCW");
   case CARotationDirectionClockWise  : return( "CW");
   }
   return( NULL);
}

static inline char   *CGWindingUTF8String( NSUInteger value)
{
   char   *s;

   s = _CGWindingUTF8String( value);
   return( s ? s : "???");
}

// CGLineCap string conversion functions
static inline char   *_CGLineCapUTF8String( NSUInteger value)
{
   switch( value)
   {
   case CGLineCapButt   : return( "Butt");
   case CGLineCapRound  : return( "Round");
   case CGLineCapSquare : return( "Square");
   case CGLineCapBevel  : return( "Bevel");
   case CGLineCapMiter  : return( "Miter");
   }
   return( NULL);
}

static inline char   *CGLineCapUTF8String( NSUInteger value)
{
   char   *s;

   s = _CGLineCapUTF8String( value);
   return( s ? s : "???");
}

// CGCompositeOperation string conversion functions
static inline char   *_CGCompositeOperationUTF8String( NSUInteger value)
{
   switch( value)
   {
   case CGCompositeOperationSourceOver      : return( "SourceOver");
   case CGCompositeOperationSourceIn        : return( "SourceIn");
   case CGCompositeOperationSourceOut       : return( "SourceOut");
   case CGCompositeOperationAtop            : return( "Atop");
   case CGCompositeOperationDestinationOver : return( "DestinationOver");
   case CGCompositeOperationDestinationIn   : return( "DestinationIn");
   case CGCompositeOperationDestinationOut  : return( "DestinationOut");
   case CGCompositeOperationDestinationAtop : return( "DestinationAtop");
   case CGCompositeOperationLighter         : return( "Lighter");
   case CGCompositeOperationCopy            : return( "Copy");
   case CGCompositeOperationXOR             : return( "XOR");
   }
   return( NULL);
}

static inline char   *CGCompositeOperationUTF8String( NSUInteger value)
{
   char   *s;

   s = _CGCompositeOperationUTF8String( value);
   return( s ? s : "???");
}

// CGTessellation string conversion functions
static inline char   *_CGTessellationUTF8String( NSUInteger value)
{
   switch( value)
   {
   case CGTessellationSubdivision : return( "Subdivision");
   case CGTessellationAFD         : return( "AFD");
   }
   return( NULL);
}

static inline char   *CGTessellationUTF8String( NSUInteger value)
{
   char   *s;

   s = _CGTessellationUTF8String( value);
   return( s ? s : "???");
}


// this is only for a single bit in buttons
static inline char   *_CGRelationUTF8String( NSUInteger bit)
{
   switch( bit)
   {
   case CGInside  : return( "Inside");
   case CGOutside : return( "Outside");
   case CGOverlap : return( "Overlap");
   }
   return( NULL);
}


static inline char   *CGRelationUTF8String( NSUInteger bit)
{
   char   *s;

   s = _CGRelationUTF8String( bit);
   return( s ? s : "???");
}


// You want to stroke a rectangle. By defaule CGOverlap (no compensation) will
// draw half the strokeWidth _outside_ of your rectangle. You can correct the
// positioning with `CGRectMakeStrokeRect`
//
// CGOverlap :  stroke extends over half the rect (i.e. no compensation)
// CGInside  :  stroke does not extend over the rect
// CGOutside :  stroke paints outside of rect
//
static inline CGRect
   CGRectMakeStrokeRect( CGRect rect, CGFloat strokeWidth, CGRelation relation)
{
   switch( relation)
   {
   case CGInside  :
     rect.origin.x    += strokeWidth / 2.0;
     rect.origin.y    += strokeWidth / 2.0;
     rect.size.width  -= strokeWidth;
     rect.size.height -= strokeWidth;
     break;

   case CGOutside   :
     rect.origin.x    -= strokeWidth / 2.0;
     rect.origin.y    -= strokeWidth / 2.0;
     rect.size.width  += strokeWidth;
     rect.size.height += strokeWidth;

   case CGOverlap :
     break;
   }
   return( rect);
}



// You made a stroke for a rectangle with CGRectMakeStrokeRect. Now you want
// to fill the inside. You use CGRectMakeFillRect with the resule of
// CGRectMakeStrokeRect and the following options:
//
// CGOverlap :  fill extends covers half the strokeWidth (i.e. no compensation)
// CGInside  :  fill extends to stroke, but does not cover any portion
// CGOverlap   :  fill extends to cover stroke completely
//
static inline CGRect
   CGRectMakeFillRect( CGRect strokeRect, CGFloat strokeWidth, CGRelation relation)
{
   switch( relation)
   {
   case CGInside  :
     strokeRect.origin.x    += strokeWidth / 2.0;
     strokeRect.origin.y    += strokeWidth / 2.0;
     strokeRect.size.width  -= strokeWidth;
     strokeRect.size.height -= strokeWidth;
     break;

   case CGOutside :
     strokeRect.origin.x    -= strokeWidth / 2.0;
     strokeRect.origin.y    -= strokeWidth / 2.0;
     strokeRect.size.width  += strokeWidth;
     strokeRect.size.height += strokeWidth;

   case CGOverlap :
     break;
   }
   return( strokeRect);
}


struct CGPaintOptions
{
   CARotation   rotation;           // default: 0.0
   CGFloat      smoothness;         // default: 1.0
   CGFloat      alpha;              // default: 1.0
   NSUInteger   textureFlags;       // default: 0
};

// MEMO: keep it so you can cast CGFillOptions * to CGStrokeOptions *
struct CGStrokeOptions
{
   struct CGPaintOptions   paint;
   CGRelation              relation;           // default: CGOverlap
};


struct CGFillOptions
{
   struct CGPaintOptions   paint;
   CGRelation              relation;        // default: CGOverlap
   CGFloat                 strokeWidth;    // default: 0.0 used by CGInside
};

#define CGPaintOptionsDefault                                     \
   ((struct CGPaintOptions) {                                     \
                              .smoothness = 1.0f,                 \
                              .alpha      = 1.0f,                 \
                            })


#define CGFillOptionsDefault                                      \
   ((struct CGFillOptions) {                                      \
                             .paint    = CGPaintOptionsDefault,   \
                             .relation = CGOverlap                \
                           })

#define CGStrokeOptionsDefault                                    \
   ((struct CGStrokeOptions) {                                    \
                               .paint    = CGPaintOptionsDefault, \
                               .relation = CGOverlap              \
                             })


typedef struct CGFillOptions     CGFillOptions;
typedef struct CGStrokeOptions   CGStrokeOptions;


static inline CGFillOptions   CGFillOptionsMake( CARotation rotation,
                                                 CGFloat smoothness,
                                                 CGFloat alpha,
                                                 NSUInteger textureFlags,
                                                 CGRelation relation,
                                                 CGFloat strokeWidth)
{
   CGFillOptions   options;

   options.paint.rotation     = rotation;
   options.paint.smoothness   = smoothness;
   options.paint.alpha        = alpha;
   options.paint.textureFlags = textureFlags;
   options.relation           = relation;
   options.strokeWidth        = strokeWidth;
   return( options);
}



static inline CGFillOptions   CGFillOptionsMakeWithRotation( CARotation rotation)
{
   CGFillOptions   options = CGFillOptionsDefault;

   options.paint.rotation = rotation;
   return( options);
}


static inline CGFillOptions   CGFillOptionsMakeWithAlpha( CGFloat alpha)
{
   CGFillOptions   options = CGFillOptionsDefault;

   options.paint.alpha = alpha;
   return( options);
}


static inline CGFillOptions   CGFillOptionsMakeWithRotationAndAlpha( CARotation rotation, CGFloat alpha)
{
   CGFillOptions   options = CGFillOptionsDefault;

   options.paint.rotation = rotation;
   options.paint.alpha    = alpha;
   return( options);
}


static inline CGStrokeOptions   CGStrokeOptionsMake( CARotation rotation,
                                                     CGFloat smoothness,
                                                     CGFloat alpha,
                                                     NSUInteger textureFlags,
                                                     CGRelation relation)
{
   CGStrokeOptions   options;

   options.paint.rotation     = rotation;
   options.paint.smoothness   = smoothness;
   options.paint.alpha        = alpha;
   options.paint.textureFlags = textureFlags;
   options.relation           = relation;
   return( options);
}


static inline CGStrokeOptions   CGStrokeOptionsMakeWithRotation( CARotation rotation)
{
   CGStrokeOptions   options = CGStrokeOptionsDefault;

   options.paint.rotation = rotation;
   return( options);
}


static inline CGStrokeOptions   CGStrokeOptionsMakeWithAlpha( CGFloat alpha)
{
   CGStrokeOptions   options = CGStrokeOptionsDefault;

   options.paint.alpha = alpha;
   return( options);
}


static inline CGStrokeOptions   CGStrokeOptionsMakeWithRotationAndAlpha( CARotation rotation, CGFloat alpha)
{
   CGStrokeOptions   options = CGStrokeOptionsDefault;

   options.paint.rotation = rotation;
   options.paint.alpha    = alpha;
   return( options);
}


struct CGShadow
{
   struct MulleEdgeInsets   extrudes;
   CGColor                  innerColor;
   CGColor                  outerColor;
   CGFloat                  blur;
   char                     hole;
};


#define CGShadowDefaultValues  (struct CGShadow)                           \
{                                                                          \
   .extrudes   = { .top = 0.5, .left = 0.5, .bottom = 4.0, .right = 2.0 }, \
   .innerColor = CGColorDataWithRGBA( 0, 0, 0, 0.5),                       \
   .outerColor = CGColorDataWithRGBA( 0, 0, 0, 0),                         \
   8.0,                                                                    \
   1                                                                       \
}


static inline struct CGShadow
   CGShadowMake( CGPoint offset, CGFloat blur, CGColor color)
{
   struct CGShadow   shadow;

   shadow.extrudes = (struct MulleEdgeInsets)
                     {
                       .top    = offset.y,
                       .bottom = offset.y,
                       .left   = offset.x,
                       .right  = offset.x
                     };
   shadow.innerColor = color;
   shadow.outerColor = CGColorMakeTransparent();
   shadow.blur       = blur;
   shadow.hole       = 1;
   return( shadow);
}



/**
 * Retrieves the current font metrics for text rendering.
 *
 * This method provides essential vertical metrics for the currently selected
 * font, which are necessary for proper text layout and positioning.
 *
 * @param metrics A pointer to a CGTextMetrics structure that will be filled
 *                with the font metrics information. If NULL, the method returns
 *                without doing anything.
 *
 * The metrics include (all values >= 0.0!!):
 *
 *   ascender    - The distance from the baseline to the top of capital letters
 *   descender   - The distance from the baseline to the bottom of descenders
 *   lineHeight  - The total height of the font
 *
 * These values can be visualized as follows:
 *
 *   +--------------------------------+  ← Top
 *   |                                |
 *   |                                |  ↑
 *   |                                |  | ascender
 *   |                                |  |
 *   +--------------------------------+  ← Baseline
 *   |                                |  ↓
 *   |                                |  | descender
 *   +--------------------------------+  ← Bottom
 *                                       ↕ lineHeight
 *
 * @note For proper line spacing in multi-line text, you typically need to add
 *       additional leading (space) between lines. A common practice is to use
 *       lineHeight * 1.2 or similar for the distance between baselines.
 *
 * @note All metrics are returned in the same coordinate space as other NanoVG
 *       drawing operations. The device pixel ratio is already accounted for
 *       internally, so no additional conversion is needed.
 *
 * @note The metrics returned are for the currently selected font. Make sure
 *       to call this method after setting the desired font and font size.
 */
#ifndef CGTextBoundsInfo_defined__
#define CGTextBoundsInfo_defined__
typedef struct CGTextBoundsInfo
{
   CGRect   bounds;
   float    size;    // can be fontPixelSize or width depending on use
} CGTextBoundsInfo;

#define CGTextBoundsInfoNull \
   (CGTextBoundsInfo) { .bounds = CGRectNull, .size = 0.0 }

static inline CGTextBoundsInfo   CGTextBoundsInfoMake( CGRect rect, float size)
{
   return( (CGTextBoundsInfo) { .bounds = rect, .size = size });
}
#endif


typedef struct CGTextMetrics
{
   float   ascender;
   float   descender;
   float   lineHeight;
   float   lineGap;      // -1 means unknown/unavailable
} CGTextMetrics;


static inline CGTextMetrics  CGTextMetricsMake( float ascender,
                                                float descender,
                                                float lineHeight)
{
   assert( ascender >= 0.0f);
   assert( descender >= 0.0f);
   assert( lineHeight >= ascender + descender);

   return( (struct CGTextMetrics)
           {
              .ascender   = ascender,
              .descender  = descender,
              .lineHeight = lineHeight,
              .lineGap    = -1
           });
}

// defined elsewhere
//static inline char   *CGTextMetricsUTF8String( CGTextMetrics metrics)


// Backend resource IDs (opaque integer handles)
typedef NSInteger    CGTextureID;   // -1 == invalid
typedef NSInteger    CGFontID;      // -1 == invalid
typedef NSUInteger   CGShaderID;    // 0 is invalid

#define CGTextureIDInvalid   0
#define CGFontIDInvalid      -1


// Attributed text: per-run styling for CGContextAttributedText.
// Runs tile the string contiguously. Each run's `offset` is the byte offset
// past the last byte of that run. So run 0 covers bytes [0, attributes[0].offset),
// run 1 covers [attributes[0].offset, attributes[1].offset), etc.
typedef struct CGTextAttribute
{
   NSUInteger  offset;           // byte offset past end of this run
   CGColor     textColor;
   CGColor     backgroundColor;  // ClearType background hint
   CGFontID    fontId;           // -1 = inherit from current state
   CGFloat     fontSize;         // <=0 = inherit from current state
   CGFloat     yOffset;          //  0 = baseline, <0 = up (superscript)
} CGTextAttribute;


// Font size rounding (nanovg is 1/10 resolution, FreeType is 1/64)
#ifndef mvgRoundedFontSize_defined__
# define mvgRoundedFontSize_defined__
static inline CGFloat  mvgRoundedFontSize( CGFloat size)
{
   NSUInteger   tenth = (NSUInteger) (10 * size);

   if( tenth < 10)
      tenth = 10;
   if( tenth >= 2044 * 10)
      tenth = 2044 * 10;
   return( tenth / 10.0f);
}
#endif

#endif
