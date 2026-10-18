# AresEdge public API reference

Import `package:ares_edge/ares_edge.dart`. Everything here is also documented in
Dart comments. The implementation and legacy private scanner classes are not part
of this entry point. All widgets require Flutter material and Android/iOS.

## AresEdgeOptions

`const AresEdgeOptions({bool forceEdgeOverlay = false, bool showEdgeOverlay = true,
Color overlayColor = const Color(0xFF00FFD1),
Color gridColor = const Color(0x47FFFFFF), Color? captureTraceColor,
AresEdgeQuality quality =
AresEdgeQuality.balanced, AresEdgeShape shape = AresEdgeShape.rectangle,
bool autoCapture = true, bool flashEnabled = false, bool extractDocument = true,
int maxDocumentDimension = 1600})`

| Property | Meaning |
| --- | --- |
| forceEdgeOverlay | False uses device policy; true overrides eligibility for continuous tracking and moving animation, including fallback devices. Does not bypass capture readiness or licensing. |
| showEdgeOverlay | Show/hide outline; detection still runs when hidden. |
| overlayColor | Detected corners, perimeter and document tint colour. |
| gridColor | Rule-of-thirds grid ARGB colour, including alpha. Default translucent white (`0x47FFFFFF`); transparent hides it. |
| captureTraceColor | Capture-countdown border trace ARGB colour, including alpha. Null follows overlayColor at the default trace opacity; transparent hides it. |
| quality | Requested analysis detail/resolution; device capability still applies. |
| shape | Detection/crop geometry. |
| autoCapture | AresScan capture hold and two-second countdown by default; false selects manual capture. |
| flashEnabled | Initial torch request; a changed value on rebuild updates the torch. |

`AresEdgeQuality`: `low`, `balanced`, `high`.
`AresEdgeShape`: `rectangle`, `circle` (bounding geometry), `card`.
All settings are immutable; construct a new options object to change settings.

## AresEdgeController extends ChangeNotifier

`AresEdgeController()` retains capture/torch bindings. Host must dispose it.

| Member | Contract |
| --- | --- |
| `bool get isAttached` | Widget attached and controller not disposed; not a native-ready/permission guarantee. |
| `bool get flashEnabled` | Last requested torch state, not hardware telemetry. |
| `bool get commandPending` | Capture/torch command awaiting acknowledgement. |
| `Future<void> capture()` | Request still; bytes arrive later through onCapture. |
| `Future<void> setFlashEnabled(bool enabled)` | Request torch state, hardware permitting. |
| `Future<void> toggleFlash()` | Toggle last requested state. |
| `void dispose()` | Release host controller; unmount camera to release native camera resources. |

Commands fail with StateError when detached/disposed or another command is pending.
Native errors may throw PlatformException; also handle the widget's onError.
Listeners are notified around commands. One active camera/controller per SDK.

## AresEdgeImage

Callback result with `Uint8List bytes`: a defensive, unmodifiable copy of cropped
document bytes by default. No public constructor, native geometry or mutable SDK
state is exposed. Persist bytes in your own storage if needed after navigation.

## AresEdgeEmbedded extends StatefulWidget

`const AresEdgeEmbedded({Key? key, required AresEdgeController controller,
required FutureOr<void> Function(AresEdgeImage image) onCapture, String? licenceKey,
AresEdgeOptions options = const AresEdgeOptions(), ValueChanged<String>? onError,
VoidCallback? onLicenceRequired, ValueChanged<AresEdgePerformance>? onPerformance,
ValueChanged<AresEdgeScanState>? onScanStateChanged})`

| Member | Contract |
| --- | --- |
| controller | Host controls; attach to one embedded widget only. |
| licenceKey | Full portal-issued signed key, not the licence ID; null for trial. Verified offline. Customer keys cover unlimited Android/iOS apps. Sandbox keys require a sandbox-trusted build. |
| options | Immutable camera and overlay settings. |
| onCapture | Extracted document. Async callbacks are serialised; duplicate callbacks while processing are ignored. |
| onError | Native/status errors and capture callback failures; host decides presentation. |
| onLicenceRequired | Camera access expired; preview already stopped/replaced. |
| onPerformance | Optional native measurement windows; null disables collection/transport. |

Contains camera/overlay, required trial notice and expired-trial message. No normal
toolbar/editor/navigation. Requires bounded constraints. Lifecycle-managed.

## AresEdgeScreen extends StatefulWidget

`const AresEdgeScreen({Key? key, String? licenceKey, AresEdgeOptions options =
const AresEdgeOptions(),
ValueChanged<Uint8List?>? onComplete, ValueChanged<String>? onError,
ValueChanged<AresEdgePerformance>? onPerformance})`

| Member | Contract |
| --- | --- |
| licenceKey | Same signed offline key as embedded. |
| options | Same immutable camera configuration. |
| onComplete | Optional callback, called once. Without it the route pops. Null indicates cancel/expiry. |
| onError | Reports failures, also shown on screen. |
| onPerformance | Native telemetry while the scanner camera is active; null disables it. |

`static Future<Uint8List?> open(BuildContext context, {String? licenceKey,
AresEdgeOptions options = const AresEdgeOptions(),
ValueChanged<AresEdgePerformance>? onPerformance})`
opens a fullscreen-dialog Flutter route. Await cropped document bytes or null.
Check context.mounted before subsequent navigation. Back dismisses the screen;
picker cancellation returns to scanning. Available controls: back, torch,
capture and gallery. Unsupported platforms throw UnsupportedError from native view
creation; permission failures are reported via onError/preview error state.

## AresEdgePerformance

Immutable native window supplied to `onPerformance`. `AresEdgePerformance.fromMap`
parses a previously recorded native map and throws FormatException on malformed
or non-finite values. Parsing metrics never authorises SDK access.

| Member | Meaning |
| --- | --- |
| sessionId | Per-camera/telemetry session identifier; changes on restart. |
| sequence | Increasing window number within that session. |
| window | Actual monotonic Duration covered by the window. |
| sessionElapsed | Native monotonic Duration since session start, for warm-up filtering. |
| cameraFrames / cameraFps | SDK camera-ingress frame count and rate. |
| analysisFrames / analysisFps | Native analysis/tracking frame count and rate. |
| inferenceRuns / inferenceFps | Completed ONNX detector cycles and rate, before geometry filtering. |
| inferenceMs | Unmodifiable ONNX execution-time samples in milliseconds. |
| processingMs | Native detector pipeline elapsed samples; platform scope is described in the benchmarking guide. |
| preprocessMs | Native input-preparation samples. |
| decodeMs | Native output-decoding samples. |
| timingSamplesDropped | Samples omitted after the 256-record per-window transport limit. |

No callback means telemetry collection is disabled. The native licence and trial
checks apply as usual. Empty inference samples mean no ONNX measurement occurred,
including classical/tracking-only paths. FPS is not inferred from overlay events,
Flutter redraws or reciprocal inference latency. See [benchmarking](performance-testing.md).

## Public API boundary

Import only `package:ares_edge/ares_edge.dart`. The customer package exposes:

| Type | Purpose |
| --- | --- |
| `AresEdgeEmbedded` | Embedded native camera and edge overlay with your controls. |
| `AresEdgeScreen` | Ready-made scanner, torch, back and gallery workflow. |
| `AresEdgeController` | Capture and torch commands for an attached camera. |
| `AresEdgeOptions` | Overlay, capture, quality, extraction and device-policy settings. |
| `AresEdgeImage` | Cropped image bytes, dimensions, format and extraction metadata. |
| `AresEdgeScanState` | Searching, holding, countdown and capturing status. |
| `AresEdgePerformance` | Native camera FPS and inference timing windows. |
| `AresEdgeQuality` | Requested camera analysis quality. |
| `AresEdgeShape` | Document, round-paper or card boundary selection. |

The native channel adapter is a library-private Dart part. It cannot be imported
as a separate library and its classes cannot be referenced from consumer code.
There is no customer compatibility `Edge*` library, activation service API,
`QuadFrame`, editor, cropper screen, identity parser or owner implementation API.
Document extraction remains internal; it does not require an exposed cropper.
Pass the purchased licence key through the camera/screen configuration.

### Capture state

`AresEdgeEmbedded.onScanStateChanged` receives an `AresEdgeScanState` with
`phase` (`searching`, `holding`, `countdown`, `capturing`), `remainingSeconds`
(zero outside a countdown), and a short `message` for your own UI. Capture is
confirmed by native detector results; displayed/smoothed points are not capture
evidence. Continuous mode holds confidence for 1.5 seconds, then counts down two
seconds. Fallback mode requires repeated settled detections before that countdown.

### Document extraction settings and result

`extractDocument` defaults to true: camera and gallery output is cropped and
perspective-corrected without an editor route. Missing geometry reports
`DOCUMENT_NOT_FOUND`. False explicitly returns the full image.
`maxDocumentDimension` defaults to 1600 pixels, accepts 256–4096 and never upscales.
`AresEdgeImage.isDocumentCropped`, `width` and `height` describe the result.
Circular extraction returns PNG with transparent corners; rectangular extraction
normally returns JPEG. Output orientation is upright with the crop applied.
