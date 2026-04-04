import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_ease/theme/app_theme.dart';

void main() {
  group('AppColors', () {
    test('primary brand colors are defined', () {
      expect(AppColors.lightBlue, const Color(0xFF117CEE));
      expect(AppColors.darkBlue, const Color(0xFF172636));
      expect(AppColors.jungleGreen, const Color(0xFF2BAB6F));
    });
  });

  group('AppTheme.light', () {
    testWidgets('uses Material 3 and expected color scheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SizedBox.shrink()),
      );
      final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.lightBlue);
      expect(theme.colorScheme.onPrimary, AppColors.white);
      expect(theme.scaffoldBackgroundColor, AppColors.grey98);
    });

    testWidgets('elevated button theme uses brand primary', (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SizedBox.shrink()),
      );
      final theme = tester.widget<MaterialApp>(find.byType(MaterialApp)).theme!;
      final style = theme.elevatedButtonTheme.style;
      expect(style, isNotNull);
      final bg = style!.backgroundColor?.resolve(<WidgetState>{});
      expect(bg, AppColors.lightBlue);
    });
  });
}
