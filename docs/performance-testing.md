# Real-device performance workbench

The example includes a runnable **Performance workbench**, using the real
AresEdgeEmbedded camera and the same signed licence configuration as the app.
No licence bypass or simulated detection is included. Missing/invalid/expired
keys use the normal 60-second process trial; use a valid key for longer runs.

## Run

Follow [example setup](../example/README.md) to point the dependency override at
the supplied customer SDK. Use a physical Android or iOS device:

```sh
cd example
flutter pub get
flutter run --profile --dart-define=ARES_EDGE_LICENCE=YOUR_PORTAL_ISSUED_KEY
```

Open **Performance workbench**. Enter a device/condition label, choose quality,
overlay policy and comparison refresh budget, then start. The first two seconds
are excluded from Flutter frame statistics. Wait for the preview to settle before
pressing Measure capture. Collect at least 20 manual captures of the same document,
stop the session, and copy the JSON. Start a fresh session for another setting.
Stop unmounts the camera; backgrounding also ends the measurement session.

## Measurements and limits

| Metric | Meaning |
| --- | --- |
| Capture callback p50/p95/mean | Monotonic time from pressing Measure capture until onCapture returns original encoded bytes; includes native still capture, SDK/channel transport, byte-copy and Dart callback scheduling. |
| Capture byte sizes | Encoded output sizes, with image contents immediately discarded. |
| Flutter build/raster p50/p95/mean | FrameTiming samples supplied by Flutter after warm-up. Includes the host UI and instrumentation overhead. |
| Flutter frames over budget | Retained frames where build or raster exceeds 1000 / selected target refresh Hz. This is an observation, not an OS dropped-frame count. |
| Errors | Observed camera/command errors and 15-second capture timeouts. |
| Native camera FPS / inference ms | Null: the current public API does not expose these measurements. |

Statistics use nearest-rank percentiles. Empty measurements are null rather than
zero. Retains the latest 10,000 Flutter frames and 100 captures. The one-second
metrics refresh and this workbench's layout contribute to measured Flutter work.
A static native camera preview can produce few Flutter frames even while its
camera stream is smooth: Flutter sample counts are not camera frame rates.
Capture request acknowledgement is not capture completion; only onCapture ends
the measured interval. Startup/permission failures are reported as errors.
The editor is skipped; these measurements do not time cropping or exporting.

Copied reports contain environment/configuration, timings and byte sizes, without
licence keys, image content or filesystem paths. The optional device label is
included verbatim, so enter test conditions rather than sensitive information.
This harness never uploads reports. Copy report JSON after stopping so it is stable.

## Repeatable comparison matrix

| Dimension | Suggested runs |
| --- | --- |
| Hardware | A slower supported device and a recent device, Android and iOS. |
| Quality | low / balanced / high, with other settings identical. |
| Overlay | Device policy; forced continuous overlay; outlines hidden. |
| Scene | Same printed page, fixed distance, bright / dim light, flat / tilted. |
| Lifetime | First open, warmed camera, repeated captures, background/reopen. |
| Licensing | Valid key; missing/expired/wrong-app key, including the trial boundary. |
| UI | Both example presentation modes; editor enabled/disabled for functional checks. |

Keep OS, display refresh rate, power mode, battery/thermal conditions, lighting,
document framing and app build mode consistent. Label each run. Cool the device
between heavy runs; compare several repetitions rather than a single score.
The comparison script requires matching labelled environment/configuration and
nonempty capture samples. For intentional quality/overlay experiments, pass
`--allow-configuration-change`; device, OS and build conditions must still match. Save copied reports as baseline.json and candidate.json:

```sh
python3 example/tool/compare_benchmarks.py baseline.json candidate.json
```

The script prints observed timing changes. It does not enforce a universal pass
threshold or claim statistical significance. Record acceptance targets for your
application/device class before interpreting changes.

For native camera/CPU/GPU profiling use the platform profilers (Android Studio
Profiler/Perfetto and Xcode Instruments). Flutter's DevTools performance view
helps explain Flutter frame work. See the official
[Flutter profiling guide](https://docs.flutter.dev/perf/ui-performance).
