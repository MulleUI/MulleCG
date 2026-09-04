//
//  UIColor.m
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
#import "UIColor.h"


@implementation UIColor

+ (instancetype) alloc
{
   assert( 0 && "don't create UIColor instances");
   return( nil);
}


- (instancetype) init
{
   assert( 0 && "don't create UIColor instances");
   [self release];
   return( nil);
}


+ (CGColor) blackColor     { return( CGColorMakeWithHexColor( 0x000000FF)); }

+ (CGColor) whiteColor     { return( CGColorMakeWithHexColor( 0xFFFFFFFF)); }
+ (CGColor) redColor       { return( CGColorMakeWithHexColor( 0xFF0000FF)); }
+ (CGColor) greenColor     { return( CGColorMakeWithHexColor( 0x00FF00FF)); }
+ (CGColor) blueColor      { return( CGColorMakeWithHexColor( 0x0000FFFF)); }
+ (CGColor) grayColor      { return( CGColorMakeWithHexColor( 0x7F7F7FFF)); }
+ (CGColor) darkGrayColor  { return( CGColorMakeWithHexColor( 0x3F3F3FFF)); }
+ (CGColor) lightGrayColor { return( CGColorMakeWithHexColor( 0xBFBFBFFF)); }
+ (CGColor) yellowColor    { return( CGColorMakeWithHexColor( 0xFFFF00FF)); }

+ (CGColor) magentaColor   { return( CGColorMakeWithHexColor( 0xFF00FFFF)); }
+ (CGColor) brownColor     { return( CGColorMakeWithHexColor( 0x8F5F2FFF)); }
+ (CGColor) cyanColor      { return( CGColorMakeWithHexColor( 0x00FFFFFF)); }
+ (CGColor) orangeColor    { return( CGColorMakeWithHexColor( 0xFF7F00FF)); }
+ (CGColor) purpleColor    { return( CGColorMakeWithHexColor( 0x7F007FFF)); }

// maus grau :) -> Loriot Eheberatung
+ (CGColor) underPageBackgroundColor  { return( CGColorMakeWithHexColor( 0x6b716fFF)); }
+ (CGColor) colorWithCGColor:(CGColor) cgColor  { return( cgColor); }
+ (CGColor) colorWithUTF8String:(char *) name
{
   return( CGColorMakeWithUTF8String( name));
}

@end
