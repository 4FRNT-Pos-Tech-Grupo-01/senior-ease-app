import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senior_ease/core/router/app_router.dart';
import 'package:senior_ease/core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SeniorEaseApp(),
    ),
  );
}

class SeniorEaseApp extends StatelessWidget {
  const SeniorEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Senior Ease',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.createRouter(),
    );
  }
}
