/// Tarefa do utilizador (persistida na nuvem por sessão).
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
}
