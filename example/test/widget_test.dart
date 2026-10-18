import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ares_edge_example/main.dart';

void main() {
  testWidgets('offers both scanner modes without an editor', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ExampleHome()));
    expect(find.text('Open AresEdgeScreen'), findsOneWidget);
    expect(find.text('Open custom AresEdgeEmbedded'), findsOneWidget);
    expect(find.text('Open performance workbench'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNothing);
  });
}
