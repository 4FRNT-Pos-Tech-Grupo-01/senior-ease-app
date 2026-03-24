import 'package:senior_ease/domain/entities/auth_session.dart';

/// Porta de autenticação (implementação em Firebase / outros).
abstract interface class AuthRepository {
  AuthSession? get currentSession;

  Stream<AuthSession?> get sessionChanges;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  /// `true` se a sessão foi criada; `false` se o utilizador cancelou o fluxo.
  Future<bool> signInWithGoogle();
}
