import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ares_edge_example/main.dart';

void main() {
  testWidgets('offers both integration modes and editor switch', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ExampleHome()));
    expect(find.text('Open AresEdgeScreen'), findsOneWidget);
    expect(find.text('Open custom AresEdgeEmbedded'), findsOneWidget);
    expect(find.text('Open performance workbench'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(tester.widget<Switch>(find.byType(Switch)).value, false);
  });
}
