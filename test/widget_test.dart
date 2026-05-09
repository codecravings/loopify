import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:loopify/main.dart';

void main() {
  testWidgets('Loopify app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LoopifyApp());

    // Verify that we have the Loopify title
    expect(find.text('Loopify'), findsOneWidget);
  });
}
