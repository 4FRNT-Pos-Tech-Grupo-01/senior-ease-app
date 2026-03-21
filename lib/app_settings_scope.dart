import 'package:flutter/material.dart';
import 'package:senior_ease/services/app_settings_controller.dart';

/// Expõe [AppSettingsController] na árvore (ex.: perfil para alterar fonte/contraste).
class AppSettingsScope extends InheritedNotifier<AppSettingsController> {
  const AppSettingsScope({
    super.key,
    required AppSettingsController notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppSettingsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope não encontrado');
    return scope!.notifier!;
  }
}
