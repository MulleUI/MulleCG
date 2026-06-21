//
// main-text-attributed.m — CGContextAttributedText demo
//
#define _GNU_SOURCE

#import "import-private.h"

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *context)
{
   CGRect            canvas;
   CGTextAttribute   attrs[3];
   char              *text;
   CGFontID          italicFont;

   canvas = [layer canvas];

   [context useFontWithNameUTF8String:"sans"];
   italicFont = CGContextFindFont( context, "sans-italic");

   CGContextClearType( context, 1);
   CGContextCombinedTextAlignment( context, CGTextAlignLeft | CGTextAlignTop);
   CGContextFontSize( context, 28.0f);
   CGContextTextBackgroundColor( context, CGColorMakeBlack());

   // --- Line 1: selection highlighting ---
   text = "Hello World!";
   attrs[0] = (CGTextAttribute){ 6,  CGColorMakeWhite(), CGColorMakeBlack(), -1, -1, 0 };
   attrs[1] = (CGTextAttribute){ 11, CGColorMakeWhite(), CGColorMake( 0.2f, 0.4f, 0.8f, 1.0f), -1, -1, 0 };
   attrs[2] = (CGTextAttribute){ 12, CGColorMakeWhite(), CGColorMakeBlack(), -1, -1, 0 };
   CGContextAttributedText( context, CGPointMake( 10, 10), text, -1, attrs, 3);

   // --- Line 2: multi-color ---
   text = "Red Green Blue";
   attrs[0] = (CGTextAttribute){ 4,  CGColorMake( 1.0f, 0.3f, 0.3f, 1.0f), CGColorMakeBlack(), -1, -1, 0 };
   attrs[1] = (CGTextAttribute){ 10, CGColorMake( 0.3f, 1.0f, 0.3f, 1.0f), CGColorMakeBlack(), -1, -1, 0 };
   attrs[2] = (CGTextAttribute){ 14, CGColorMake( 0.3f, 0.3f, 1.0f, 1.0f), CGColorMakeBlack(), -1, -1, 0 };
   CGContextAttributedText( context, CGPointMake( 10, 50), text, -1, attrs, 3);

   // --- Line 3: superscript ---
   text = "E=mc2";
   attrs[0] = (CGTextAttribute){ 4, CGColorMakeWhite(), CGColorMakeBlack(), -1, -1, 0 };
   attrs[1] = (CGTextAttribute){ 5, CGColorMakeWhite(), CGColorMakeBlack(), -1, 16.0f, -12.0f };
   CGContextAttributedText( context, CGPointMake( 10, 90), text, 5, attrs, 2);

   // --- Line 4: italic font switch ---
   text = "This is italic text";
   attrs[0] = (CGTextAttribute){ 8,  CGColorMakeWhite(), CGColorMakeBlack(), -1, -1, 0 };
   attrs[1] = (CGTextAttribute){ 14, CGColorMake( 1.0f, 0.8f, 0.4f, 1.0f), CGColorMakeBlack(), italicFont, -1, 0 };
   attrs[2] = (CGTextAttribute){ 19, CGColorMakeWhite(), CGColorMakeBlack(), -1, -1, 0 };
   CGContextAttributedText( context, CGPointMake( 10, 130), text, -1, attrs, 3);

   // --- Line 5: plain text comparison ---
   CGContextTextColor( context, CGColorMake( 0.5f, 0.5f, 0.5f, 1.0f));
   CGContextText( context, CGPointMake( 10, 170), "Plain CGContextText for comparison", -1);

   return( YES);
}


int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 400, 220),
                                           NULL,
                                           0.0f));
}
