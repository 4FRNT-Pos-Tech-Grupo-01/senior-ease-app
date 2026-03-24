/// Tarefa do utilizador (persistida em Firestore por sessão).
final class UserTaskItem {
  const UserTaskItem({
    required this.id,
    required this.title,
    this.completed = false,
  });

  final String id;
  final String title;
  final bool completed;

  UserTaskItem copyWith({String? title, bool? completed}) {
    return UserTaskItem(
      id: id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'title': title,
        'completed': completed,
      };

  factory UserTaskItem.fromFirestore(Map<String, dynamic> m) {
    return UserTaskItem(
      id: m['id'] as String,
      title: m['title'] as String,
      completed: m['completed'] as bool? ?? false,
    );
  }
}
