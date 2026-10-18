# AresEdge example

A complete Android/iOS Flutter host showing AresEdgeScreen, editor on/off, and
AresEdgeEmbedded under custom capture/torch controls. No real licence is included.

## Local SDK setup (before pub.dev release)

Obtain the customer binary package from Ares Defence Labs. In this example folder
create an untracked `pubspec_overrides.yaml`:

```yaml
dependency_overrides:
  ares_edge:
    path: /absolute/path/to/customer-package
```

When the example is distributed inside the SDK package, use `path: ..` instead.
The public documentation repository is not a plugin and cannot be used as this
dependency. The planned hosted ^2.0.0 dependency is not published yet.

```sh
flutter pub get
flutter run # No key: exercise trial notice and 60-second lock.
flutter run --dart-define=ARES_EDGE_LICENCE=YOUR_PORTAL_ISSUED_KEY
```

Configure keys only in developer source or private build configuration. There is
no end-user licence input screen. Restart the process to test a fresh trial.

Android: API 24+ and compileSdk required by supplied AAR, Java17. iOS:16+; camera
and photo-library explanations are already included in Info.plist. Configure your
own signing/team and app identifiers; a real key must permit that exact app and
its signing identity. Do not use AresScan's owner key.

Use a real device for camera acceptance. Tap Open AresEdgeScreen for gallery,
flashlight, capture and editor. Disable Edit after capture to return original
bytes directly. The custom embedded example returns original bytes using its own
buttons. Cancellation shows no image; returned images appear on the home page.

See the repository docs for error handling, licences and platform setup. The
example can be adapted for licensed integration under the commercial LICENSE.
