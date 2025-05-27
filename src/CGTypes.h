//
// Copyright (c) <|YEAR|> Nat!, Mulle kybernetiK
//
#ifndef cgtypes_h__
#define cgtypes_h__

#include "include.h"


typedef NS_ENUM(NSUInteger, CGContextType)
{
   CGContextTypeFull = 0,
   CGContextTypePath = 1,
   CGContextTypeFont = 2
};


typedef NS_ENUM(NSUInteger, CGWinding)
{
   CGWindingCCW = 1,            // Winding for solid shapes
   CGWindingCW  = 2             // Winding for holes
};


typedef NS_ENUM(NSUInteger, CGSolidity)
{
   CGSoliditySolid = 1,         // CCW
   CGSolidityHole  = 2          // CW
};


typedef NS_ENUM(NSUInteger, CGLineCap)
{
   CGLineCapButt,
   CGLineCapRound,
   CGLineCapSquare,
   CGLineCapBevel,
   CGLineCapMiter
};


typedef NS_OPTIONS(NSUInteger, CGTextAlign)
{
   // Horizontal align
   CGTextAlignLeft    = 1<<0,   // Default, align text horizontally to left
   CGTextAlignCenter  = 1<<1,   // Align text horizontally to center
   CGTextAlignRight   = 1<<2,   // Align text horizontally to right

   // Vertical align
   CGTextAlignTop     = 1<<3,   // Align text vertically to top
   CGTextAlignMiddle  = 1<<4,   // Align text vertically to middle
   CGTextAlignBottom  = 1<<5,   // Align text vertically to bottom
   CGTextAlignBaseline = 1<<6   // Default, align text vertically to baseline
};


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
   CGCover,
   CGInside,
   CGOutside,
   CGOverlap
};

static inline CGRect
   CGRectMakeFillRect( CGRect rect, CGFloat strokeWidth, CGRelation relation)
{
   switch( relation)
   {
   case CGInside  :
     rect.origin.x    += strokeWidth / 2.0;
     rect.origin.y    += strokeWidth / 2.0;
     rect.size.width  -= strokeWidth;
     rect.size.height -= strokeWidth;
     break;

   case CGCover   :
     rect.origin.x    -= strokeWidth / 2.0;
     rect.origin.y    -= strokeWidth / 2.0;
     rect.size.width  += strokeWidth;
     rect.size.height += strokeWidth;
     break;

   // useless
   case CGOutside :
     rect.origin.x    -= strokeWidth;
     rect.origin.y    -= strokeWidth;
     rect.size.width  += strokeWidth * 2.0;
     rect.size.height += strokeWidth * 2.0;
   }
   return( rect);
}


static inline CGRect
   CGRectMakeStrokeRect( CGRect rect, CGFloat strokeWidth, CGRelation relation)
{
   switch( relation)
   {
   case CGInside  :
   case CGCover   :
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
     break;
   }
   return( rect);
}


struct CGPaintOptions
{
   CARotation   rotation;           // default: 0.0
   CGFloat      smoothness;         // default: 1.0
   CGFloat      alpha;              // default: 1.0
};

struct CGStrokeOptions
{
   struct CGPaintOptions   paint;
   CGRelation              relation;           // default: CGCover
};


struct CGFillOptions
{
   struct CGPaintOptions   paint;
   CGRelation              relation;        // default: CGCover
   CGFloat                 fillStrokeWidth; // default: 0.0 used by CGInside
};

#define CGPaintOptionsDefault                                     \
   ((struct CGPaintOptions) {                                     \
                              .smoothness = 1.0f,                 \
                              .alpha      = 1.0f,                 \
                            })


#define CGFillOptionsDefault                                      \
   ((struct CGFillOptions) {                                      \
                             .paint    = CGPaintOptionsDefault,   \
                             .relation = CGInside                 \
                           })

#define CGStrokeOptionsDefault                                    \
   ((struct CGStrokeOptions) {                                    \
                               .paint    = CGPaintOptionsDefault, \
                               .relation = CGInside               \
                             })


typedef struct CGFillOptions     CGFillOptions;
typedef struct CGStrokeOptions   CGStrokeOptions;


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
typedef struct CGTextMetrics
{
   float   ascender;
   float   descender;
   float   lineHeight;
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
              .lineHeight = lineHeight
           });
}


#endif
