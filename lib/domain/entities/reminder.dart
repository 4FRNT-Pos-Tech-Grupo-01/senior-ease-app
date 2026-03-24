import 'dart:convert';

/// Lembrete persistido e agendado no sistema com [notificationId].
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.notificationId,
    this.iconIndex = 0,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final int notificationId;

  /// 0 = agenda, 1 = sino, 2 = coração.
  final int iconIndex;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'scheduledAt': scheduledAt.toIso8601String(),
        'notificationId': notificationId,
        'iconIndex': iconIndex,
      };

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      notificationId: json['notificationId'] as int,
      iconIndex: (json['iconIndex'] as num?)?.toInt() ?? 0,
    );
  }

  static String encodeList(List<Reminder> list) =>
      jsonEncode(list.map((e) => e.toJson()).toList());

  static List<Reminder> decodeList(String raw) {
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => Reminder.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
