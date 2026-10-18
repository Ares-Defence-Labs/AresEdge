# AresEdge public API reference

Import `package:ares_edge/ares_edge.dart`. Everything here is also documented in
Dart comments. The implementation and legacy private scanner classes are not part
of this entry point. All widgets require Flutter material and Android/iOS.

## AresEdgeOptions

`const AresEdgeOptions({bool forceEdgeOverlay = false, bool showEdgeOverlay = true,
Color overlayColor = const Color(0xFF00FFD1), AresEdgeQuality quality =
AresEdgeQuality.balanced, AresEdgeShape shape = AresEdgeShape.rectangle,
bool autoCapture = false, bool flashEnabled = false})`

| Property | Meaning |
| --- | --- |
| forceEdgeOverlay | Force continuous overlay instead of automatic device policy. Does not enable auto-capture. |
| showEdgeOverlay | Show/hide outline; detection still runs when hidden. |
| overlayColor | ARGB outline colour. |
| quality | Requested analysis detail/resolution; device capability still applies. |
| shape | Detection/crop geometry. |
| autoCapture | Capture stable detections automatically; false requires controller/button. |
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

Callback result with `Uint8List bytes`: a defensive, unmodifiable copy of original
compressed image bytes. No public constructor, native geometry or mutable SDK
state is exposed. Persist bytes in your own storage if needed after navigation.

## AresEdgeEmbedded extends StatefulWidget

`const AresEdgeEmbedded({Key? key, required AresEdgeController controller,
required FutureOr<void> Function(AresEdgeImage image) onCapture, String? licenceKey,
AresEdgeOptions options = const AresEdgeOptions(), ValueChanged<String>? onError,
VoidCallback? onLicenceRequired, ValueChanged<AresEdgePerformance>? onPerformance})`

| Member | Contract |
| --- | --- |
| controller | Host controls; attach to one embedded widget only. |
| licenceKey | Developer-configured signed key or null for trial; verified offline. |
| options | Immutable camera and overlay settings. |
| onCapture | Original image. Async callbacks are serialised; duplicate callbacks while processing are ignored. |
| onError | Native/status errors and capture callback failures; host decides presentation. |
| onLicenceRequired | Camera access expired; preview already stopped/replaced. |
| onPerformance | Optional native measurement windows; null disables collection/transport. |

Contains camera/overlay, required trial notice and expired-trial message. No normal
toolbar/editor/navigation. Requires bounded constraints. Lifecycle-managed.

## AresEdgeScreen extends StatefulWidget

`const AresEdgeScreen({Key? key, String? licenceKey, AresEdgeOptions options =
const AresEdgeOptions(), bool editAfterCapture = true,
ValueChanged<Uint8List?>? onComplete, ValueChanged<String>? onError,
ValueChanged<AresEdgePerformance>? onPerformance})`

| Member | Contract |
| --- | --- |
| licenceKey | Same signed offline key as embedded. |
| options | Same immutable camera configuration. |
| editAfterCapture | true: editor; false: original camera/gallery image, no edits. |
| onComplete | Optional callback, called once. Without it the route pops. Null indicates cancel/expiry. |
| onError | Reports failures, also shown on screen. |
| onPerformance | Native telemetry while the scanner camera is active; null disables it. |

`static Future<Uint8List?> open(BuildContext context, {String? licenceKey,
AresEdgeOptions options = const AresEdgeOptions(), bool editAfterCapture = true,
ValueChanged<AresEdgePerformance>? onPerformance})`
opens a fullscreen-dialog Flutter route. Await returned compressed bytes or null.
Check context.mounted before subsequent navigation. Back dismisses the screen;
editor/picker cancellation returns to scanning. Available controls: back, torch,
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

## Compatibility

`edge_detection_sdk.dart` remains a compatibility adapter. New consumers should
use the AresEdge entry point above. Do not mix the owner/source implementation's
private APIs with the customer binary package. Its old enum/signature differences
are intentionally hidden by the AresEdge API.
