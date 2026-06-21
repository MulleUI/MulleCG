<!-- keywords: debugger, mulle-cg-paint, color, gradient, geometry, brighten, dim -->
# mulle-cg-paint

Use this when a visual output is wrong in color, alpha, gradient, or blend — but geometry is correct.

## Local references

- `src/CGPaint.h`
- `src/CGBlendedPaint.h`
- `src/CGColor+MulleObjC.h`
- `src/CGColor+UTF8String.h`
- `test/40-gradient/brighten.m`
- `test/40-gradient/dim.m`
- `test/10-first/paintleak.m`
- `demo/main-cglayer-paint.m`

## Local workflow

1. Start with the same draw path using a flat solid color. If geometry is correct but output color is wrong, the bug is in the paint family.
2. Use `test/40-gradient/brighten.m` and `dim.m` as ground truth for color behavior — they are better references than generic Quartz expectations.
3. If colors/gradients disappear only after refactoring, inspect paint/image lifetime (`test/10-first/paintleak.m` is the canary).
4. If a regression appears after changing color creation or textual color parsing, inspect `src/CGColor+MulleObjC.h` and `src/CGColor+UTF8String.h`.

## Quirks

- Small brighten/dim errors usually mean paint/color math trouble, not tessellation trouble.
- Paints are object families, not just scalar values — `CGPaint`, `CGBlendedPaint`, gradients, and color conversion categories can all be the source of a mismatch.
