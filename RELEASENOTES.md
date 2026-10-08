## 0.2.0


* README now shows how to add MulleCG and its full dependency graph as git submodules, `add_subdirectory()` each, and link them with `target_link_libraries()`
* API documentation notes the CMake subproject alternative to adding MulleCG via mulle-sde



* fontconfig is now initialized at most once and finalized via FcFini, eliminating process-lifetime "definitely lost" allocations reported by valgrind when querying or resolving system fonts
* the fontconfig backend no longer leaks its parsed configuration (loaded through libexpat) after system font enumeration or resolution



feature: add native system font backends for Apple, Windows and Android

* Core Text backend resolves and enumerates installed fonts on macOS and iOS
* DirectWrite backend for Windows, bound at runtime so cross-build toolchains need no import library
* Android NDK backend using ASystemFontIterator/AFontMatcher on Android 10 (API 29) and later
* system font descriptors now uniformly report family, style, weight, italic and .ttc/.otc face index across backends


## 0.1.0




feature: add CGNullContext headless drawing context

* new CGNullContext class draws nothing yet keeps full text/layout machinery, so views lay out and hit-test even without a GPU backend
* new no-op/trace drawing function table (CGNullContextFunctionTable) so drawing accessors no longer hit NULL function pointers on the headless context
* new CGNullContextFunctionTableSetTrace/SetTraceFile and -setTraceFile: to log CGContext-level drawing calls as no-ops
* CGNullContextPatchFontFunctionTable keeps real text measurement while no-opping text drawing in font-only contexts
* CGContext now captures an optional Metal surface via -backendMetalLayer and tracks framebuffer textureFlags changes when reusing framebuffers
