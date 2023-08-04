

// its convenient, that _CGMonoColor can act like CGGradient
@interface _CGMonoColor : CGGradient

@property( readonly) CGColor   color;

+ (instancetype) newWithColor:(CGColor) color;

@end


