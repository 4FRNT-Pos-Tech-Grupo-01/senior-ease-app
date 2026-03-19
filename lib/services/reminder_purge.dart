import 'package:senior_ease/models/reminder.dart';
import 'package:senior_ease/services/notification_service.dart';
import 'package:senior_ease/services/reminders_storage.dart';

/// Remove lembretes cuja hora já passou há pelo menos [graceAfterScheduled].
///
/// **Importante:** isto é independente da notificação ter sido entregue ou vista.
/// Se a margem for curta, o cartão desaparece logo após a hora mesmo sem alerta
/// do sistema — por isso usamos várias horas para ainda ver o lembrete na app.
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
    final storage = RemindersStorage.instance;
    final list = await storage.load();
    if (list.isEmpty) return false;

    final now = DateTime.now();
    final kept = list.where((r) => _shouldKeep(r, now)).toList();
    if (kept.length == list.length) return false;

    await storage.save(kept);
    await NotificationService.instance.syncReminders(kept);
    // A UI dos lembretes (Screen2) sincroniza lendo o armazenamento num timer
    // local — evita ValueNotifier global que no iOS pode disparar
    // `'_dependents.isEmpty'` com InheritedWidget.
    return true;
  }
}
