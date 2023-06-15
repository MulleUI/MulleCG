#import "CGDrawable.h"

#import "CGContext.h"
#import "CGImage.h"


// #define DRAWABLE_DEBUG


CGDrawableOptions   CGDrawableOptionsDefault =
{
   .alpha             = 1.0f,
   .cornerRadius      = 0.0f,
   .rotation          = CGRotationNone,
   .scale             = CGScaleNone,
   .flags.flip        = CGFlipNone,
   .flags.repeat      = CGRepeatNone,
   .flags.contentMode = CGContentModeCenterPoint
};


CGDrawableOptions   CGDrawableOptionsScaleToFit =
{
   .alpha             = 1.0f,
   .cornerRadius      = 0.0f,
   .rotation          = CGRotationNone,
   .scale             = CGScaleToFit,
   .flags.flip        = CGFlipNone,
   .flags.repeat      = CGRepeatNone,
   .flags.contentMode = CGContentModeCenterPoint
};


PROTOCOLCLASS_IMPLEMENTATION( CGBitmapDrawable)

- (struct MulleIntegerSize) bitmapSize
{
   return( [self bitmapInfo].size);
}


- (CGSize) size
{
   struct MulleIntegerSize   size;

   size = [self bitmapSize];

   return( CGSizeMake( size.width, size.height));
}


// if you want to do more, do your own layer

CGPoint  CGRectGetCenterPointAtAngle( CGRect patternRect, CAAngleRadians angle)
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
   rotatedPolarPoint = CAPolarPointAddAngle( centerPolarPoint, angle);
   rotatedPoint      = CGPointMakeWithPolarPoint( rotatedPolarPoint);
   diffPoint         = CGPointMake( rotatedPoint.x - centerPoint.x,
                                    rotatedPoint.y - centerPoint.y);
   patternRect.origin.x -= diffPoint.x;
   patternRect.origin.y -= diffPoint.y;
   return( patternRect.origin);
}


CGPoint  CGRectGetCenterPointAtAngleWithScaling( CGRect patternRect,
                                                 CAAngleRadians angle,
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
   rotatedPolarPoint = CAPolarPointAddAngle( centerPolarPoint, angle);
   rotatedPoint      = CGPointMakeWithPolarPoint( rotatedPolarPoint);
   diffPoint         = CGPointMake( rotatedPoint.x - centerPoint.x,
                                    rotatedPoint.y - centerPoint.y);
   patternRect.origin.x -= diffPoint.x * scaleFactor.dx;
   patternRect.origin.y -= diffPoint.y * scaleFactor.dy;
   return( patternRect.origin);
}


static CGAffineTransform   textureMapperTransform( CGRect rect,
                                                   CGFloat angle,
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
   rotate        = CGAffineTransformMakeRotationInline( angle);
   translate     = CGAffineTransformMakeTranslationInline( rect.origin.x, rect.origin.y);
   paint         = CGAffineTransformConcatInline( rotate, translate);

   //combined = CGAffineTransformConcat( current, paint);
   shader        = CGAffineTransformInvertInline( paint);

   // actual shader code is:
   // "     // Calculate color fron texture\n"
   // "     vec2 texturePoint = (shader * vec3( vertex,1.0)).xy / extent;\n"
   // "     vec4 color = texture2D( image, texturePoint);\n"

   textureScale  = CGAffineTransformMakeScaleInline( 1.0 / extent.width, 1.0 / extent.height);
   fragment      = CGAffineTransformConcatInline( shader, textureScale);

   return( fragment);
}


//
// rect should not be changed, it's the rectangle to draw
// bitmapSize should also be the correct max imageSize
//
CGAffineTransform   CGRectReverseImageMapperTransform( CGRect rect,
                                                       CGFloat angle,
                                                       CGSize extent,
                                                       CGSize imageSize)
{
   CGAffineTransform   fragment;
   CGAffineTransform   bitmapScale;
   CGAffineTransform   combined;
   CGAffineTransform   reverse;

   fragment      = textureMapperTransform( rect, angle, extent);

   bitmapScale   = CGAffineTransformMakeScaleInline( imageSize.width, imageSize.height);
   combined      = CGAffineTransformConcatInline( fragment, bitmapScale);
   reverse       = CGAffineTransformInvertInline( combined);

   return( reverse);
}


//static CGPoint  CGRectGetOriginToCenterForAngleAndExtent( CGRect rect,
//                                                          CAAngleRadians angle,
//                                                          CGSize extent)
//{
//   CGPoint             imageCenterPoint;
//   CGPoint             rotatedPoint;
//   CGPoint             rotatedOrigin;
//   CGPoint             centerPoint;
//   CGSize              diff;
//   CGAffineTransform   xform;
//   CGPoint             patternPoint;
//   CGRect              centeredRect;
//
//   fprintf( stderr, "rect=%s angle=%.3f extent=%s\n",
//         CGRectUTF8String( rect), CAAngleRadiansToDegrees( angle), CGSizeUTF8String( extent));
//
//   // xform should place texture at center so
//   //rect.origin        = CGRectGetCenterPoint( rect);
//
//   // if we draw unscaled and unangled, the image will be at top/left
//   // so when we then calculate the imageCenter this will not be the center
//   // of the drawing.
//   // So we first have to fake the rect to be in the center of the drawing.
//   centeredRect       = CGSizeCenterInRect( extent, rect);
//   fprintf( stderr, "centeredRect     : %s\n", CGRectUTF8String( centeredRect));
//   centerPoint        = CGRectGetCenterPoint( centeredRect);
//   fprintf( stderr, "centerPoint      : %s\n", CGPointUTF8String( centerPoint));
//
//   xform              = textureMapperTransform( centeredRect, angle, extent);
//   xform              = CGAffineTransformInvert( xform);
//
//   // now when we apply the transform to the center point of the texture
//   // we get a rotated point, which can lie outside of centered rect (no problem)
//   rotatedPoint       = CGPointApplyAffineTransform( CGPointMake( 0.5, 0.5), xform);
//   fprintf( stderr, "rotatedPoint     : %s\n", CGPointUTF8String( rotatedPoint));
//
//   // rotatedPoint is the center of the texture, which we want to place in the
//   // middle of the pattern. The extent is the size of the texture in  the
//   // shader. Within "extent" texture coordinates are valid outside of the
//   // extent they clamp.
//   //
//   // The shader will scan (pseudo code)
//   // for( y = CGRectMinY( rect); y <= CGRectMaxY( rect); y++)
//   //    for( x = CGRectMinX( rect); x <= CGRectMaxX( rect); x++)
//   // {
//   //    texture.x = x - patternRect.origin.x;
//   //    texture.y = y - patternRect.origin.y;
//   //    texture.x /= extent.size;
//   //    texture.y /= extent.width;
//   //    if( texture.x < 0.0) texture.x = 0.0;
//   //    if( texture.x > 1.0) texture.x = 1.0;
//   //    if( texture.y < 0.0) texture.y = 0.0;
//   //    if( texture.y > 1.0) texture.y = 1.0;
//   //    color = image[ texture.y * image.height][ texture.x * image.width]
//   // }
//   rotatedOrigin.x = (rotatedPoint.x - (extent.width / 2.0));
//   rotatedOrigin.y = (rotatedPoint.y - (extent.height / 2.0));
//   fprintf( stderr, "rotatedOrigin    : %s\n", CGPointUTF8String( rotatedOrigin));
//
//   patternPoint = CGPointMake( centeredRect.origin.x - (extent.width / 2.0) + (centerPoint.x - rotatedOrigin.x),
//                               centeredRect.origin.y - (extent.height / 2.0) + (centerPoint.y - rotatedOrigin.y)); // + rotatedOrigin.y);/*
//
//   fprintf( stderr, "patternPoint     : %s\n\n", CGPointUTF8String( patternPoint));
//   return( patternPoint);
//}
//


CGPoint  CGRectGetOriginToTexturePointForAngleAndExtent( CGRect rect,
                                                         CGPoint texturePoint,
                                                         CAAngleRadians angle,
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
         CGRectUTF8String( rect), CAAngleRadiansToDegrees( angle), CGSizeUTF8String( extent));
#endif

   // xform should place texture at center so
   //rect.origin        = CGRectGetCenterPoint( rect);

   // if we draw unscaled and unangled, the image will be at top/left
   // so when we then calculate the imageCenter this will not be the center
   // of the drawing.
   // So we first have to fake the rect to be in the center of the drawing.
   centeredRect      = rect;
#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "centeredRect     : %s\n", CGRectUTF8String( centeredRect));
#endif   

   centerPoint        = CGRectGetCenterPoint( centeredRect);
#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "centerPoint      : %s\n", CGPointUTF8String( centerPoint));
#endif   

   xform              = textureMapperTransform( centeredRect, angle, extent);
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


static CGPoint  CGRectGetOriginToCenterForAngleAndExtent( CGRect rect,
                                                          CAAngleRadians angle,
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
         CGRectUTF8String( rect), CAAngleRadiansToDegrees( angle), CGSizeUTF8String( extent));
#endif
   // xform should place texture at center so
   //rect.origin        = CGRectGetCenterPoint( rect);

   // if we draw unscaled and unangled, the image will be at top/left
   // so when we then calculate the imageCenter this will not be the center
   // of the drawing.
   // So we first have to fake the rect to be in the center of the drawing.
   centeredRect      = rect;
#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "centeredRect     : %s\n", CGRectUTF8String( centeredRect));
#endif
   centerPoint        = CGRectGetCenterPoint( centeredRect);
#ifdef DRAWABLE_DEBUG
   fprintf( stderr, "centerPoint      : %s\n", CGPointUTF8String( centerPoint));
#endif
   xform              = textureMapperTransform( centeredRect, angle, extent);
   xform              = CGAffineTransformInvert( xform);

   // now when we apply the transform to the center point of the texture
   // we get a rotated point, which can lie outside of centered rect (no problem)
   rotatedPoint       = CGPointApplyAffineTransform( CGPointMake( 0.5, 0.5), xform);
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


static NSInteger   CGBitmapDrawableGetImageID( id <CGBitmapDrawable> self, 
                                               CGDrawableOptions *options,
                                               CGContext *context)
{
   NSInteger    imageFlags;
   NSInteger    textureID;
   CGImage      *image;

   // if we are a CGImage we can't really change, but a UIBitmapImage can
   imageFlags = [self imageFlags];
   if( options->flags.repeat != CGRepeatAsIs)
   {
      imageFlags  &= ~(NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY);
      if( options->flags.repeat & CGRepeatHorizontally)
         imageFlags |= NVG_IMAGE_REPEATX;
      if( options->flags.repeat & CGRepeatVertically)
         imageFlags |= NVG_IMAGE_REPEATY;
   }

   image = [self cgImageWithContext:context
                         imageFlags:imageFlags];

   if( ! image)
      return( -1);

   textureID = [image textureID];

   assert( textureID != -1);
   return( textureID);
}


static CGSize   CGBitmapDrawableGetBitmapExtent( id <CGBitmapDrawable> self, 
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


void  CGBitmapDrawableDrawRect( id <CGBitmapDrawable> self,
                                CGRect rect,
                                CGPoint origin,
                                CGSize extent,
                                CGDrawableOptions *options,
                                CGContext *context)
{
   NVGpaint     imgPaint;
   NVGcontext   *vg;
   NSInteger    textureID;

   vg = CGContextGetNVGContext( context);

   if( options->flags.flip & CGFlipHorizontally)
   {
      origin.x         += rect.size.width;
      rect.origin.x    += rect.size.width;
      rect.size.width  *= -1.0;
      extent.width     *= -1.0;
   }

   if( options->flags.flip & CGFlipVertically)
   {
      origin.y         += rect.size.height;
      rect.origin.y    += rect.size.height;
      rect.size.height *= -1.0;
      extent.height    *= -1.0;
   }

   textureID = CGBitmapDrawableGetImageID( self, options, context);
   if( textureID == -1)
   {
#ifdef DEBUG
      abort();      
#endif      
      return;  
   }

   // what this does is:
   // origin is subtracted from rect.origin.x to get an initial value
   // extent divides the resultant value, if we get a value between 0.0 and 1.0
   // it's a valid texture.
   //
   imgPaint  = nvgImagePattern( vg, origin.x,
                                    origin.y,
                                    extent.width,
                                    extent.height,
                                    options->rotation,
                                    textureID,
                                    options->alpha);

   nvgBeginPath( vg);
   nvgRoundedRect( vg, rect.origin.x,
                       rect.origin.y,
                       rect.size.width,
                       rect.size.height,
                       options->cornerRadius);
   nvgFillPaint( vg, imgPaint);
   nvgFill( vg);   
}


- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   CGSize   extent;
   CGPoint  origin;
   CGRect   placedRect;

   if( ! options)
      options = &CGDrawableOptionsDefault;

   extent = CGBitmapDrawableGetBitmapExtent( self, rect.size, [self size], options);

   //
   // the nvg texture rotation is around the top left corner, but that's
   // never useful (IMO), so we use the center point instead, except if we
   // know we fill the whole texture anyway (and don't rotate)
   // 
   if( options->rotation != 0.0 || options->scale != CGScaleToFit)
   {
      placedRect = CGSizePlaceInRect( extent, rect, options->flags.contentMode);
      origin     = CGRectGetOriginToCenterForAngleAndExtent( placedRect, options->rotation, extent);
   }
   else
      origin = rect.origin;

   CGBitmapDrawableDrawRect( self, rect, origin, extent, options, context);
}


- (void) drawRect:(CGRect) rect
         fromRect:(CGRect) fromRect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   CGPoint             origin;
   CGSize              size;
   CGSize              extent;
   CGRect              sectionRect;
   CGAffineTransform   xform;
   CGPoint             texturePoint;

   if( ! options)
      options = &CGDrawableOptionsScaleToFit;

   size        = [self size];
   xform       = CGRectReverseImageMapperTransform( rect, options->rotation, rect.size, size);
   // if fromRect is { CGPointZero, [self size] }, then sectionRect should be
   // exactly rect, otherwise we get a subsection of rect
   sectionRect = CGRectApplyAffineTransform( fromRect, xform);

//
//  +----------+
//  |          |  
//  |  +       |
//  |          |
//  |          | 
//  +----------+
//
   // reduce extent to fromRect.size
   extent.width  = rect.size.width  * (rect.size.width / sectionRect.size.width);
   extent.height = rect.size.height * (rect.size.height / sectionRect.size.height);

   assert( options->scale == CGScaleToFit);
   assert( options->flags.repeat      == CGRepeatNone);
   assert( options->flags.contentMode == CGContentModeCenterPoint);

   // get fromOrigin texture coordinate
   texturePoint.x = (CGRectGetMidX( sectionRect) - rect.origin.x) / rect.size.width;
   texturePoint.y = (CGRectGetMidY( sectionRect) - rect.origin.y) / rect.size.height;

   origin = CGRectGetOriginToTexturePointForAngleAndExtent( rect, texturePoint, options->rotation, extent);

   // punkt: 

   CGBitmapDrawableDrawRect( self, rect, origin, extent, options, context);
}


- (void *) bytes
{
   return( NULL);
}


- (NSUInteger) imageFlags 
{
   return( 0);
}


- (BOOL) isRepeating   
{
   return( [self imageFlags] & (NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY) ? YES : NO);
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
