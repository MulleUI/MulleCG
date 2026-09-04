//
//  CGContext+DrawingConveniences.h
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
#import "CGContext+Drawing.h"
#import "CGDrawable.h"


// these convenience build on CGContext+Drawing.h
// CGContext calls, no nanovg or microvg

MULLE_CG_GLOBAL
void   CGContextFillWithColor( CGContext *context, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeWithColor( CGContext *context, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeLineHWithColor( CGContext *context, CGPoint p, CGFloat w, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeLineVWithColor( CGContext *context, CGPoint p, CGFloat h, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextFillRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGColor color);
MULLE_CG_GLOBAL
void   CGContextFillRectWithColor( CGContext *context, CGRect rect, CGColor color);
MULLE_CG_GLOBAL
void   CGContextFillCircleWithColor( CGContext *context, CACircle circle, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeInsideOfRoundedRectWithColor( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeRectWithColor( CGContext *context, CGRect rect, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeInsideOfRectWithColor( CGContext *context, CGRect rect, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeLineWithColor( CGContext *context, CGPoint start, CGPoint end, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextStrokeCircleWithColor( CGContext *context, CACircle circle, CGFloat strokeWidth, CGColor color);
MULLE_CG_GLOBAL
void   CGContextFillCircleWithGradientColors( CGContext *context, CACircle circle, CGColor outerColor, CGColor innerColor);
MULLE_CG_GLOBAL
void   CGContextStrokeCircleWithGradientColors( CGContext *context, CACircle circle, CGColor outerColor, CGColor innerColor, CGFloat strokeWidth);
MULLE_CG_GLOBAL
void   CGContextFormatInRect( CGContext *context, CGRect rect, CGContentMode contentMode, CGTextOptions options, char *format, ...);
MULLE_CG_GLOBAL
void   CGContextFormat( CGContext *context, CGPoint point, char *format, ...);
MULLE_CG_GLOBAL
CGPoint   CGContextTLAdjustmentForVisualBounds( CGLayoutContext *context, char *s, size_t length, int alignment, CGTextOptions options);
MULLE_CG_GLOBAL
void   CGContextFillRoundedShadow( CGContext *context, CGRect rect, CGFloat cornerRadius, struct CGShadow *shadow);
MULLE_CG_GLOBAL
void   CGContextTextInRect( CGContext *context, char *s, size_t length, CGRect rect, CGContentMode contentMode, CGTextOptions options);
MULLE_CG_GLOBAL
struct CGTextBoundsInfo   CGContextTextBoundsOptions( CGContext *context, char *s, size_t length, CGRect rect, CGContentMode contentMode, CGTextOptions options);
MULLE_CG_GLOBAL
void   CGContextExtendedAlignedText( CGContext *context, char *s, size_t length, CGPoint origin, int alignment, CGTextOptions options);
MULLE_CG_GLOBAL
void   CGContext_ExtendedAlignedText( CGContext *context, char *s, size_t length, CGPoint origin, int alignment, CGTextOptions options);
