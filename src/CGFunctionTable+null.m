//
//  CGFunctionTable+null.m
//  MulleCG
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
// The "null" drawing backend vtable. Every entry is a no-op. When tracing is
// enabled each call is logged as a CGContext-level operation (mirroring the way
// the nanovg backend can trace, but expressed as CGContext calls rather than
// nvg calls). Value-returning entries return zero / identity.
//
// This table is installed into CGNullContext's _cgBackend.functions, so the C
// drawing accessors CGContextFN(ctx)->foo(...) dispatch here instead of to a
// NULL pointer.
//
#import "import-private.h"

#include "CGFunctionTable+null.h"

#include <stdio.h>


static BOOL    CGNullTrace     = NO;
static FILE   *CGNullTraceFile = NULL;   // defaults to stderr when tracing on

void   CGNullContextFunctionTableSetTrace( BOOL flag)
{
   CGNullTrace = flag;
}

BOOL   CGNullContextFunctionTableGetTrace( void)
{
   return( CGNullTrace);
}


//
// Set the destination for trace output and enable/disable tracing accordingly.
// Returns the previous file. Passing NULL disables tracing.
//
FILE   *CGNullContextFunctionTableSetTraceFile( FILE *file)
{
   FILE   *previous;

   previous        = CGNullTraceFile;
   CGNullTraceFile = file;
   CGNullTrace     = (file != NULL);
   return( previous);
}


//
// Trace helper. "vg" is the backend context pointer; for CGNullContext it is
// NULL/unused, so we only log the operation name and its salient arguments.
//
#define CGNULL_TRACE( ...)                                       \
   do {                                                          \
      if( CGNullTrace)                                           \
      {                                                          \
         FILE   *_fp = CGNullTraceFile ? CGNullTraceFile : stderr; \
         fprintf( _fp, "CGNullContext: ");                       \
         fprintf( _fp, __VA_ARGS__);                             \
         fprintf( _fp, "\n");                                    \
      }                                                          \
   } while( 0)


#pragma mark - state / frame

static void   _save( void *vg)                                                       { CGNULL_TRACE( "save"); }
static void   _restore( void *vg)                                                    { CGNULL_TRACE( "restore"); }
static void   _reset( void *vg)                                                      { CGNULL_TRACE( "reset"); }

static void   _beginFrame( void *vg, CGSize s, CGFloat r)                            { CGNULL_TRACE( "beginFrame { %.1f, %.1f } @%.2f", s.width, s.height, (double) r); }
static void   _cancelFrame( void *vg)                                                { CGNULL_TRACE( "cancelFrame"); }
static void   _endFrame( void *vg)                                                   { CGNULL_TRACE( "endFrame"); }


#pragma mark - composite

static void   _globalCompositeOperation( void *vg, NSInteger op)                     { CGNULL_TRACE( "globalCompositeOperation %ld", (long) op); }
static void   _globalCompositeBlendFunc( void *vg, NSUInteger sf, NSUInteger df)     { CGNULL_TRACE( "globalCompositeBlendFunc"); }
static void   _globalCompositeBlendFuncSeparate( void *vg, NSUInteger sr, NSUInteger dr, NSUInteger sa, NSUInteger da) { CGNULL_TRACE( "globalCompositeBlendFuncSeparate"); }


#pragma mark - transform

static void              _resetTransform( void *vg)                                  { CGNULL_TRACE( "resetTransform"); }
static void              _transform( void *vg, CGAffineTransform *x)                 { CGNULL_TRACE( "transform"); }
static CGAffineTransform _currentTransform( void *vg)                                { CGAffineTransform x = CGAffineTransformIdentity; CGNULL_TRACE( "currentTransform"); return( x); }
static void              _translate( void *vg, CGPoint p)                            { CGNULL_TRACE( "translate { %.1f, %.1f }", p.x, p.y); }
static void              _rotate( void *vg, CARotation r)                            { CGNULL_TRACE( "rotate"); }
static void              _scale( void *vg, CGVector v)                               { CGNULL_TRACE( "scale"); }
static void              _skewX( void *vg, CAAngle a)                                { CGNULL_TRACE( "skewX"); }
static void              _skewY( void *vg, CAAngle a)                                { CGNULL_TRACE( "skewY"); }


#pragma mark - images

static CGTextureID _createImage( void *vg, char *f, NSUInteger fl)                              { CGNULL_TRACE( "createImage"); return( 0); }
static CGTextureID _createImageMem( void *vg, NSInteger fl, void *d, size_t n)                  { CGNULL_TRACE( "createImageMem"); return( 0); }
static CGTextureID _createImageRGBA( void *vg, NSInteger w, NSInteger h, NSUInteger fl, void *d){ CGNULL_TRACE( "createImageRGBA %ldx%ld", (long) w, (long) h); return( 0); }
static void        _updateImage( void *vg, CGTextureID img, void *d)                            { CGNULL_TRACE( "updateImage"); }
static CGPixelSize _imageSize( void *vg, CGTextureID img)                                        { CGPixelSize z = { 0, 0 }; CGNULL_TRACE( "imageSize"); return( z); }
static void        _deleteImage( void *vg, CGTextureID img)                                     { CGNULL_TRACE( "deleteImage"); }


#pragma mark - scissor

static void   _scissor( void *vg, CGRect r)                                          { CGNULL_TRACE( "scissor"); }
static void   _intersectScissor( void *vg, CGRect r)                                 { CGNULL_TRACE( "intersectScissor"); }
static void   _resetScissor( void *vg)                                               { CGNULL_TRACE( "resetScissor"); }


#pragma mark - render style

static void   _shapeAntiAlias( void *vg, BOOL e)                                     { CGNULL_TRACE( "shapeAntiAlias %d", (int) e); }
static void   _bezierTessellation( void *vg, CGTessellation m)                       { CGNULL_TRACE( "bezierTessellation"); }
static void   _strokeColor( void *vg, CGColor c)                                     { CGNULL_TRACE( "strokeColor"); }
static void   _fillColor( void *vg, CGColor c)                                       { CGNULL_TRACE( "fillColor"); }
static void   _miterLimit( void *vg, CGFloat l)                                      { CGNULL_TRACE( "miterLimit"); }
static void   _strokeWidth( void *vg, CGFloat s)                                     { CGNULL_TRACE( "strokeWidth %.2f", (double) s); }
static void   _lineCap( void *vg, NSInteger c)                                       { CGNULL_TRACE( "lineCap"); }
static void   _lineJoin( void *vg, NSInteger j)                                      { CGNULL_TRACE( "lineJoin"); }
static void   _globalAlpha( void *vg, CGFloat a)                                     { CGNULL_TRACE( "globalAlpha %.2f", (double) a); }


#pragma mark - path

static void   _beginPath( void *vg)                                                  { CGNULL_TRACE( "beginPath"); }
static void   _moveTo( void *vg, CGPoint p)                                          { CGNULL_TRACE( "moveTo { %.1f, %.1f }", p.x, p.y); }
static void   _lineTo( void *vg, CGPoint p)                                          { CGNULL_TRACE( "lineTo { %.1f, %.1f }", p.x, p.y); }
static void   _bezierTo( void *vg, CGPoint c1, CGPoint c2, CGPoint p)                { CGNULL_TRACE( "bezierTo"); }
static void   _quadTo( void *vg, CGPoint c, CGPoint p)                               { CGNULL_TRACE( "quadTo"); }
static void   _arcTo( void *vg, CGPoint t1, CGPoint t2, CGFloat r)                   { CGNULL_TRACE( "arcTo"); }
static void   _closePath( void *vg)                                                  { CGNULL_TRACE( "closePath"); }
static void   _pathWinding( void *vg, CGPathFillStyle s)                             { CGNULL_TRACE( "pathWinding"); }


#pragma mark - shapes

static void   _rect( void *vg, CGRect r)                                             { CGNULL_TRACE( "rect { %.1f, %.1f, %.1f, %.1f }", r.origin.x, r.origin.y, r.size.width, r.size.height); }
static void   _roundedRect( void *vg, CGRect r, CGFloat rad)                         { CGNULL_TRACE( "roundedRect"); }
static void   _roundedRectVarying( void *vg, CGRect r, struct MulleCornerInsets i)   { CGNULL_TRACE( "roundedRectVarying"); }
static void   _ellipse( void *vg, CGPoint c, CGFloat rx, CGFloat ry)                 { CGNULL_TRACE( "ellipse"); }
static void   _arc( void *vg, CACircle c, CAAngle a, CARotation rot)                 { CGNULL_TRACE( "arc"); }
static void   _arcRadians( void *vg, CACircle c, CGFloat r1, CGFloat r2, CARotationDirection dir) { CGNULL_TRACE( "arcRadians"); }
static void   _fill( void *vg)                                                       { CGNULL_TRACE( "fill"); }
static void   _stroke( void *vg)                                                     { CGNULL_TRACE( "stroke"); }
static void   _addCGPath( void *vg, struct CGPath *path)                             { CGNULL_TRACE( "addCGPath"); }
static void   _copyPath( void *vg, void *src_vg)                                     { CGNULL_TRACE( "copyPath"); }
static void   _precompilePath( void *vg)                                             { CGNULL_TRACE( "precompilePath"); }


#pragma mark - paint

static void   _setFillLinearGradient( void *vg, CGPoint s, CGPoint e, CGColor sc, CGColor ec)          { CGNULL_TRACE( "setFillLinearGradient"); }
static void   _setStrokeLinearGradient( void *vg, CGPoint s, CGPoint e, CGColor sc, CGColor ec)        { CGNULL_TRACE( "setStrokeLinearGradient"); }
static void   _setFillBoxGradient( void *vg, CGRect r, CGFloat cr, CGColor c, CGFloat f, CGColor fc)   { CGNULL_TRACE( "setFillBoxGradient"); }
static void   _setStrokeBoxGradient( void *vg, CGRect r, CGFloat cr, CGColor c, CGFloat f, CGColor fc) { CGNULL_TRACE( "setStrokeBoxGradient"); }
static void   _setFillRadialGradient( void *vg, CACircle ci, CGColor oc, CGFloat ir, CGColor ic)       { CGNULL_TRACE( "setFillRadialGradient"); }
static void   _setStrokeRadialGradient( void *vg, CACircle ci, CGColor oc, CGFloat ir, CGColor ic)     { CGNULL_TRACE( "setStrokeRadialGradient"); }
static void   _setFillImagePattern( void *vg, CGTextureID t, CGRect r, CARotation rot, CGFloat a)      { CGNULL_TRACE( "setFillImagePattern"); }
static void   _setStrokeImagePattern( void *vg, CGTextureID t, CGRect r, CARotation rot, CGFloat a)    { CGNULL_TRACE( "setStrokeImagePattern"); }


#pragma mark - debugging

static void   _trace( void *vg, FILE *fp)                                            { }
static void   _traceComment( void *vg, char *comment)                                { }


#pragma mark - font-context text DRAWING no-ops

//
// The font context (nanovg font-only) supports measurement, but its text
// *drawing* entrypoints assert NOT_AVAILABLE_IN_FONT_CONTEXT. Since a
// CGNullContext draws nothing, we replace just those drawing slots with no-ops
// and keep the measurement slots (textBounds/textMetrics/glyphPositions/
// breakLines/...) delegating to the real font context, so layout still works.
//
static void      _font_textColor( void *vg, CGColor c)                               { CGNULL_TRACE( "textColor"); }
static void      _font_textBackgroundColor( void *vg, CGColor c)                     { CGNULL_TRACE( "textBackgroundColor"); }
static void      _font_clearType( void *vg, BOOL e)                                  { CGNULL_TRACE( "clearType %d", (int) e); }
static CGFloat   _font_text( void *vg, CGPoint p, char *s, size_t len)               { CGNULL_TRACE( "text \"%.*s\"", (int) (len == (size_t) -1 ? 0 : len), s ? s : ""); return( p.x); }
static void      _font_textBox( void *vg, CGPoint p, CGFloat w, char *s, size_t len) { CGNULL_TRACE( "textBox"); }
static CGFloat   _font_attributedText( void *vg, CGPoint p, char *s, size_t len, struct CGTextAttribute *a, int n) { CGNULL_TRACE( "attributedText"); return( p.x); }


void   CGNullContextPatchFontFunctionTable( CGFontFunctionTable *table)
{
   if( ! table)
      return;

   // Only the drawing entrypoints; measurement stays real.
   table->textColor           = _font_textColor;
   table->textBackgroundColor = _font_textBackgroundColor;
   table->clearType           = _font_clearType;
   table->text                = _font_text;
   table->textBox             = _font_textBox;
   table->attributedText      = _font_attributedText;
}


CGFunctionTable   CGNullContextFunctionTable =
{
   .beginFrame                    = _beginFrame,
   .cancelFrame                   = _cancelFrame,
   .endFrame                      = _endFrame,

   .save                          = _save,
   .restore                       = _restore,
   .reset                         = _reset,

   .globalCompositeOperation      = _globalCompositeOperation,
   .globalCompositeBlendFunc      = _globalCompositeBlendFunc,
   .globalCompositeBlendFuncSeparate = _globalCompositeBlendFuncSeparate,

   .resetTransform                = _resetTransform,
   .transform                     = _transform,
   .currentTransform              = _currentTransform,
   .translate                     = _translate,
   .rotate                        = _rotate,
   .scale                         = _scale,
   .skewX                         = _skewX,
   .skewY                         = _skewY,

   .createImage                   = _createImage,
   .createImageMem                = _createImageMem,
   .createImageRGBA               = _createImageRGBA,
   .updateImage                   = _updateImage,
   .imageSize                     = _imageSize,
   .deleteImage                   = _deleteImage,

   .scissor                       = _scissor,
   .intersectScissor              = _intersectScissor,
   .resetScissor                  = _resetScissor,

   .shapeAntiAlias                = _shapeAntiAlias,
   .bezierTessellation            = _bezierTessellation,
   .strokeColor                   = _strokeColor,
   .fillColor                     = _fillColor,
   .miterLimit                    = _miterLimit,
   .strokeWidth                   = _strokeWidth,
   .lineCap                       = _lineCap,
   .lineJoin                      = _lineJoin,
   .globalAlpha                   = _globalAlpha,

   .beginPath                     = _beginPath,
   .moveTo                        = _moveTo,
   .lineTo                        = _lineTo,
   .bezierTo                      = _bezierTo,
   .quadTo                        = _quadTo,
   .arcTo                         = _arcTo,
   .closePath                     = _closePath,
   .pathWinding                   = _pathWinding,

   .rect                          = _rect,
   .roundedRect                   = _roundedRect,
   .roundedRectVarying            = _roundedRectVarying,
   .ellipse                       = _ellipse,
   .arc                           = _arc,
   .arcRadians                    = _arcRadians,
   .fill                          = _fill,
   .stroke                        = _stroke,
   .addCGPath                     = _addCGPath,
   .copyPath                      = _copyPath,
   .precompilePath                = _precompilePath,

   .setFillLinearGradient         = _setFillLinearGradient,
   .setStrokeLinearGradient       = _setStrokeLinearGradient,
   .setFillBoxGradient            = _setFillBoxGradient,
   .setStrokeBoxGradient          = _setStrokeBoxGradient,
   .setFillRadialGradient         = _setFillRadialGradient,
   .setStrokeRadialGradient       = _setStrokeRadialGradient,
   .setFillImagePattern           = _setFillImagePattern,
   .setStrokeImagePattern         = _setStrokeImagePattern,

   .trace                         = _trace,
   .traceComment                  = _traceComment,
};
