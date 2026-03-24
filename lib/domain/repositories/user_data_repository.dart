import 'package:senior_ease/domain/entities/activity_history_entry.dart';
import 'package:senior_ease/domain/entities/guided_step_item.dart';
import 'package:senior_ease/domain/entities/reminder.dart';
import 'package:senior_ease/domain/entities/user_task_item.dart';

/// Porta de dados do utilizador autenticado (`users/{uid}/...`).
abstract interface class UserDataRepository {
  Future<int> takeNextNotificationId(String uid);

  Future<List<Reminder>> loadRemindersOnce(String uid);

  Stream<List<Reminder>> remindersStream(String uid);

  Future<void> upsertReminder(String uid, Reminder r);

  Future<void> deleteReminder(String uid, String reminderId);

  Future<void> replaceAllReminders(String uid, List<Reminder> list);

  Stream<List<UserTaskItem>> taskItemsStream(String uid);

  Future<({List<UserTaskItem> pending, List<UserTaskItem> completed})>
      loadTaskListsOnce(String uid);

  Future<void> saveTaskLists(
    String uid, {
    required List<UserTaskItem> pending,
    required List<UserTaskItem> completed,
  });

  Stream<List<GuidedStepItem>> guidedStepsStream(String uid);

  Future<void> saveGuidedSteps(String uid, List<GuidedStepItem> steps);

  Stream<List<ActivityHistoryEntry>> activityHistoryStream(String uid);

  Future<void> appendActivityHistory(String uid, String title);
}
