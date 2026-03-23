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