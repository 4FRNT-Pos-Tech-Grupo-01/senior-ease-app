import 'package:senior_ease/domain/entities/guided_step_item.dart';

final class GuidedStepItemMapper {
  GuidedStepItemMapper._();

  static Map<String, dynamic> toFirestore(GuidedStepItem e) => {
        'id': e.id,
        'title': e.title,
        'completed': e.completed,
        'order': e.order,
      };

  static GuidedStepItem fromFirestore(Map<String, dynamic> m) {
    return GuidedStepItem(
      id: m['id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      completed: m['completed'] as bool? ?? false,
      order: (m['order'] as num?)?.toInt() ?? 0,
    );
  }
}
