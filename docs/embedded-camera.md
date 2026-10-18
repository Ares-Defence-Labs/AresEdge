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
See the [complete example](../example/lib/main.dart) for both integration styles.

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
