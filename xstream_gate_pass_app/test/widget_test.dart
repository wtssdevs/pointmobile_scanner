import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';

import 'package:xstream_gate_pass_app/main.dart';

import 'helpers/test_helpers.dart';

void main() {
  setUp(() => registerServices());
  tearDown(() => locator.reset());

  testWidgets('App shell builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
