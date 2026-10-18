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
// Save the original image, display it, or pass it to your own processing flow.
```

Capture and gallery selection return original compressed image bytes directly.
No editor, cropping, filtering or perspective correction is included in this
release. The edge overlay guides capture; it does not modify the returned image.
Image editing is planned for a later release.

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
