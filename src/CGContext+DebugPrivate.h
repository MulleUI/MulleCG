
enum
{
   CGContextDebug                 = 0x000001,
   CGContextDebugVerbose          = 0x001000,

   CGContextDebugRender           = 0x000008,  // like UIWindowDebugRender
   CGContextDebugRenderVerbose    = 0x008000,

   CGContextDebugTraceDrawCalls   = UIGraphicsContextTraceDrawCalls,
   CGContextDebugDumpFrameToFile  = 0x08000000  // same bit as UIWindow
};


@interface NSObject ( CGContext)

- (BOOL) __isCGContext     MULLE_OBJC_THREADSAFE_METHOD;

@end



#if ! defined( CG_CONTEXT_LOG_DISABLED)

#define CGContextLog( format, ...)                                          \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debuggingFlags & CGContextDebug)                              \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGContextLogVerbose( format, ...)                                   \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debuggingFlags & CGContextDebugVerbose)                       \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)


#define _CGContextRenderLog( self, format, ...)                             \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( [self debuggingFlags] & CGContextDebugRender)                        \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGContextRenderLog( format, ...)                                    \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debuggingFlags & CGContextDebugRender)                        \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGContextRenderLogVerbose( format, ...)                             \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debuggingFlags & CGContextDebugRenderVerbose)                 \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#else

#define CGContextLog( format, ...)                  do {} while( 0)
#define CGContextLogVerbose( format, ...)           do {} while( 0)
#define _CGContextRenderLog( self, format, ...)     do {} while( 0)
#define CGContextRenderLog( format, ...)            do {} while( 0)
#define CGContextRenderLogVerbose( format, ...)     do {} while( 0)

#endif


