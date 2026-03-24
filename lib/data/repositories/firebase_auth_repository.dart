import 'package:firebase_auth/firebase_auth.dart';
import 'package:senior_ease/domain/entities/auth_exception.dart';
import 'package:senior_ease/domain/entities/auth_session.dart';
import 'package:senior_ease/domain/repositories/auth_repository.dart';
import 'package:senior_ease/services/auth_error_messages.dart';
import 'package:senior_ease/services/google_auth_service.dart';

/// Implementação Firebase de [AuthRepository].
final class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleAuthService? googleAuth,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _google = googleAuth ?? GoogleAuthService.instance;

  final FirebaseAuth _auth;
  final GoogleAuthService _google;

  AuthSession? _mapUser(User? u) {
    if (u == null) return null;
    return AuthSession(
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
    );
  }

  @override
  AuthSession? get currentSession => _mapUser(_auth.currentUser);

  @override
  Stream<AuthSession?> get sessionChanges =>
      _auth.authStateChanges().map(_mapUser);

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageForFirebaseAuthException(e));
    }
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageForFirebaseAuthException(e));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageForFirebaseAuthException(e));
    }
  }

  @override
  Future<void> signOut() async {
    await _google.signOutGoogle();
    await _auth.signOut();
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final cred = await _google.signInWithGoogle();
      return cred != null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(messageForFirebaseAuthException(e));
    }
  }
}
