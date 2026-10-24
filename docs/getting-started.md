# Install and capture

## Obtain the package

AresEdge is a commercial SDK. Purchase through the
[AresEdge portal](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview).
Copy the full signed customer licence key from the portal, not its licence ID.
Sandbox keys require a sandbox-trusted test build; the production package accepts
production-issued keys. One licence covers an
unlimited number of your apps across all SDK-supported platforms (currently
Android and iOS). Configure the same key in developer source or a private build
define, never an end-user activation dialog. Replace it in every app and distribute
updates before its expiry; older installations with an expired key show the trial
popup and are subject to the live-session trial lock. See [licensing and renewal](licensing.md).

Install the published Flutter package from pub.dev:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ares_edge: ^2.1.5
```

Run `flutter pub get`. Configure [Android and iOS](platforms.md) before launching.
The public GitHub repository contains documentation and issue tracking; use the
hosted dependency above rather than a Git dependency on that repository.

Use the single public import `package:ares_edge/ares_edge.dart`. The nine
[scanning API types](api-reference.md#public-api-boundary) remain available.
The 2.1.5 API includes the [modular editor](image-editor.md); legacy owner
cropper/editor classes and internal adapters remain private.

## Ready-made scanner

```dart
import 'package:ares_edge/ares_edge.dart';
import 'package:flutter/material.dart';

Future<void> scan(BuildContext context) async {
  final image = await AresEdgeScreen.open(
    context,
    licenceKey: const String.fromEnvironment('ARES_EDGE_LICENCE'),
    options: const AresEdgeOptions(
      overlayColor: Colors.teal,
      forceEdgeOverlay: false,
    ),
  );
  if (!context.mounted || image == null) return;
  // Store the returned compressed bytes, or show Image.memory(image).
}
```

Capture or gallery selection returns cropped, perspective-corrected document
bytes. In 2.1.5, `photoEditor` defaults to true and opens
the basic editor before return. Set it to false for direct cropped output. Cancellation or trial expiry returns null. The
result has no SDK-managed persistent file.

## Licence at build time

```sh
flutter run --dart-define=ARES_EDGE_LICENCE=YOUR_PORTAL_ISSUED_KEY
```

Keep real keys in your private build configuration; never commit them to a public
example, issue or screenshot. Build defines are configuration and can be extracted
from an app. Signed offline tokens prevent forgery, not binary patching.
Omit the define to exercise the 60-second process trial.

Use [AresEdgeEmbedded](embedded-camera.md) for a camera under your own UI.

## Choose the editor integration

Compose the embedded Crop, Draw, Filters, Text and Adjust components for your own
UI, or open the Ares Defence Labs activity for its fixed five-tool interface.
The activity supports colour customisation only. See [the editor integration
contract](image-editor.md) and [cropper guide](cropper.md).
