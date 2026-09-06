## 0.1.0




feature: add CGNullContext headless drawing context

* new CGNullContext class draws nothing yet keeps full text/layout machinery, so views lay out and hit-test even without a GPU backend
* new no-op/trace drawing function table (CGNullContextFunctionTable) so drawing accessors no longer hit NULL function pointers on the headless context
* new CGNullContextFunctionTableSetTrace/SetTraceFile and -setTraceFile: to log CGContext-level drawing calls as no-ops
* CGNullContextPatchFontFunctionTable keeps real text measurement while no-opping text drawing in font-only contexts
* CGContext now captures an optional Metal surface via -backendMetalLayer and tracks framebuffer textureFlags changes when reusing framebuffers
