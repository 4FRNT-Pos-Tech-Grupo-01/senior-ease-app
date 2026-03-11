import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior_ease/screens/screen_1.dart';
import 'package:senior_ease/screens/screen_2.dart';
import 'package:senior_ease/screens/screen_3.dart';

final class AppRouter {
  AppRouter._();

  static const String screen1 = '/screen_1';
  static const String screen2 = '/screen_2';
  static const String screen3 = '/screen_3';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: screen1,
      routes: [
        GoRoute(
          path: screen1,
          name: 'screen_1',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const Screen1(),
          ),
        ),
        GoRoute(
          path: screen2,
          name: 'screen_2',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const Screen2(),
          ),
        ),
        GoRoute(
          path: screen3,
          name: 'screen_3',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const Screen3(),
          ),
        ),
      ],
    );
  }
}
