
@interface _CGMonoColorGradient : CGGradient

@property( readonly) CGColor   startColor;

@end


@interface _CGTwoColorGradient : CGGradient

@property( readonly) CGColor          startColor;
@property( readonly) CGColor          endColor;
@property( readonly) CAAngleRadians   angle;

@end


@interface _CGMultiColorGradient : CGGradient
{
   struct mulle__structarray    _colors;     // currently just 0 an 1
   struct mulle__floatarray     _locations;  // currently just 0 an 1
}

@property( readonly) CAAngleRadians   angle;

@end

