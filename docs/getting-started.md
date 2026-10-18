# Install and capture

## Obtain the package

AresEdge is a commercial SDK. Purchase through the
[AresEdge portal](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview).
Copy the signed licence string for your application from the portal. Configure it
in developer source or a build define, never an end-user activation dialog.

The planned pub.dev name is `ares_edge`. It has not been published. For now use
the supplied **customer binary package**, not this documentation repository:

```yaml
dependencies:
  flutter:
    sdk: flutter
  ares_edge:
    path: /absolute/path/to/customer-package
```

Run `flutter pub get`. Configure [Android and iOS](platforms.md) before launching.
Do not use a Git dependency pointing at the public documentation repository: it
is not the SDK package. After an actual release, use the version announced in
its release notes rather than guessing a hosted version.

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

Capture or gallery selection returns the original image bytes directly, without
an editor or image processing. Cancellation or trial expiry returns null. The
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
