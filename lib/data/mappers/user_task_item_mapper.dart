import 'package:senior_ease/domain/entities/user_task_item.dart';

final class UserTaskItemMapper {
  UserTaskItemMapper._();

  static Map<String, dynamic> toFirestore(UserTaskItem e) => {
        'id': e.id,
        'title': e.title,
        'completed': e.completed,
      };

  static UserTaskItem fromFirestore(Map<String, dynamic> m) {
    return UserTaskItem(
      id: m['id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      completed: m['completed'] as bool? ?? false,
    );
  }
}
