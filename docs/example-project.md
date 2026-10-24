# Example app and performance workbench

The `ares_edge` SDK package includes a complete Android/iOS example with both
scanner modes, custom flashlight/capture controls and the performance workbench.
The public GitHub repository contains documentation only.

After publication, open the [pub.dev example](https://pub.dev/packages/ares_edge/example)
or download the package and open its `example/` directory. Before publication,
use the example included in your local customer binary package.

```sh
cd example
flutter pub get
flutter run --dart-define=ARES_EDGE_LICENCE=YOUR_PORTAL_ISSUED_KEY
```

Provide the licence in your own build configuration; no real key is included.
Without a key you can test the shared 60-second process trial. Use a physical
device for camera acceptance and profile mode for benchmarking.

The 2.1.5 example includes the fixed
activity editor and independently embedded Crop, Draw, Filters, Text and Adjust
components. The activity opens its editor by default; `photoEditor: false` returns
the cropped image directly. Use embedded components for custom tool selection
and UI; the activity’s supported UI customisation is colours only. See [performance testing](performance-testing.md) for
measurement definitions, the device test matrix and JSON comparison commands.
