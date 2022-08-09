#import "import.h"

#define MULLE_CG_VERSION   ((0 << 20) | (0 << 8) | 1)

#import "_MulleCG-export.h"

// we have no provide
#include "nanovg.h"

#include "microvg.h"
#include "millivg.h"

#ifdef __has_include
# if __has_include( "_MulleCG-versioncheck.h")
#  include "_MulleCG-versioncheck.h"
# endif
#endif

