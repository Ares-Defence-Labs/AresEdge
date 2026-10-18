import 'dart:math' as math;

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

  /// Retain the most recent samples to bound instrumentation memory.
  static const maxFrameSamples = 10000;
  static const maxCaptureSamples = 100;

  void recordFrame({required double buildMs, required double rasterMs}) {
    if (!buildMs.isFinite || !rasterMs.isFinite || buildMs < 0 || rasterMs < 0) {
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

  static Map<String, Object?> _summary(List<double> values) {
    if (values.isEmpty) {
      return {'samples': 0, 'meanMs': null, 'p50Ms': null, 'p95Ms': null};
    }
    final sorted = [...values]..sort();
    double percentile(double fraction) =>
        sorted[math.max(0, (sorted.length * fraction).ceil() - 1)];
    return {
      'samples': sorted.length,
      'meanMs': values.reduce((a, b) => a + b) / values.length,
      'p50Ms': percentile(.5),
      'p95Ms': percentile(.95),
    };
  }

  /// JSON-safe report with no images, paths, licence keys or native secrets.
  Map<String, Object?> report() {
    final budget = 1000 / refreshRate;
    final overBudget = List.generate(
      _buildMs.length,
      (i) => _buildMs[i] > budget || _rasterMs[i] > budget,
    ).where((v) => v).length;
    return {
      'measurement': 'captureCallbackAndFlutterFrames',
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
      'nativeCameraFps': null,
      'nativeInferenceMs': null,
    };
  }
}
