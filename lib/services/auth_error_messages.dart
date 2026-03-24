import 'package:firebase_auth/firebase_auth.dart';

/// Mensagens em português para erros comuns do [FirebaseAuthException].
String messageForFirebaseAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'Email inválido.';
    case 'user-disabled':
      return 'Esta conta foi desativada.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Email ou senha incorretos.';
    case 'email-already-in-use':
      return 'Este email já está registado.';
    case 'weak-password':
      return 'Senha fraca. Use pelo menos 6 caracteres.';
    case 'network-request-failed':
      return 'Sem ligação. Verifique a internet.';
    case 'too-many-requests':
      return 'Demasiadas tentativas. Tente mais tarde.';
    default:
      return e.message?.isNotEmpty == true
          ? e.message!
          : 'Não foi possível concluir o pedido. Tente novamente.';
  }
}
