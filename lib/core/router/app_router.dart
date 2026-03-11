import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/features/login/presentation/login_screen.dart';

/// Rotas definidas conforme ecrãs existentes no Figma.
/// Não adicionar rotas que não existam no design.
final class AppRouter {
  AppRouter._();

  static const String login = '/login';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: login,
      routes: [
        GoRoute(
          path: login,
          name: 'login',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LoginScreen(),
          ),
        ),
      ],
    );
  }
}
