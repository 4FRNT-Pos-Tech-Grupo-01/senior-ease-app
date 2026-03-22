import 'package:shared_preferences/shared_preferences.dart';
import 'package:senior_ease/models/activity_history_entry.dart';

/// Histórico de atividades (últimas [maxEntries] entradas, mais recentes primeiro).
final class ActivityHistoryStorage {
  ActivityHistoryStorage._();
  static final ActivityHistoryStorage instance = ActivityHistoryStorage._();

  static const _key = 'senior_ease_activity_history_v1';
  static const maxEntries = 100;

  Future<List<ActivityHistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return ActivityHistoryEntry.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<ActivityHistoryEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, ActivityHistoryEntry.encodeList(list));
  }

  /// Adiciona entrada no topo e persiste.
  Future<void> append(String title) async {
    final list = await load();
    list.insert(
      0,
      ActivityHistoryEntry(
        id: 'h_${DateTime.now().microsecondsSinceEpoch}',
        title: title,
        recordedAt: DateTime.now(),
      ),
    );
    if (list.length > maxEntries) {
      list.removeRange(maxEntries, list.length);
    }
    await save(list);
  }
}
