/// Uma etapa guiada criada pelo utilizador (Firestore: `home/guided` → campo `steps`).
final class GuidedStepItem {
  const GuidedStepItem({
    required this.id,
    required this.title,
    required this.completed,
    required this.order,
  });

  final String id;
  final String title;
  final bool completed;

  /// Ordem de apresentação (menor = primeiro).
  final int order;

  GuidedStepItem copyWith({
    String? title,
    bool? completed,
    int? order,
  }) {
    return GuidedStepItem(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'title': title,
        'completed': completed,
        'order': order,
      };

  factory GuidedStepItem.fromFirestore(Map<String, dynamic> m) {
    return GuidedStepItem(
      id: m['id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      completed: m['completed'] as bool? ?? false,
      order: (m['order'] as num?)?.toInt() ?? 0,
    );
  }
}
