# Ready-made scanner

`AresEdgeScreen` provides back, flashlight, capture and gallery controls. It is a
Flutter widget hosted in your existing Activity/UIViewController, with a native
camera preview backed by the compiled SDK core.

```dart
final bytes = await AresEdgeScreen.open(
  context,
  licenceKey: configuredKey,
  options: const AresEdgeOptions(autoCapture: false),
);
if (bytes == null) return;
// Save the cropped document, display it, or pass it to your own processing flow.
```

Camera capture and gallery selection return the detected document, cropped and
perspective-corrected in the native core. No ImageCapture/Cropper screen or filter
UI is opened. A missing boundary reports DOCUMENT_NOT_FOUND and keeps the scanner
available. Set extractDocument:false only to request the full image explicitly.

To provide your own route:

```dart
final bytes = await Navigator.of(context).push<Uint8List>(MaterialPageRoute(
  builder: (_) => AresEdgeScreen(licenceKey: configuredKey),
));
```

When mounting the screen inside your own layout/navigation container, provide
`onComplete: (bytes) { ... }`. With that callback the screen does not pop a route.
Unmount it after completion; the callback fires at most once per screen instance.
Without the callback, capture or back pops the current route. Null means back or
trial timeout. Cancelling the gallery picker returns to scanning. Supply the
platform privacy declarations for camera and photo-library access.

Trial expiry is not extended by opening the gallery. The completion path rechecks
native access after the picker returns.

The compatibility `EdgeDetectionSdk.openActivity` entry point opens a separate
Android Activity. New integrations should use the documented AresEdge widgets;
`AresEdgeScreen.open` itself does not launch a second Android Activity.

### AresScan capture behaviour

The default is automatic capture: a confident hold followed by a two-second
countdown, with the same movement cancellation and detector-freshness rules as
AresScan. The screen displays the current prompt/countdown. Its manual shutter
can still capture immediately. The cropped document returns to the calling route;
there is no editor in this version. Choose `autoCapture: false` for manual-only
operation.
