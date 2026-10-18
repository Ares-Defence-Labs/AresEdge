# Platform setup and troubleshooting

## Requirements

- Flutter 3.44+, Dart 3.12+.
- Android minSdk 24, Java 17. Use the compileSdk minimum specified by your supplied
  customer artifact's BINARY_DISTRIBUTION.md (the current reviewed AAR requires 36).
  The current example uses Android Gradle Plugin 9.1.1, Gradle 9.3.1 and Kotlin 2.4.0.
- iOS 16+ with Xcode/CocoaPods appropriate to your Flutter release. Set
  `platform :ios, '16.0'` in the host Podfile.
- Android and iOS only; no web/desktop camera implementation is supplied.

The SDK requests Android camera permission at runtime; its core manifest declares
CAMERA. The gallery uses image_picker and the native photo picker. Ensure a
foreground Activity exists. A physical device is recommended for camera testing.

Add to the iOS host Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>Capture documents for scanning.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Choose a document image to scan.</string>
```

The gallery only reads a selected image and does not write to Photos. The host owns
saving/sharing permissions. Handle photo-picker cancellation. After Android
activity recreation, image_picker can report lost data; apps with their own
embedded gallery workflow should follow image_picker's retrieveLostData guidance.
The ready-made screen does not promise recovery of an in-progress scan after the
OS destroys the app Activity; start a fresh scan in that case.

## Model packaging

The customer binary package bundles the default ONNX model in native resources;
no Google Play asset pack or Apple asset download is required. AresScan+ currently
uses a temporary owner/source integration with store-delivered
models. At publication it will migrate to the same `ares_edge` package and public
scanner API as customers; that dependency migration and store-model delivery
configuration must be verified before its release. Do not copy
owner delivery scripts or private credentials into a customer integration.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| Package not found on pub.dev | It is not published yet; use the supplied local customer binary package. |
| MissingPluginException | Stop and fully rebuild after adding the plugin; hot reload cannot register native code. |
| Camera is not attached | Wait for the preview to mount; controller attachment is not a native-ready signal. Catch command failures during startup. |
| Camera/permission error | Check privacy declarations and app permission settings. Reopen the scanner after granting permission. |
| Black preview | Use a physical device, close other camera widgets/apps, verify permissions and model resources. |
| Multiple-camera conflict | Unmount the existing SDK camera before opening another. |
| Trial with a configured customer key | Check the full signed key (not its licence ID), SDK product, validity dates and sandbox/production environment. Current customer keys cover unlimited app IDs on both platforms. Never post the key publicly. |
| Sandbox key rejected by production package | Expected: use an explicitly sandbox-trusted test build, or a production-portal key with the production package. |
| Owner/admin key rejected | Check its signed app ID, platform, product and current native signing identity. Customer keys do not require these owner restrictions. |
| Trial immediately expired after reopening | The allowance is per process, not per widget/route. |
| Torch unchanged | Hardware may lack a torch; flashEnabled records a request, not physical confirmation. |
| Native link/build error | Check the artifact's platform requirements, resolve pods, inspect dependency conflicts, and fully rebuild. |

When reporting a bug include SDK/Flutter versions, OS/device, presentation mode,
redacted error codes and minimal reproduction. Remove keys, documents, personal
images and proprietary application code.

### Model protection

The customer package bundles an authenticated encrypted model. Android decrypts
it into memory; iOS loads it through a protected temporary file removed after
session creation. Model encryption and compiled native implementations increase
inspection effort. They cannot prevent extraction or patching by an app owner.
See the package SECURITY.md for the offline security boundaries.
