# Anything that does nvg or mvg calls resides in this directory.

So all of this needs to be rewritten if we ditch nanovg sometime..

Ideally the classes in src/ only declare methods in "Future" categories
and then get the actual code from +nanovg headers.

An exception are the CGContext functions which are in CGContext+Drawing.h
and CGContext+DrawingConveniences and the various CGImage/Paint/...+nanovg.h
headers.

