import 'package:flutter/material.dart';

const double kMinTouchTargetSize = 48.0;

class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.child,
    this.minHeight = kMinTouchTargetSize,
    this.minWidth = kMinTouchTargetSize,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? child;
  final double minHeight;
  final double minWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = semanticLabel ?? label;

    return Semantics(
      button: true,
      label: effectiveLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          minHeight: minHeight,
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(minWidth, minHeight),
          ),
          child: child ?? Text(label),
        ),
      ),
    );
  }
}
