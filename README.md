[![Ares Defence Labs](https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/branding/ares-defence-labs-banner.png)](https://aresdefencelabs.com)

# AresEdge

[Official website](https://aresdefencelabs.com/) · [GitHub repository](https://github.com/Ares-Defence-Labs/AresEdge) · [Developer documentation](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview)

> **Commercial SDK — paid licence required for production use.**
> AresEdge is proprietary software from Ares Defence Labs. Developers are free
> to trial the SDK for evaluation. Without a valid licence, the SDK deactivates
> after 60 seconds during a live session.
>
> Before deploying to real customers, purchase a licence key from the portal
> and paste it into your application’s source code or private build configuration.
> One licence covers unlimited apps across all SDK-supported platforms. You must
> ship the renewed key in every app before the current key expires; otherwise,
> customers running an expired key see the trial popup and session lock.
>
> [Purchase a licence](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview) · [Read the commercial licence](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/LICENSE)

Commercial Flutter document scanner with real-time edge detection, automatic
capture and perspective-corrected image cropping for Android and iOS.

Embed a native camera and configurable edge overlay with **AresEdgeEmbedded**, or
open **AresEdgeScreen** for a minimal back/torch/capture/gallery interface. The
scanner returns a cropped, perspective-corrected document. Version 2.1.3 opens a basic photo editor by default (`photoEditor: true`); set it to false
for immediate image return. Embed crop/magnifier, drawing, filters, text and adjustments
individually with a shared editor controller. See [modular image editing](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/image-editor.md).

The public GitHub repository provides documentation, support and a versioned
package-metadata snapshot (`pubspec.yaml`). Install the compiled SDK from pub.dev;
the documentation repository does not contain its implementation.

## Choose your image-editing integration

**Build your own UI:** pick individual crop/magnifier, drawing, filter, text and
adjustment components and share one `AresEdgeEditorController` between them.
Embed only the tools your app needs and connect your own navigation and buttons.

**Use the provided UI:** open `AresEdgeScreen` for scanning and its editor, or
`AresEdgePhotoEditor.open` for an existing image. Ares Defence Labs supplies the
fixed five-tool editor activity, whose UI customisation is colour codes only.
The scanner also supports state hints and a stable-document countdown;
custom layouts and tool selection belong to the embedded route.
`photoEditor: false` skips editing and still returns the cropped document.

### 1. Scan a document or card

AresEdge is a complete document scanner: frame the page or card, follow the live
edge overlay and capture the image. Use `AresEdgeScreen` for the ready-made
scanner, or `AresEdgeEmbedded` to build your own camera UI.

[![Live document scanning and automatic capture](https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/media/scanner.webp)](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/scanner-screen.md)

### 2. Refine the crop

After capture, the image opens in the editor. Choose **Crop** to adjust the four
corners, use the magnifier and straighten the document before continuing.

[![Crop handles and magnifier](https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/media/editor-cropper.png)](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/cropper.md)

### 3. Edit and return the image

Apply filters, draw, add text or adjust the image, then save the result back to
your app. You can use the provided editor or compose your own UI from the
embedded editing components.

[![Filter previews](https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/media/editor-filters.png)](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/filters.md)

[![Text annotation controls](https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/media/editor-text.png)](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/image-editor.md#crop-filter-and-text-workflows)

AresScan+ workflow references: AresEdge includes Crop, Draw, Filters, Text and
Adjust. AI Tools, OCR/Extract Text shown in the app screenshots are not included. Portable text formatting is
available through the Text component. See the
[editor guide](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/image-editor.md).

**Version 2.1.3** includes the scanner, modular editor and provided five-tool activity.

Automatic scanning follows AresScan: hold a confident document steady, watch
its configurable countdown (two seconds by default), and receive the cropped document. Moving the document or
losing reliable detection cancels capture. Set `autoCapture: false` for manual
shutter control. The embedded widget exposes `onScanStateChanged` so your own UI
can show the hold/countdown state.


### Configure the supplied scanner

The supplied route keeps the SDK layout while allowing scanner colours, state
hints and the stable-document countdown to be configured:

```dart
final bytes = await AresEdgeScreen.open(
  context,
  licenceKey: configuredKey,
  options: const AresEdgeOptions(
    overlayColor: Color(0xFF448AFF),
    captureTraceColor: Color(0xFFFFD740),
    captureCountdownSeconds: 3,
  ),
  hintBuilder: (state) => switch (state.phase) {
    'holding' => 'Hold your document steady',
    'countdown' => 'Taking photo in ${state.remainingSeconds}',
    'capturing' => 'Preparing your scan…',
    _ => 'Place a document inside the guide',
  },
);
```

`captureCountdownSeconds` accepts whole seconds from 1 through 10 (default 2).
It starts after confident, stable detection; movement or stale detection cancels
it. It is not a maximum session duration and has no effect in manual mode.
Omit `hintBuilder` to retain the SDK hints, including the manual-capture prompt.
The builder receives live camera states only; gallery extraction and errors keep
their separate messages. The same settings work when constructing
`AresEdgeScreen` directly. Custom layouts belong to `AresEdgeEmbedded`, where
`onScanStateChanged` supplies the same states for host-owned hints.

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

AresScan+ will use the same published `ares_edge` package and public scanner API
as other applications when the package launches. Its owner entitlement changes
licensing only; it does not select a separate scanner implementation.

## Try AresEdge in AresScan+

Experience document scanning in **AresScan+**, the official Ares Defence Labs app
powered by AresEdge.

[![Get AresScan+ on Google Play](https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/branding/google-play-badge.png)](https://play.google.com/store/apps/details?id=ai.aresdefencelabs.aresscan) [![Download AresScan+ on the App Store](https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/branding/app-store-badge.png)](https://apps.apple.com/us/app/aresscan/id6759765449)

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

<img src="https://raw.githubusercontent.com/Ares-Defence-Labs/AresEdge/main/media/scanner.webp" alt="Document scanning with AresEdge in AresScan+" width="280">

Document detection in **AresScan+**. Build your own scanner controls with
AresEdgeEmbedded, or use the compact AresEdgeScreen.

## Run the performance workbench

The SDK [example project](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/example-project.md) includes a **Performance workbench** for
real Android/iOS devices. Select analysis quality and overlay policy, collect
capture latency and Flutter frame timings, then copy a JSON report for comparisons.
The normal offline licence checks and 60-second trial still apply.

```sh
# From the downloaded package example directory:
cd example
flutter pub get
flutter run --profile --dart-define=ARES_EDGE_LICENCE=YOUR_PORTAL_ISSUED_KEY
```

Tap **Open performance workbench**, record your device/test conditions, and start
a session. Capture the same document repeatedly, stop, and copy the report. The
workbench reports native camera and analysis FPS, ONNX inference p50/p95,
capture-callback latency, and Flutter build/raster timings.

See [performance testing](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/performance-testing.md) for the repeatable test
matrix, measurement definitions and report-comparison script, and
[visual demos](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/visual-demos.md) for media sources and feature scope.

**Current release:** [ares_edge 2.1.3](https://pub.dev/packages/ares_edge/versions/2.1.3).

- [Installation and quick start](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/getting-started.md)
- [Embedded camera and custom controls](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/embedded-camera.md)
- [Ready-made scanner](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/scanner-screen.md)
- [Cropper and magnifier](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/cropper.md)
- [Image editor: components or activity](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/image-editor.md)
- [Full filter catalogue](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/filters.md)
- [Complete public API reference](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/api-reference.md)
- [Offline licensing, trial and renewal](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/licensing.md)
- [Platform setup and troubleshooting](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/platforms.md)
- [Video demos and screenshots](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/visual-demos.md)
- [Performance workbench](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/performance-testing.md)
- [Example application](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/example-project.md)
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

Keys verify offline and cover unlimited apps on Android and iOS. Pass the full
signed key, not the portal's licence ID. Missing, invalid or expired keys use the
shared process trial and deactivate scanning after 60 seconds of a live session.
Do not commit a real key to this public example/repository.

**Sandbox keys require a sandbox-trusted test build.** The production package
rejects sandbox keys; use a production-portal key for production apps. See
[offline licensing and renewal](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/licensing.md) for environments, expiry and
how to distribute replacement keys before customers encounter the trial lock.

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
selecting an image returns its detected document, cropped and perspective-corrected,
in the direct-return path. In the 2.1.3 API, the default path opens the image editor first with a cropped preview. Tap Crop
to adjust detected corners over the retained full photo, with a drag magnifier
and Retake / Detect / Done controls. Set
`photoEditor: false` to return the cropped image immediately. Saving the editor
returns PNG bytes; cancelling returns to scanning. `DOCUMENT_NOT_FOUND` keeps the scanner available for another attempt.

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
          // image.bytes contains the extracted document.
          // image.isDocumentCropped is true; image.width/height describe the output.
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
licence. See [LICENSE](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/LICENSE). Third-party components retain their own terms.

## Document extraction

Both camera capture and gallery import extract the detected document by default.
The native core crops to the four detected corners, corrects perspective and
returns compressed image bytes. `AresEdgeEmbedded` returns these directly;
`AresEdgeScreen` opens its basic editor by default in the 2.1.3 API.
Set `photoEditor: false` for direct cropped return. A missing usable boundary reports `DOCUMENT_NOT_FOUND`, so your app
can ask the user to align the document and try again.

`AresEdgeOptions(maxDocumentDimension: 1600)` sets the maximum output side in
pixels (256–4096); extraction never upscales. Round documents use transparent PNG
outside the detected disc; rectangular documents normally use JPEG. Embedded
callbacks also expose `image.isDocumentCropped`, `image.width` and `image.height`.
Use `extractDocument: false` only when you explicitly want the full image for your
own processing. This flag is independent of `photoEditor`.

### Supported public API

Use `package:ares_edge/ares_edge.dart` for `AresEdgeEmbedded`, `AresEdgeScreen`,
`AresEdgeController`, `AresEdgeOptions`, `AresEdgeImage`, `AresEdgeScanState`,
`AresEdgePerformance`, `AresEdgeQuality` and `AresEdgeShape`. The 2.1.3 API
also exposes the documented `AresEdgeEditorController`, options/modes/filter types,
`AresEdgePhotoEditor`, `AresEdgeCropper`, `AresEdgeDrawing`, `AresEdgeFilters`, `AresEdgeText` and
`AresEdgeAdjustments`. Legacy owner cropper/editor classes, activation helpers
and native channel adapters remain private.
See the [API reference](https://github.com/Ares-Defence-Labs/AresEdge/blob/main/docs/api-reference.md).

### Complete filter catalogue

The 2.1.3 editor includes all 37 AresScan presets, plus Sepia. Discover available filters through `AresEdgeFilter.aresScanPresets` or `AresEdgeFilter.values`, and configure strength, preset parameters and custom LUTs. See the [filter reference](docs/filters.md).
