//
//  UIColor.h
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

//
// UIColor is merely a factory for CGColor which is really the
// nanovg color struct
//
// I think colors wrapped into objects is too heavyweight
// In case of need, one should use NSValue for that.

@interface UIColor : NSObject

+ (CGColor) blackColor;
+ (CGColor) whiteColor;
+ (CGColor) redColor;
+ (CGColor) blueColor;
+ (CGColor) greenColor;
+ (CGColor) grayColor;
+ (CGColor) yellowColor;
+ (CGColor) darkGrayColor;
+ (CGColor) lightGrayColor;

+ (CGColor) magentaColor;
+ (CGColor) brownColor;
+ (CGColor) cyanColor;
+ (CGColor) orangeColor;
+ (CGColor) purpleColor;

+ (CGColor) underPageBackgroundColor;
+ (CGColor) colorWithCGColor:(CGColor) cgColor;
+ (CGColor) colorWithUTF8String:(char *) name;


@end

