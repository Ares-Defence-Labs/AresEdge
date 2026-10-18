# Changelog

## Unreleased

- Harden queued native scanner work and capture delivery against trial expiry;
  remove licence keys from capture events and disable owner AI/video channel tools
  in customer binaries.
- Encrypt customer model assets with authenticated AES-256-GCM; reject corrupted
  containers and plain model replacements. Android loads decrypted model bytes in
  memory; iOS removes protected staging files after ONNX Runtime session creation.
  Offline model encryption does not prevent recovery by a hostile host process.

- Align customer guides and release preparation with verified offline unlimited-app
  licensing, sandbox/production separation, portal licence IDs and cropped output.

- Add repeatable purchased-customer offline checks for multiple Android/iOS app
  identities, customer/admin classification, expiry and Edge-only issuance/renewal.

- Cancel automatic capture immediately when native camera motion invalidates
  geometry, including Pixel fallback/frozen outlines. Preserve cancellation
  events across frame coalescing and discard staged snapshots after invalidation.

- Expose independent grid and capture-countdown trace colours with alpha support.
- Apply the continuous-overlay hardware override to Android motion tracking as
  well as rendering; reset capture readiness when the policy changes.
- Document the shared future pub.dev package integration for AresScan+.

- Suspend automatic camera capture during gallery selection/extraction so imports
  cannot race a camera capture, and retain processing feedback until completion.

- Return cropped, perspective-corrected documents directly from camera and gallery,
  without opening ImageCapture/Cropper or filter UI. Reject missing boundaries
  rather than silently returning the full frame. Add output dimensions, crop
  status and explicit full-frame opt-out configuration.

- Match AresScan automatic scanning: confidence hold, two-second countdown,
  movement cancellation, fresh detector confirmation and fallback readiness.
- Default to automatic capture; retain explicit manual capture configuration.
- Expose scan-state callbacks for custom embedded UI, add countdown feedback to
  the minimal scanner, and stage the image during the final countdown second.
- Apply AresScan display smoothing and bounded motion prediction in native cores.

- Correct native camera overlay rotation, front-camera mirroring and centred
  preview fitting; match AresScan's document tint, grid and glowing corners.
- Compile the Android core against API 36 to match its native dependencies.

- Clarify that the customer package includes the runnable example and the public
  GitHub repository provides documentation and support.

- Reject GitHub/pub.dev redirects through explicit manual response inspection
  for compatibility with the deployed Worker fetch runtime.

- Preserve the Cloudflare fetch receiver when authenticating GitHub Apps and
  fetching source files, so webhook validations can post their required status.

- Fix release-workflow manifest paths to use the runner shell environment and
  add credential-safe diagnostics for retrying validation events.

- Enable webhook changelog validation independently of releases, with runner
  publication endpoints explicitly disabled in validation-only mode.

- Add private repository protection policies with trusted changelog checks,
  automation-only release tag creation and immutable release tags.

- Prepare the private release activation and recovery runbook; use macOS system
  certificate verification for credential-safe release callbacks.

- Configure disabled release infrastructure, repository-scoped GitHub App credentials and an offline macOS runner with an isolated native build host.

- Prepare a private, disabled release setup bundle and verify Cloudflare/GitHub connection readiness.

- Verify unlimited-app customer keys against native Android/iOS verifiers and normalize legacy AresEdge checkout and renewal app hints.

- Document unlimited customer apps across supported platforms and the developer’s responsibility to ship renewed keys before expiry.

- Clarify free developer evaluation, live-session deactivation and production licence configuration.

- Automate versioned SDK releases and public documentation from main-branch changelog updates.
- Enforce meaningful release notes on every push, with exact-version overrides through the AresEdge footer.

AresEdge v2.0.0

## 2.0.0 — unreleased

- Add opt-in native camera/analysis FPS and ONNX timing windows via onPerformance.
- Extend the workbench and JSON comparisons with native measurements.

- Introduce AresEdgeEmbedded and AresEdgeScreen through ares_edge.dart.
- Add AresEdgeController capture, explicit torch and toggle controls.
- Add typed options, quality/shape enums and immutable image callback results.
- Return cropped, perspective-corrected camera/gallery document bytes directly; defer image editing to a later release.
- Prepare the ares_edge customer binary package and complete integration example.
- Document offline licensing, commercial use, process trial and renewal.

No version has been published to pub.dev by this preparation work.
