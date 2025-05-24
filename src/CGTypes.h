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


static inline CGFloat  CGRectGetStrokeMinX( CGRect rect, CGFloat strokeWidth)
{
   return( CGRectGetMinX( rect) + strokeWidth / 2.0);
}


static inline CGFloat  CGRectGetStrokeMaxX( CGRect rect, CGFloat strokeWidth)
{
   return( CGRectGetMaxX( rect) - strokeWidth / 2.0);
}


static inline CGFloat  CGRectGetStrokeMinY( CGRect rect, CGFloat strokeWidth)
{
   return( CGRectGetMinY( rect) + strokeWidth / 2.0);
}


static inline CGFloat  CGRectGetStrokeMaxY( CGRect rect, CGFloat strokeWidth)
{
   return( CGRectGetMaxY( rect) - strokeWidth / 2.0);
}


struct CGPaintOptions
{
   CGFloat   rotation;           // default: 0.0
   CGFloat   smoothness;         // default: 1.0
   CGFloat   alpha;              // default: 1.0
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


#endif
