# Changelog

## 2.1.5 — 2026-10-24

- Archive the AresEdge developer signing and security guide, its source references, and the published-package offline/network audit evidence in the private source repository.
- Clean up unused legacy editor imports and standardise editor error-message formatting without changing scanner or editor behaviour.
- Stop tracking machine-generated Dart tooling caches so local dependency state and build locks stay out of source changes.

- Resolve CI customer examples from the previously reviewed dependency lock instead of selecting newer versions from the shared cache; reuse the verified lock for SwiftPM acceptance builds.

AresEdge v2.1.5

## 2.1.3 — 2026-10-22

- Refresh installation examples and current-version documentation for AresEdge 2.1.2.

- Add scanner and precision-crop screenshots to the pub.dev listing and keep final dry-run generated files separate from the verified upload snapshot.

- Configure supplied Edge scanner state hints with `AresEdgeScreen.hintBuilder`, alongside overlay colours and the bounded 1–10 second stable-document countdown.

- Prefer precise iOS model corners and explicit confidence independently of output dictionary order; use heatmaps only as fallback.

- Retire camera ownership explicitly on widget disposal and let queued iOS scanner routes acquire a released camera without stealing an active session.

- Support a bounded native stable-document capture countdown (1–10 seconds) for supplied and embedded Identity scanner integrations without changing confidence, motion, freshness or licensing checks.

- Keep iOS neural detection running through automatic capture countdowns and request the photo only after freshness and motion checks succeed, preventing early snapshot pauses from restarting countdowns.

- Prepare authenticated encrypted scanner models from owner store delivery only after native permanent-admin verification, exact model hash validation and atomic private-cache installation.

- Move identity scanner components into the private AresIdentity SDK, retain shared redaction helper imports, and add product-scoped Identity camera licensing.



- Add the public AresEdge documentation and support repository to published package metadata.

- Validate the queued licence-expiry delivery fence using an authenticated model fixture, keeping production model authentication and expiry checks unchanged.

AresEdge v2.1.3

## 2.1.1 — 2026-10-21

- Add the public AresEdge documentation and support repository to published package metadata.
- Restore the Mac runner’s prior pub.dev authentication after short-lived publishing credentials are removed.

- Encode website-only editor screenshots as WebP while retaining PNG assets for the published package and public documentation repository.

- Recover authenticated same-tag pre-upload build retries and document the reviewed dependency cache used by the Mac release runner.

AresEdge v2.1.1

## 2.1.0 — 2026-10-21

- Preserve store-delivered model packaging for owner apps using the same compiled customer core; standard customer apps bundle the encrypted model by default.

- Verify the company publisher independently of source repository metadata and retain the requested editor version across pre-allocation corrective pushes.

- Enable main-push release allocation, macOS native builds, pub.dev publication and documentation-only GitHub releases for the modular editor release.

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

- Add a modular native photo editor with crop/magnifier, drawing, filters and tonal adjustments.
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
