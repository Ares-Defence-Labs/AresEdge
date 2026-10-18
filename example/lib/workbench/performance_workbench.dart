import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ares_edge/ares_edge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'benchmark_session.dart';

/// Real-device capture/UI workbench. The normal native licence gates apply.
class PerformanceWorkbench extends StatefulWidget {
  const PerformanceWorkbench({super.key, required this.licenceKey});
  final String licenceKey;
  @override
  State<PerformanceWorkbench> createState() => _WorkbenchState();
}

class _WorkbenchState extends State<PerformanceWorkbench>
    with WidgetsBindingObserver {
  final _camera = AresEdgeController();
  final _device = TextEditingController();
  AresEdgeQuality _quality = AresEdgeQuality.balanced;
  bool _forceOverlay = false;
  bool _showOverlay = true;
  int _refreshRate = 60;
  int _generation = 0;
  bool _running = false;
  bool _observingTimings = false;
  bool _capturePending = false;
  String? _error;
  late BenchmarkSession _session = BenchmarkSession(refreshRate: _refreshRate);
  final _elapsed = Stopwatch();
  Stopwatch? _captureElapsed;
  Timer? _redraw;
  Timer? _captureTimeout;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _running) _stop();
  }

  void _timings(List<FrameTiming> timings) {
    if (!_running || _elapsed.elapsed < const Duration(seconds: 2)) return;
    for (final timing in timings) {
      _session.recordFrame(
        buildMs: timing.buildDuration.inMicroseconds / 1000,
        rasterMs: timing.rasterDuration.inMicroseconds / 1000,
      );
    }
  }

  void _start() {
    setState(() {
      _generation++;
      _session = BenchmarkSession(refreshRate: _refreshRate);
      _elapsed
        ..reset()
        ..start();
      _running = true;
      _error = null;
    });
    SchedulerBinding.instance.addTimingsCallback(_timings);
    _observingTimings = true;
    // Refresh metrics once per second rather than rebuilding for every frame.
    _redraw = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _running) setState(() {});
    });
  }

  void _detachTimings() {
    if (_observingTimings) {
      SchedulerBinding.instance.removeTimingsCallback(_timings);
      _observingTimings = false;
    }
  }

  void _stop() {
    _detachTimings();
    _redraw?.cancel();
    _captureTimeout?.cancel();
    _elapsed.stop();
    _captureElapsed = null;
    if (mounted) {
      setState(() {
        _running = false;
        _capturePending = false;
      });
    }
  }

  void _failure(Object error) {
    if (!mounted) return;
    _captureTimeout?.cancel();
    _captureElapsed = null;
    setState(() {
      _session.errors++;
      _error = error.toString();
      _capturePending = false;
    });
  }

  Future<void> _capture() async {
    if (!_running || _capturePending) return;
    final generation = _generation;
    setState(() {
      _capturePending = true;
      _error = null;
    });
    _captureElapsed = Stopwatch()..start();
    _captureTimeout = Timer(const Duration(seconds: 15), () {
      if (mounted && _running && generation == _generation) {
        _failure('Capture callback timed out after 15 seconds.');
      }
    });
    try {
      await _camera.capture();
    } on Object catch (error) {
      if (mounted && _running && generation == _generation) _failure(error);
    }
  }

  Future<void> _torch() async {
    try {
      await _camera.toggleFlash();
      if (mounted) setState(() {});
    } on Object catch (error) {
      if (mounted && _running) _failure(error);
    }
  }

  Map<String, Object?> _report() => {
    'schemaVersion': 1,
    'createdAtUtc': DateTime.now().toUtc().toIso8601String(),
    'deviceLabel': _device.text.trim(),
    'os': Platform.operatingSystem,
    'osVersion': Platform.operatingSystemVersion,
    'buildMode': kReleaseMode
        ? 'release'
        : kProfileMode
        ? 'profile'
        : 'debug',
    'sdkVersion': '2.0.0-unreleased',
    'elapsedMs': _elapsed.elapsedMilliseconds,
    'warmupSeconds': 2,
    'configuration': {
      'quality': _quality.name,
      'forceEdgeOverlay': _forceOverlay,
      'showEdgeOverlay': _showOverlay,
      'autoCapture': false,
      'editAfterCapture': false,
      'shape': 'rectangle',
    },
    'torchRequestedAtStop': _camera.flashEnabled,
    ..._session.report(),
  };

  Future<void> _copyReport() async {
    await Clipboard.setData(
      ClipboardData(
        text: const JsonEncoder.withIndent('  ').convert(_report()),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Benchmark JSON copied. No image or licence key included.',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detachTimings();
    _redraw?.cancel();
    _captureTimeout?.cancel();
    _camera.dispose();
    _device.dispose();
    super.dispose();
  }

  String _format(Object? value) =>
      value is num ? value.toStringAsFixed(1) : '—';
  @override
  Widget build(BuildContext context) {
    final report = _session.report();
    final captures = report['captureCallback']! as Map<String, Object?>;
    final build = report['flutterBuild']! as Map<String, Object?>;
    final raster = report['flutterRaster']! as Map<String, Object?>;
    final generation = _generation;
    return Scaffold(
      appBar: AppBar(title: const Text('Performance workbench')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Measure on a real device in profile/release mode. Capture latency includes still capture, byte transport and callback delivery. Flutter timings do not measure native camera FPS or model inference.',
            ),
            if (kDebugMode)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Debug mode: use flutter run --profile for useful comparisons.',
                ),
              ),
            TextField(
              controller: _device,
              enabled: !_running,
              decoration: const InputDecoration(
                labelText: 'Device / test-condition label',
                hintText: 'e.g. Samsung S24, bright desk, cool device',
              ),
            ),
            DropdownButtonFormField<AresEdgeQuality>(
              initialValue: _quality,
              decoration: const InputDecoration(labelText: 'Analysis quality'),
              items: AresEdgeQuality.values
                  .map((q) => DropdownMenuItem(value: q, child: Text(q.name)))
                  .toList(),
              onChanged: _running ? null : (q) => setState(() => _quality = q!),
            ),
            DropdownButtonFormField<int>(
              initialValue: _refreshRate,
              decoration: const InputDecoration(
                labelText: 'Comparison frame budget (Hz)',
              ),
              items: [60, 90, 120]
                  .map(
                    (hz) => DropdownMenuItem(value: hz, child: Text('$hz Hz')),
                  )
                  .toList(),
              onChanged: _running
                  ? null
                  : (hz) => setState(() => _refreshRate = hz!),
            ),
            SwitchListTile(
              title: const Text('Force continuous overlay'),
              value: _forceOverlay,
              onChanged: _running
                  ? null
                  : (v) => setState(() => _forceOverlay = v),
            ),
            SwitchListTile(
              title: const Text('Show overlay'),
              value: _showOverlay,
              onChanged: _running
                  ? null
                  : (v) => setState(() => _showOverlay = v),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _running ? _stop : _start,
                  child: Text(_running ? 'Stop session' : 'Start session'),
                ),
                OutlinedButton(
                  onPressed: _running ? null : _copyReport,
                  child: const Text('Copy report JSON'),
                ),
              ],
            ),
            if (_running) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 320,
                child: AresEdgeEmbedded(
                  key: ValueKey(generation),
                  controller: _camera,
                  licenceKey: widget.licenceKey,
                  options: AresEdgeOptions(
                    quality: _quality,
                    forceEdgeOverlay: _forceOverlay,
                    showEdgeOverlay: _showOverlay,
                  ),
                  onCapture: (image) {
                    if (!mounted || !_running || generation != _generation) {
                      return;
                    }
                    final watch = _captureElapsed;
                    if (watch == null) return;
                    watch.stop();
                    _captureTimeout?.cancel();
                    _session.recordCapture(
                      milliseconds: watch.elapsedMicroseconds / 1000,
                      bytes: image.bytes.length,
                    );
                    _captureElapsed = null;
                    setState(() => _capturePending = false);
                  },
                  onError: (error) {
                    if (_running && generation == _generation) _failure(error);
                  },
                  onLicenceRequired: () {
                    if (_running && generation == _generation) {
                      _failure(
                        'SDK trial expired. Configure a valid developer licence for longer tests.',
                      );
                      _stop();
                    }
                  },
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(
                    onPressed: _capturePending ? null : _capture,
                    child: Text(
                      _capturePending
                          ? 'Waiting for capture…'
                          : 'Measure capture',
                    ),
                  ),
                  TextButton(
                    onPressed: _capturePending ? null : _torch,
                    child: const Text('Toggle flashlight'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Session: ${_elapsed.elapsed.inSeconds}s · Warm-up: first 2s excluded from Flutter timings',
            ),
            Text(
              'Capture samples: ${captures['samples']} · p50: ${_format(captures['p50Ms'])} ms · p95: ${_format(captures['p95Ms'])} ms',
            ),
            Text(
              'Flutter frames: ${build['samples']} · build p95: ${_format(build['p95Ms'])} ms · raster p95: ${_format(raster['p95Ms'])} ms',
            ),
            Text(
              'Flutter frames over budget: ${_format(report['flutterFramesOverBudgetPercent'])}%',
            ),
            Text('Errors: ${report['errors']}'),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 12),
            const Text(
              'Stop before changing configuration or copying results. Only measured samples are exported; native FPS/inference fields remain null. Images are discarded after counting their encoded byte size. Timings retain the last 10,000 Flutter frames and 100 captures.',
            ),
          ],
        ),
      ),
    );
  }
}
