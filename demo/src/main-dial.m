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

   //
   // Corner radius clamping for rounded sectors
   // ============================================
   //
   // A rounded sector has four corners connected by two arcs (inner, outer)
   // and two straight-ish end caps. Each corner is drawn with arcTo() using
   // a corner radius. Two constraints limit the corner radius:
   //
   // 1. Radial constraint: cornerRadius <= halfDistance
   //    The corner can't be larger than half the track width (outer - inner
   //    radius). Same idea as nvgRoundedRectVarying clamping to halfh.
   //
   // 2. Tangential constraint: cornerRadius <= R * sin(arcSpan/2)
   //    The corner's tangent point on the arc can't exceed half the arc's
   //    chord length. At small arc spans this is the binding constraint.
   //    Example: outerRadius=115, arcSpan=5.4° (0.094 rad)
   //      maxOuter = 115 * sin(0.047) = 115 * 0.047 ≈ 5.4
   //    So a 10px corner radius gets clamped to ~5.4px.
   //    Same idea as nvgRoundedRectVarying clamping to halfw.
   //
   // After computing corner radii, we derive deltaAngle — the angular span
   // consumed by each corner: deltaAngle = asin(cornerRadius / arcRadius).
   // The two corners at each end (start, end) each consume deltaAngle from
   // the outer/inner arc. A third constraint ensures they don't overlap:
   //
   // 3. Delta angle constraint: deltaAngle <= arcSpan/2
   //    Both corners must fit within the arc. Without this clamp, at small
   //    fills the start and end corners overlap, collapsing the arc between
   //    them to zero and producing a degenerate line instead of a filled
   //    wedge. Example: arcSpan=0.094 rad, deltaAngle=0.047 rad
   //      2 * deltaAngle = 0.094 ≈ arcSpan → outer arc span ≈ 0
   //    Clamping deltaAngle to arcSpan/2 = 0.047 ensures the outer arc
   //    always has non-negative span, and the sector smoothly shrinks to
   //    a pill shape at very small fills — same visual behavior as
   //    nvgRoundedRectVarying producing a capsule when width < 2*radius.
   //
   // TL;DR: Think of it like a rounded rectangle that gets very narrow.
   // The corners shrink to fit, and eventually the shape becomes a pill.
   // Same thing happens here, but on a curved track instead of a straight
   // box. Without the clamping, the corners overlap and the shape
   // collapses into an invisible line. Since on OpenGL the line draw ordering
   // is important an inconsistency in the lines may lead to the "fill" going
   // astray (filling the outer), which would be real ugly.
   //
   outerCornerRadius = fminf( cornerRadius, halfDistance);
   innerCornerRadius = fminf( cornerRadius, halfDistance);

   {
      CGFloat   arcSpan = fabsf( CAAngleToRadians( CAAngleSubtract( endAngle, startAngle)));
      if( arcSpan > 0.0f)
      {
         CGFloat   halfArc = arcSpan / 2.0f;
         CGFloat   maxOuter = outerCircle.radius * sinf( fminf( halfArc, (CGFloat) M_PI_2));
         CGFloat   maxInner = innerCircle.radius * sinf( fminf( halfArc, (CGFloat) M_PI_2));
         outerCornerRadius = fminf( outerCornerRadius, maxOuter);
         innerCornerRadius = fminf( innerCornerRadius, maxInner);
      }
   }

   deltaAngleOuter   = asinf( outerCornerRadius / outerCircle.radius);
   deltaAngleInner   = asinf( innerCornerRadius / innerCircle.radius);

   {
      CGFloat   arcSpan  = fabsf( CAAngleToRadians( CAAngleSubtract( endAngle, startAngle)));
      CGFloat   halfSpan = arcSpan / 2.0f;
      deltaAngleOuter = fminf( deltaAngleOuter, halfSpan);
      deltaAngleInner = fminf( deltaAngleInner, halfSpan);
   }

   mulle_fprintf( stderr, "  arcSpan=%.6f outerCR=%.4f innerCR=%.4f dOuter=%.6f dInner=%.6f\n",
                  CAAngleToRadians( CAAngleSubtract( endAngle, startAngle)),
                  outerCornerRadius, innerCornerRadius,
                  deltaAngleOuter, deltaAngleInner);

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

   CGContextArcFromAngleToAngle( context, outerCircle, increasedOuterStartAngle, reducedOuterEndAngle, CARotationDirectionClockWise);

   mulle_fprintf( stderr, "  outerArc: from=%.6f to=%.6f rot=%.6f\n",
                  increasedOuterStartAngle, reducedOuterEndAngle,
                  CAAngleGetRotationTowardsAngle( increasedOuterStartAngle, reducedOuterEndAngle, CARotationDirectionClockWise));

   CGContextArcTo( context, outerEnd, middleEnd, outerCornerRadius); // Converted from mvgArcTo
   if( outerCornerRadius < halfDistance)
       CGContextLineTo( context, middleEnd); // Converted from mvgLineTo
   CGContextArcTo( context, innerEnd, compensatedInnerEnd, innerCornerRadius); // Converted from mvgArcTo

   CGContextArcFromAngleToAngle( context, innerCircle, reducedInnerEndAngle, increasedInnerStartAngle, CARotationDirectionCounterClockWise);

   CGContextClosePath( context);
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
   CGContextArcFromAngleToAngle( context, innerCircle, startAngle, endAngle, CARotationDirectionClockWise);
   CGContextArcFromAngleToAngle( context, outerCircle, endAngle, startAngle, CARotationDirectionCounterClockWise);
   CGContextClosePath( context);
#endif
   CGContextFillColor( context, color);
   CGContextFill( context);
}

static CGFloat   g_fill = -1.0f;  // -1 = animate

static BOOL   drawStuff( CGGraphicsLayer *layer, CGContext *_context)
{
   CGContext           *context = _context;
   CGRect              canvas;
   CGRect              rect;
   CGFloat             percentage;

   canvas = CGSizePlaceInRect( CGSizeMake( 400, 200), [layer canvas], CGContentModeCenterPoint);
   rect   = CGRectIntegral( canvas);

   percentage = (g_fill >= 0.0f) ? g_fill
                                  : CGContextGetBackAndForthAnimationFactor( context, 120.f * 10.0);

   mulle_fprintf( stderr, "fill=%.6f\n", percentage);
   CGContextStrokeRectWithColor( context, rect, 0.5, CGColorMakeBlack());
   drawDial( context, rect, 50.0f, CAAngleSouthWest, CAAngleSouthEast, percentage, CGColorMakeDodgerBlue());

   return( YES);
}

int   main( int argc, char *argv[])
{
   CGFloat   fps = 60.0f;
   int       i;

   for( i = 1; i < argc; i++)
   {
      if( ! strcmp( argv[ i], "-f") && i + 1 < argc)
         fps = atof( argv[ ++i]);
      else if( ! strcmp( argv[ i], "-p") && i + 1 < argc)
         g_fill = atof( argv[ ++i]);
      else if( ! strcmp( argv[ i], "-h") || ! strcmp( argv[ i], "--help") || ! strcmp( argv[ i], "help"))
      {
         mulle_fprintf( stderr,
            "Usage: dial [options]\n"
            "\n"
            "Options:\n"
            "  -f <fps>   framerate (default: 60)\n"
            "  -p <fill>  freeze at fixed fill value 0.0..1.0 (default: animate)\n"
            "  -h         this help\n"
            "\n"
            "Logging (stderr):\n"
            "  fill=       current fill percentage\n"
            "  arcSpan=    arc span in radians\n"
            "  outerArc:   from/to angles and rotation of outer arc\n");
         return( 0);
      }
   }

   return( UIApplicationRunDrawCallbackHz( (CGGraphicsLayerDrawCallback_t *) drawStuff,
                                           CGSizeMake( 600, 400),
                                           NULL,
                                           fps));
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
