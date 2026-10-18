# Changelog

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
