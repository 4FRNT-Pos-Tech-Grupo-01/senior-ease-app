import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:senior_ease/models/reminder.dart';
import 'package:senior_ease/services/notification_platform.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Notificações locais (Android, iOS, macOS). Em web / Linux / Windows não agenda.
final class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isSupported => notificationPlatformSupported;

  Future<void> init() async {
    if (!isSupported || _initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );

    tzdata.initializeTimeZones();
    try {
      final tzName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (e, st) {
      debugPrint('NotificationService: timezone IANA falhou ($e), a usar UTC.');
      debugPrint('$st');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    if (notificationIsAndroid) {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      const channel = AndroidNotificationChannel(
        'senior_ease_reminders',
        'Lembretes',
        description: 'Consultas, medicamentos e compromissos',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await androidImpl?.createNotificationChannel(channel);

      final notifGranted = await androidImpl?.requestNotificationsPermission();
      debugPrint('NotificationService: POST_NOTIFICATIONS = $notifGranted');

      final exactGranted = await androidImpl?.requestExactAlarmsPermission();
      debugPrint('NotificationService: alarmes exatos = $exactGranted');
    }
    if (notificationIsIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
      final perm = await ios?.checkPermissions();
      debugPrint(
        'NotificationService: iOS permissões — enabled=${perm?.isEnabled} '
        'alert=${perm?.isAlertEnabled} sound=${perm?.isSoundEnabled}',
      );
    }
    if (notificationIsMacOS) {
      final mac = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      await mac?.requestPermissions(alert: true, badge: true, sound: true);
      final perm = await mac?.checkPermissions();
      debugPrint(
        'NotificationService: macOS permissões — enabled=${perm?.isEnabled}',
      );
    }

    _initialized = true;
  }

  /// `false` em iOS/macOS se o utilizador desativou notificações nas definições.
  Future<bool> notificationsEnabledOnDarwin() async {
    if (!_initialized || !isSupported) return false;
    if (notificationIsIOS) {
      final o = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return o?.isEnabled ?? false;
    }
    if (notificationIsMacOS) {
      final o = await _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.checkPermissions();
      return o?.isEnabled ?? false;
    }
    return true;
  }

  /// iOS/macOS: `true` se alertas do sistema estão desativados para a app.
  Future<bool> isDarwinNotificationsBlocked() async {
    if (!notificationIsIOS && !notificationIsMacOS) return false;
    if (!_initialized || !isSupported) return false;
    return !(await notificationsEnabledOnDarwin());
  }

  NotificationDetails _notificationDetails({required bool playSound}) {
    final darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'senior_ease_reminders',
        'Lembretes',
        channelDescription: 'Consultas, medicamentos e compromissos',
        importance: Importance.high,
        priority: Priority.high,
        playSound: playSound,
        enableVibration: true,
        visibility: NotificationVisibility.public,
      ),
      iOS: darwin,
      macOS: darwin,
    );
  }

  /// Instante do lembrete no fuso [tz.local] (alinhado ao picker / relógio).
  tz.TZDateTime _scheduledTz(Reminder r) {
    final w = r.scheduledAt;
    final wall = DateTime(
      w.year,
      w.month,
      w.day,
      w.hour,
      w.minute,
      w.second,
    );
    return tz.TZDateTime(
      tz.local,
      wall.year,
      wall.month,
      wall.day,
      wall.hour,
      wall.minute,
      wall.second,
    );
  }

  Future<void> _scheduleOne(Reminder r, {required bool playSound}) async {
    if (!_initialized || !isSupported) return;

    final scheduled = _scheduledTz(r);
    final nowTz = tz.TZDateTime.now(tz.local);
    if (!scheduled.isAfter(nowTz)) {
      debugPrint(
        'NotificationService: não agenda "${r.title}" — $scheduled não é '
        'depois de agora ($nowTz). O minuto escolhido pode já ter passado ao guardar.',
      );
      return;
    }

    final details = _notificationDetails(playSound: playSound);

    try {
      await _plugin.zonedSchedule(
        r.notificationId,
        'Senior Ease',
        r.title,
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
        'NotificationService: agendado id=${r.notificationId} '
        '$scheduled (${tz.local.name}) — "${r.title}"',
      );
      if (kDebugMode) {
        final pending = await _plugin.pendingNotificationRequests();
        debugPrint(
          'NotificationService: pedidos pendentes no sistema=${pending.length}',
        );
      }
    } catch (e, st) {
      debugPrint(
        'NotificationService: falha ao agendar id=${r.notificationId}: $e',
      );
      debugPrint('$st');
      try {
        await _plugin.zonedSchedule(
          r.notificationId,
          'Senior Ease',
          r.title,
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        debugPrint(
          'NotificationService: reagendado em modo inexact id=${r.notificationId}',
        );
      } catch (e2, st2) {
        debugPrint('NotificationService: fallback inexact falhou: $e2');
        debugPrint('$st2');
      }
    }
  }

  Future<void> cancel(int notificationId) async {
    if (!_initialized || !isSupported) return;
    await _plugin.cancel(notificationId);
  }

  /// Cancela pedidos deste plugin. Se [notificationsEnabled], volta a agendar só futuros.
  Future<void> syncReminders(
    List<Reminder> reminders, {
    bool notificationsEnabled = true,
    bool playSound = true,
  }) async {
    if (!_initialized || !isSupported) return;

    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      await _plugin.cancel(p.id);
    }

    if (!notificationsEnabled) return;

    final nowTz = tz.TZDateTime.now(tz.local);
    for (final r in reminders) {
      if (_scheduledTz(r).isAfter(nowTz)) {
        await _scheduleOne(r, playSound: playSound);
      }
    }
  }
}
