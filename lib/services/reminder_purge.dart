import 'package:firebase_auth/firebase_auth.dart';
import 'package:senior_ease/models/reminder.dart';
import 'package:senior_ease/services/app_settings_controller.dart';
import 'package:senior_ease/services/user_cloud_data_service.dart';

/// Remove lembretes cuja hora já passou há pelo menos [graceAfterScheduled].
///
/// **Importante:** isto é independente da notificação ter sido entregue ou vista.
/// Se a margem for curta, o cartão desaparece logo após a hora mesmo sem alerta
/// do sistema — por isso usamos várias horas para ainda ver o lembrete na app.
///
/// Dados por utilizador: Firestore `users/{uid}/reminders`.
final class ReminderPurge {
  ReminderPurge._();

  /// Tempo **depois** de [Reminder.scheduledAt] em que o item ainda aparece na lista.
  /// Passado esse instante, é removido do armazenamento (e das notificações pendentes).
  static const Duration graceAfterScheduled = Duration(hours: 6);

  static bool _shouldKeep(Reminder r, DateTime now) {
    return now.isBefore(r.scheduledAt.add(graceAfterScheduled));
  }

  /// Evita execuções em paralelo (timer + resume + post-frame).
  static Future<bool>? _ongoing;

  /// Devolve `true` se a lista foi alterada.
  static Future<bool> purgeExpired() {
    if (_ongoing != null) return _ongoing!;
    _ongoing = _purgeExpiredBody().whenComplete(() => _ongoing = null);
    return _ongoing!;
  }

  static Future<bool> _purgeExpiredBody() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final svc = UserCloudDataService.instance;
    final list = await svc.loadRemindersOnce(uid);
    if (list.isEmpty) return false;

    final now = DateTime.now();
    final kept = list.where((r) => _shouldKeep(r, now)).toList();
    if (kept.length == list.length) return false;

    await svc.replaceAllReminders(uid, kept);
    await AppSettingsController.syncRemindersWithPersistedFlags(kept);
    return true;
  }
}
