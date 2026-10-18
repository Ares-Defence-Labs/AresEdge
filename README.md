# AresEdge

Commercial document scanning for Flutter by Ares Defence Labs.

Embed a native camera and configurable edge overlay with **AresEdgeEmbedded**, or
open **AresEdgeScreen** for a minimal back/torch/capture/gallery interface. The
optional lightweight editor provides perspective cropping, filters, adjustments,
drawing and text. No AI editor features are included.

**Release status:** the `ares_edge` customer package is being prepared and is not
published to pub.dev. This repository contains documentation and a runnable host
example, not the proprietary implementation or a downloadable SDK binary. Obtain
a local customer package from Ares Defence Labs before running the example.

- [Installation and quick start](docs/getting-started.md)
- [Embedded camera and custom controls](docs/embedded-camera.md)
- [Ready-made scanner and editor](docs/scanner-screen.md)
- [Complete public API reference](docs/api-reference.md)
- [Offline licensing, trial and renewal](docs/licensing.md)
- [Platform setup and troubleshooting](docs/platforms.md)
- [Example application](example/README.md)
- [Purchase a licence](https://aresdefencelabs.com/development-sdks?sdk=edge-detection&view=overview)
- [Report a bug or ask a question](https://github.com/Ares-Defence-Labs/AresEdge/issues)

```dart
import 'package:ares_edge/ares_edge.dart';

final bytes = await AresEdgeScreen.open(
  context,
  licenceKey: const String.fromEnvironment('ARES_EDGE_LICENCE'),
  editAfterCapture: false, // Return the original photo without crop/edit screens.
);
if (bytes == null) return; // Cancelled or trial expired.
// Save bytes to storage owned by your app.
```

Android API 24+, iOS 16+, Flutter 3.44+, Dart 3.12+. Customers receive compiled
native cores and the bundled default ONNX model. Store-asset delivery is not
required. Only one SDK camera can be active at a time.

A commercial licence is required for production use. Downloading the example,
viewing source wrappers, or obtaining binaries does not grant a free production
licence. See [LICENSE](LICENSE). Third-party components retain their own terms.
