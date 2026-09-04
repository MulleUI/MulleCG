//
//  CGPaint+DrawingConveniences.h
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
#import "import.h"

#import "CGPaintable.h"


MULLE_CG_GLOBAL
void   CGContextFillRoundedRectVaryingWithPaintable( CGContext *context, CGRect rect, MulleCornerInsets cornerInsets, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextFillRoundedRectWithPaintable( CGContext *context, CGRect rect, CGFloat cornerRadius, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextFillRectWithPaintable( CGContext *context, CGRect rect, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextFillCircleWithPaintable( CGContext *context, CACircle circle, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextFillLineWithPaintable( CGContext *context, CGPoint start, CGPoint end, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeRoundedRectVaryingWithPaintable( CGContext *context, CGRect rect, MulleCornerInsets cornerInsets, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeRoundedRectWithPaintable( CGContext *context, CGRect rect, CGFloat cornerRadius, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeRectWithPaintable( CGContext *context, CGRect rect, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeCircleWithPaintable( CGContext *context, CACircle circle, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeLineWithPaintable( CGContext *context, CGPoint start, CGPoint end, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeLineHWithPaintable( CGContext *context, CGPoint point, CGFloat width, CGFloat strokeWidth, id <CGPaintable> paint);
MULLE_CG_GLOBAL
void   CGContextStrokeLineVWithPaintable( CGContext *context, CGPoint start, CGFloat height, CGFloat strokeWidth, id <CGPaintable> paint);
