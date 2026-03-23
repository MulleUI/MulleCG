//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#import "CGImage.h"
#import "CGPaintable.h"
#import "CGContext+Drawing.h"

#import "import-private.h"


@implementation CGImage( CGPaintable)

- (void) fillWithBounds:(CGRect) rect
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   CGImage       *image;
   CGTextureID   textureID;

   assert( options);

   image     = [self resolvedImage];
   textureID = [image textureID];
   if( ! context || textureID == CGTextureIDInvalid)
      return;

   CGContextSetFillImagePattern( context, textureID, rect,
                                 options->paint.rotation + [image rotation],
                                 options->paint.alpha * [image alpha]);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   CGImage       *image;
   CGTextureID   textureID;

   assert( options);
   assert( strokeWidth > 0.0f);

   image     = [self resolvedImage];
   textureID = [image textureID];
   if( ! context || textureID == CGTextureIDInvalid)
      return;

   CGContextSetStrokeImagePattern( context, textureID, rect,
                                   options->paint.rotation + [image rotation],
                                   options->paint.alpha * [image alpha]);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

@end


void   CGContextFillImageOptions( CGContext *context,
                                  CGImage *image,
                                  CGRect rect,
                                  CGFillOptions *options)
{
   static CGFillOptions   defaults = CGFillOptionsDefault;
   CGFloat                alpha;
   CARotation             rotation;

   if( ! options)
      options = &defaults;

   alpha    = [image alpha] * options->paint.alpha;
   rotation = [image rotation] + options->paint.rotation;

   if( alpha <= 0.0f)
   {
      CGContextFillColor( context, CGColorMakeTransparent());
      return;
   }

   if( CGRectIsNull( rect))
      rect = CGRectMakeWithSize( [image size]);

   rect = CGRectMakeFillRect( rect, options->strokeWidth, options->relation);
   CGContextSetFillImagePattern( context, [image textureID], rect, rotation, alpha);
}


void   CGContextStrokeImageOptions( CGContext *context,
                                    CGImage *image,
                                    CGRect rect,
                                    CGFloat strokeWidth,
                                    CGStrokeOptions *options)
{
   static CGStrokeOptions   defaults = CGStrokeOptionsDefault;
   CGFloat                  alpha;
   CARotation               rotation;

   if( ! options)
      options = &defaults;

   alpha    = [image alpha] * options->paint.alpha;
   rotation = [image rotation] + options->paint.rotation;

   if( alpha <= 0.0f)
   {
      CGContextStrokeColor( context, CGColorMakeTransparent());
      return;
   }

   if( CGRectIsNull( rect))
      rect = CGRectMakeWithSize( [image size]);

   rect = CGRectMakeStrokeRect( rect, strokeWidth, options->relation);
   CGContextSetStrokeImagePattern( context, [image textureID], rect, rotation, alpha);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

