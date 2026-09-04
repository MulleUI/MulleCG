//
//  CGFunctionTable.h
//  MulleCG
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
// CGFunctionTable.h
// MulleCG
//
// Function pointer vtable for the drawing backend.
// The nanovg implementation is in MulleCGNanoVG/CGFunctionTable+nanovg.m.
//
#ifndef cgfunctiontable_h__
#define cgfunctiontable_h__

#import "import.h"


#include "CGTypes.h"

struct CGPath;

typedef struct CGFunctionTable
{
   // State management
   void        (*save)( void *vg);
   void        (*restore)( void *vg);
   void        (*reset)( void *vg);

   // Frame management
   void        (*beginFrame)( void *vg, CGSize windowSize, CGFloat devicePixelRatio);
   void        (*cancelFrame)( void *vg);
   void        (*endFrame)( void *vg);

   // Composite operations
   void        (*globalCompositeOperation)( void *vg, NSInteger op);
   void        (*globalCompositeBlendFunc)( void *vg, NSUInteger sfactor, NSUInteger dfactor);
   void        (*globalCompositeBlendFuncSeparate)( void *vg, NSUInteger srcRGB, NSUInteger dstRGB, NSUInteger srcAlpha, NSUInteger dstAlpha);

   // Transform operations
   void        (*resetTransform)( void *vg);
   void        (*transform)( void *vg, CGAffineTransform *xform);
   CGAffineTransform (*currentTransform)( void *vg);
   void        (*translate)( void *vg, CGPoint p);
   void        (*rotate)( void *vg, CARotation rotation);
   void        (*scale)( void *vg, CGVector v);
   void        (*skewX)( void *vg, CAAngle angle);
   void        (*skewY)( void *vg, CAAngle angle);

   // Image operations
   CGTextureID (*createImage)( void *vg, char *filename, NSUInteger textureFlags);
   CGTextureID (*createImageMem)( void *vg, NSInteger textureFlags, void *data, size_t ndata);
   CGTextureID (*createImageRGBA)( void *vg, NSInteger w, NSInteger h, NSUInteger textureFlags, void *data);
   void        (*updateImage)( void *vg, CGTextureID image, void *data);
   CGPixelSize (*imageSize)( void *vg, CGTextureID image);
   void        (*deleteImage)( void *vg, CGTextureID image);

   // Scissor operations
   void        (*scissor)( void *vg, CGRect rect);
   void        (*intersectScissor)( void *vg, CGRect rect);
   void        (*resetScissor)( void *vg);

   // Render style
   void        (*shapeAntiAlias)( void *vg, BOOL enable);
   void        (*bezierTessellation)( void *vg, CGTessellation mode);
   void        (*strokeColor)( void *vg, CGColor color);
   void        (*fillColor)( void *vg, CGColor color);
   void        (*miterLimit)( void *vg, CGFloat limit);
   void        (*strokeWidth)( void *vg, CGFloat size);
   void        (*lineCap)( void *vg, NSInteger cap);
   void        (*lineJoin)( void *vg, NSInteger join);
   void        (*globalAlpha)( void *vg, CGFloat alpha);

   // Path operations
   void        (*beginPath)( void *vg);
   void        (*moveTo)( void *vg, CGPoint point);
   void        (*lineTo)( void *vg, CGPoint point);
   void        (*bezierTo)( void *vg, CGPoint control1, CGPoint control2, CGPoint point);
   void        (*quadTo)( void *vg, CGPoint control, CGPoint point);
   void        (*arcTo)( void *vg, CGPoint tangent1, CGPoint tangent2, CGFloat radius);
   void        (*closePath)( void *vg);
   void        (*pathWinding)( void *vg, CGPathFillStyle style);

   // Shape operations
   void        (*rect)( void *vg, CGRect rect);
   void        (*roundedRect)( void *vg, CGRect rect, CGFloat r);
   void        (*roundedRectVarying)( void *vg, CGRect rect, struct MulleCornerInsets insets);
   void        (*ellipse)( void *vg, CGPoint center, CGFloat rx, CGFloat ry);
   void        (*arc)( void *vg, CACircle circle, CAAngle angle, CARotation rotation);
   void        (*arcRadians)( void *vg, CACircle circle, CGFloat radians1, CGFloat radians2, CARotationDirection dir);
   void        (*fill)( void *vg);
   void        (*stroke)( void *vg);
   void        (*addCGPath)( void *vg, struct CGPath *path);
   void        (*copyPath)( void *vg, void *src_vg);
   void        (*precompilePath)( void *vg);

   // Paint style (set before fill/stroke)
   void        (*setFillLinearGradient)( void *vg, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor);
   void        (*setStrokeLinearGradient)( void *vg, CGPoint start, CGPoint end, CGColor startColor, CGColor endColor);
   void        (*setFillBoxGradient)( void *vg, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor);
   void        (*setStrokeBoxGradient)( void *vg, CGRect rect, CGFloat cornerRadius, CGColor color, CGFloat feather, CGColor featherColor);
   void        (*setFillRadialGradient)( void *vg, CACircle circle, CGColor outerColor, CGFloat innerRadius, CGColor innerColor);
   void        (*setStrokeRadialGradient)( void *vg, CACircle circle, CGColor outerColor, CGFloat innerRadius, CGColor innerColor);
   void        (*setFillImagePattern)( void *vg, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha);
   void        (*setStrokeImagePattern)( void *vg, CGTextureID textureID, CGRect rect, CARotation rotation, CGFloat alpha);

   // Debugging
   void        (*trace)( void *vg, FILE *fp);
   void        (*traceComment)( void *vg, char *comment);

} CGFunctionTable;

#endif
