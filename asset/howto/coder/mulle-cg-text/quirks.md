<!-- keywords: mulle-cg-text, quirks, font, lifetime, default -->
# Quirks

- `CGFont` is only valid during rendering. Do not retain it across passes.
- Font loading can do I/O. Avoid first-time font loads deep inside hot draw paths — preload earlier if possible.
- The default font name is `"sans"`. If a font switch fails, check that you are using names the context already knows.
- `CGContextFormat` works out of the box with the default font. No explicit font setup is required for simple text if you accept the default.
- There is no built-in "centered in rect" function. Use `CGTextAlignCenter | CGTextAlignMiddle` with the rect's midpoint coordinates.
