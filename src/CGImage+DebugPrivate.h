enum
{
   CGImageDebug        = 0x001,
   CGImageDebugVerbose = 0x001000
};


@interface NSObject ( CGImage)

- (BOOL) __isCGImage;

@end



#if ! defined( CG_IMAGE_DEBUG_DISABLED)

#define CGImageLog( format, ...)                                             \
do                                                                          \
{                                                                           \
   assert( [self __isCGImage]);                                              \
   if( self->_debugEnabled & CGImageDebug)                                   \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGImageLogVerbose( format, ...)                                      \
do                                                                          \
{                                                                           \
   assert( [self __isCGImage]);                                              \
   if( self->_debugEnabled & CGImageDebugVerbose)                            \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#else

#define CGImageLog( format, ...)                  do {} while( 0)
#define CGImageLogVerbose( format, ...)           do {} while( 0)

#endif


