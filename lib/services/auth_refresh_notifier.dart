import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:senior_ease/domain/repositories/auth_repository.dart';

/// Notifica o [GoRouter] quando a sessão muda (login / logout).
final class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(AuthRepository auth) {
    _subscription = auth.sessionChanges.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
