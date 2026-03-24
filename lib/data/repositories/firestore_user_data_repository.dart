import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_ease/data/mappers/guided_step_item_mapper.dart';
import 'package:senior_ease/data/mappers/user_task_item_mapper.dart';
import 'package:senior_ease/domain/entities/activity_history_entry.dart';
import 'package:senior_ease/domain/entities/guided_step_item.dart';
import 'package:senior_ease/domain/entities/reminder.dart';
import 'package:senior_ease/domain/entities/user_task_item.dart';
import 'package:senior_ease/domain/repositories/user_data_repository.dart';

/// Implementação Firestore de [UserDataRepository].
final class FirestoreUserDataRepository implements UserDataRepository {
  FirestoreUserDataRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _remindersCol(String uid) =>
      _db.collection('users').doc(uid).collection('reminders');

  DocumentReference<Map<String, dynamic>> _tasksDoc(String uid) =>
      _db.collection('users').doc(uid).collection('home').doc('tasks');

  DocumentReference<Map<String, dynamic>> _guidedDoc(String uid) =>
      _db.collection('users').doc(uid).collection('home').doc('guided');

  DocumentReference<Map<String, dynamic>> _metaLocalDoc(String uid) =>
      _db.collection('users').doc(uid).collection('meta').doc('local');

  CollectionReference<Map<String, dynamic>> _historyCol(String uid) =>
      _db.collection('users').doc(uid).collection('activityHistory');

  Reminder _reminderFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return Reminder(
      id: d.id,
      title: m['title'] as String,
      scheduledAt: (m['scheduledAt'] as Timestamp).toDate(),
      notificationId: (m['notificationId'] as num).toInt(),
      iconIndex: (m['iconIndex'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> _reminderToMap(Reminder r) => {
        'title': r.title,
        'scheduledAt': Timestamp.fromDate(r.scheduledAt),
        'notificationId': r.notificationId,
        'iconIndex': r.iconIndex,
      };

  @override
  Future<int> takeNextNotificationId(String uid) async {
    final ref = _metaLocalDoc(uid);
    return _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final next = (snap.data()?['nextNotificationId'] as num?)?.toInt() ??
          10000;
      tx.set(ref, {'nextNotificationId': next + 1}, SetOptions(merge: true));
      return next;
    });
  }

  @override
  Future<List<Reminder>> loadRemindersOnce(String uid) async {
    final snap = await _remindersCol(uid).get();
    final list = snap.docs.map(_reminderFromDoc).toList();
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return list;
  }

  @override
  Stream<List<Reminder>> remindersStream(String uid) {
    return _remindersCol(uid).snapshots().map((snap) {
      final list = snap.docs.map(_reminderFromDoc).toList();
      list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return list;
    });
  }

  @override
  Future<void> upsertReminder(String uid, Reminder r) async {
    await _remindersCol(uid).doc(r.id).set(_reminderToMap(r));
  }

  @override
  Future<void> deleteReminder(String uid, String reminderId) async {
    await _remindersCol(uid).doc(reminderId).delete();
  }

  @override
  Future<void> replaceAllReminders(String uid, List<Reminder> list) async {
    final col = _remindersCol(uid);
    final batch = _db.batch();
    final existing = await col.get();
    final keepIds = list.map((e) => e.id).toSet();
    for (final d in existing.docs) {
      if (!keepIds.contains(d.id)) {
        batch.delete(d.reference);
      }
    }
    for (final r in list) {
      batch.set(col.doc(r.id), _reminderToMap(r));
    }
    await batch.commit();
  }

  static const List<String> _legacyGuidedTitles = [
    'Pegue o remédio na caixa azul',
    'Tome com um copo cheio de água',
    'Anote no caderno que já tomou',
  ];

  List<UserTaskItem> _parseTaskItems(Map<String, dynamic>? data) {
    final raw = data?['items'] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return [];
    final out = <UserTaskItem>[];
    for (final e in raw) {
      if (e is! Map) continue;
      try {
        out.add(
          UserTaskItemMapper.fromFirestore(Map<String, dynamic>.from(e)),
        );
      } catch (_) {}
    }
    return out;
  }

  @override
  Future<void> saveTaskLists(
    String uid, {
    required List<UserTaskItem> pending,
    required List<UserTaskItem> completed,
  }) async {
    final items = <Map<String, dynamic>>[
      ...pending.map(
        (e) => UserTaskItemMapper.toFirestore(e.copyWith(completed: false)),
      ),
      ...completed.map(
        (e) => UserTaskItemMapper.toFirestore(e.copyWith(completed: true)),
      ),
    ];
    await _tasksDoc(uid).set({'items': items}, SetOptions(merge: true));
  }

  @override
  Stream<List<UserTaskItem>> taskItemsStream(String uid) {
    return _tasksDoc(uid).snapshots().map((snap) {
      return _parseTaskItems(snap.data());
    });
  }

  @override
  Future<({List<UserTaskItem> pending, List<UserTaskItem> completed})>
      loadTaskListsOnce(String uid) async {
    final snap = await _tasksDoc(uid).get();
    final items = _parseTaskItems(snap.data());
    final pending = <UserTaskItem>[];
    final completed = <UserTaskItem>[];
    for (final t in items) {
      if (t.completed) {
        completed.add(t);
      } else {
        pending.add(t);
      }
    }
    return (pending: pending, completed: completed);
  }

  List<GuidedStepItem> _parseGuidedSteps(Map<String, dynamic>? data) {
    final raw = data?['steps'] as List<dynamic>?;
    if (raw != null && raw.isNotEmpty) {
      final list = <GuidedStepItem>[];
      for (final e in raw) {
        if (e is! Map) continue;
        try {
          list.add(
            GuidedStepItemMapper.fromFirestore(
              Map<String, dynamic>.from(e),
            ),
          );
        } catch (_) {}
      }
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    }

    final legacyDone = data?['stepsDone'] as List<dynamic>?;
    if (legacyDone != null && legacyDone.isNotEmpty) {
      final n = legacyDone.length.clamp(1, _legacyGuidedTitles.length);
      return List.generate(
        n,
        (i) => GuidedStepItem(
          id: 'legacy_$i',
          title: i < _legacyGuidedTitles.length
              ? _legacyGuidedTitles[i]
              : 'Passo ${i + 1}',
          completed: i < legacyDone.length && legacyDone[i] == true,
          order: i,
        ),
      );
    }

    return [];
  }

  @override
  Stream<List<GuidedStepItem>> guidedStepsStream(String uid) {
    return _guidedDoc(uid).snapshots().map((snap) {
      return _parseGuidedSteps(snap.data());
    });
  }

  @override
  Future<void> saveGuidedSteps(String uid, List<GuidedStepItem> steps) async {
    await _guidedDoc(uid).set({
      'steps': steps.map(GuidedStepItemMapper.toFirestore).toList(),
    });
  }

  @override
  Stream<List<ActivityHistoryEntry>> activityHistoryStream(String uid) {
    return _historyCol(uid)
        .orderBy('recordedAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) {
      return snap.docs.map((d) {
        final m = d.data();
        return ActivityHistoryEntry(
          id: d.id,
          title: m['title'] as String,
          recordedAt: (m['recordedAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  @override
  Future<void> appendActivityHistory(String uid, String title) async {
    await _historyCol(uid).add({
      'title': title,
      'recordedAt': FieldValue.serverTimestamp(),
    });
  }
}
