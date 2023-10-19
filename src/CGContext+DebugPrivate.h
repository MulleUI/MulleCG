
enum
{
   CGContextDebug                 = 0x000001,
   CGContextDebugVerbose          = 0x001000,

   CGContextDebugRender           = 0x000002,
   CGContextDebugRenderVerbose    = 0x002000,

   CGContextDebugDumpFrameToFile   = 0x08000000  // same bit as UIWindow
};


@interface NSObject ( CGContext)

- (BOOL) __isCGContext;

@end



#if ! defined( CG_CONTEXT_DEBUG_DISABLED)

#define CGContextLog( format, ...)                                          \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debugEnabled & CGContextDebug)                                \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGContextLogVerbose( format, ...)                                   \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debugEnabled & CGContextDebugVerbose)                         \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)


#define CGContextRenderLog( format, ...)                                    \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debugEnabled & CGContextDebugRender)                          \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#define CGContextRenderLogVerbose( format, ...)                             \
do                                                                          \
{                                                                           \
   assert( [self __isCGContext]);                                           \
   if( self->_debugEnabled & CGContextDebugRenderVerbose)                   \
      mulleui_log_object_method( self, (char *) __PRETTY_FUNCTION__,        \
                                       (char *) format, ## __VA_ARGS__);    \
}                                                                           \
while( 0)

#else

#define CGContextLog( format, ...)                  do {} while( 0)
#define CGContextLogVerbose( format, ...)           do {} while( 0)
#define CGContextRenderLog( format, ...)            do {} while( 0)
#define CGContextRenderLogVerbose( format, ...)     do {} while( 0)

#endif


