/// Uma etapa guiada criada pelo utilizador.
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
}
