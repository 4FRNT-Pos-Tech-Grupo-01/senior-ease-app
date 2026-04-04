import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_ease/screens/screen_3.dart';
import 'package:senior_ease/theme/app_theme.dart';

void main() {
  testWidgets('Screen3 shows title and back action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Screen3(),
      ),
    );

    expect(find.text('Tela 3'), findsOneWidget);
    expect(find.text('Voltar'), findsOneWidget);
  });
}
