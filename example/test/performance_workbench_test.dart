import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ares_edge_example/workbench/performance_workbench.dart';

void main() {
  testWidgets('workbench fits a phone and exports no licence or image', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: PerformanceWorkbench(licenceKey: 'never-export-this-test-key'),
      ),
    );
    expect(find.text('Start session'), findsOneWidget);
    await tester.ensureVisible(find.text('Copy report JSON'));
    await tester.tap(find.text('Copy report JSON'));
    await tester.pump();
    final report = jsonDecode(copied!) as Map;
    expect(report['nativeCameraFps'], isNull);
    expect((report['nativeInferenceMs'] as Map)['samples'], 0);
    expect((report['nativeInferenceMs'] as Map)['p95Ms'], isNull);
    expect((report['captureCallback'] as Map)['samples'], 0);
    expect(copied, isNot(contains('never-export-this-test-key')));
    expect(report.keys, isNot(contains('licenceKey')));
    expect(report.keys, isNot(contains('image')));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('backgrounding stops the workbench and permits a new session', (
    tester,
  ) async {
    const native = MethodChannel('ares_defence_labs_embedded_edge_detection');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      native,
      (call) async => false,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        native,
        null,
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(home: PerformanceWorkbench(licenceKey: 'test')),
    );
    await tester.ensureVisible(find.text('Start session'));
    await tester.tap(find.text('Start session'));
    await tester.pump();
    expect(find.text('Stop session'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(find.text('Start session'), findsOneWidget);
    expect(find.text('Stop session'), findsNothing);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(const SizedBox());
  });
}
