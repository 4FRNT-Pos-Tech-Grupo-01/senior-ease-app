/// Utilitários de acessibilidade para utilizadores sénior.
///
/// Requisitos (conforme doc):
/// - Alvos de toque ≥ 48px
/// - Semantics onde fizer sentido
/// - Labels acessíveis
/// - Respeitar text scaling do sistema
library;

import 'package:flutter/material.dart';

/// Tamanho mínimo de alvo de toque (WCAG / doc).
const double kMinTouchTargetSize = 48.0;

/// Garante que um widget tenha área de toque mínima acessível.
Widget ensureMinTouchTarget({
  required Widget child,
  double minSize = kMinTouchTargetSize,
}) {
  return Semantics(
    button: true,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: null,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
          child: Center(child: child),
        ),
      ),
    ),
  );
}
