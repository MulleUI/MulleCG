#ifndef MulleCG_asprintf_h__
#define MulleCG_asprintf_h__

#include <stdarg.h>

// This is MulleCG_asprintf duplicated, as we don't base on
// MulleObjCValueFoundation. It can't be moved into MulleObjC, as
// we don't want mulle-buffer and mulle-sprintf there
//
char   *MulleCG_vasprintf( char *format, va_list args);
char   *MulleCG_asprintf( char *format, ...);

#endif
