#ifndef microvg_nanowrap_h__
#define microvg_nanowrap_h__


#include "nanovg.h"

#include <mulle-c11/mulle-c11-bool.h>
#include <mulle-c11/mulle-c11-integer.h>

#include <assert.h>

#include "CGTypes.h"


// This is the nanovg header wrapped for mulle-geometry and mulle-color types.
// In order to not have to "think" too much which functions are available in
// microvg and which in nanovg, all other functions that are available in
// nanovg are wrapped so mvgBeginFrame is just the same as nvgBeginFrame.
//
// But mvgRect takes a CGRect instead of four floats for example.
// For you convenience all const types have been removed.

// None of the functions check incoming parameters, some may assert. It's
// assumed that those checks are done in the caller. Technically all the
// mvg functions should therefore be _mvg functions, maybe they will at some
// point in time (but the nvg will remain, so.. whats the use)
//
// Almost all nanovg functions are wrapped here for use with mulle-gfx
// geometry. Some functions with pointer parameter return values are changed
// to return structs now...
//
// x,y            -> CGPoint
// w,h            -> CGSize
// dy,dy          -> CGVector
// x,y,w,h        -> CGRect
// float[6] xform -> CGAffineTransform
// nvgColor       -> CGColor
// radians        -> CARotation (!!! not radians)
//
// A few functions may change parameter order (mostly gradient related stuff).
// A few functions may "fix" stuff nvg does wrong. There are no "return"
// by reference functions i.e. float *fontSize, because javascript won't like
// it.
//
typedef NSInteger    CGTextureID;
typedef NSUInteger   CGShaderID;    // 0 is invalid
typedef NSInteger    CGFontID;      // -1 == invalid

#define CGFontIDInvalid      -1  // FONS_INVALID
#define CGShaderIDInvalid    0
#define CGTextureIDInvalid   0



typedef struct CGTextBoundsInfo
{
   CGRect   bounds;
   float    size;    // can be fontPixelSize or width depending on use (:-/)
} CGTextBoundsInfo;

#define CGTextBoundsInfoNull \
   (CGTextBoundsInfo) { .bounds = CGRectNull, .size = 0.0 }

static inline CGTextBoundsInfo   CGTextBoundsInfoMake( CGRect rect, float size)
{
   return( (CGTextBoundsInfo) { .bounds = rect, .size = size });
}


struct UIGlyphPosition;
struct UITextRow;


// Begin drawing a new frame
// Calls to nanovg drawing API should be wrapped in nvgBeginFrame() & nvgEndFrame()
// nvgBeginFrame() defines the size of the window to render to in relation currently
// set viewport (i.e. glViewport on GL backends). Device pixel ration allows to
// control the rendering on Hi-DPI devices.
// For example, GLFW returns two dimension for an opened window: window size and
// frame buffer size. In that case you would set windowWidth/Height to the window size
// devicePixelRatio to: frameBufferWidth / windowWidth.
//
static inline void   mvgBeginFrame( NVGcontext *vg, CGSize windowSize, CGFloat devicePixelRatio)
{
   nvgBeginFrame( vg, windowSize.width, windowSize.height, devicePixelRatio);
}

// Cancels drawing the current frame.
static inline void   mvgCancelFrame( NVGcontext *vg)
{
   nvgCancelFrame( vg);
}

// Ends drawing flushing remaining render state.
static inline void   mvgEndFrame( NVGcontext *vg)
{
   nvgEndFrame( vg);
}

//
// Composite operation
//
// The composite operations in NanoVG are modeled after HTML Canvas API, and
// the blend func is based on OpenGL (see corresponding manuals for more info).
// The colors in the blending state have premultiplied alpha.

// Sets the composite operation. The op parameter should be one of NVGcompositeOperation.
// Composite operation.
static inline void   mvgGlobalCompositeOperation( NVGcontext *vg, NSInteger op)
{
   nvgGlobalCompositeOperation( vg, op);
}

// Composite operation with custom pixel arithmetic.
static inline void   mvgGlobalCompositeBlendFunc( NVGcontext *vg, 
                                                  NSUInteger sfactor,
                                                  NSUInteger dfactor)
{
   nvgGlobalCompositeBlendFunc( vg, sfactor, dfactor);
}

// Composite operation with custom pixel arithmetic for RGB and alpha components separately.
static inline void   mvgGlobalCompositeBlendFuncSeparate( NVGcontext *vg, 
                                                          NSUInteger srcRGB,
                                                          NSUInteger dstRGB,
                                                          NSUInteger srcAlpha,
                                                          NSUInteger dstAlpha)
{
   nvgGlobalCompositeBlendFuncSeparate( vg, srcRGB, dstRGB, srcAlpha, dstAlpha);
}



//
// State Handling
//
// NanoVG contains state which represents how paths will be rendered.
// The state contains transform, fill and stroke styles, text and font styles,
// and scissor clipping.

// Pushes and saves the current render state into a state stack.
// A matching nvgRestore() must be used to restore the state.

// Sets the transparency applied to all rendered shapes.
// Pushes and saves the current render state into a state stack.
static inline void   mvgSave( NVGcontext *vg)
{
   nvgSave( vg);
}


// Pops and restores the current render state from the state stack.
static inline void   mvgRestore( NVGcontext *vg)
{
   nvgRestore( vg);
}


// Resets current render state to default values. Does not affect the render state stack.
static inline void  mvgReset( NVGcontext *vg)
{
   nvgReset( vg);
}

//
// Render styles
//
// Fill and stroke render style can be either a solid color or a paint which is a gradient or a pattern.
// Solid color is simply defined as a color value, different kinds of paints can be created
// using nvgLinearGradient(), nvgBoxGradient(), nvgRadialGradient() and nvgImagePattern().
//
// Current render style can be saved and restored using nvgSave() and nvgRestore().

// Sets whether to draw antialias for nvgStroke() and nvgFill(). It's enabled by default.
static inline void   mvgShapeAntiAlias( NVGcontext *vg, BOOL enable)
{
   nvgShapeAntiAlias( vg, (int) enable);
}

// Sets the stroke style.
static inline void   mvgStrokeColor( NVGcontext *vg, CGColor color)
{
   nvgStrokeColor( vg, color);
}

// Sets the stroke style with a paint.
static inline void   mvgStrokePaint( NVGcontext *vg, NVGpaint paint)
{
   nvgStrokePaint( vg, paint);
}

// Sets the fill style.
static inline void   mvgFillColor( NVGcontext *vg, CGColor color)
{
   nvgFillColor( vg, color);
}

// Sets the fill style with a paint.
static inline void   mvgFillPaint( NVGcontext *vg, NVGpaint paint)
{
   nvgFillPaint( vg, paint);
}

// Sets the miter limit of the stroke style.
static inline void   mvgMiterLimit( NVGcontext *vg, CGFloat limit)
{
   nvgMiterLimit( vg, limit);
}

// Sets the stroke width of the stroke style.
static inline void   mvgStrokeWidth( NVGcontext *vg, CGFloat size)
{
   assert( size >= 0.0);
   nvgStrokeWidth( vg, size);
}

// Sets the line cap of the stroke style.
static inline void   mvgLineCap( NVGcontext *vg, NSInteger cap)
{
   nvgLineCap( vg, cap);
}

// Sets the line join of the stroke style.
static inline void   mvgLineJoin( NVGcontext *vg, NSInteger join)
{
   nvgLineJoin( vg, join);
}

// Sets the transparency applied to all rendered shapes.
// Already transparent paths will get proportionally more transparent as well.
static inline void   mvgGlobalAlpha( NVGcontext *vg, CGFloat alpha)
{
   nvgGlobalAlpha( vg, alpha);
}



//
// Transforms
//
// The paths, gradients, patterns and scissor region are transformed by an transformation
// matrix at the time when they are passed to the API.
// The current transformation matrix is a affine matrix:
//   [sx kx tx]
//   [ky sy ty]
//   [ 0  0  1]
// Where: sx,sy define scaling, kx,ky skewing, and tx,ty translation.
// The last row is assumed to be 0,0,1 and is not stored.
//
// Apart from nvgResetTransform(), each transformation function first creates
// specific transformation matrix and pre-multiplies the current transformation by it.
//
// Current coordinate system (transformation) can be saved and restored using nvgSave() and nvgRestore().


// Sets the global transform matrix to the result of current render target.
static inline void   mvgResetTransform( NVGcontext *vg)
{
   nvgResetTransform( vg);
}

// Premultiplies current coordinate system by specified matrix.
static inline void   mvgTransform( NVGcontext *vg, CGAffineTransform *xform)
{
   nvgTransform( vg, xform->a, xform->b, xform->c, xform->d, xform->tx, xform->ty);
}

// Translates current coordinate system.
static inline void   mvgTranslate( NVGcontext *vg, CGPoint p)
{
   nvgTranslate( vg, p.x, p.y);
}

// Rotates current coordinate system.
static inline void   mvgRotate( NVGcontext *vg, CARotation rotation)
{
   nvgRotate( vg, CARotationToRadiansAsRotation( rotation));
}

// Skews the current coordinate system along X axis.
static inline void   mvgSkewX( NVGcontext *vg, CAAngle angle)
{
   nvgSkewX( vg, CAAngleToRadians( angle));
}

// Skews the current coordinate system along Y axis.
static inline void   mvgSkewY( NVGcontext *vg, CAAngle angle)
{
   nvgSkewY( vg, CAAngleToRadians( angle));
}

// Scales the current coordinate system.
static inline void   mvgScale( NVGcontext *vg, CGVector v)
{
   nvgScale( vg, v.dx, v.dy);
}


//
// Stores the top part (a-f) of the current transformation matrix in to the specified buffer.
//   [a c e]
//   [b d f]
//   [0 0 1]
// There should be space for 6 CGFloats in the return buffer for the values a-f.
// Sets the current transform to identity matrix.
// Retrieves the current transform matrix.
//
static inline CGAffineTransform   mvgCurrentTransform( NVGcontext *vg)
{
   CGAffineTransform   xform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgCurrentTransform( vg, (float *) &xform);
   return( xform);
}


//
// MEMO: do not use these functions, use CGAffineTransform directly instead
//

#if 0
// Sets the transform to identity matrix.
static inline CGAffineTransform   mvgTransformIdentity( void)
{
   CGAffineTransform   xform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformIdentity( (float *) &xform);
   return( xform);
}


// Sets the transform to translation matrix.
static inline CGAffineTransform   mvgTransformTranslate( CGPoint t)
{
   CGAffineTransform   xform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformTranslate( (float *) &xform, t.x, t.y);
   return( xform);
}

// Sets the transform to scale matrix.
static inline CGAffineTransform   mvgTransformScale( CGVector s)
{
   CGAffineTransform   xform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformScale( (float *) &xform, s.dx, s.dy);
   return( xform);
}


// Sets the transform to rotate matrix. Give a rotation here not an angle.
static inline CGAffineTransform   mvgTransformRotate( CARotation a)
{
   CGAffineTransform   xform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformRotate( (float *) &xform, CARotationToRadians( a));
   return( xform);
}


// Sets the transform to skew-x matrix.
static inline CGAffineTransform   mvgTransformSkewX( CAAngle a)
{
   CGAffineTransform   xform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformSkewX( (float *) &xform, CAAngleToRadians( a));
   return( xform);
}


// Sets the transform to skew-y matrix.
static inline CGAffineTransform   mvgTransformSkewY( CAAngle a)
{
   CGAffineTransform   xform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformSkewY( (float *) &xform, CAAngleToRadians( a));
   return( xform);
}

// Sets the transform to the result of multiplication of two transforms, of A = A*B.
static inline CGAffineTransform   mvgTransformMultiply( CGAffineTransform *aform,
                                                        CGAffineTransform *bform)
{
   CGAffineTransform   xform = *aform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformMultiply( (float *) &xform, (float *) bform);
   return( xform);
}


// Sets the transform to the result of multiplication of two transforms, of A = B*A.
static inline CGAffineTransform   mvgTransformPremultiply( CGAffineTransform *aform,
                                                           CGAffineTransform *bform)
{
   CGAffineTransform   xform = *aform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformPremultiply( (float *) &xform, (float *) bform);
   return( xform);
}


// Sets the destination to inverse of specified transform.
// Returns 1 if the inverse could be calculated, else 0.
static inline CGAffineTransform   mvgTransformInverse( CGAffineTransform *aform)
{
   CGAffineTransform   xform = *aform;

   assert( sizeof( CGAffineTransform) == sizeof( float) * 6);

   nvgTransformInverse( (float *) &xform, (float *) aform);
   return( xform);
}


// Sets the current transform to the result of A * B.
static inline CGPoint   mvgTransformPoint( CGAffineTransform *xform, CGPoint point)
{
   float   dstx, dsty;

   nvgTransformPoint( &dstx, &dsty, (float *) xform, point.x, point.y);
   return( CGPointMake( dstx, dsty));
}
#endif

//
// Images
//
// NanoVG allows you to load jpg, png, psd, tga, pic and gif files to be used for rendering.
// In addition you can upload your own image. The image loading is provided by stb_image.
// The parameter textureFlags is combination of flags defined in NVGimageFlags.

// Creates image by loading it from the disk from specified file name.
// Returns handle to the image
// Creates image by loading it from the disk from specified file name.
static inline CGTextureID   mvgCreateImage( NVGcontext *vg,
                                            char *filename,
                                            NSUInteger textureFlags)
{
   assert( filename);

   return( nvgCreateImage( vg, filename, textureFlags));
}


// Creates image by loading it from the specified chunk of memory.
static inline CGTextureID   mvgCreateImageMem( NVGcontext *vg,
                                               NSInteger textureFlags,
                                               void *data,
                                               size_t ndata)
{
   assert( data);

   return( nvgCreateImageMem( vg, textureFlags, data, ndata));
}


// Creates image from specified image data.
static inline CGTextureID   mvgCreateImageRGBA( NVGcontext *vg,
                                                NSInteger w,
                                                NSInteger h,
                                                NSUInteger textureFlags,
                                                void *data)
{
   assert( data);

   return( nvgCreateImageRGBA( vg, w, h, textureFlags, data));
}


// Updates image data specified by image handle.
static inline void   mvgUpdateImage( NVGcontext *vg, CGTextureID image, void *data)
{
   assert( image != CGTextureIDInvalid);
   assert( data);

   nvgUpdateImage( vg, image, (const unsigned char *) data);
}


// Returns the dimensions of a created image.
static inline CGPixelSize  mvgImageSize( NVGcontext *vg, CGTextureID image)
{
   int   w, h;

   assert( image != CGTextureIDInvalid);
   nvgImageSize( vg, image, &w, &h);
   return( CGPixelSizeMake( w, h));
}


// Deletes created image.
static inline void   mvgDeleteImage( NVGcontext *vg, CGTextureID image)
{
   assert( image != CGTextureIDInvalid);
   nvgDeleteImage( vg, image);
}


//
// Paints
//
// NanoVG supports four types of paints: linear gradient, box gradient, radial gradient and image pattern.
// These can be used as paints for strokes and fills.

// Creates and returns a linear gradient. Parameters (sx,sy)-(ex,ey) specify the start and end coordinates
// of the linear gradient, icol specifies the start color and ocol the end color.
// The gradient is transformed by the current transform when it is passed to nvgFillPaint() or nvgStrokePaint().
// Paints

static inline NVGpaint   mvgLinearGradient( NVGcontext *vg,
                                            CGPoint start,
                                            CGColor startColor,
                                            CGPoint end,
                                            CGColor endColor)
{
   return( nvgLinearGradient( vg, start.x,
                                  start.y,
                                  end.x,
                                  end.y,
                                  startColor,
                                  endColor));
}

//
// Creates and returns a box gradient. Box gradient is a feathered rounded
// rectangle, it is useful for rendering drop shadows or highlights for boxes.
// Feather defines how blurry the border of the rectangle is.
// Parameter color specifies the inner color and featherColor the outer color
// of the gradient.
// The gradient is transformed by the current transform when it is passed to
// nvgFillPaint() or nvgStrokePaint().
// This function "fixes" the behavior of the original box gradient, where you
// had to manually correct "rect" for the feather value.
//
static inline NVGpaint   mvgBoxGradient( NVGcontext *vg,
                                         CGRect rect,
                                         CGFloat cornerRadius,
                                         CGColor color,
                                         CGFloat feather,
                                         CGColor featherColor)
{
   CGRect   gradientRect;

   gradientRect = CGRectInset( rect, feather / 4.0, feather / 4.0);
   return( nvgBoxGradient( vg, gradientRect.origin.x,
                               gradientRect.origin.y,
                               gradientRect.size.width,
                               gradientRect.size.height,
                               cornerRadius,
                               feather,
                               color,
                               featherColor));
}

//
// Creates and returns a radial gradient.
// The radial gradient fills circle with color. Specify an innerRadius with
// an innerColor for the gradient.
// The gradient is transformed by the current transform when it is passed
// to nvgFillPaint() or nvgStrokePaint().
//
// This function is quite unlike `nvgRadialGradient` in terms of parameter
// order. `nvgRadialGradient` is sort of inner circle first than outer circle,
// which I find counter intuitive.
//
static inline NVGpaint   mvgRadialGradient( NVGcontext *vg,
                                            CACircle circle,
                                            CGColor outerColor,
                                            CGFloat innerRadius,
                                            CGColor innerColor)
{
   return( nvgRadialGradient( vg, circle.center.x,
                                  circle.center.y,
                                  innerRadius,
                                  circle.radius,
                                  innerColor,
                                  outerColor));
}

// Creates and returns an image pattern. Parameters the location and size of
// one image, angle rotation around the top-left corner, image is handle to
// the image to render. Because the angle rotation is around the left corner
// and not the center, the rotation will rarely do what you want it to, so
// use CGImage instead.
// The gradient is transformed by the current transform when it is passed to
// nvgFillPaint() or nvgStrokePaint().
//
static inline NVGpaint   mvgImagePattern( NVGcontext *vg,
                                          CGTextureID image,
                                          CGRect rect,
                                          CARotation rotation,
                                          CGFloat alpha)
{
   assert( image != CGTextureIDInvalid);

   return( nvgImagePattern( vg, rect.origin.x,
                                rect.origin.y,
                                rect.size.width,
                                rect.size.height,
                                CARotationToRadiansAsRotation( rotation),
                                image,
                                alpha));
}



//
// Scissoring
//
// Scissoring allows you to clip the rendering into a rectangle. This is
// useful for various user interface cases like rendering a text edit or a
// timeline.



// Sets the current scissor rectangle.
// The scissor rectangle is transformed by the current transform.
static inline void   mvgScissor( NVGcontext *vg, CGRect rect)
{
   nvgScissor( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

// Intersects current scissor rectangle with the specified rectangle.
// The scissor rectangle is transformed by the current transform.
// Note: in case the rotation of previous scissor rect differs from
// the current one, the intersection will be done between the specified
// rectangle and the previous scissor rectangle transformed in the current
// transform space. The resulting shape is always rectangle.
static inline void   mvgIntersectScissor( NVGcontext *vg, CGRect rect)
{
   nvgIntersectScissor( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}


// Reset and disables scissoring.
static inline void   mvgResetScissor( NVGcontext *vg)
{
   nvgResetScissor( vg);
}


//
// Paths
//
// Drawing a new shape starts with nvgBeginPath(), it clears all the currently defined paths.
// Then you define one or more paths and sub-paths which describe the shape. The are functions
// to draw common shapes like rectangles and circles, and lower level step-by-step functions,
// which allow to define a path curve by curve.
//
// NanoVG uses even-odd fill rule to draw the shapes. Solid shapes should have counter clockwise
// winding and holes should have counter clockwise order. To specify winding of a path you can
// call nvgPathWinding(). This is useful especially for the common shapes, which are drawn CCW.
//
// Finally you can fill the path using current fill style by calling nvgFill(), and stroke it
// with current stroke style by calling nvgStroke().
//
// The curve segments and sub-paths are transformed by the current transform.

// Clears the current path and sub-path
static inline void   mvgBeginPath( NVGcontext *vg)
{
   nvgBeginPath( vg);
}

// Starts new sub-path with specified point as first point.
static inline void   mvgMoveTo( NVGcontext *vg, CGPoint point)
{
   nvgMoveTo( vg, point.x, point.y);
}

// Adds line segment from the last point in the path to the specified point.
static inline void   mvgLineTo( NVGcontext *vg, CGPoint point)
{
   nvgLineTo( vg, point.x, point.y);
}

// Adds cubic bezier segment from last point in the path via two control points to the specified point.
static inline void   mvgBezierTo( NVGcontext *vg, CGPoint control1, CGPoint control2, CGPoint point)
{
   nvgBezierTo( vg, control1.x, control1.y, control2.x, control2.y, point.x, point.y);
}

// Adds quadratic bezier segment from last point in the path via a control point to the specified point.
static inline void   mvgQuadTo( NVGcontext *vg, CGPoint control, CGPoint point)
{
   nvgQuadTo( vg, control.x, control.y, point.x, point.y);
}

// Adds an arc segment at the corner defined by the last path point, and two specified points.
static inline void   mvgArcTo( NVGcontext *vg, CGPoint tangent1, CGPoint tangent2, CGFloat radius)
{
   nvgArcTo( vg, tangent1.x, tangent1.y, tangent2.x, tangent2.y, radius);
}

// Closes current sub-path with a line segment.
static inline void   mvgClosePath( NVGcontext *vg)
{
   nvgClosePath( vg);
}


// Sets the current sub-path winding, see NVGwinding and NVGsolidity.
static inline void   mvgPathWinding( NVGcontext *vg, CGPathFillStyle style)
{
   assert( CGPathFillStyleSolid == style || CGPathFillStyleHole == style);

   nvgPathWinding( vg, style == CGPathFillStyleSolid ? NVG_SOLID: NVG_HOLE);
}


// Creates new circle arc shaped sub-path, unless ther is no rotation from the
// starting angle, then we just move the point
static inline void
   mvgArc( NVGcontext *vg, CACircle circle, CAAngle angle, CARotation rotation)
{
   if( fabsf( rotation) < CA_EPSILON)
   {
      mvgMoveTo( vg, CACirclePointAtAngle( circle, angle));
      return;
   }

   nvgArc( vg, circle.center.x,
               circle.center.y,
               circle.radius,
               CAAngleToRadians( angle),
               CAAngleRotateToRadiansAsAngle( angle, rotation),
               CARotationGetRotationDirection( rotation));
}


// Creates new rectangle shaped sub-path.
static inline void   mvgRect( NVGcontext *vg, CGRect rect)
{
   nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}


//
// mvgRoundedRectVarying function accepts negative insets
//
static inline void   mvgRoundedRectVarying( NVGcontext *vg,
                                            CGRect rect,
                                            struct MulleCornerInsets insets)
{
// nvgRoundedRectVarying_alternative is defined in nanovg-extensions.inc
   void nvgRoundedRectVarying_alternative( NVGcontext *vg, float x, float y, float w, float h,
                                            float radTopLeft, float radTopRight,
                                            float radBottomRight, float radBottomLeft);

   nvgRoundedRectVarying_alternative( vg, rect.origin.x,
                                      rect.origin.y,
                                      rect.size.width,
                                      rect.size.height,
                                      insets.topLeft,
                                      insets.topRight,
                                      insets.bottomRight,
                                      insets.bottomLeft);
}

// Creates new rounded rectangle shaped sub-path.
// this function accepts negative radius
static inline void   mvgRoundedRect( NVGcontext *vg, CGRect rect, CGFloat r)
{
   mvgRoundedRectVarying( vg, rect, MulleCornerInsetsMakeWithCornerRadius( r));
}


// Creates new ellipse shaped sub-path.
static inline void   mvgEllipse( NVGcontext *vg, CGPoint center, CGFloat rx, CGFloat ry)
{
   nvgEllipse( vg, center.x, center.y, rx, ry);
}

// Creates new circle shaped sub-path.
static inline void   mvgCircle( NVGcontext *vg, CACircle circle)
{
   nvgCircle( vg, circle.center.x, circle.center.y, circle.radius);
}

// Fills the current path with current fill style.
static inline void   mvgFill( NVGcontext *vg)
{
   nvgFill( vg);
}

// Fills the current path with current stroke style.
static inline void   mvgStroke( NVGcontext *vg)
{
   nvgStroke( vg);
}

// Creates font by loading it from the disk from specified file name.
static inline CGFontID   mvgCreateFont( NVGcontext *vg, char *name, char *filename)
{
   assert( name);
   assert( filename);

   return nvgCreateFont( vg, name, filename);
}

// Creates font by loading it from the specified memory chunk.
static inline CGFontID   mvgCreateFontMem( NVGcontext *vg, 
                                           char *name,
                                           void * data, 
                                           size_t length,
                                           BOOL freeData)
{
   assert( data);

   return( nvgCreateFontMem( vg, name, data, length, freeData));
}

// Finds a loaded font of specified name, and returns handle to it, or -1 if the font is not found.
static inline CGFontID   mvgFindFont( NVGcontext *vg, char *name)
{
   return( nvgFindFont( vg, name));
}


// Adds a fallback font by handle.
static inline CGFontID   mvgAddFallbackFontId( NVGcontext *vg,
                                               CGFontID baseFont,
                                               CGFontID fallbackFont)
{
   assert( baseFont != CGFontIDInvalid);
   assert( fallbackFont != CGFontIDInvalid);

   return nvgAddFallbackFontId( vg, baseFont, fallbackFont);
}


// Adds a fallback font by name.
static inline CGFontID   mvgAddFallbackFont( NVGcontext *vg,
                                             char *baseFont,
                                             char *fallbackFont)
{
   assert( baseFont);
   assert( fallbackFont);

   return nvgAddFallbackFont( vg, (const char *) baseFont, (const char *) fallbackFont);
}


// Resets fallback fonts by handle.
static inline void   mvgResetFallbackFontsId( NVGcontext *vg, NSInteger baseFont)
{
   nvgResetFallbackFontsId( vg, baseFont);
}


// Resets fallback fonts by name.
static inline void   mvgResetFallbackFonts( NVGcontext *vg, char *baseFont)
{
   nvgResetFallbackFonts( vg, baseFont);
}


static inline CGFloat  mvgRoundedFontSize( CGFloat size)
{
   NSUInteger   tenth = (NSUInteger) 10 * size;

   if( tenth < 10)
      tenth = 10;             // not less than 1pt
   if( tenth >= 2044 * 10)    // not more than 2044pt only one char per atlas!
      tenth = 2044 * 10;
   size = tenth / 10.0f;
   return( size);
}


// Sets the font size of current text style.
// FreeType is like 1/64 rez, but nanovg is only 1/10
//
static inline CGFloat  mvgFontSize( NVGcontext *vg, CGFloat size)
{
   CGFloat   computed;

   computed = mvgRoundedFontSize( size);
   nvgFontSize( vg, computed);
   return( computed);
}

// Sets the blur of current text style.
static inline void   mvgFontBlur( NVGcontext *vg, CGFloat blur)
{
   nvgFontBlur( vg, blur);
}

// Sets the letter spacing of current text style.
static inline void   mvgTextLetterSpacing( NVGcontext *vg, CGFloat spacing)
{
   nvgTextLetterSpacing( vg, spacing);
}

// Sets the line height of current text style.
static inline void   mvgTextLineHeight( NVGcontext *vg, CGFloat lineHeight)
{
   nvgTextLineHeight( vg, lineHeight);
}

// Sets the text align of current text style.
static inline void   mvgTextAlign( NVGcontext *vg, CGCombinedTextAlign align)
{
   assert( CGTextAlignIsValid( align));

   nvgTextAlign( vg, align);
}

// Sets the font face based on specified id(font handle).
static inline void   mvgFontFaceId( NVGcontext *vg, CGFontID fontID)
{
   nvgFontFaceId( vg, fontID);
}

// Sets the font face based on specified name.
static inline void   mvgFontFace( NVGcontext *vg, char *fontname)
{
   nvgFontFace( vg, fontname);
}

// Draws text string at specified location.
static inline CGFloat   mvgText( NVGcontext *vg,
                                 CGPoint point,
                                 char *s,
                                 size_t length)
{
   char   *end;

   assert( s);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   return( nvgText( vg, point.x, point.y, s, end));
}


// void nvgTextBox(NVGcontext* ctx, float x, float y, float breakRowWidth, const char* string, const char* end)

static inline void   mvgTextBox( NVGcontext *vg,
                                 CGPoint point,
                                 CGFloat breakRowWidth,
                                 char *s,
                                 size_t length)
{
   char   *end;

   end = (length == (size_t) -1) ? NULL : &s[ length];
   nvgTextBox( vg, point.x, point.y, breakRowWidth, s, end);
}


// use after mvgTextColor not before
static inline void   mvgClearType( NVGcontext *vg, BOOL enable)
{
   nvgClearType( vg, (int) enable);
}


static inline void   mvgTextColor( NVGcontext *vg, CGColor color)
{
   nvgTextColor( vg, color);
}

// use after mvgTextColor not before
static inline void   mvgTextBackgroundColor( NVGcontext *vg, CGColor color)
{
   nvgTextBackgroundColor( vg, color);
}


//
// Measures the specified text string and bounding box
// Returns the horizontal advance of the measured text in info.size.
// (i.e. where the next character should drawn).
// Measured values are returned in local coordinate space.
//
static inline CGTextBoundsInfo   mvgTextBounds( NVGcontext *vg,
                                                CGPoint point,
                                                char *s,
                                                size_t length)
{
   float   w;
   float   bounds[ 4];
   char    *end;
   CGRect  bbox;
   
   assert( s);

   end  = (length == (size_t) -1) ? NULL : &s[ length];
   w    = nvgTextBounds( vg, point.x, point.y, s, end, bounds);
   bbox = CGRectMake( bounds[ 0],
                      bounds[ 1],
                      bounds[ 2] - bounds[ 0],
                      bounds[ 3] - bounds[ 1]);
   return( CGTextBoundsInfoMake( bbox, w));
}


static inline CGRect   mvgTextVisualBounds( NVGcontext *vg,
                                            CGPoint point,
                                            char *s,
                                            size_t length)
{
   float  bounds[ 6];
   char   *end;

   assert( s);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   nvgTextVisualBounds( vg, point.x, point.y, s, end, bounds);
   return( CGRectMake( bounds[ 0],
                       bounds[ 1],
                       bounds[ 2] - bounds[ 0],
                       bounds[ 3] - bounds[ 1]));
}



// Measures the specified multi-text string. bbox is not optional.
// Measured values are returned in local coordinate space.
// Measures the specified multi-text string.
static inline void   
   mvgTextBoxBounds( NVGcontext *vg, 
                     CGPoint point, 
                     char *s,
                     size_t length,
                     CGFloat breakRowWidth,
                     CGRect *bbox)
{
   float  bounds[ 4];
   char   *end;

   assert( s);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   nvgTextBoxBounds( vg, point.x, point.y, breakRowWidth, s, end, bounds);
   *bbox = CGRectMake( bounds[ 0],
                       bounds[ 1],
                       bounds[ 2] - bounds[ 0],
                       bounds[ 3] - bounds[ 1]);
}

//
// TODO: what about this ? for javascript. May need another method that
//       returns a malloced area ?
//
// Calculates the glyph x positions of the specified text. If end is specified only the sub-string will be used.
static inline NSUInteger
   mvgTextGlyphPositions( NVGcontext *vg,
                          CGPoint point, 
                          char *s,
                          size_t length,
                          struct UIGlyphPosition* positions,
                          NSInteger maxPositions)
{
   char   *end;

   assert( s);
   assert( positions != NULL || maxPositions == 0);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   return( nvgTextGlyphPositions( vg, point.x, point.y,
                                      s, end,
                                      (NVGglyphPosition *) positions,
                                      maxPositions));
}


static inline NSUInteger   _mvgTextBreakLinesInPlace( NVGcontext *vg,
                                                      char *s,
                                                      size_t length,
                                                      CGFloat breakRowWidth,
                                                      struct UITextRow *rows,
                                                      NSUInteger maxRows,
                                                      size_t textRowSize)
{
   char                *end;
   NSUInteger          count;
   char                *address;
   char                *sentinel;
   struct UITextRow    *p;
   struct NVGtextRow   *nvg_rows;
   struct NVGtextRow   *q;
   float               minx;
   float               maxx;
   float               width;
   NSRange             range;

   assert( s);

   if( maxRows > INT_MAX)
      maxRows = INT_MAX;

   end      = (length == (size_t) -1) ? NULL : &s[ length];
   nvg_rows = (NVGtextRow *) rows;
   count    = nvgTextBreakLines( vg, s,
                                     end,
                                     breakRowWidth,
                                     nvg_rows,
                                     (int) maxRows);

   if( rows)
   {
      // super pedantic, but now we can also have UITextRow being
      // bigger than NVGtextRow and still do it in place

      q        = &nvg_rows[ count];
      address  = &((char *) rows)[ count * textRowSize];
      sentinel = (char *) rows;
      while( address > sentinel)
      {
         address  = &address[ - (int) textRowSize];
         p        = (struct UITextRow *) address;
         --q;

         range    = NSRangeMake( q->start - s, q->end - q->start);
         minx     = q->minx;
         maxx     = q->maxx;
         width    = q->width;

         p->range = range;
         p->minx  = minx;
         p->maxx  = maxx;
         p->width = width;
      }
   }

   return( count);
}


static inline NSUInteger   _mvgTextBreakLinesAlloca( NVGcontext *vg,
                                                    char *s,
                                                    size_t length,
                                                    CGFloat breakRowWidth,
                                                    struct UITextRow *rows,
                                                    NSUInteger maxRows,
                                                    size_t textRowSize)
{
   char                *end;
   NSUInteger          count;
   char                *address;
   char                *sentinel;
   struct UITextRow    *p;
   struct NVGtextRow   *q;

   assert( s);
   assert( rows);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   mulle_alloca_do( nvg_rows, NVGtextRow, maxRows)
   {
      if( maxRows > INT_MAX)
         maxRows = INT_MAX;
      count = nvgTextBreakLines( vg, s,
                                     end,
                                     breakRowWidth,
                                     nvg_rows,
                                     (int) maxRows);


      q        = &nvg_rows[ count];
      address  = &((char *) rows)[ count * textRowSize];
      sentinel = (char *) rows;
      while( address > sentinel)
      {
         address  = &address[ - (int) textRowSize];
         p        = (struct UITextRow *) address;
         --q;

         p->range       = NSRangeMake( q->start - s, q->end - q->start);
         p->minx        = q->minx;
         p->maxx        = q->maxx;
         p->width       = q->width;
      }
   }

   return( count);
}


// Breaks the specified text into lines.
static inline NSUInteger   mvgTextBreakLines( NVGcontext *vg,
                                              char *s,
                                              size_t length,
                                              CGFloat breakRowWidth,
                                              struct UITextRow *rows,
                                              NSUInteger maxRows,
                                              size_t textRowSize)
{
   NSInteger   count;

   assert( s);

   // if we don't write into rows, or rows are large enough
   // do it inplace. MEMO: is this really worth it ?
   if( ! rows || textRowSize >= sizeof( NVGtextRow))
   {
      count = _mvgTextBreakLinesInPlace( vg, s, length,
                                             breakRowWidth,
                                             rows,
                                             maxRows,
                                             textRowSize);
      return( count);
   }

   count = _mvgTextBreakLinesAlloca( vg, s, length,
                                            breakRowWidth,
                                            rows,
                                            maxRows,
                                            textRowSize);
   return( count);
}


// Creates a NanoVG context with specified flags.
static inline NVGcontext * mvgCreateInternal( NVGparams *params)
{
   assert( params);

   return( nvgCreateInternal( params));
}

// Deletes a NanoVG context created with nvgCreateInternal.
static inline void   mvgDeleteInternal( NVGcontext *vg)
{
   nvgDeleteInternal( vg);
}

#endif
