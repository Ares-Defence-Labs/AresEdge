[![Ares Defence Labs](./branding/ares-defence-labs-banner.png)](https://aresdefencelabs.com)

# AresEdge

> **Commercial SDK — paid licence required for production use.**
> AresEdge is proprietary software from Ares Defence Labs. A free 60-second trial
> is available for evaluation.
>
> [Purchase a licence](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview) · [Read the commercial licence](LICENSE)

Commercial document scanning for Flutter by Ares Defence Labs.

Embed a native camera and configurable edge overlay with **AresEdgeEmbedded**, or
open **AresEdgeScreen** for a minimal back/torch/capture/gallery interface. The
scanner returns original image bytes to your app. Image editing is planned for
a later release.

## Try AresEdge in AresScan+

Experience document scanning in **AresScan+**, the official Ares Defence Labs app
powered by AresEdge.

<p>
  <a href="https://play.google.com/store/apps/details?id=ai.aresdefencelabs.aresscan">
    <img src="branding/google-play.webp" alt="Get AresScan+ on Google Play" height="48">
  </a>
  &nbsp;
  <a href="https://apps.apple.com/us/app/aresscan/id6759765449">
    <img src="branding/app-store.webp" alt="Download AresScan+ on the App Store" height="48">
  </a>
</p>

[Discover AresScan+](https://aresdefencelabs.com/ares-scan) ·
[Explore more Ares Defence Labs SDKs](https://aresdefencelabs.com/development-sdks)

## Watch scanning in action

Live document tracking and the automatic capture countdown in AresScan+.

[![AresEdge live document tracking and capture countdown](https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/media/scanning-demo.gif)](https://github.com/Ares-Defence-Labs/AresEdge/raw/refs/heads/main/media/scanning-demo.mp4)

[Watch the MP4](https://github.com/Ares-Defence-Labs/AresEdge/raw/refs/heads/main/media/scanning-demo.mp4) ·
[Full demo](https://www.youtube.com/watch?v=au0fnn8yGHE) ·
[Official trailer](https://www.youtube.com/watch?v=QoQ2w-9bvho) ·
[Explore AresScan+](https://aresdefencelabs.com/ares-scan)

### Document scanning

<img src="media/scanner.webp" alt="Document scanning with AresEdge in AresScan+" width="280">

Document detection in **AresScan+**. Build your own scanner controls with
AresEdgeEmbedded, or use the compact AresEdgeScreen.

## Run the performance workbench

The [example project](example/README.md) includes a **Performance workbench** for
real Android/iOS devices. Select analysis quality and overlay policy, collect
capture latency and Flutter frame timings, then copy a JSON report for comparisons.
The normal offline licence checks and 60-second trial still apply.

```sh
# After configuring the local SDK path in example/pubspec_overrides.yaml:
cd example
flutter pub get
flutter run --profile --dart-define=ARES_EDGE_LICENCE=YOUR_PORTAL_ISSUED_KEY
```

Tap **Open performance workbench**, record your device/test conditions, and start
a session. Capture the same document repeatedly, stop, and copy the report. The
workbench reports native camera and analysis FPS, ONNX inference p50/p95,
capture-callback latency, and Flutter build/raster timings.

See [performance testing](docs/performance-testing.md) for the repeatable test
matrix, measurement definitions and report-comparison script, and
[visual demos](docs/visual-demos.md) for media sources and feature scope.

**Release status:** the `ares_edge` customer package is being prepared and is not
published to pub.dev. This repository contains documentation and a runnable host
example, not the proprietary implementation or a downloadable SDK binary. Obtain
a local customer package from Ares Defence Labs before running the example.

- [Installation and quick start](docs/getting-started.md)
- [Embedded camera and custom controls](docs/embedded-camera.md)
- [Ready-made scanner](docs/scanner-screen.md)
- [Complete public API reference](docs/api-reference.md)
- [Offline licensing, trial and renewal](docs/licensing.md)
- [Platform setup and troubleshooting](docs/platforms.md)
- [Video demos and screenshots](docs/visual-demos.md)
- [Performance workbench](docs/performance-testing.md)
- [Example application](example/README.md)
- [Purchase a licence](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview)
- [Report a bug or ask a question](https://github.com/Ares-Defence-Labs/AresEdge/issues)

## Configure your licence

Copy your signed customer key from the portal and supply it in developer source
or private build configuration. End users never enter a key in the app.

```dart
const licenceKey = String.fromEnvironment('ARES_EDGE_LICENCE');
// Alternatively: const licenceKey = 'YOUR_PORTAL_ISSUED_LICENCE_KEY';
```

```sh
flutter run --dart-define=ARES_EDGE_LICENCE=YOUR_PORTAL_ISSUED_LICENCE_KEY
```

Keys verify offline. Missing, invalid or expired keys use the shared 60-second
process trial. Do not commit a real key to this public example/repository.

## Ready-made scanner: AresEdgeScreen

```dart
import 'package:ares_edge/ares_edge.dart';
import 'package:flutter/material.dart';

Future<void> scanDocument(BuildContext context) async {
  final bytes = await AresEdgeScreen.open(
    context,
    licenceKey: licenceKey,
    options: const AresEdgeOptions(
      overlayColor: Colors.teal,
      flashEnabled: false, // Initial torch state; the screen has a torch button.
    ),
  );
  if (bytes == null) return; // Cancelled or trial expired.
  // Save bytes to storage owned by your app, or display Image.memory(bytes).
}
```

The screen includes back, flashlight, capture and gallery controls. Capturing or
selecting an image returns its original bytes directly to the calling app. No
editor, filters or perspective correction are included in this release.

## Custom camera: AresEdgeEmbedded

Retain a controller in State, add your own controls, and handle the captured bytes:

```dart
class CustomScanner extends StatefulWidget {
  const CustomScanner({super.key});
  @override
  State<CustomScanner> createState() => _CustomScannerState();
}

class _CustomScannerState extends State<CustomScanner> {
  final camera = AresEdgeController();

  Future<void> runCommand(Future<void> Function() action) async {
    try {
      await action();
      if (mounted) setState(() {});
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  void dispose() {
    camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(children: [
      Expanded(child: AresEdgeEmbedded(
        licenceKey: licenceKey,
        controller: camera,
        options: const AresEdgeOptions(
          forceEdgeOverlay: false, // Keep automatic device policy.
          overlayColor: Colors.orange,
        ),
        onCapture: (image) {
          // Return the original image to your app.
          // Save image.bytes, or return them to your calling route:
          if (mounted) Navigator.of(context).pop(image.bytes);
        },
        onError: (message) {
          // Display or log your application's camera error message.
        },
        onLicenceRequired: () {
          // The SDK has already stopped/replaced the expired preview.
        },
      )),
      SafeArea(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: 'Toggle flashlight',
            icon: Icon(camera.flashEnabled ? Icons.flash_on : Icons.flash_off),
            onPressed: () => runCommand(camera.toggleFlash),
          ),
          FilledButton(
            onPressed: () => runCommand(camera.capture),
            child: const Text('Capture'),
          ),
        ],
      )),
    ]),
  );
}
```

The embedded snippet uses the same imports and `licenceKey` constant shown above.
For explicit torch control, use `await camera.setFlashEnabled(true)` or
`await camera.setFlashEnabled(false)`. Torch support depends on the device.
Await each command and handle startup/permission errors. The embedded component
supplies the camera/overlay; your app owns navigation, controls and image handling.


Android API 24+, iOS 16+, Flutter 3.44+, Dart 3.12+. Customers receive compiled
native cores and the bundled default ONNX model. Store-asset delivery is not
required. Only one SDK camera can be active at a time.

A commercial licence is required for production use. Downloading the example,
viewing source wrappers, or obtaining binaries does not grant a free production
licence. See [LICENSE](LICENSE). Third-party components retain their own terms.
