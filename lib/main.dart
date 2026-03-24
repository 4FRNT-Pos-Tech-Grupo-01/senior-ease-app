import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:senior_ease/app.dart';
import 'package:senior_ease/application/reminder_purge_runner.dart';
import 'package:senior_ease/application/use_cases/purge_expired_reminders.dart';
import 'package:senior_ease/data/repositories/firebase_auth_repository.dart';
import 'package:senior_ease/data/repositories/firestore_user_data_repository.dart';
import 'package:senior_ease/firebase_options.dart';
import 'package:senior_ease/services/app_settings_controller.dart';
import 'package:senior_ease/services/auth_refresh_notifier.dart';
import 'package:senior_ease/services/notification_service.dart';

/// Purga lembretes expirados sem envolver o [MaterialApp] num [StatefulWidget],
/// para evitar efeitos colaterais no foco dos campos (ex.: login).
///
/// Em hot-restart / segunda execução de [main], remove o observer antigo para
/// não acumular dependentes no [WidgetsBinding] (evita assert `_dependents.isEmpty`).
final class _ReminderPurgeLifecycleObserver with WidgetsBindingObserver {
  _ReminderPurgeLifecycleObserver() {
    WidgetsBinding.instance.addObserver(this);
  }

  bool _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Adiar para fora da fase de notificação de ciclo de vida — evita
      // conflitos com InheritedWidget durante transições (assert
      // `_dependents.isEmpty` em debug).
      _schedulePurgeAfterFrame();
    }
  }
}

Timer? _reminderPurgeTimer;
_ReminderPurgeLifecycleObserver? _reminderPurgeLifecycleObserver;

ReminderPurgeRunner? _reminderPurgeRunner;

void _schedulePurgeAfterFrame() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _reminderPurgeRunner?.purgeExpired();
  });
}

void _startReminderMaintenance() {
  _reminderPurgeTimer?.cancel();
  _reminderPurgeLifecycleObserver?.dispose();

  _schedulePurgeAfterFrame();
  _reminderPurgeTimer = Timer.periodic(
    const Duration(seconds: 2),
    (_) => _schedulePurgeAfterFrame(),
  );
  _reminderPurgeLifecycleObserver = _ReminderPurgeLifecycleObserver();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final userDataRepository = FirestoreUserDataRepository();
  final authRepository = FirebaseAuthRepository();
  final purgeExpiredReminders = PurgeExpiredReminders(userDataRepository);
  _reminderPurgeRunner = ReminderPurgeRunner(
    userData: userDataRepository,
    auth: authRepository,
    purge: purgeExpiredReminders,
    syncLocalNotifications: AppSettingsController.syncRemindersWithPersistedFlags,
  );
  final authRefreshNotifier = AuthRefreshNotifier(authRepository);
  final settings = AppSettingsController(
    userData: userDataRepository,
    auth: authRepository,
  );
  await settings.load();
  await NotificationService.instance.init();
  _startReminderMaintenance();
  runApp(
    SeniorEaseApp(
      settings: settings,
      authRefreshNotifier: authRefreshNotifier,
      userDataRepository: userDataRepository,
      authRepository: authRepository,
    ),
  );
}
