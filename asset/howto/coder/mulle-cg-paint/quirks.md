<!-- keywords: mulle-cg-paint, quirks, gradient, limit, two-color, box, radial -->
# Quirks

- `CGPaint` is value-like. Do not transfer it with `mulleGainAccess`/`mulleRelinquishAccess`.
- The API accepts multiple gradient stops, but nanovg effectively limits you to two colors. For richer ramps, stack overlapping shapes or layers.
- `CGBoxGradient` and `CGRadialGradient` are geometry-bound and not rotatable.
- `CGImagePaint` is for using an image as a paint. For bitmap placement or rotation, prefer `CGDrawable` options.
- `CGBlendedPaint` exists for animation/interpolation, not as a general mutable paint container.
- Non-mono paints need bounds. A solid-color pass can succeed while a gradient or image paint path still fails.
