import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_ease/screens/profile_screen.dart';
import 'package:senior_ease/theme/app_theme.dart';

void main() {
  testWidgets('ProfileScreen shows user and font size section', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ProfileScreen(),
      ),
    );

    expect(find.text('Usuário Senior Ease'), findsOneWidget);
    expect(find.text('usuario@email.com'), findsOneWidget);
    expect(find.text('Tamanho da Fonte'), findsOneWidget);
  });

  testWidgets('confirmações extras switch toggles', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(3));
    expect(tester.widget<Switch>(switches.at(0)).value, isFalse);

    await tester.tap(switches.at(0));
    await tester.pump();

    expect(tester.widget<Switch>(switches.at(0)).value, isTrue);
  });
}
