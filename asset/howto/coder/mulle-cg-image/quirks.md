<!-- keywords: mulle-cg-image, quirks, context-bound, textureFlags, multisample, drawable -->
# Quirks

- Create `CGImage` objects only while the owning context is active. They survive across passes but not across unrelated contexts.
- `textureFlags` are part of image identity. Repeated, flipped, or filtered variants are separate `CGImage` values even when they share bytes.
- Multisample images cannot be used as paints; resolve them first with `resolvedImage`.
- `cornerInsets` in `CGDrawableOptions` are for bitmap images only.
- `CGScaleToFit` is the `0.0` sentinel, `CGScaleNone` is `1.0`. Do not treat those as interchangeable numeric scales.
- Unlike CoreGraphics, `CGDrawable` is a first-class drawing surface/value in this repo.
