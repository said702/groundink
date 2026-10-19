import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:groundink/main.dart';

void main() {
  testWidgets('GroundInk creates its app shell',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GroundInkApp());

    expect(find.byType(GroundInkApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
