import 'package:shared_preferences/shared_preferences.dart';
import 'package:senior_ease/models/reminder.dart';

/// Persistência local dos lembretes e contador de IDs de notificação.
final class RemindersStorage {
  RemindersStorage._();
  static final RemindersStorage instance = RemindersStorage._();

  static const _keyReminders = 'senior_ease_reminders_v1';
  static const _keyNextNotifId = 'senior_ease_next_notif_id';

  Future<List<Reminder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyReminders);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Reminder.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Reminder> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReminders, Reminder.encodeList(list));
  }

  /// IDs únicos para o plugin de notificações (estável por lembrete).
  Future<int> takeNextNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    final next = prefs.getInt(_keyNextNotifId) ?? 10000;
    await prefs.setInt(_keyNextNotifId, next + 1);
    return next;
  }
}
