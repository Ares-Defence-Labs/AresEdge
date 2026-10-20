# Real-device performance workbench

The example includes a runnable **Performance workbench**, using the real
AresEdgeEmbedded camera and the same signed licence configuration as the app.
No licence bypass or simulated detection is included. Missing/invalid/expired
keys use the normal 60-second process trial; use a valid key for longer runs.

## Run

Follow [example setup](example-project.md) to point the dependency override at
the supplied customer SDK. Use a physical Android or iOS device:

```sh
cd example
flutter pub get
flutter run --profile --dart-define=ARES_EDGE_LICENCE=YOUR_PORTAL_ISSUED_KEY
```

Open **Performance workbench**. Enter a device/condition label, choose quality,
overlay policy and comparison refresh budget, then start. The first two seconds
are excluded from Flutter frame statistics; native windows wholly within the
first two seconds of each native session are also excluded, including windows
that cross the warm-up boundary. Wait for the preview to settle before
pressing Measure capture. Collect at least 20 manual captures of the same document,
stop the session, and copy the JSON. Start a fresh session for another setting.
Stop unmounts the camera; backgrounding also ends the measurement session.

## Measurements and limits

| Metric | Meaning |
| --- | --- |
| Capture callback p50/p95/mean | Monotonic time from pressing Measure capture until onCapture returns document output bytes; includes native capture and document extraction, SDK/channel transport, byte-copy and Dart callback scheduling. |
| Capture byte sizes | Encoded output sizes, with image contents immediately discarded. |
| Flutter build/raster p50/p95/mean | FrameTiming samples supplied by Flutter after warm-up. Includes the host UI and instrumentation overhead. |
| Flutter frames over budget | Retained frames where build or raster exceeds 1000 / selected target refresh Hz. This is an observation, not an OS dropped-frame count. |
| Errors | Observed camera/command errors and 15-second capture timeouts. |
| Native camera FPS | CameraX/AVCapture frame callbacks delivered to the SDK per native monotonic second, before latest-frame analysis selection. This measures SDK camera ingress, not display refresh or an estimated sensor rate. |
| Native analysis FPS | Frames entering native analysis/tracking per second. |
| Native inference cycles/s | Completed detector cycles containing an ONNX run per second, independent of tracking/overlay updates. |
| ONNX inference p50/p95/mean | Actual ONNX execution time per completed detector cycle, including combined full-frame/ROI calls where applicable. |
| Native pipeline/preprocess/decode | Detector elapsed, input-preparation and output-decoding timings. Decode excludes subsequent tracking/geometry updates. |

Telemetry is enabled by supplying `onPerformance` to AresEdgeEmbedded or
AresEdgeScreen (including `AresEdgeScreen.open`). Omit it to disable collection.
Native windows arrive about once a second; native FPS is computed from the actual
window duration, so a delayed UI callback is not mistaken for a slow camera.
Camera/telemetry restart creates a fresh session; stale inference completions from
a previous session are excluded. Transport retains at most 256 timing records per
window and reports any omitted timing records while continuing to count frames/runs.

```dart
AresEdgeEmbedded(
  controller: camera,
  licenceKey: configuredKey,
  onCapture: (image) { /* Save image.bytes. */ },
  onPerformance: (metrics) {
    // Native measurements; independent of Flutter FrameTiming.
    print('Camera: ${metrics.cameraFps} FPS');
    print('Analysis: ${metrics.analysisFps} FPS');
    print('ONNX execution samples: ${metrics.inferenceMs} ms');
  },
);
```

Android pipeline elapsed time includes preparation and worker-dispatch wait.
iOS pipeline elapsed time covers the detector function's preparation, execution
and decoding. `inferenceMs` contains ONNX execution time on both platforms; a
cycle may include more than one ONNX call when full-frame/ROI passes are combined.
Compare the same platform, configuration and scene when tracking regressions.

Statistics use nearest-rank percentiles. Empty measurements are null rather than
zero. Retains the latest 600 native windows, 10,000 Flutter frames and 100 captures.
Aggregate native FPS divides retained frame counts by their summed native window
durations. No native window yields null FPS; an observed idle window yields zero
FPS. Tracking-only/classical detection yields no ONNX timing sample. The one-second
metrics refresh and this workbench's layout contribute to measured Flutter work.
A static native camera preview can produce few Flutter frames even while its
camera stream is smooth: Flutter sample counts are not camera frame rates.
Capture request acknowledgement is not capture completion; only onCapture ends
the measured interval. Startup/permission failures are reported as errors.
The scanner returns the extracted document by default; capture measurements include
native extraction but exclude additional host-app processing.

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
| Licensing | Valid customer key in multiple apps; missing/expired/wrong-product or wrong-environment key, including the trial boundary. Owner grants additionally require their bound app/signer. |
| UI | Both scanner modes; activity editor Save/Cancel and photoEditor:false direct cropped return. Benchmark embedded editing tools separately from camera inference. |

Keep OS, display refresh rate, power mode, battery/thermal conditions, lighting,
document framing and app build mode consistent. Label each run. Cool the device
between heavy runs; compare several repetitions rather than a single score.
Reports use schema version 2. The comparison script requires matching labelled
environment/configuration and at least one capture sample or native window. For intentional quality/overlay experiments, pass
`--allow-configuration-change`; device, OS and build conditions must still match. Save copied reports as baseline.json and candidate.json. From the repository root:

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

The workbench disables automatic capture while measuring sustained inference.
Use its manual shutter to measure capture latency separately.
