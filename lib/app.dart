import 'package:flutter/material.dart';
import 'package:senior_ease/app_router.dart';
import 'package:senior_ease/app_scope.dart';
import 'package:senior_ease/app_settings_scope.dart';
import 'package:senior_ease/domain/repositories/auth_repository.dart';
import 'package:senior_ease/domain/repositories/user_data_repository.dart';
import 'package:senior_ease/services/app_settings_controller.dart';
import 'package:senior_ease/services/auth_refresh_notifier.dart';
import 'package:senior_ease/theme/app_theme.dart';

class SeniorEaseApp extends StatelessWidget {
  const SeniorEaseApp({
    super.key,
    required this.settings,
    required this.authRefreshNotifier,
    required this.userDataRepository,
    required this.authRepository,
  });

  final AppSettingsController settings;
  final AuthRefreshNotifier authRefreshNotifier;
  final UserDataRepository userDataRepository;
  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      userData: userDataRepository,
      auth: authRepository,
      child: AppSettingsScope(
        notifier: settings,
        child: ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'Senior Ease',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.themeForSettings(settings),
              routerConfig:
                  AppRouter.router(authRepository, authRefreshNotifier),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(settings.textScale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
