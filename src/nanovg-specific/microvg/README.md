# microvg / millivg

These functions are not at the abstraction layer, the UI programmer would
use. Instead they form the basis for the UI..Draw.. C functions, one should
use instead. Why ?

* supposed portability across different drawing libraries


#### 🍢 microvg - conveniences atop nanovg

All functions accept the current nanovg context `NVGcontext *vg` as the
first parameter. To distinguish them from **nanovg**, they are prefixed `mvg`
(microvg) instead of nvg (nanovg).

Unless indicated or obvious from the function parameters, you set the desired
nanovg state before the function call. Functions try to avoid clobbering nanovg
state, that is not apparently affected from the function call parameters.
(But check the header declaration for exceptions).

Though not prefixed with `_` these functions will crash if the `vg` 
parameter is NULL, just like the nanovg counterparts.


#### Example

`mvgLineH` draws a horizontal of a specific color. It is expected that this
function changes the stroke color state (and leaves it as blue). It is also
expected that this function begins a new path and discards a possible old one.
But as there is no parameter for the width of the stroke, the current value
will be inherited and left unchanged.


``` c
nvgStrokeWidth( vg, 1.0f);
mvgLineH( vg, 100.0f, 200,0f, 50.0f, CGColorMakeBlue());
```

| Function                    | Clobbers | Description               |
|-----------------------------|----------|---------------------------|
| `[mvgLineH](microvg.h#6)`   |    NO    | Draw a horizontal line    |
| `[mvgLineV](microvg.h#15)`  |    NO    | Draw a vertical line      |



#### 🥙 millivg - mulle-geometry conveniences atop nanovg and microvg

These functions use "mulle-geometry" and "mulle-color" datatypes like
`CGRect` and `CGColor`. Yet the context is still a `NVGcontext` and the same
principles apply as outlined in `microvg`. This allows the library to keep
the number of parameters in a function down. A CGContext would be necessarily
more abstract...


The prefix use is `mvg` (millivg), which is shared with microvg.


| Function                      | Clobbers  | Description
|-------------------------------|-----------|---------------------------
| `mvgFillRectWithColor(millivg.h#22)`   |     -     | Draw a horizontal line
| `mvgStrokeRectWithColor(millivg.h#35)` |     -     | Draw a vertical line
| `mvgTextInRect(millivg.h#28)` | alignment | Draw text in rectangle, with multiple contentModes and options
| `mvgText(millivg.h#56)`       | alignment | Draw text in rectangle, with multiple contentModes and options

