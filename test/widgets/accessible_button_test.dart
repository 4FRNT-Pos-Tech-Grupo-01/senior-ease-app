import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_ease/widgets/accessible_button.dart';

void main() {
  group('AccessibleButton', () {
    testWidgets('shows label and invokes onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              label: 'Continuar',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Continuar'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('uses semanticLabel when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              label: 'OK',
              semanticLabel: 'Confirmar e avançar',
              onPressed: null,
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(
        find.descendant(of: find.byType(AccessibleButton), matching: find.byType(Semantics)).first,
      );
      expect(semantics.label, 'Confirmar e avançar');
    });

    testWidgets('applies minimum touch target on ElevatedButton', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibleButton(
              label: 'Grande',
              minWidth: 64,
              minHeight: 56,
              onPressed: () {},
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(ElevatedButton));
      expect(size.width, greaterThanOrEqualTo(64));
      expect(size.height, greaterThanOrEqualTo(56));
    });
  });
}
