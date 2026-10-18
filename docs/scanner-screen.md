# Ready-made scanner and editor

`AresEdgeScreen` provides back, flashlight, capture and gallery controls. It is a
Flutter widget hosted in your existing Activity/UIViewController. The embedded
preview and editor use native platform views backed by compiled SDK cores.

```dart
final bytes = await AresEdgeScreen.open(
  context,
  licenceKey: configuredKey,
  options: const AresEdgeOptions(autoCapture: false),
  editAfterCapture: false,
);
```

Set `editAfterCapture: false` to skip **all** cropping/editing for both camera and
gallery. Returns original bytes without perspective correction or filtering.
With true (the default), the user can crop perspective, rotate, filter, adjust,
draw and add text. No AI tools are exposed. Edited output is PNG; original input
may be JPEG or another platform-supported image format.

To provide your own route:

```dart
final bytes = await Navigator.of(context).push<Uint8List>(MaterialPageRoute(
  builder: (_) => AresEdgeScreen(
    licenceKey: configuredKey,
    editAfterCapture: true,
  ),
));
```

When mounting the screen inside your own layout/navigation container, provide
`onComplete: (bytes) { ... }`. With that callback the screen does not pop a route.
Unmount it after completion; the callback fires at most once per screen instance.
Without the callback, capture or back pops the current route. Null means back or
trial timeout. Editor cancellation returns to scanning; cancelling the gallery
picker also returns to scanning. The gallery control uses the platform photo
picker; the app must supply the platform privacy declarations.

Trial expiry is not extended by opening the gallery or editor. The original-image
completion path rechecks native access after the picker returns.

The previous `EdgeDetectionSdk.openActivity` API remains available through the
compatibility entry point for a separate Android Activity. New integrations should
use the documented AresEdge widgets; `AresEdgeScreen.open` itself does not launch
a second Android Activity.
