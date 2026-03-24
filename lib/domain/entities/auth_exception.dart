/// Erro de autenticação com mensagem já adequada à UI.
final class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
