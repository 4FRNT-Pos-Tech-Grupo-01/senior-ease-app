import 'package:flutter/material.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/theme/app_theme.dart';

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
