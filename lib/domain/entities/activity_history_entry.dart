import 'dart:convert';

/// Registo de uma atividade concluída na app (histórico).
class ActivityHistoryEntry {
  const ActivityHistoryEntry({
    required this.id,
    required this.title,
    required this.recordedAt,
  });

  final String id;
  final String title;
  final DateTime recordedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory ActivityHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ActivityHistoryEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  static String encodeList(List<ActivityHistoryEntry> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<ActivityHistoryEntry> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (e) => ActivityHistoryEntry.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}
