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
perspective-corrected in the native core. In the 2.1.5 API, `photoEditor: true` opens the image editor first with a cropped preview. Tap Crop to adjust detected corners over the retained full photo; Done returns to the editor.
Set `photoEditor: false` for direct cropped return. Cancelling editing resumes
scanning; Save returns edited PNG bytes. See [modular image editing](image-editor.md). A missing boundary reports DOCUMENT_NOT_FOUND and keeps the scanner
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

Use `AresEdgeScreen.open` for the supported scanner route. Internal native Activity
bootstrap and legacy adapter classes are not public customer APIs.

The SDK activity defaults to Document mode, with floating back/flash buttons,
a circular shutter, gallery input and Auto/Manual capture controls. There is no
top Document heading, template picker, shape picker or Book/Forms/Cards specialisation navigation.
`options.autoCapture` sets the initial capture mode; changing Auto/Manual only
affects this scanner session. AresScan+ application UI is not changed.

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

## Activity UI contract

The scanner and its editor are Ares Defence Labs provided pages. The editor has
Crop, Draw, Filters, Text and Adjust in a fixed layout and order. Developers
customise scanner colours, state hints and countdown duration. Editor colour
roles are also configurable; adding/removing tools or supplying custom
button/layout builders requires the embedded components. The photoEditor flag controls whether editing is opened;
it is not a UI-builder setting. For a composed interface, use
[AresEdgeEmbedded](embedded-camera.md) with the [embedded editor components](image-editor.md).
Use `editorColors: AresEdgeEditorColors(...)` for activity colours. Tool lists,
layout and component/session options are SDK-owned on this route.
