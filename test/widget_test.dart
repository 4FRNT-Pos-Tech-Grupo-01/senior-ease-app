import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_ease/app.dart';

void main() {
  testWidgets('App loads and shows Senior Ease', (WidgetTester tester) async {
    await tester.pumpWidget(const SeniorEaseApp());
    expect(find.text('Senior Ease'), findsOneWidget);
  });
}
