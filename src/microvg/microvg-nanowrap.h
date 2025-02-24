#ifndef microvg_nanowrap_h__
#define microvg_nanowrap_h__


#include "nanovg.h"

#include <mulle-c11/mulle-c11-bool.h>
#include <mulle-c11/mulle-c11-integer.h>


// This is the nanovg header wrapped for mulle-geometry and mulle-color types.
// In order to not have to "think" too much which functions are available in
// microvg and which in nanovg, all other functions that are available in
// nanovg are wrapped so mvgBeginFrame is just the same as nvgBeginFrame.
//
// But mvgRect takes a CGRect instead of four floats for example.
// For you convenience all const types have been removed.
//
typedef NSInteger    CGTextureID;
typedef NSUInteger   CGShaderID;    // 0 is invalid
typedef NSInteger    CGFontID;      // -1 == invalid

#define CGFontIDInvalid      -1  // FONS_INVALID
#define CGShaderIDInvalid    0
#define CGTextureIDInvalid   0



// Begin drawing a new frame
// Calls to nanovg drawing API should be wrapped in nvgBeginFrame() & nvgEndFrame()
// nvgBeginFrame() defines the size of the window to render to in relation currently
// set viewport (i.e. glViewport on GL backends). Device pixel ration allows to
// control the rendering on Hi-DPI devices.
// For example, GLFW returns two dimension for an opened window: window size and
// frame buffer size. In that case you would set windowWidth/Height to the window size
// devicePixelRatio to: frameBufferWidth / windowWidth.
static inline void   mvgBeginFrame( NVGcontext *vg, CGSize windowSize, CGFloat devicePixelRatio)
{
   if( vg)
      nvgBeginFrame( vg, windowSize.width, windowSize.height, devicePixelRatio);
}

// Cancels drawing the current frame.
static inline void   mvgCancelFrame( NVGcontext *vg)
{
   if( vg)
      nvgCancelFrame( vg);
}

// Ends drawing flushing remaining render state.
static inline void   mvgEndFrame( NVGcontext *vg)
{
   if( vg)
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
   if( vg)
      nvgGlobalCompositeOperation( vg, op);
}

// Composite operation with custom pixel arithmetic.
static inline void   mvgGlobalCompositeBlendFunc( NVGcontext *vg, 
                                                  NSUInteger sfactor,
                                                  NSUInteger dfactor)
{
   if( vg)
      nvgGlobalCompositeBlendFunc( vg, sfactor, dfactor);
}

// Composite operation with custom pixel arithmetic for RGB and alpha components separately.
static inline void   mvgGlobalCompositeBlendFuncSeparate( NVGcontext *vg, 
                                                          NSUInteger srcRGB,
                                                          NSUInteger dstRGB,
                                                          NSUInteger srcAlpha,
                                                          NSUInteger dstAlpha)
{
   if( vg)
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
   if( vg)
      nvgSave( vg);
}


// Pops and restores the current render state from the state stack.
static inline void   mvgRestore( NVGcontext *vg)
{
   if( vg)
      nvgRestore( vg);
}


// Resets current render state to default values. Does not affect the render state stack.
static inline void  mvgReset( NVGcontext *vg)
{
   if( vg)
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
   if( vg)
      nvgShapeAntiAlias( vg, (int) enable);
}

// Sets the stroke style.
static inline void   mvgStrokeColor( NVGcontext *vg, CGColor color)
{
   if( vg)
      nvgStrokeColor( vg, color);
}

// Sets the stroke style with a paint.
static inline void   mvgStrokePaint( NVGcontext *vg, NVGpaint paint)
{
   if( vg)
      nvgStrokePaint( vg, paint);
}

// Sets the fill style.
static inline void   mvgFillColor( NVGcontext *vg, CGColor color)
{
   if( vg)
      nvgFillColor( vg, color);
}

// Sets the fill style with a paint.
static inline void   mvgFillPaint( NVGcontext *vg, NVGpaint paint)
{
   if( vg)
      nvgFillPaint( vg, paint);
}

// Sets the miter limit of the stroke style.
static inline void   mvgMiterLimit( NVGcontext *vg, CGFloat limit)
{
   if( vg)
      nvgMiterLimit( vg, limit);
}

// Sets the stroke width of the stroke style.
// If size is -1, then don't do anthing
static inline void   mvgStrokeWidth( NVGcontext *vg, CGFloat size)
{
   if( vg && size >= 0.0)
      nvgStrokeWidth( vg, size);
}

// Sets the line cap of the stroke style.
static inline void   mvgLineCap( NVGcontext *vg, NSInteger cap)
{
   if( vg)
      nvgLineCap( vg, cap);
}

// Sets the line join of the stroke style.
static inline void   mvgLineJoin( NVGcontext *vg, NSInteger join)
{
   if( vg)
      nvgLineJoin( vg, join);
}

// Sets the transparency applied to all rendered shapes.
// Already transparent paths will get proportionally more transparent as well.
static inline void   mvgGlobalAlpha( NVGcontext *vg, CGFloat alpha)
{
   if( vg)
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
   if( vg)
      nvgResetTransform( vg);
}

// Premultiplies current coordinate system by specified matrix.
static inline void   mvgTransform( NVGcontext *vg, CGFloat a, CGFloat b, CGFloat c, CGFloat d, CGFloat e, CGFloat f)
{
   if( vg)
      nvgTransform( vg, a, b, c, d, e, f);
}

// Translates current coordinate system.
static inline void   mvgTranslate( NVGcontext *vg, CGPoint p)
{
   if( vg)
      nvgTranslate( vg, p.x, p.y);
}

// Rotates current coordinate system.
static inline void   mvgRotate( NVGcontext *vg, CARotation rotation)
{
   if( vg)
      nvgRotate( vg, CARotationToRadians( rotation));
}

// Skews the current coordinate system along X axis.
static inline void   mvgSkewX( NVGcontext *vg, CAAngle angle)
{
   if( vg)
      nvgSkewX( vg, CAAngleToRadians( angle));
}

// Skews the current coordinate system along Y axis.
static inline void   mvgSkewY( NVGcontext *vg, CAAngle angle)
{
   if( vg)
      nvgSkewY( vg, CAAngleToRadians( angle));
}

// Scales the current coordinate system.
static inline void   mvgScale( NVGcontext *vg, CGVector v)
{
   if( vg)
      nvgScale( vg, v.dx, v.dy);
}


typedef float   *mvgTransform_t;


// Stores the top part (a-f) of the current transformation matrix in to the specified buffer.
//   [a c e]
//   [b d f]
//   [0 0 1]
// There should be space for 6 CGFloats in the return buffer for the values a-f.
// Sets the current transform to identity matrix.
// Retrieves the current transform matrix.
static inline void   mvgCurrentTransform( NVGcontext *vg, float xform[6])
{
   if( vg)
      nvgCurrentTransform( vg, xform);
}

// Sets the transform to identity matrix.
static inline void   mvgTransformIdentity( float dst[6])
{
   nvgTransformIdentity( dst);
}

// Sets the transform to translation matrix.
static inline void   mvgTransformTranslate( float dst[6], CGPoint t)
{
   nvgTransformTranslate( dst, t.x, t.y);
}

// Sets the transform to scale matrix.
static inline void   mvgTransformScale( float dst[6], CGVector s)
{
   nvgTransformScale( dst, s.dx, s.dy);
}

// Sets the transform to rotate matrix. Give a rotation here not an angle.
static inline void   mvgTransformRotate( float dst[6], CARotation a)
{
   nvgTransformRotate( dst, CARotationToRadians( a));
}

// Sets the transform to skew-x matrix.
static inline void   mvgTransformSkewX( float dst[6], CAAngle a)
{
   nvgTransformSkewX( dst, CAAngleToRadians( a));
}

// Sets the transform to skew-y matrix.
static inline void   mvgTransformSkewY( float dst[6], CGFloat a)
{
   nvgTransformSkewY( dst, CAAngleToRadians( a));
}

// Sets the transform to the result of multiplication of two transforms, of A = A*B.
static inline void   mvgTransformMultiply( float dst[6], float src[6])
{
   nvgTransformMultiply( dst, src);
}

// Sets the transform to the result of multiplication of two transforms, of A = B*A.
static inline void   mvgTransformPremultiply( float dst[6], float src[6])
{
   nvgTransformPremultiply( dst, src);
}

// Sets the destination to inverse of specified transform.
// Returns 1 if the inverse could be calculated, else 0.
static inline BOOL   mvgTransformInverse( float dst[6], float src[6])
{
   return( nvgTransformInverse( dst, src));
}


// Sets the current transform to the result of A * B.
static inline CGPoint   mvgTransformPoint( float xform[ 6], CGPoint point)
{
   float   dstx, dsty;

   nvgTransformPoint( &dstx, &dsty, xform, point.x, point.y);
   return( CGPointMake( dstx, dsty));
}

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
   if( ! vg || ! filename)
      return( CGTextureIDInvalid);

   return( nvgCreateImage( vg, filename, textureFlags));
}


// Creates image by loading it from the specified chunk of memory.
static inline CGTextureID   mvgCreateImageMem( NVGcontext *vg,
                                               NSInteger textureFlags,
                                               void *data,
                                               size_t ndata)
{
   if( ! vg ||! data || ! ndata)
      return( CGTextureIDInvalid);
   return( nvgCreateImageMem( vg, textureFlags, data, ndata));
}


// Creates image from specified image data.
static inline CGTextureID   mvgCreateImageRGBA( NVGcontext *vg,
                                                NSInteger w,
                                                NSInteger h,
                                                NSUInteger textureFlags,
                                                void *data)
{
   if( ! vg || ! data)
      return( CGTextureIDInvalid);
   return( nvgCreateImageRGBA( vg, w, h, textureFlags, data));
}


// Updates image data specified by image handle.
static inline void   mvgUpdateImage( NVGcontext *vg, CGTextureID image, void *data)
{
   if( ! vg || ! data || image == CGTextureIDInvalid)
      return;
   nvgUpdateImage( vg, image, (const unsigned char *) data);
}


// Returns the dimensions of a created image.
static inline CGPixelSize  mvgImageSize( NVGcontext *vg, CGTextureID image)
{
   int   w, h;

   if( ! vg || image == CGTextureIDInvalid)
      return( CGPixelSizeZero);

   nvgImageSize( vg, image, &w, &h);
   return( CGPixelSizeMake( w, h));
}


// Deletes created image.
static inline void   mvgDeleteImage( NVGcontext *vg, CGTextureID image)
{
   if( vg && image != CGTextureIDInvalid)
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

static inline NVGpaint
   mvgLinearGradient( NVGcontext* vg, CGRect rect, CGColor icol, CGColor ocol)
{
   if( ! vg)
      return( (NVGpaint){ 0});

   return( nvgLinearGradient( vg, CGRectGetMinX( rect),
                                  CGRectGetMinY( rect),
                                  CGRectGetMaxX( rect),
                                  CGRectGetMaxY( rect),
                                  icol,
                                  ocol));
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
static inline NVGpaint
   mvgBoxGradient( NVGcontext *vg,
                   CGRect rect,
                   CGColor color,
                   CGFloat cornerRadius,
                   CGFloat feather,
                   CGColor featherColor)
{
   CGRect   gradientRect;

   if( ! vg)
      return( (NVGpaint){ 0});

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
static inline NVGpaint
   mvgRadialGradient( NVGcontext *vg,
                      CACircle circle,
                      CGColor color,
                      CGFloat innerRadius,
                      CGColor innerColor)
{
   if( ! vg)
      return( (NVGpaint){ 0});

   return( nvgRadialGradient( vg, circle.center.x,
                                  circle.center.y,
                                  innerRadius,
                                  circle.radius,
                                  innerColor,
                                  color));
}

// Creates and returns an image pattern. Parameters the location and size of
// one image, angle rotation around the top-left corner, image is handle to
// the image to render. Because the angle rotation is around the left corner
// and not the center, the rotation will rarely do what you want it to, so
// use CGImage instead.
// The gradient is transformed by the current transform when it is passed to
// nvgFillPaint() or nvgStrokePaint().
//
static inline NVGpaint   mvgImagePattern( NVGcontext* vg,
                                          CGRect rect,
                                          CARotation rotation,
                                          CGTextureID image,
                                          CGFloat alpha)
{
   if( ! vg || image == CGTextureIDInvalid)
      return( (NVGpaint){ 0});

   return( nvgImagePattern( vg, rect.origin.x,
                                rect.origin.y,
                                rect.size.width,
                                rect.size.height,
                                CARotationToRadians( rotation),
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
static inline void   mvgScissor( NVGcontext* vg, CGRect rect)
{
   if( vg)
      nvgScissor( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

// Intersects current scissor rectangle with the specified rectangle.
// The scissor rectangle is transformed by the current transform.
// Note: in case the rotation of previous scissor rect differs from
// the current one, the intersection will be done between the specified
// rectangle and the previous scissor rectangle transformed in the current
// transform space. The resulting shape is always rectangle.
static inline void   mvgIntersectScissor( NVGcontext* vg, CGRect rect)
{
   if( vg)
      nvgIntersectScissor( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}


// Reset and disables scissoring.
static inline void   mvgResetScissor( NVGcontext* vg)
{
   if( vg)
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
   if( vg)
      nvgBeginPath( vg);
}

// Starts new sub-path with specified point as first point.
static inline void   mvgMoveTo( NVGcontext *vg, CGPoint point)
{
   if( vg)
      nvgMoveTo( vg, point.x, point.y);
}

// Adds line segment from the last point in the path to the specified point.
static inline void   mvgLineTo( NVGcontext *vg, CGPoint point)
{
   if( vg)
      nvgLineTo( vg, point.x, point.y);
}

// Adds cubic bezier segment from last point in the path via two control points to the specified point.
static inline void   mvgBezierTo( NVGcontext *vg, CGPoint control1, CGPoint control2, CGPoint point)
{
   if( vg)
      nvgBezierTo( vg, control1.x, control1.y, control2.x, control2.y, point.x, point.y);
}

// Adds quadratic bezier segment from last point in the path via a control point to the specified point.
static inline void   mvgQuadTo( NVGcontext *vg, CGPoint control, CGPoint point)
{
   if( vg)
      nvgQuadTo( vg, control.x, control.y, point.x, point.y);
}

// Adds an arc segment at the corner defined by the last path point, and two specified points.
static inline void   mvgArcTo( NVGcontext *vg, CGPoint tangent1, CGPoint tangent2, CGFloat radius)
{
   if( vg)
      nvgArcTo( vg, tangent1.x, tangent1.y, tangent2.x, tangent2.y, radius);
}

// Closes current sub-path with a line segment.
static inline void   mvgClosePath( NVGcontext *vg)
{
   if( vg)
      nvgClosePath( vg);
}

// Sets the current sub-path winding, see NVGwinding and NVGsolidity.
static inline void   mvgPathWinding( NVGcontext *vg, NSInteger dir)
{
   if( vg)
      nvgPathWinding( vg, dir);
}

// Creates new circle arc shaped sub-path
static inline void   mvgArc( NVGcontext *vg, 
                             CACircle circle,
                             CAAngle a0, 
                             CAAngle a1, 
                             NSInteger dir)
{
   if( vg)
      nvgArc( vg, circle.center.x,
                  circle.center.y,
                  circle.radius,
                  CAAngleToRadians( a0),
                  CAAngleToRadians( a1),
                  dir);
}

// Creates new rectangle shaped sub-path.
static inline void   mvgRect( NVGcontext *vg, CGRect rect)
{
   if( vg)
      nvgRect( vg, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}


// this function accepts negative insets
static inline void   mvgRoundedRectVarying( NVGcontext *vg,
                                            CGRect rect,
                                            struct MulleCornerInsets insets)
{
   void _mvgRoundedRectVarying( NVGcontext* vg, float x, float y, float w, float h,
                                            float radTopLeft, float radTopRight,
                                            float radBottomRight, float radBottomLeft);

   if( vg)
      _mvgRoundedRectVarying( vg, rect.origin.x,
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
   if( vg)
      mvgRoundedRectVarying( vg, rect, MulleCornerInsetsMakeWithCornerRadius( r));
}


// Creates new ellipse shaped sub-path.
static inline void   mvgEllipse( NVGcontext *vg, CGPoint center, CGFloat rx, CGFloat ry)
{
   if( vg)
      nvgEllipse( vg, center.x, center.y, rx, ry);
}

// Creates new circle shaped sub-path.
static inline void   mvgCircle( NVGcontext *vg, CACircle circle)
{
   if( vg)
      nvgCircle( vg, circle.center.x, circle.center.y, circle.radius);
}

// Fills the current path with current fill style.
static inline void   mvgFill( NVGcontext *vg)
{
   if( vg)
      nvgFill( vg);
}

// Fills the current path with current stroke style.
static inline void   mvgStroke( NVGcontext *vg)
{
   if( vg)
      nvgStroke( vg);
}

// Creates font by loading it from the disk from specified file name.
static inline CGFontID   mvgCreateFont( NVGcontext *vg, char *name, char *filename)
{
   if( ! vg || ! name || ! filename)
      return( CGFontIDInvalid);
   return nvgCreateFont( vg, name, filename);
}

// Creates font by loading it from the specified memory chunk.
static inline CGFontID   mvgCreateFontMem( NVGcontext *vg, 
                                           char *name,
                                           void * data, 
                                           size_t length,
                                           BOOL freeData)
{
   if( ! vg || ! name || ! data || ! length)
      return( CGFontIDInvalid);
   return( nvgCreateFontMem( vg, name, data, length, freeData));
}

// Finds a loaded font of specified name, and returns handle to it, or -1 if the font is not found.
static inline CGFontID   mvgFindFont( NVGcontext *vg, char *name)
{
   if( ! vg)
      return( CGFontIDInvalid);
   return( nvgFindFont( vg, name));
}


// Adds a fallback font by handle.
static inline CGFontID   mvgAddFallbackFontId( NVGcontext* vg, CGFontID baseFont, CGFontID fallbackFont)
{
   if( ! vg || ! baseFont || ! fallbackFont)
      return( CGFontIDInvalid);

   return nvgAddFallbackFontId( vg, baseFont, fallbackFont);
}


// Adds a fallback font by name.
static inline CGFontID   mvgAddFallbackFont( NVGcontext *vg, char *baseFont, char *fallbackFont)
{
   if( ! vg || ! baseFont || ! fallbackFont)
      return( CGFontIDInvalid);
   return nvgAddFallbackFont( vg, (const char *) baseFont, (const char *) fallbackFont);
}


// Resets fallback fonts by handle.
static inline void   mvgResetFallbackFontsId( NVGcontext *vg, NSInteger baseFont)
{
   if( vg)
      nvgResetFallbackFontsId( vg, baseFont);
}


// Resets fallback fonts by name.
static inline void   mvgResetFallbackFonts( NVGcontext *vg, char *baseFont)
{
   if( vg)
      nvgResetFallbackFonts( vg, baseFont);
}


// Sets the font size of current text style.
static inline void   mvgFontSize( NVGcontext *vg, CGFloat size)
{
   if( vg)
      nvgFontSize( vg, size);
}

// Sets the blur of current text style.
static inline void   mvgFontBlur( NVGcontext *vg, CGFloat blur)
{
   if( vg)
      nvgFontBlur( vg, blur);
}

// Sets the letter spacing of current text style.
static inline void   mvgTextLetterSpacing( NVGcontext *vg, CGFloat spacing)
{
   if( vg)
      nvgTextLetterSpacing( vg, spacing);
}

// Sets the line height of current text style.
static inline void   mvgTextLineHeight( NVGcontext *vg, CGFloat lineHeight)
{
   if( vg)
      nvgTextLineHeight( vg, lineHeight);
}

// Sets the text align of current text style.
static inline void   mvgTextAlign( NVGcontext *vg, NSUInteger align)
{
   if( vg)
      nvgTextAlign( vg, align);
}

// Sets the font face based on specified id(font handle).
static inline void   mvgFontFaceId( NVGcontext *vg, CGFontID fontID)
{
   if( vg)
      nvgFontFaceId( vg, fontID);
}

// Sets the font face based on specified name.
static inline void   mvgFontFace( NVGcontext *vg, char *fontname)
{
   if( vg)
      nvgFontFace( vg, fontname);
}

// Draws text string at specified location.
static inline CGFloat   mvgText( NVGcontext *vg, CGPoint point, char *s, size_t length)
{
   char   *end;

   if( ! vg | ! s)
      return( 0.0);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   return( nvgText( vg, point.x, point.y, s, end));
}

// use after mvgTextColor not before
static inline void   mvgClearType( NVGcontext *vg, BOOL enable)
{
   if( vg)
      nvgClearType( vg, (int) enable);
}


static inline void   mvgTextColor( NVGcontext *vg, CGColor color)
{
   if( vg)
      nvgTextColor( vg, color);
}

// use after mvgTextColor not before
static inline void   mvgTextBackgroundColor( NVGcontext *vg, CGColor color)
{
   if( vg)
      nvgTextBackgroundColor( vg, color);
}


// Measures the specified text string. Parameter bbox is optional,
// if the bounding box of the text should be returned.
// Returns the horizontal advance of the measured text
// (i.e. where the next character should drawn).
// Measured values are returned in local coordinate space.
static inline CGFloat   mvgTextBounds( NVGcontext *vg,
                                       CGPoint point,
                                       char *s,
                                       size_t length,
                                       CGRect *bbox)
{
   float  w;
   float  bounds[ 4];
   char   *end;

   if( ! vg || ! s)
      return( 0.0);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   w   = nvgTextBounds( vg, point.x, point.y, s, end, bbox ? bounds : NULL);
   if( bbox)
      *bbox = CGRectMake( bounds[ 0],
                          bounds[ 1],
                          bounds[ 2] - bounds[ 0],
                          bounds[ 3] - bounds[ 1]);
   return( w);
}


static inline void   mvgTextVisualBounds( NVGcontext *vg,
                                          CGPoint point,
                                          char *s,
                                          size_t length,
                                          CGRect *vbounds)
{
   float  bounds[ 6];
   char   *end;

   if( ! vg || ! s)
   {
      memset( vbounds, 0, sizeof( CGRect));
      return;
   }

   end = (length == (size_t) -1) ? NULL : &s[ length];
   nvgTextVisualBounds( vg, point.x, point.y, s, end, bounds);
   *vbounds = CGRectMake( bounds[ 0],
                          bounds[ 1],
                          bounds[ 2] - bounds[ 0],
                          bounds[ 3] - bounds[ 1]);
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

   if( ! vg || ! s)
   {
      memset( bbox, 0, sizeof( CGRect));
      return;
   }

   end = (length == (size_t) -1) ? NULL : &s[ length];
   nvgTextBoxBounds( vg, point.x, point.y, breakRowWidth, s, end, bounds);
   *bbox = CGRectMake( bounds[ 0],
                       bounds[ 1],
                       bounds[ 2] - bounds[ 0],
                       bounds[ 3] - bounds[ 1]);
}

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

   if( ! vg || ! s)
      return( 0);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   return( nvgTextGlyphPositions( vg, point.x, point.y,
                                      s, end,
                                      (NVGglyphPosition *) positions, maxPositions));
}



// Breaks the specified text into lines.
static inline NSInteger   mvgTextBreakLines( NVGcontext *vg, 
                                             char *s,
                                             size_t length,
                                             CGFloat breakRowWidth, 
                                             struct UITextRow* rows,
                                             NSInteger maxRows)
{
   char   *end;

   if( ! vg || ! s)
      return( 0);

   end = (length == (size_t) -1) ? NULL : &s[ length];
   return( nvgTextBreakLines( vg, s, end,
                                  breakRowWidth,
                                  (NVGtextRow *) rows, maxRows));
}


// Creates a NanoVG context with specified flags.
static inline NVGcontext * mvgCreateInternal( NVGparams *params)
{
   if( ! params)
      return( NULL);

   return( nvgCreateInternal( params));
}

// Deletes a NanoVG context created with nvgCreateInternal.
static inline void   mvgDeleteInternal( NVGcontext *vg)
{
   if( vg)
      nvgDeleteInternal( vg);
}

#endif
