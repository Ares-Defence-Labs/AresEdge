import 'dart:math' as math;
import 'package:ares_edge/ares_edge.dart';

/// Bounded, in-memory measurements from one real-device workbench session.
/// Values are observed timings, never simulated camera/inference results.
class BenchmarkSession {
  BenchmarkSession({required this.refreshRate}) {
    if (refreshRate <= 0) throw ArgumentError.value(refreshRate, 'refreshRate');
  }

  final int refreshRate;
  final List<double> _buildMs = [];
  final List<double> _rasterMs = [];
  final List<double> _captureMs = [];
  final List<int> _captureBytes = [];
  int errors = 0;
  final List<AresEdgePerformance> _native = [];

  /// Records a native window once; late/duplicate windows are discarded.
  void recordNative(AresEdgePerformance value) {
    if (_native.any(
      (old) =>
          old.sessionId == value.sessionId && old.sequence >= value.sequence,
    )) {
      return;
    }
    _append(_native, value, 600);
  }

  /// Retain the most recent samples to bound instrumentation memory.
  static const maxFrameSamples = 10000;
  static const maxCaptureSamples = 100;

  void recordFrame({required double buildMs, required double rasterMs}) {
    if (!buildMs.isFinite ||
        !rasterMs.isFinite ||
        buildMs < 0 ||
        rasterMs < 0) {
      return;
    }
    _append(_buildMs, buildMs, maxFrameSamples);
    _append(_rasterMs, rasterMs, maxFrameSamples);
  }

  void recordCapture({required double milliseconds, required int bytes}) {
    if (!milliseconds.isFinite || milliseconds < 0 || bytes < 0) return;
    _append(_captureMs, milliseconds, maxCaptureSamples);
    _append(_captureBytes, bytes, maxCaptureSamples);
  }

  static void _append<T>(List<T> values, T value, int limit) {
    values.add(value);
    if (values.length > limit) values.removeRange(0, values.length - limit);
  }

  static Map<String, Object?> _summary(
    List<double> values, {
    String suffix = 'Ms',
  }) {
    if (values.isEmpty) {
      return {
        'samples': 0,
        'mean$suffix': null,
        'p50$suffix': null,
        'p95$suffix': null,
      };
    }
    final sorted = [...values]..sort();
    double percentile(double fraction) =>
        sorted[math.max(0, (sorted.length * fraction).ceil() - 1)];
    return {
      'samples': sorted.length,
      'mean$suffix': values.reduce((a, b) => a + b) / values.length,
      'p50$suffix': percentile(.5),
      'p95$suffix': percentile(.95),
    };
  }

  double? _rate(int Function(AresEdgePerformance) count) {
    final microseconds = _native.fold<int>(
      0,
      (sum, v) => sum + v.window.inMicroseconds,
    );
    return microseconds == 0
        ? null
        : 1000000 *
              _native.fold<int>(0, (sum, v) => sum + count(v)) /
              microseconds;
  }

  /// JSON-safe report with no images, paths, licence keys or native secrets.
  Map<String, Object?> report() {
    final budget = 1000 / refreshRate;
    final overBudget = List.generate(
      _buildMs.length,
      (i) => _buildMs[i] > budget || _rasterMs[i] > budget,
    ).where((v) => v).length;
    return {
      'measurement': 'nativeCameraInferenceCaptureAndFlutterFrames',
      'targetRefreshHz': refreshRate,
      'flutterFrameBudgetMs': budget,
      'flutterBuild': _summary(_buildMs),
      'flutterRaster': _summary(_rasterMs),
      'flutterFramesOverBudget': overBudget,
      'flutterFramesOverBudgetPercent': _buildMs.isEmpty
          ? null
          : 100 * overBudget / _buildMs.length,
      'captureCallback': _summary(_captureMs),
      'captureBytes': List<int>.unmodifiable(_captureBytes),
      'errors': errors,
      'nativeWindows': _native.length,
      'nativeWindowMs': _native.fold<double>(
        0,
        (sum, v) => sum + v.window.inMicroseconds / 1000,
      ),
      'nativeCameraFrames': _native.fold<int>(
        0,
        (sum, v) => sum + v.cameraFrames,
      ),
      'nativeAnalysisFrames': _native.fold<int>(
        0,
        (sum, v) => sum + v.analysisFrames,
      ),
      'nativeInferenceRuns': _native.fold<int>(
        0,
        (sum, v) => sum + v.inferenceRuns,
      ),
      'nativeCameraFps': _rate((v) => v.cameraFrames),
      'nativeAnalysisFps': _rate((v) => v.analysisFrames),
      'nativeInferenceFps': _rate((v) => v.inferenceRuns),
      'nativeCameraFpsStats': _summary(
        _native.map((v) => v.cameraFps).toList(),
        suffix: '',
      ),
      'nativeInferenceMs': _summary(
        _native.expand((v) => v.inferenceMs).toList(),
      ),
      'nativeProcessingMs': _summary(
        _native.expand((v) => v.processingMs).toList(),
      ),
      'nativePreprocessMs': _summary(
        _native.expand((v) => v.preprocessMs).toList(),
      ),
      'nativeDecodeMs': _summary(_native.expand((v) => v.decodeMs).toList()),
      'nativeTimingSamplesDropped': _native.fold<int>(
        0,
        (sum, v) => sum + v.timingSamplesDropped,
      ),
    };
  }
}
