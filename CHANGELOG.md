# Changelog

## Unreleased

- Separate fixed activity colours from embedded component/session options; add cropper, filter and text workflow screenshots.
- Add portable typography controls, host-owned component toolbars, crop/stroke/colour-matrix commands, and bounded undo/redo.
- Route AresScan’s existing filter, adjustment and crop controls through the shared licensed native editor without replacing its owner UI.

- Build the native filter core with 16 KiB ELF/RELRO alignment and reject misaligned Android customer binaries during package validation.

- Include the full AresScan filter catalogue in the native editor, with strength, parameter controls and custom LUT support; share preset discovery with AresScan.

- Size Google Play and App Store README badges consistently with compact PNG
  assets and standard Markdown links for pub.dev and GitHub rendering.

- Open the SDK image editor first with a cropped preview; preserve the full
  captured photo for its on-demand Adjust crop activity, seed detected
  corners, and provide Retake/Detect/Done, shaded surroundings, dashed guides and
  white corner handles with a source-aligned magnifier. Animate Auto Detect
  corner/grid transitions without replacing the source image. Add non-destructive
  `detectCorners()` to the reusable editor controller. Direct capture without
  the editor still returns the perspective-cropped document.

- Add basic offline text annotations and native filter preview cards; simplify the SDK activity to Document scanning with Auto/Manual controls and no templates or specialisations.

- Align ready-made scanner/editor pages and native embedded controls with the AresScan mint palette, rounded tool docks and light/dark surfaces.

- Add a local, unpublished modular native photo editor with crop/magnifier, drawing, filters and tonal adjustments.
- Open the editor by default from the scanner; allow developers to skip it or embed individual editing components.

- Verify the commercial customer package against pub.dev scoring conventions without exposing private SDK source.

AresEdge v2.1.0

## 2.0.2 — 2026-10-19

- Resolve all ten public-wrapper flow-control lints and verify Dart formatting.
- Enforce flow-control lint checks during customer API validation.
- Keep the documentation-only GitHub project in README and issue links rather than declaring it as the package source repository.

## 2.0.1 — 2026-10-19

- Keep automated upload receipts consistent with the files included in registry downloads, without changing guarded review inputs.

- Improve discovery with document-scanner, edge-detection, scanner, camera and image-processing topics and an accurate searchable description.
- Use absolute branding, scanning media and documentation links that render on pub.dev and GitHub.
- Support the current-release README marker when assembling future customer packages.

## 2.0.0 — 2026-10-18

- Introduce the commercial AresEdge document-scanning SDK for Android and iOS.
- Embed a camera and edge overlay with AresEdgeEmbedded, or use AresEdgeScreen for a minimal ready-made scanner.
- Control capture and the flashlight through AresEdgeController and receive scan-state callbacks.
- Return cropped, perspective-corrected documents directly, including gallery input, without opening an image editor.
- Automatically capture steady documents after a confidence hold and countdown; cancel capture when motion or stale detection invalidates the boundary.
- Configure overlay, grid and capture-trace colours, quality, document shape and output size.
- Select device-managed overlay behaviour or force continuous tracking for performance comparisons.
- Expose opt-in native camera/analysis/inference FPS and detector timing samples.
- Validate signed customer licences entirely offline across unlimited supported Android/iOS apps, with a process-scoped evaluation trial.
- Distribute compiled native cores and an authenticated encrypted inference model behind a documented Flutter API.
- Include a complete scanner example, performance workbench, scanning demonstrations, integration guides, commercial terms and third-party notices.
