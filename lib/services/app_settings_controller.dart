import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senior_ease/models/reminder.dart';
import 'package:senior_ease/services/notification_service.dart';
import 'package:senior_ease/services/user_cloud_data_service.dart';

/// Preferências persistidas (acessibilidade, navegação, notificações).
final class AppSettingsController extends ChangeNotifier {
  AppSettingsController();

  static const _kFontSize = 'app_font_size';
  static const _kContrast = 'app_contrast';
  static const _kNavigation = 'app_navigation_mode';
  static const _kExtraConfirm = 'app_extra_confirmations';
  static const _kNotifications = 'app_notifications_enabled';
  static const _kSoundAlerts = 'app_sound_alerts';

  String _fontSize = 'normal';
  String _contrast = 'normal';
  String _navigationMode = 'default';
  bool _extraConfirmations = false;
  bool _notificationsEnabled = true;
  bool _soundAlerts = false;

  String get fontSize => _fontSize;
  String get contrast => _contrast;
  String get navigationMode => _navigationMode;

  bool get highContrast => _contrast == 'high';
  bool get navigationSimple => _navigationMode == 'simple';
  bool get extraConfirmations => _extraConfirmations;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundAlerts => _soundAlerts;

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
    _navigationMode = prefs.getString(_kNavigation) ?? 'default';
    _extraConfirmations = prefs.getBool(_kExtraConfirm) ?? false;
    _notificationsEnabled = prefs.getBool(_kNotifications) ?? true;
    _soundAlerts = prefs.getBool(_kSoundAlerts) ?? false;
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

  Future<void> setNavigationMode(String value) async {
    if (_navigationMode == value) return;
    _navigationMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNavigation, value);
  }

  Future<void> setExtraConfirmations(bool value) async {
    if (_extraConfirmations == value) return;
    _extraConfirmations = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kExtraConfirm, value);
  }

  Future<void> _resyncNotificationsFromStorage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    var list = await UserCloudDataService.instance.loadRemindersOnce(uid);
    list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    await NotificationService.instance.syncReminders(
      list,
      notificationsEnabled: _notificationsEnabled,
      playSound: _soundAlerts,
    );
  }

  /// Sincroniza notificações com as flags guardadas (ex.: [ReminderPurge] sem instância).
  static Future<void> syncRemindersWithPersistedFlags(
    List<Reminder> reminders,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getBool(_kNotifications) ?? true;
    final sound = prefs.getBool(_kSoundAlerts) ?? false;
    final sorted = [...reminders]..sort(
        (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
      );
    await NotificationService.instance.syncReminders(
      sorted,
      notificationsEnabled: notifications,
      playSound: sound,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
    if (!value) {
      await NotificationService.instance.syncReminders(
        const [],
        notificationsEnabled: false,
        playSound: false,
      );
    } else {
      await _resyncNotificationsFromStorage();
    }
  }

  Future<void> setSoundAlerts(bool value) async {
    if (_soundAlerts == value) return;
    _soundAlerts = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundAlerts, value);
    if (_notificationsEnabled) {
      await _resyncNotificationsFromStorage();
    }
  }

  /// Repõe fonte, contraste, navegação e preferências adicionais; reagenda notificações.
  Future<void> resetAllSettings() async {
    _fontSize = 'normal';
    _contrast = 'normal';
    _navigationMode = 'default';
    _extraConfirmations = false;
    _notificationsEnabled = true;
    _soundAlerts = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFontSize);
    await prefs.remove(_kContrast);
    await prefs.remove(_kNavigation);
    await prefs.remove(_kExtraConfirm);
    await prefs.remove(_kNotifications);
    await prefs.remove(_kSoundAlerts);
    await _resyncNotificationsFromStorage();
  }
}
