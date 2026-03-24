import 'package:flutter/material.dart';
import 'package:senior_ease/domain/repositories/auth_repository.dart';
import 'package:senior_ease/domain/repositories/user_data_repository.dart';

/// Injeta portas de domínio na árvore de widgets (camada de apresentação).
final class AppScope extends InheritedWidget {
  const AppScope({
    required this.userData,
    required this.auth,
    required super.child,
    super.key,
  });

  final UserDataRepository userData;
  final AuthRepository auth;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado acima deste contexto.');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) {
    return userData != oldWidget.userData || auth != oldWidget.auth;
  }
}
