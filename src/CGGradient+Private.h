

@interface _CGTwoColorGradient : CGGradient

@property( readonly) CGColor   startColor;
@property( readonly) CGColor   endColor;

@end


@interface _CGMultiColorGradient : CGGradient
{
   struct mulle__structarray   _colors;     // currently just 0 an 1
   struct mulle__floatarray    _locations;  // currently just 0 an 1
}

@end

