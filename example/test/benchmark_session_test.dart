import 'dart:convert';
import 'package:ares_edge/ares_edge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ares_edge_example/workbench/benchmark_session.dart';

void main() {
  test('empty samples remain null and report is JSON safe', () {
    final report = BenchmarkSession(refreshRate: 60).report();
    expect((report['captureCallback'] as Map)['p95Ms'], isNull);
    expect(report['flutterFramesOverBudgetPercent'], isNull);
    expect(report['nativeCameraFps'], isNull);
    expect(() => jsonEncode(report), returnsNormally);
    expect(() => BenchmarkSession(refreshRate: 0), throwsArgumentError);
  });
  test('capture percentiles use measured values and nearest rank', () {
    final session = BenchmarkSession(refreshRate: 60);
    for (var i = 1; i <= 20; i++) {
      session.recordCapture(milliseconds: i.toDouble(), bytes: i);
    }
    final stats = session.report()['captureCallback'] as Map;
    expect(stats['p50Ms'], 10);
    expect(stats['p95Ms'], 19);
    expect(stats['meanMs'], 10.5);
  });
  test('over-budget percentage checks build or raster, not camera fps', () {
    final session = BenchmarkSession(refreshRate: 60);
    session.recordFrame(buildMs: 2, rasterMs: 3);
    session.recordFrame(buildMs: 20, rasterMs: 2);
    session.recordFrame(buildMs: 2, rasterMs: 20);
    expect(session.report()['flutterFramesOverBudget'], 2);
    expect(
      session.report()['flutterFramesOverBudgetPercent'],
      closeTo(200 / 3, .001),
    );
  });
  test('invalid data is excluded and capture history is bounded', () {
    final session = BenchmarkSession(refreshRate: 60);
    session.recordCapture(milliseconds: double.nan, bytes: 10);
    session.recordFrame(buildMs: -1, rasterMs: 3);
    for (var i = 0; i < 110; i++) {
      session.recordCapture(milliseconds: i.toDouble(), bytes: i);
    }
    final report = session.report();
    expect((report['flutterBuild'] as Map)['samples'], 0);
    expect((report['captureCallback'] as Map)['samples'], 100);
    expect((report['captureBytes'] as List).first, 10);
    expect((report['captureBytes'] as List).last, 109);
  });
  test(
    'native FPS is duration-weighted and inference samples survive without Flutter frames',
    () {
      final session = BenchmarkSession(refreshRate: 60);
      AresEdgePerformance sample(
        int sequence,
        int ms,
        int frames,
        List<double> inference,
      ) => AresEdgePerformance.fromMap({
        'sessionId': 'native-session',
        'sequence': sequence,
        'windowMs': ms.toDouble(),
        'elapsedMs': 5000.0,
        'cameraFrames': frames,
        'analysisFrames': frames ~/ 2,
        'inferenceRuns': inference.length,
        'cameraFps': 1000 * frames / ms,
        'analysisFps': 1000 * (frames ~/ 2) / ms,
        'inferenceFps': 1000 * inference.length / ms,
        'inferenceMs': inference,
        'processingMs': <double>[],
        'preprocessMs': <double>[],
        'decodeMs': <double>[],
        'timingSamplesDropped': 0,
      });
      final first = sample(1, 1000, 30, [10, 20]);
      session.recordNative(first);
      session.recordNative(first);
      session.recordNative(sample(2, 2000, 30, [30]));
      final report = session.report();
      expect(report['nativeWindows'], 2);
      expect(report['nativeCameraFps'], 20);
      expect(report['nativeAnalysisFps'], 10);
      expect((report['nativeInferenceMs'] as Map)['samples'], 3);
      expect((report['nativeInferenceMs'] as Map)['p95Ms'], 30);
      expect((report['flutterBuild'] as Map)['samples'], 0);
    },
  );
}
