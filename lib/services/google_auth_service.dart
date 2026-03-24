import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:senior_ease/config/google_oauth.dart';

/// Login com Google + Firebase Auth (web: popup; iOS/Android: [GoogleSignIn]).
final class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  GoogleSignIn? _googleSignIn;

  GoogleSignIn get _mobileGoogle {
    return _googleSignIn ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: kGoogleOAuthWebClientId.trim().isEmpty
          ? null
          : kGoogleOAuthWebClientId.trim(),
    );
  }

  /// Devolve `null` se o utilizador cancelar o fluxo Google.
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile')
        ..setCustomParameters(const {'prompt': 'select_account'});
      return FirebaseAuth.instance.signInWithPopup(provider);
    }

    final g = _mobileGoogle;
    // Sem isto, [signIn] devolve a mesma conta em cache sem abrir UI
    // (canSkipCall + currentUser reposto pelo init nativo após logout).
    await g.signOut();

    final googleUser = await g.signIn();
    if (googleUser == null) return null;

    final auth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    if (auth.idToken == null && !kIsWeb) {
      throw FirebaseAuthException(
        code: 'missing-google-id-token',
        message:
            'Configure kGoogleOAuthWebClientId em lib/config/google_oauth.dart '
            'e um google-services.json atualizado (SHA-1 no Firebase).',
      );
    }

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Chamar antes de [FirebaseAuth.signOut] para limpar a sessão Google no
  /// dispositivo / browser (inclui revogar ligação para não entrar na mesma conta
  /// em silêncio no próximo login).
  Future<void> signOutGoogle() async {
    if (kIsWeb) {
      try {
        await GoogleSignIn(
          scopes: const ['email', 'profile'],
        ).signOut();
      } catch (_) {}
      return;
    }

    Future<void> clearClient(GoogleSignIn client) async {
      try {
        await client.signOut();
      } catch (_) {}
      try {
        await client.disconnect();
      } catch (_) {}
    }

    final existing = _googleSignIn;
    if (existing != null) {
      await clearClient(existing);
    } else {
      await clearClient(
        GoogleSignIn(
          scopes: const ['email', 'profile'],
          serverClientId: kGoogleOAuthWebClientId.trim().isEmpty
              ? null
              : kGoogleOAuthWebClientId.trim(),
        ),
      );
    }
    _googleSignIn = null;
  }
}
