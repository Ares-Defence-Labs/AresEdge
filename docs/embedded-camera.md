# Embedded camera and custom controls

`AresEdgeEmbedded` contains only the camera preview and default edge overlay.
The SDK still presents required trial notices and the expired-trial screen.
Your application owns capture/torch buttons, navigation and result storage.

```dart
class CustomScanner extends StatefulWidget {
  const CustomScanner({super.key, required this.licenceKey});
  final String licenceKey;
  @override
  State<CustomScanner> createState() => _CustomScannerState();
}

class _CustomScannerState extends State<CustomScanner> {
  final camera = AresEdgeController();
  String? error;

  Future<void> command(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (failure) {
      if (mounted) setState(() => error = failure.toString());
    }
  }

  @override
  void dispose() { camera.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(children: [
      Positioned.fill(child: AresEdgeEmbedded(
        licenceKey: widget.licenceKey,
        controller: camera,
        options: const AresEdgeOptions(overlayColor: Colors.orange),
        onCapture: (image) async {
          // Save image.bytes. Implement your own navigation or preview.
        },
        onError: (message) { if (mounted) setState(() => error = message); },
        onLicenceRequired: () { /* The SDK has already stopped the preview. */ },
      )),
      Align(alignment: Alignment.bottomCenter, child: SafeArea(
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(tooltip: 'Torch', icon: const Icon(Icons.flash_on),
            onPressed: () => command(camera.toggleFlash)),
          FilledButton(onPressed: () => command(camera.capture),
            child: const Text('Capture')),
        ]),
      )),
      if (error != null) Center(child: Text(error!)),
    ]),
  );
}
```

Import `package:ares_edge/ares_edge.dart` and Flutter material for this snippet.
See the [complete example](example-project.md) for both integration styles.


## Overlay appearance and device override

The same options work with `AresEdgeEmbedded` and `AresEdgeScreen`:

```dart
const options = AresEdgeOptions(
  overlayColor: Color(0xFF00FFD1), // Corners, perimeter and document tint.
  gridColor: Color(0x66FFFFFF), // Grid, including alpha.
  captureTraceColor: Color(0xFFFFB74D), // Animated capture-countdown border.
  forceEdgeOverlay: false, // Default: let the SDK select the device policy.
);
```

Set `forceEdgeOverlay: true` to override the hardware guard and enable continuous
tracking and moving overlay animation on devices that would normally use the
fixed-outline fallback. This can increase processing load; compare native camera
FPS, inference timings and frame performance in the workbench on your target
devices. The override does not bypass detection confidence, motion cancellation,
camera permissions or the licence/trial lock.

`gridColor` respects alpha; use `Colors.transparent` to hide the grid.
`captureTraceColor: null` follows `overlayColor` at the default trace opacity;
a supplied colour respects its own alpha. It colours the border that traces the
document during the capture countdown. It does not colour the photo returned to
your app. Rebuild with new options to change colours. Changing
`forceEdgeOverlay` restarts the camera and clears the pending capture countdown.

## Controls and lifetime

Retain one controller in State. Do not create it in build or attach it to two
widgets. Give the preview finite layout constraints. Remove/dispose an existing
camera before opening another one. The widget pauses/resumes the native camera
with application lifecycle; lifecycle restarts do not reset the trial.

`capture()` acknowledges a request; image delivery occurs later in `onCapture`.
Native startup can still be in progress after Flutter attachment. Handle command
exceptions and `onError`. Only one controller command may be pending at a time;
await it before the next command. Capture callbacks are serialised while an
async callback is running. The controller's `flashEnabled` is the last requested
state, not confirmation that physical hardware is illuminated.

`setFlashEnabled(true/false)` and `toggleFlash()` request the torch. Some devices
lack one. Rebuild with new options to change colour, visibility, quality, shape or
auto-capture. Changing key, analysis quality or shape can restart native capture.

### Scan state and automatic capture

Automatic capture is enabled by default. Like AresScan, continuous tracking
requires 1.5 seconds of confident detection before a two-second countdown.
Motion cancels an armed countdown; motion tracking alone cannot confirm capture.
The device fallback uses repeated settled detections and shows its fixed outline
during the countdown. Manual shutter capture remains available in either mode.

```dart
AresEdgeEmbedded(
  controller: camera,
  licenceKey: licenceKey,
  options: const AresEdgeOptions(autoCapture: true),
  onScanStateChanged: (state) {
    // Use these in your own hint label or shutter button.
    debugPrint('${state.message} (${state.remainingSeconds})');
  },
  onCapture: (image) => saveImage(image.bytes),
)
```

Set `autoCapture: false` when only your capture button should take a photo.
Overlay animation affects presentation only; it never confirms a capture lock.

### Extracted image output

`image.bytes` contains the detected document with perspective correction, without
opening an editor. `image.isDocumentCropped` confirms extraction and
`image.width` / `image.height` report its output size. Missing boundaries report
`DOCUMENT_NOT_FOUND` through `onError`; no full-frame success is substituted.
`extractDocument:false` explicitly opts into full-frame capture. Configure the
maximum output side with `maxDocumentDimension` (default 1600, range 256–4096).
