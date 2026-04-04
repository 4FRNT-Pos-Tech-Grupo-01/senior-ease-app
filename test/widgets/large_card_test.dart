import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_ease/widgets/large_card.dart';

void main() {
  group('LargeCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LargeCard(
              child: Text('Conteúdo do card'),
            ),
          ),
        ),
      );

      expect(find.text('Conteúdo do card'), findsOneWidget);
    });

    testWidgets('wraps with Semantics when semanticLabel is set', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LargeCard(
              semanticLabel: 'Resumo do dia',
              child: SizedBox.shrink(),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Resumo do dia'), findsOneWidget);
    });

    testWidgets('uses custom padding on inner container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LargeCard(
              padding: EdgeInsets.all(10),
              child: Text('Item'),
            ),
          ),
        ),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(of: find.byType(LargeCard), matching: find.byType(Container)),
      );
      expect(containers.first.padding, const EdgeInsets.all(10));
    });
  });
}
