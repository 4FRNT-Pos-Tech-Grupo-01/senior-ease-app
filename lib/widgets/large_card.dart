import 'package:flutter/material.dart';
import 'package:senior_ease/theme/app_theme.dart';

class LargeCard extends StatelessWidget {
  const LargeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );

    if (semanticLabel != null && semanticLabel!.isNotEmpty) {
      return Semantics(
        container: true,
        label: semanticLabel,
        child: card,
      );
    }
    return card;
  }
}
