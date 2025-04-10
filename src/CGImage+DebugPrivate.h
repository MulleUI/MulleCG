enum
{
   CGImageDebug        = 0x001,
   CGImageDebugVerbose = 0x001000
};


@interface NSObject ( CGImage)

- (BOOL) __isCGImage       MULLE_OBJC_THREADSAFE_METHOD;

@end

//
// since CGImages have been the greatest source of problems
// when developing MulleUI, we have two special log formats _CGImageLog
// which you can use in methods of a different class than GCImage, yet
// enjoy the specifity of CGImageDebuggingFlags to get log verbosity slim
//
#if ! defined( CG_IMAGE_LOG_DISABLED)

#define _CGImageLog( self, format, ...)                                     \
do                                                                          \
{                                                                           \
   assert( ! self || [self __isCGImage]);                                   \
   if( [self debuggingFlags] & CGImageDebug)                                \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGImageLog( format, ...)                                            \
do                                                                          \
{                                                                           \
   assert( [self __isCGImage]);                                             \
   if( self->_debuggingFlags & CGImageDebug)                                \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define _CGImageLogVerbose( self, format, ...)                              \
do                                                                          \
{                                                                           \
   assert( ! self || [self __isCGImage]);                                   \
   if( [self debuggingFlags] & CGImageDebugVerbose)                         \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)


#define CGImageLogVerbose( format, ...)                                     \
do                                                                          \
{                                                                           \
   assert( [self __isCGImage]);                                             \
   if( self->_debuggingFlags & CGImageDebugVerbose)                         \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#else

#define _CGImageLog( image, format, ...)          do {} while( 0)
#define CGImageLog( format, ...)                  do {} while( 0)
#define _CGImageLogVerbose( format, ...)          do {} while( 0)
#define CGImageLogVerbose( format, ...)           do {} while( 0)

#endif


