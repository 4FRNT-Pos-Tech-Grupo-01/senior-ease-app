import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/screens/screen_1.dart';
import 'package:senior_ease/screens/screen_2.dart';
import 'package:senior_ease/screens/screen_3.dart';
import 'package:senior_ease/screens/task_management_screen.dart';

final class AppRouter {
  AppRouter._();

  static const String screen1 = '/screen_1';
  static const String screen2 = '/screen_2';

  static const String screen3 = '$screen2/perfil';

  static const String taskManagement = '$screen2/tarefas';

  static final GoRouter router = GoRouter(
    initialLocation: screen1,
    routes: [
      GoRoute(
        path: screen1,
        name: 'screen_1',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const Screen1()),
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
