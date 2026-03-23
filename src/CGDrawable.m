#import "CGDrawable.h"

#import "CGContext.h"
#import "CGContext.h"


// #define DRAWABLE_DEBUG


CGDrawableOptions   CGDrawableOptionsDefault =
{
   .alpha             = 1.0f,
   .cornerInsets      = (MulleCornerInsets) { 0.0f, 0.0f, 0.0f, 0.0f },
   .rotation          = CGRotationNone,
   .scale             = CGScaleNone,
   .flags.flip        = CGFlipNone,
   .flags.repeat      = CGRepeatAsIs,
   .flags.contentMode = CGContentModeCenterPoint
};


CGDrawableOptions   CGDrawableOptionsScaleToFit =
{
   .alpha             = 1.0f,
   .cornerInsets      = (MulleCornerInsets) { 0.0f, 0.0f, 0.0f, 0.0f },
   .rotation          = CGRotationNone,
   .scale             = CGScaleToFit,
   .flags.flip        = CGFlipNone,
   .flags.repeat      = CGRepeatAsIs,
   .flags.contentMode = CGContentModeCenterPoint
};


PROTOCOLCLASS_IMPLEMENTATION( CGBitmapDrawable)

- (CGPixelSize) bitmapSize
{
   return( [self bitmapInfo].size);
}


- (CGSize) size
{
   CGPixelSize   size;

   size = [self bitmapSize];

   return( CGSizeMake( size.width, size.height));
}


// if you want to do more, do your own layer

CGPoint  CGRectGetCenterAtAngle( CGRect patternRect, CAAngle angle)
{
   CAPolarPoint   rotatedPolarPoint;
   CAPolarPoint   centerPolarPoint;
   CGPoint        rotatedPoint;
   // texture is at 0.0, we calc the "scaled" texture point
   CGPoint        centerPoint;
   CGPoint        diffPoint;

   // calculate position independent the amout of rotation for the
   // center point
   centerPoint       = CGPointMake( patternRect.size.width / 2.0, patternRect.size.height / 2.0);
   centerPolarPoint  = CAPolarPointMakeWithPoint( centerPoint);
   rotatedPolarPoint = CAPolarPointAddRadians( centerPolarPoint, CAAngleToRadians( angle));
   rotatedPoint      = CGPointMakeWithPolarPoint( rotatedPolarPoint);
   diffPoint         = CGPointMake( rotatedPoint.x - centerPoint.x,
                                    rotatedPoint.y - centerPoint.y);
   patternRect.origin.x -= diffPoint.x;
   patternRect.origin.y -= diffPoint.y;
   return( patternRect.origin);
}


CGPoint  CGRectGetCenterAtAngleWithScaling( CGRect patternRect,
                                                 CAAngle angle,
                                                 CGVector scaleFactor)
{
   CAPolarPoint   rotatedPolarPoint;
   CAPolarPoint   centerPolarPoint;
   CGPoint        rotatedPoint;
   // texture is at 0.0, we calc the "scaled" texture point
   CGPoint        centerPoint;
   CGPoint        diffPoint;

   // calculate position independent the amout of rotation for the
   // center point
   centerPoint       = CGPointMake( patternRect.size.width / 2.0, patternRect.size.height / 2.0);
   centerPolarPoint  = CAPolarPointMakeWithPoint( centerPoint);
   rotatedPolarPoint = CAPolarPointAddRadians( centerPolarPoint, CAAngleToRadians( angle));
   rotatedPoint      = CGPointMakeWithPolarPoint( rotatedPolarPoint);
   diffPoint         = CGPointMake( rotatedPoint.x - centerPoint.x,
                                    rotatedPoint.y - centerPoint.y);
   patternRect.origin.x -= diffPoint.x * scaleFactor.dx;
   patternRect.origin.y -= diffPoint.y * scaleFactor.dy;
   return( patternRect.origin);
}


static CGAffineTransform   textureMapperTransform( CGRect rect,
                                                   CARotation rotation,
                                                   CGSize extent)
{
   CGAffineTransform   rotate;
   CGAffineTransform   translate;
   CGAffineTransform   paint;
   CGAffineTransform   shader;
   CGAffineTransform   textureScale;
   CGAffineTransform   fragment;

   // stand in for current transformation
   //   current  = CGAffineTransformMakeIdentity();

   // NVGpaint nvgImagePattern(NVGcontext* ctx,
   //                          float point_x, float point_y,
   //                          float extent_w, float extent_h,
   //                          float angle,
   //                          int image,
   //                          float alpha)
   rotate        = CGAffineTransformMakeRotationInline( rotation);
   translate     = CGAffineTransformMakeTranslationInline( rect.origin);
   paint         = CGAffineTransformConcatInline( rotate, translate);

   //combined = CGAffineTransformConcat( current, paint);
   shader        = CGAffineTransformInvertInline( paint);

   // actual shader code is:
   // "     // Calculate color fron texture\n"
   // "     vec2 texturePoint = (shader * vec3( vertex,1.0)).xy / extent;\n"
   // "     vec4 color = texture2D( image, texturePoint);\n"

   textureScale  = CGAffineTransformMakeScaleInline( CGVectorMake( 1.0 / extent.width, 1.0 / extent.height));
   fragment      = CGAffineTransformConcatInline( shader, textureScale);

   return( fragment);
}


//
// rect should not be changed, it's the rectangle to draw
// bitmapSize should also be the correct max imageSize
//
CGAffineTransform   CGRectReverseImageMapperTransform( CGRect rect,
                                                       CAAngle angle,
                                                       CGSize extent,
                                                       CGSize imageSize)
{
   CGAffineTransform   fragment;
   CGAffineTransform   bitmapScale;
   CGAffineTransform   combined;
   CGAffineTransform   reverse;

   fragment      = textureMapperTransform( rect, angle, extent);

   bitmapScale   = CGAffineTransformMakeScaleInline( CGVectorMakeWithSize( imageSize));
   combined      = CGAffineTransformConcatInline( fragment, bitmapScale);
   reverse       = CGAffineTransformInvertInline( combined);

   return( reverse);
}



CGPoint  CGRectGetOriginToTexturePointForRotationAndExtent( CGRect rect,
                                                            CGPoint texturePoint,
                                                            CARotation rotation,
                                                            CGSize extent)
{
   CGPoint             rotatedPoint;
   CGPoint             rotatedOrigin;
   CGPoint             centerPoint;
   CGAffineTransform   xform;
   CGPoint             patternPoint;
   CGRect              centeredRect;

#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "rect=%s angle=%.3f extent=%s\n",
         CGRectUTF8String( rect), CAAngleToDegrees( rotation), CGSizeUTF8String( extent));
#endif

   // xform should place texture at center so
   //rect.origin        = CGRectGetCenter( rect);

   // if we draw unscaled and unangled, the image will be at top/left
   // so when we then calculate the imageCenter this will not be the center
   // of the drawing.
   // So we first have to fake the rect to be in the center of the drawing.
   centeredRect      = rect;
#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "centeredRect     : %s\n", CGRectUTF8String( centeredRect));
#endif   

   centerPoint        = CGRectGetCenter( centeredRect);
#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "centerPoint      : %s\n", CGPointUTF8String( centerPoint));
#endif   

   xform              = textureMapperTransform( centeredRect, rotation, extent);
   xform              = CGAffineTransformInvert( xform);

   // now when we apply the transform to the center point of the texture
   // we get a rotated point, which can lie outside of centered rect (no problem)
   rotatedPoint       = CGPointApplyAffineTransform( texturePoint, xform);
#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "rotatedPoint     : %s\n", CGPointUTF8String( rotatedPoint));
#endif   

   // rotatedPoint is the center of the texture, which we want to place in the
   // middle of the pattern. The extent is the size of the texture in  the
   // shader. Within "extent" texture coordinates are valid outside of the
   // extent they clamp.
   //
   // The shader will scan (pseudo code)
   // for( y = CGRectMinY( rect); y <= CGRectMaxY( rect); y++)
   //    for( x = CGRectMinX( rect); x <= CGRectMaxX( rect); x++)
   // {
   //    texture.x = x - patternRect.origin.x;
   //    texture.y = y - patternRect.origin.y;
   //    texture.x /= extent.size;
   //    texture.y /= extent.width;
   //    if( texture.x < 0.0) texture.x = 0.0;
   //    if( texture.x > 1.0) texture.x = 1.0;
   //    if( texture.y < 0.0) texture.y = 0.0;
   //    if( texture.y > 1.0) texture.y = 1.0;
   //    color = image[ texture.y * image.height][ texture.x * image.width]
   // }
   rotatedOrigin.x = (rotatedPoint.x - (extent.width / 2.0));
   rotatedOrigin.y = (rotatedPoint.y - (extent.height / 2.0));
#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "rotatedOrigin    : %s\n", CGPointUTF8String( rotatedOrigin));
#endif   

   patternPoint = CGPointMake( centeredRect.origin.x - (extent.width / 2.0) + (centerPoint.x - rotatedOrigin.x),
                               centeredRect.origin.y - (extent.height / 2.0) + (centerPoint.y - rotatedOrigin.y)); // + rotatedOrigin.y);/*

#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "patternPoint     : %s\n\n", CGPointUTF8String( patternPoint));
#endif   
   return( patternPoint);
}


CGSize   CGBitmapDrawableGetBitmapExtent( id <CGBitmapDrawable> self,
                                          CGSize size,
                                          CGSize bitmapSize,
                                          CGDrawableOptions *options)
{
   CGSize       extent;

   extent = size;
   if( options->scale == CGScaleNone || (options->flags.repeat & CGRepeatHorizontally))
      extent.width = bitmapSize.width;
   if( options->scale == CGScaleNone || (options->flags.repeat & CGRepeatVertically))
      extent.height = bitmapSize.height;

   if( options->scale != CGScaleToFit && options->scale != CGScaleNone)
   {
      extent.width  /= options->scale;
      extent.height /= options->scale;
   }  
   return( extent); 
}




- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   MULLE_C_UNUSED( rect);
   MULLE_C_UNUSED( options);
   MULLE_C_UNUSED( context);
   // implemented by nanovg backend
}


CGRect   CGDrawablePatternRect( id <CGDrawable> self,
                                CGRect rect,
                                CGRect fromRect,
                                CGDrawableOptions *options)
{
   CGSize              size;
   CGRect              sectionRect;
   CGRect              r;
   CGAffineTransform   xform;
   CGPoint             texturePoint;
   CGPoint             scale;
   CGPoint             factor;

   size  = [self size];

   if( ! options->flags.textureOverreach &&
         options->scale != CGScaleNone)
   {
      //
      // Unfortunately OpenGL "overreaches" into neighboring texturing, when
      // scaling up the pixels... so we correct this, otherwise you get ugly
      // artifacts and borders...
      scale.x = rect.size.width  / fromRect.size.width;
      if( scale.x > 1.0)
      {
         factor.x = scale.x < 2.0
                    ? (rect.size.width - fromRect.size.width) / fromRect.size.width / 2.0
                    : 0.5;
         fromRect.origin.x += factor.x;
         if( factor.x * 2.0 < fromRect.size.width)
            fromRect.size.width -= factor.x * 2.0;
         else
            fromRect.size.width  = 1.0 / scale.x;
      }

      scale.y = rect.size.height / fromRect.size.height;
      if( scale.y > 1.0)
      {
         factor.y = scale.y < 2.0
                    ? (rect.size.height - fromRect.size.height) / fromRect.size.height / 2.0
                    : 0.5;

         fromRect.origin.y += factor.y;
         if( factor.y * 2.0 < fromRect.size.height)
            fromRect.size.height -= factor.y * 2.0;
         else
            fromRect.size.height  = 1.0 / scale.y;
      }
   }

   // if fromRect is { CGPointZero, [self size] }, then sectionRect should be
   // exactly rect, otherwise we get a subsection of rect
   xform       = CGRectReverseImageMapperTransform( rect, options->rotation, rect.size, size);
   sectionRect = CGRectApplyAffineTransform( fromRect, xform);

   // get fromOrigin texture coordinate
   texturePoint.x = (CGRectGetMidX( sectionRect) - rect.origin.x) / rect.size.width;
   texturePoint.y = (CGRectGetMidY( sectionRect) - rect.origin.y) / rect.size.height;

   // hacky hack
   if( sectionRect.size.width == 0.0 || sectionRect.size.height == 0.0)
      return( CGRectMakeWithOriginAndSize( texturePoint, CGSizeMake( 0.5, 0.5)));

//
//  +----------+
//  |          |
//  |  +       |
//  |          |
//  |          |
//  +----------+
//
// reduce extent to fromRect.size

   r.size.width   = rect.size.width  * (rect.size.width / sectionRect.size.width);
   r.size.height  = rect.size.height * (rect.size.height / sectionRect.size.height);
   r.origin       = CGRectGetOriginToTexturePointForRotationAndExtent( rect,
                                                                       texturePoint,
                                                                       options->rotation,
                                                                       r.size);
   return( r);
}


- (void) drawRect:(CGRect) rect
         fromRect:(CGRect) fromRect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   MULLE_C_UNUSED( rect);
   MULLE_C_UNUSED( fromRect);
   MULLE_C_UNUSED( options);
   MULLE_C_UNUSED( context);
   // implemented by nanovg backend
}


- (void *) bytes
{
   return( NULL);
}


- (NSUInteger) textureFlags
{
   return( 0);
}


- (BOOL) isRepeating   
{
   return( [self textureFlags] & (CGTextureRepeatX|CGTextureRepeatY) ? YES : NO);
}


PROTOCOLCLASS_END()


PROTOCOLCLASS_IMPLEMENTATION( CGVectorDrawable)

- (CGRect) canvas
{
   return( (CGRect){ .origin = CGPointZero, .size = [self size]});
}


- (CGRect) bounds
{
   return( [self canvas]);
}

- (BOOL) isRepeating
{
   return( NO);
}

PROTOCOLCLASS_END()
