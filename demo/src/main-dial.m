//
// Copyright (c) 2023 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "import-private.h"
static inline void mvgRoundedSector(CGContext *context, // Changed parameter type
                                    CACircle innerCircle,
                                    CACircle outerCircle,
                                    CAAngle startAngle,
                                    CAAngle endAngle,
                                    CGFloat cornerRadius)
{
   CGFloat    halfDistance;
   CGFloat    deltaAngleInner;
   CGFloat    deltaAngleOuter;
   CGPoint    compensatedInnerStart;
   CGPoint    compensatedInnerEnd;
   CGPoint    compensatedOuterStart;
   CGPoint    compensatedOuterEnd;
   CGPoint    innerStart;
   CGPoint    innerEnd;
   CGPoint    outerStart;
   CGPoint    outerEnd;
   CGPoint    middleStart;
   CGPoint    middleEnd;
   CACircle   midCircle;
   CAAngle    increasedOuterStartAngle;
   CAAngle    reducedOuterStartAngle;
   CAAngle    increasedInnerStartAngle;
   CAAngle    reducedInnerStartAngle;
   CAAngle    increasedOuterEndAngle;
   CAAngle    reducedOuterEndAngle;
   CAAngle    increasedInnerEndAngle;
   CAAngle    reducedInnerEndAngle;
   CGFloat    outerCornerRadius;
   CGFloat    innerCornerRadius;

   halfDistance      = (outerCircle.radius - innerCircle.radius) / 2.0f;
   midCircle         = CACircleExtrude( innerCircle, halfDistance);

   outerCornerRadius = fminf( cornerRadius, halfDistance);
   innerCornerRadius = fminf( cornerRadius, halfDistance);

   deltaAngleOuter   = asinf( outerCornerRadius / outerCircle.radius);
   deltaAngleInner   = asinf( innerCornerRadius / innerCircle.radius); // sic

//   reducedStartAngle = CAAngleSubtractRadians( startAngle, deltaAngleInner);
//   compensatedInnerStart = CACirclePointAtAngle( innerCircle, increasedEndAngle);
//   compensatedOuterStart = CACirclePointAtAngle( outerCircle, increasedStartAngle);
   reducedInnerEndAngle   = CAAngleSubtractRadians( endAngle, deltaAngleInner);
   reducedOuterEndAngle   = CAAngleSubtractRadians( endAngle, deltaAngleOuter);

//   increasedInnerEndAngle = CAAngleAddRadians( endAngle, deltaAngleInner);
//   increasedOuterEndAngle = CAAngleAddRadians( endAngle, deltaAngleOuter);
   innerEnd            = CACirclePointAtAngle( innerCircle, endAngle);
   outerEnd            = CACirclePointAtAngle( outerCircle, endAngle);
   middleEnd           = CACirclePointAtAngle( midCircle, endAngle);
   compensatedInnerEnd = CACirclePointAtAngle( innerCircle, reducedInnerEndAngle);
   compensatedOuterEnd = CACirclePointAtAngle( outerCircle, reducedOuterEndAngle);

#if 0
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( innerEnd, 3.0), CGColorMakeMagenta()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( outerEnd, 3.0), CGColorMakeRed()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( middleEnd, 3.0), CGColorMakeOrange()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( compensatedInnerEnd, 3.0), CGColorMakeHotPink()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( compensatedOuterEnd, 3.0), CGColorMakeYellow()); // Converted from mvgFillCircleWithColor
#endif

   increasedInnerStartAngle = CAAngleAddRadians( startAngle, deltaAngleInner);
   increasedOuterStartAngle = CAAngleAddRadians( startAngle, deltaAngleOuter);

//   reducedOuterStartAngle   = CAAngleSubtractRadians( startAngle, deltaAngleOuter);
//   reducedInnerStartAngle   = CAAngleSubtractRadians( startAngle, deltaAngleInner);

   innerStart            = CACirclePointAtAngle( innerCircle, startAngle);
   middleStart           = CACirclePointAtAngle( midCircle, startAngle);
   outerStart            = CACirclePointAtAngle( outerCircle, startAngle);
   compensatedInnerStart = CACirclePointAtAngle( innerCircle, increasedInnerStartAngle);
   compensatedOuterStart = CACirclePointAtAngle( outerCircle, increasedOuterStartAngle);

#if 0
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( innerStart, 3.0), CGColorMakeDodgerBlue()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( middleStart, 3.0), CGColorMakeBlue()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( outerStart, 3.0), CGColorMakeIndigo()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( compensatedInnerStart, 3.0), CGColorMakeBlack()); // Converted from mvgFillCircleWithColor
   CGContextFillCircleWithColor( context, CACircleMakeWithCenterAndRadius( compensatedOuterStart, 3.0), CGColorMakeDarkGray()); // Converted from mvgFillCircleWithColor
#endif

   CGContextBeginPath(context); // Converted from mvgBeginPath

   CGContextMoveTo( context, compensatedInnerStart); // Converted from mvgMoveTo
   CGContextArcTo( context, innerStart, middleStart, innerCornerRadius); // Converted from mvgArcTo

   if( innerCornerRadius < halfDistance)
       CGContextLineTo( context, middleStart); // Converted from mvgLineTo
   CGContextArcTo( context, outerStart, compensatedOuterStart, outerCornerRadius); // Converted from mvgArcTo

   CGContextArc( context, outerCircle, increasedOuterStartAngle,
                 (CAAngleToRadians( reducedOuterEndAngle) - CAAngleToRadians( increasedOuterStartAngle)) / (2.0f * M_PI_f));

   CGContextArcTo( context, outerEnd, middleEnd, outerCornerRadius); // Converted from mvgArcTo
   if( outerCornerRadius < halfDistance)
       CGContextLineTo( context, middleEnd); // Converted from mvgLineTo
   CGContextArcTo( context, innerEnd, compensatedInnerEnd, innerCornerRadius); // Converted from mvgArcTo

   CGContextArc( context, innerCircle, reducedInnerEndAngle,
                 (CAAngleToRadians( increasedInnerStartAngle) - CAAngleToRadians( reducedInnerEndAngle)) / (2.0f * M_PI_f));

#if 0
   CGContextClosePath( context); // Converted from mvgClosePath
#endif
}

static void   drawDial( CGContext *context, // Changed parameter type
                        CGRect rect,
                        CGFloat width,
                        CAAngle startAngle,
                        CAAngle endAngle,
                        CGFloat fill,
                        CGColor color)
{
   CACircle            outerCircle;
   CACircle            innerCircle;
   CGPoint             startPoint;
   CGPoint             endPoint;
   CGFloat             space;
   CGFloat             radians;
   outerCircle = CGRectGetInnerCircle( rect);
   innerCircle = CACircleInset( outerCircle, width);

   startPoint  = CACirclePointAtAngle( outerCircle, startAngle);
   endPoint    = CACirclePointAtAngle( outerCircle, endAngle);

   // the assumption here is, that the "hole" of the dial is at the bottom.
   // The code should be smarter about this though. Idea: take the midpoint
   // get that coordinate, use three points to form a rectangle. Aspect fit
   // rectangle into "rect", now we got an offset and a new inner radius (?)
   //
   space       = CGFloatMinimum( CGRectGetMaxY( rect) - startPoint.y,
                                 CGRectGetMaxY( rect) - endPoint.y);

   innerCircle = CACircleOffset( innerCircle, 0.0f, space / 2.0);
   innerCircle = CACircleExtrude( innerCircle, space / 2.0);

   outerCircle = CACircleOffset( outerCircle, 0.0f, space / 2.0);
   outerCircle = CACircleExtrude( outerCircle, space / 2.0);

   radians     = CAAngleToRadians( CAAngleSubtract( endAngle, startAngle));
   CAAngle  fullEndAngle = endAngle;  // full arc end before fill scaling

   radians    *= CGFloatClampToUnity( fill);
   endAngle    = CAAngleAddRadians( startAngle, radians);

   // draw background track (full arc, dim)
   mvgRoundedSector( context, innerCircle, outerCircle, startAngle, fullEndAngle, 10.0);
   {
      CGColor   dimColor = color;
      dimColor.a = 0.2f;
      CGContextFillColor( context, dimColor);
   }
   CGContextFill( context);

#if 1
   mvgRoundedSector( context, innerCircle, outerCircle, startAngle, endAngle, 10.0);
#else
   CGContextBeginPath( context);
   CGContextArc( context, innerCircle, startAngle, endAngle - startAngle);
   CGContextArc( context, outerCircle, endAngle, startAngle - endAngle);
   CGContextClosePath( context);
#endif
   CGContextFillColor( context, color);
   CGContextFill( context);
}

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext           *context = _context;
   CGRect              canvas;
   CGRect              rect;
   CGFloat             percentage;

   canvas = CGSizePlaceInRect( CGSizeMake( 400, 200), [layer canvas], CGContentModeCenterPoint);
   rect   = CGRectIntegral( canvas);

   percentage = CGContextGetBackAndForthAnimationFactor( context, 120.f * 10.0);

   CGContextStrokeRectWithColor( context, rect, 0.5, CGColorMakeBlack()); // Converted from mvgStrokeRectWithColor
   drawDial( context, rect, 50.0f, CAAngleSouthWest, CAAngleSouthEast, percentage, CGColorMakeDodgerBlue()); // Changed function call

   return( YES);
}

int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 600, 400),
                                           NULL,
                                           60.0f));
}
//
//                           ,╓≤æKª╨╙╙▓█D"╙╙╙*╨¥W▄╓,
//                      ╓▄ª╙└╧▓        █           ⁿ▓▓ª╦w
//                  ╓#╜^*█⌐   `╕       █           ╓▌    `╙%w
//               ╓ΦΓ      █    ╙⌐     ,█,,,Φ      ╓▌         ╙¥▄
//            ,▄▀ █▄       █µ,╓╝,╓≤╗≡≡ª╨╨╨¥≡∞╗w╓,ª█,  ,       ]▄▀V,
//          ,Φ└   ║"▀▄     ,▄▀╨"                 "╙¥▓▓       ▄▀  º▄¥,
//        ,#▌Φ▓▄╓  Φ `█Q▄M╙                           ╙¥▄ ,▄▀ ╙▄⌐`  `Φ
//       ▄▀   `V,"▀▀¼╓╩└                                 ╙¥▓╗ ,       ╙▄
//      Φ       `¥═▄▀                            ╒          ▀▄          ▓
//    .▓         ╓▓]V▄H       ▓                 ,Å            ▀,         ▀
//    █      ,-ª▓╛  `██▀½      "▄  ,╓╓╓╓;╓▄▄▄▄╗▄█,             ╙▄         ▀
//   █  `██▄   ▓. - Φ█═.~     ,≤█▄▀-      `   █└"▀▀▀▀▄╓╓╓╓       ▌    ██▄, █
//  ║⌐  " ▀   ▓╨⌐   }▀`      ,█  `           █      .█▀▄▄███▄     ▌  ` ▀    ▌
//  ▌        ▐M A   '┴      ▌                ▀        ╙█▌████▌    ╙▄        ║⌐
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙███` `╙╙║█  ▐H        █
// █]     ,▄▐H  ██████═ª  ╓` ▄█▀▀▀▀█▄        ████     ╓███` `╙╙║█  ▐H        █
// █ "% ,▄▀ ║░╠K█═╣███^   ╛╓█▀      ▐█         ,╓╓═ª╙└   █      ╙█▄▐▌▓######▌╫
// █║▄▄▄█▄▄▄║H:  "╙▀███▄╓▄,█▌╓▄,,▄∩  ██p$ΦΦ▀▀▀▀▀ΦΦΦR≡≥▄╓ ║▄       ╙j▌` ▄▀╙╗ `╫
// █"      ╙▐H-═M ▄███████¥█H "^╙    '█, ,«^``     `     ║▌        ▐M▄▀    "Φ█
// ║        !█▄▄████≤═^`╓█ █▌╓▀╦▄▀█   ╙█⌐               ╓█▌        ▓ `       █
//  ▌      ,▄██╫██ ▄█═╜" █▌▐█╣Hj⌐ █    █▌╙¥w,           ██▄       ╓▌        ▐M
//  ╢"▄▄#▀▀╙╟█Ü███▀`▀█  ║██J█▄▌jH █    ██    ╙▀W▄;    ,██  `╙w,   █▄     ,╓ █
//   █╙     ▐███▌▀█w ▀█ ╠██████j▌║█▌   ▀██▄       `╙▓██▀w,     ╙╗█'`"▀█▀╙"`║`
//   ╙▌     Φ████████▄██ ███████████    ═██▀W▄,   ╓█▀└         ╓▀ "    ╙▄ ╓▀
//    ╙▄     ╙▀███╙█▄▐██▄,╙▀█████▄▀▄▀▄   ,█M╗ ▀▄██▀╙""*ⁿ═─≈-,,▄▌,        ▄▀
//     `▌╙µ,▄Φ▀x███▄██████████▀V███▀╙└ ,▄#▌████▀`"*«,      .█▀▄▀▄,      ▄╛
//       ▀Ö█  ;▓████████▄▄█▀▄╙W "V▄██▀▀│▄███▀└ ▀╦     "*═╥▄▀ ║,  ║▀▄  ,▓
//        ╙W▀ '█████╨▀▀█████████   "▀▀████└      ╙▄   ,▄▀'   `▀▀╣H ▐▀▄▀
//          ╙▄  ▀▀Γ╓▌  ▄▀ⁿ`╙▀███      ██▌         ╓█R▀▄A█        ▀▀▄▀
//            ╙W,Φ╙  ║█        ▄╙╙ª%≡╦██≤≤╗╗≡≡╜▀▀   ╣▌   █╕     ,▄▀
//              `▀▄M█┘        ║▀▌   ╫"    *Φ▄  █       Φ` ▀▌, ▄M╙
//                 "▀╦,       M ╙▌  ▀       `█W▐▌       wæQ▄▀╙
//                     ╙▀W╥,╓╣   ╙█║        ╫M  █    ,╓▄╝╙`
//                          ╙╙▀%▄▄▄▌,≤▄_▄≡,▐▓▓▄▄#ª▀"`
