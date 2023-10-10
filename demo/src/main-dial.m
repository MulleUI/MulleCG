#define _GNU_SOURCE

#import "import-private.h"


static inline void mvgRoundedSector(NVGcontext *vg,
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
   CGPoint    innerStart;
   CGPoint    innerEnd;
   CGPoint    outerStart;
   CGPoint    outerEnd;
   CGPoint    compensatedOuterStart;
   CGPoint    compensatedOuterEnd;
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
   mvgFillCircleWithColor( vg, CACircleMake( innerEnd, 3.0), CGColorMakeMagenta());
   mvgFillCircleWithColor( vg, CACircleMake( outerEnd, 3.0), CGColorMakeRed());
   mvgFillCircleWithColor( vg, CACircleMake( middleEnd, 3.0), CGColorMakeOrange());
   mvgFillCircleWithColor( vg, CACircleMake( compensatedInnerEnd, 3.0), CGColorMakeHotPink());
   mvgFillCircleWithColor( vg, CACircleMake( compensatedOuterEnd, 3.0), CGColorMakeYellow());
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
   mvgFillCircleWithColor( vg, CACircleMake( innerStart, 3.0), CGColorMakeDodgerBlue());
   mvgFillCircleWithColor( vg, CACircleMake( middleStart, 3.0), CGColorMakeBlue());
   mvgFillCircleWithColor( vg, CACircleMake( outerStart, 3.0), CGColorMakeIndigo());
   mvgFillCircleWithColor( vg, CACircleMake( compensatedInnerStart, 3.0), CGColorMakeBlack());
   mvgFillCircleWithColor( vg, CACircleMake( compensatedOuterStart, 3.0), CGColorMakeDarkGray());
#endif

   mvgBeginPath(vg);

   mvgMoveTo( vg, compensatedInnerStart);
   mvgArcTo( vg, innerStart, middleStart, innerCornerRadius);

   if( innerCornerRadius < halfDistance)
       mvgLineTo( vg, middleStart);
   mvgArcTo( vg, outerStart, compensatedOuterStart, outerCornerRadius);

   mvgArc( vg, outerCircle, increasedOuterStartAngle, reducedOuterEndAngle, NVG_CW);

   mvgArcTo( vg, outerEnd, middleEnd, outerCornerRadius);
   if( outerCornerRadius < halfDistance)
       mvgLineTo( vg, middleEnd);
   mvgArcTo( vg, innerEnd, compensatedInnerEnd, innerCornerRadius);

   mvgArc( vg, innerCircle, reducedInnerEndAngle, increasedInnerStartAngle, NVG_CCW);
}





static void   drawDial( CGContext *context,
                        CGRect rect,
                        CGFloat width,
                        CAAngle startAngle,
                        CAAngle endAngle,
                        CGFloat fill,
                        CGColor color)
{
   struct NVGcontext   *vg;
   CACircle            outerCircle;
   CACircle            innerCircle;
   CGPoint             startPoint;
   CGPoint             endPoint;
   CGFloat             space;
   CGFloat             radians;

   vg          = CGContextGetNVGContext( context);

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
   radians    *= CGFloatClampToUnity( fill);
   endAngle    = CAAngleAddRadians( startAngle, radians);

#if 1
   mvgRoundedSector( vg, innerCircle, outerCircle, startAngle, endAngle, 10.0);
#else
   mvgBeginPath( vg);
   mvgArc( vg, innerCircle, startAngle, endAngle, NVG_CW);
   mvgArc( vg, outerCircle, endAngle, startAngle, NVG_CCW);
   mvgClosePath( vg);
#endif
//   mvgFillWithColor( vg, CGColorMakeLightGray());
   mvgStrokeWithColor( vg, 1.0, CGColorMakeGray());
}



static BOOL   drawStuff( CALayer *layer, void *_context)
{
   CGContext           *context = _context;
   struct NVGcontext   *vg;
   CGRect              canvas;
   CGRect              rect;
   CGFloat             percentage;

   vg     = CGContextGetNVGContext( context);
   canvas = CGSizePlaceInRect( CGSizeMake( 400, 200), [layer canvas], CGContentModeCenterPoint);
   rect   = CGRectIntegral( canvas);

   percentage = CGContextGetBackAndForthAnimationFactor( context, 120.f * 10.0);

   mvgStrokeRectWithColor( vg, rect, 0.5, CGColorMakeBlack());
   drawDial( context, rect, 50.0f, CAAngleSouthWest, CAAngleSouthEast, percentage, CGColorMakeDodgerBlue());

   return( YES);
}



int   main( int argc, char *argv[])
{
   return( UIApplicationRunDrawCallbackHz( (CALayerDrawCallback_t *) drawStuff,
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
// ║⌐        █⌐'║▄ Γr2«    ║▀                 ▄▄▄      ╙▌▄███      █         ▌
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
