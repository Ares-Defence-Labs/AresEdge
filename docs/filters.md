# Image filters

Available in AresEdge **2.1.1** for Android and iOS.

The SDK includes the complete 37-preset AresScan catalogue and the additional Sepia preset. AresScan’s existing filter picker reads its available preset names and order from this shared SDK catalogue, preserving its UI and existing shader renderer. The customer SDK implements the filters in compiled native processing on Android and iOS.

## Discover filters

```dart
final allFilters = AresEdgeFilter.values; // 38, including Sepia.
final scanPresets = AresEdgeFilter.aresScanPresets; // AresScan’s 37 presets.
for (final filter in scanPresets) {
  print('${filter.id}: ${filter.label}');
  print(filter.defaultParameters);
  print(filter.parameterRanges);
}
```

Build your own picker from this list, or embed `AresEdgeFilters(controller: editor)` for the SDK’s thumbnail picker, strength slider and parameter controls. The activity editor provides the same catalogue. Each selection replaces the previous preset; tonal adjustments can be applied afterward. Some presets have neutral defaults until their parameters or LUT are supplied.

## Apply and configure

```dart
await editor.setFilter(AresEdgeFilter.exposure,
  parameters: {'exposure': 0.5}, intensity: 0.8);
await editor.setFilter(AresEdgeFilter.original); // Remove the preset.
await editor.undo(); // Restore previous filter and settings.
final png = await editor.exportImage();
```

Parameters are optional overrides of `defaultParameters`. Unknown keys, non-finite values and out-of-range values are rejected. Strength (`intensity`) ranges from 0 to 1: zero preserves the source. Vignette requires `end > start`. Settings and LUT selections are included in undo history. Image dimensions and orientation are preserved by the filter operation.

## Custom lookup tables

```dart
await editor.setFilter(AresEdgeFilter.lookupTable,
  lookupTable: lutPngBytes, intensity: 0.75);
```

Supply a **512 × 512 PNG or JPEG** containing an 8 × 8 tile layout of 64 blue slices. The encoded input must be no larger than 8 MiB. Without a LUT, LookupTable leaves the image unchanged. The built-in picker’s Import LUT action opens the gallery. Image data is processed on device.

## Full catalogue

Ranges below describe scalar settings; colours use packed ARGB numeric values where named `color`. Matrix entries are `m0`…`m15`. Defaults retain AresScan’s existing preset configurations. CPU/GPU rounding and sampling may produce small pixel differences between renderers.

| API identifier | Display name | Parameters: default (range) |
| --- | --- | --- |
| `original` | Original | None |
| `bright` | Bright | `brightness`: 0.25 (-1…1) |
| `highContrast` | High Contrast | `contrast`: 1.35 (0…4) |
| `grayscale` | GrayScale | None |
| `warm` | Warm | `temperature`: 0.4 (0…15000); `tint`: 0.1 (-200…200); `vibrance`: 0.15 (-2…2) |
| `cool` | Cool | `temperature`: -0.35 (-2000…15000); `tint`: 0 (-200…200); `saturation`: 0.9 (0…2) |
| `bulge` | Bulge | `centerX`: 0.5 (0…1); `centerY`: 0.5 (0…1); `radius`: 1.2 (0…2); `scale`: 0.5 (-1…1) |
| `invert` | Invert | None |
| `cga` | CGA | None |
| `matrix` | Matrix | `matrixIntensity`: 1.2 (0…2); `m0`: 1 (-4…4); `m1`: 0 (-4…4); `m2`: 0 (-4…4); `m3`: 0 (-4…4); `m4`: 0 (-4…4); `m5`: 1 (-4…4); `m6`: 0 (-4…4); `m7`: 0 (-4…4); `m8`: 0 (-4…4); `m9`: 0 (-4…4); `m10`: 1 (-4…4); `m11`: 0 (-4…4); `m12`: 0 (-4…4); `m13`: 0 (-4…4); `m14`: 0 (-4…4); `m15`: 1 (-4…4) |
| `cross` | Cross | `spacing`: 0.03 (0.001…0.5); `lineWidth`: 0.003 (0.0001…0.1) |
| `exposure` | Exposure | `exposure`: 1 (-10…10) |
| `falseColor` | False Color | `firstRed`: 0 (0…1); `firstGreen`: 0 (0…1); `firstBlue`: 0.5 (0…1); `secondRed`: 1 (0…1); `secondGreen`: 0 (0…1); `secondBlue`: 0 (0…1) |
| `gamma` | Gamma | `gamma`: 1.2 (0…3) |
| `glass` | Glass | `centerX`: 0.5 (0…1); `centerY`: 0.5 (0…1); `radius`: 0.25 (0.001…1); `refractiveIndex`: 0.71 (0.01…2) |
| `halftone` | Halftone | `fractionalWidth`: 0.01 (0.001…0.25) |
| `haze` | Haze | `distance`: 0.2 (-0.9…0.9); `slope`: 0 (-0.9…0.9) |
| `highlight` | Highlight | `shadows`: 0 (0…1); `highlights`: 1 (0…1) |
| `hue` | Hue | `hue`: 90 (0…360) |
| `lookupTable` | LookupTable | `lookupIntensity`: 1 (0…1) |
| `luminance` | Luminance | None |
| `threshold` | Threshold | `threshold`: 0.5 (0…1) |
| `opacity` | Opacity | `opacity`: 1 (0…1) |
| `pixelation` | Pixelation | `widthFactor`: 0.005 (0.0001…1); `heightFactor`: 0.005 (0.0001…1); `pixel`: 1 (0.1…100) |
| `rgb` | RGB | `red`: 255 (0…255); `green`: 255 (0…255); `blue`: 255 (0…255) |
| `saturation` | Saturation | `saturation`: 1 (0…2) |
| `solarize` | Solarize | `threshold`: 0.5 (0…1) |
| `vibrance` | Vibrance | `vibrance`: 0 (-2…2) |
| `whiteBalance` | White Balance | `temperature`: 5000 (0…15000); `tint`: 0 (-200…200) |
| `zoomBlur` | Zoom Blur | `centerX`: 0.5 (0…1); `centerY`: 0.5 (0…1); `blurSize`: 1 (0…100) |
| `monochrome` | Monochrome | `monoIntensity`: 0.9 (0…1); `red`: 46 (0…255); `green`: 46 (0…255); `blue`: 46 (0…255) |
| `vivid` | Vivid | `vibrance`: 0.45 (-2…2); `saturation`: 1.2 (0…2) |
| `matte` | Matte | `gamma`: 0.85 (0…3); `contrast`: 0.85 (0…4) |
| `vignette` | Vignette | `centerX`: 0 (0…1); `centerY`: 0 (0…1); `start`: 0.3 (0…1); `end`: 0.85 (0.001…2); `red`: 0 (0…255); `green`: 0 (0…255); `blue`: 0 (0…255) |
| `film` | Film | `exposure`: 0.15 (-10…10) |
| `posterize` | Posterize | `levels`: 10 (2…256) |
| `swirl` | Swirl | `centerX`: 0.5 (0…1); `centerY`: 0.5 (0…1); `radius`: 0.5 (0.001…2); `angle`: 1.2 (-8…8) |
| `sepia` | Sepia | None |

## Access and processing

Scanner and editor share the same offline Edge SDK licence. Filters and export remain subject to native licence checks and the process-wide trial deadline. The catalogue metadata is readable; the processing recipes and implementation remain in the compiled native core. This does not make an on-device binary impossible to inspect.

See [image editor](image-editor.md) for session lifecycle, undo limits, image limits and error handling.

## Embedded picker or activity

Use `AresEdgeFilters(controller: editor)` as one component in your own interface,
or let users open Filters in the fixed activity editor. The activity’s layout
and tool list are supplied by Ares Defence Labs; developer UI customisation is
colour codes only. End users can still select presets and adjust filter settings.

[![Filter previews and selection in AresScan+](../media/editor-filters.png)](../media/editor-filters-full.png)

AresScan+ filter workflow. The SDK includes the catalogue above; AI Tools and
app-specific controls visible in the reference are not included.
