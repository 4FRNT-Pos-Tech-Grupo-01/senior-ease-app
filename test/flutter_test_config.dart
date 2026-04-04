import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Evita requisições HTTP em testes (Google Fonts); o estilo ainda é criado com fallback.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
