/// Sessão autenticada (sem dependências de Firebase na UI).
final class AuthSession {
  const AuthSession({
    required this.uid,
    this.email,
    this.displayName,
  });

  final String uid;
  final String? email;
  final String? displayName;
}
