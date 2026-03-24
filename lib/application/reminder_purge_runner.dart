import 'package:senior_ease/application/use_cases/purge_expired_reminders.dart';
import 'package:senior_ease/domain/entities/reminder.dart';
import 'package:senior_ease/domain/repositories/auth_repository.dart';
import 'package:senior_ease/domain/repositories/user_data_repository.dart';

/// Orquestra purga + sincronização de notificações locais (anti-paralelismo).
final class ReminderPurgeRunner {
  ReminderPurgeRunner({
    required UserDataRepository userData,
    required AuthRepository auth,
    required PurgeExpiredReminders purge,
    required Future<void> Function(List<Reminder> reminders) syncLocalNotifications,
  })  : _userData = userData,
        _auth = auth,
        _purge = purge,
        _syncLocalNotifications = syncLocalNotifications;

  final UserDataRepository _userData;
  final AuthRepository _auth;
  final PurgeExpiredReminders _purge;
  final Future<void> Function(List<Reminder> reminders) _syncLocalNotifications;

  Future<bool>? _ongoing;

  Future<bool> purgeExpired() {
    if (_ongoing != null) return _ongoing!;
    _ongoing = _run().whenComplete(() => _ongoing = null);
    return _ongoing!;
  }

  Future<bool> _run() async {
    final uid = _auth.currentSession?.uid;
    if (uid == null) return false;

    final changed = await _purge.call(uid);
    if (!changed) return false;

    final list = await _userData.loadRemindersOnce(uid);
    await _syncLocalNotifications(list);
    return true;
  }
}
