import 'package:senior_ease/domain/entities/reminder.dart';
import 'package:senior_ease/domain/repositories/user_data_repository.dart';

/// Remove lembretes cuja janela de tolerância após a hora agendada já expirou.
final class PurgeExpiredReminders {
  PurgeExpiredReminders(this._userData);

  final UserDataRepository _userData;

  /// Tempo **depois** de [Reminder.scheduledAt] em que o item ainda aparece na lista.
  static const Duration graceAfterScheduled = Duration(hours: 6);

  static bool _shouldKeep(Reminder r, DateTime now) {
    return now.isBefore(r.scheduledAt.add(graceAfterScheduled));
  }

  /// Devolve `true` se a lista no servidor foi alterada.
  Future<bool> call(String uid) async {
    final list = await _userData.loadRemindersOnce(uid);
    if (list.isEmpty) return false;

    final now = DateTime.now();
    final kept = list.where((r) => _shouldKeep(r, now)).toList();
    if (kept.length == list.length) return false;

    await _userData.replaceAllReminders(uid, kept);
    return true;
  }
}
