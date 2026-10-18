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

Use the single public import `package:ares_edge/ares_edge.dart`. Only the nine
[scanning API types](api-reference.md#public-api-boundary) are supported; editor,
cropper and internal adapter APIs are not exposed.

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
bytes directly, without navigating through an editor. Cancellation or trial expiry returns null. The
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
