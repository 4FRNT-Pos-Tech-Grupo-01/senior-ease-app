import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Notifica o [GoRouter] quando a sessão Firebase muda (login / logout).
final class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
