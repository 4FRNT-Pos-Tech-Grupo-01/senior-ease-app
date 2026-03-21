import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências de acessibilidade persistidas e aplicadas em toda a app.
final class AppSettingsController extends ChangeNotifier {
  AppSettingsController();

  static const _kFontSize = 'app_font_size';
  static const _kContrast = 'app_contrast';

  String _fontSize = 'normal';
  String _contrast = 'normal';

  String get fontSize => _fontSize;
  String get contrast => _contrast;

  bool get highContrast => _contrast == 'high';

  /// Escala aplicada via [MediaQuery.textScaler] (1.0 = Normal).
  double get textScale {
    switch (_fontSize) {
      case 'large':
        return 1.15;
      case 'xlarge':
        return 1.30;
      default:
        return 1.0;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getString(_kFontSize) ?? 'normal';
    _contrast = prefs.getString(_kContrast) ?? 'normal';
    notifyListeners();
  }

  Future<void> setFontSize(String value) async {
    if (_fontSize == value) return;
    _fontSize = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontSize, value);
  }

  Future<void> setContrast(String value) async {
    if (_contrast == value) return;
    _contrast = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kContrast, value);
  }

  Future<void> resetAccessibility() async {
    _fontSize = 'normal';
    _contrast = 'normal';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFontSize);
    await prefs.remove(_kContrast);
  }
}
