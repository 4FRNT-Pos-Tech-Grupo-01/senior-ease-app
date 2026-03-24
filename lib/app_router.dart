import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/domain/repositories/auth_repository.dart';
import 'package:senior_ease/screens/register_screen.dart';
import 'package:senior_ease/screens/screen_1.dart';
import 'package:senior_ease/screens/screen_2.dart';
import 'package:senior_ease/screens/screen_3.dart';
import 'package:senior_ease/screens/task_management_screen.dart';

final class AppRouter {
  AppRouter._();

  static const String screen1 = '/screen_1';
  static const String screen2 = '/screen_2';
  static const String register = '/cadastro';

  static const String screen3 = '$screen2/perfil';
  static const String taskManagement = '$screen2/tarefas';

  static GoRouter? _router;

  /// Chamar uma vez a partir do [main], com o mesmo [authListenable] em todas as reconstruções.
  static GoRouter router(
    AuthRepository auth,
    Listenable authListenable,
  ) {
    return _router ??= GoRouter(
      initialLocation: screen1,
      refreshListenable: authListenable,
      redirect: (context, state) => _redirect(auth, state),
      routes: [
        GoRoute(
          path: screen1,
          name: 'screen_1',
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const Screen1()),
        ),
        GoRoute(
          path: register,
          name: 'register',
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const RegisterScreen()),
        ),
        GoRoute(
          path: screen2,
          name: 'screen_2',
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const Screen2()),
          routes: [
            GoRoute(
              path: 'perfil',
              name: 'screen_3',
              pageBuilder: (context, state) =>
                  MaterialPage(key: state.pageKey, child: const Screen3()),
            ),
            GoRoute(
              path: 'tarefas',
              name: 'task_management',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: const TaskManagementScreen(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String? _redirect(AuthRepository auth, GoRouterState state) {
    final loggedIn = auth.currentSession != null;
    final loc = state.matchedLocation;
    final isPublic = loc == screen1 || loc == register;
    if (!loggedIn && !isPublic) return screen1;
    if (loggedIn && isPublic) return screen2;
    return null;
  }
}
