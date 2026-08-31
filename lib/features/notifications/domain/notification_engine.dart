/// ─────────────────────────────────────────────────────────────────────────────
///  NOTIFICATION ENGINE  — Alarm-grade local notifications
///  Android: SCHEDULE_EXACT_ALARM + USE_EXACT_ALARM + WAKE_LOCK
///           full-screen intent, max priority, visibility PUBLIC
///  iOS:     critical alerts (requires entitlement), interruptionLevel.timeSensitive
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:convert';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../../reminders/domain/entities/reminder.dart';
import '../../calendar/domain/calendar_engine.dart';
import '../../holidays/domain/holiday_engine.dart';
import '../../calendar/domain/bahire_hasab_engine.dart';

class NotificationEngine {
  NotificationEngine._internal();
  static final NotificationEngine instance = NotificationEngine._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Channels ───────────────────────────────────────────────────────────────
  // ALARM channel: max importance, sound, wake screen, bypass DND
  static const AndroidNotificationChannel alarmChannel =
      AndroidNotificationChannel(
    'zemen_alarm',
    'Zemen Alarms',
    description: 'High-priority reminder alarms — fires even in Do Not Disturb',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    ledColor: Color(0xFFE5B842),
    showBadge: true,
    sound: RawResourceAndroidNotificationSound('notification'),
           // bypass Do-Not-Disturb
  );

  static const AndroidNotificationChannel feastChannel =
      AndroidNotificationChannel(
    'zemen_feasts',
    'Feasts & Holidays',
    description: 'Ethiopian Orthodox feast and holiday notifications',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel fastingChannel =
      AndroidNotificationChannel(
    'zemen_fasting',
    'Fasting',
    description: 'Fasting period notifications',
    importance: Importance.high,
    playSound: true,
  );

  static const AndroidNotificationChannel dailySaintChannel =
      AndroidNotificationChannel(
    'zemen_saints',
    'Daily Saints',
    description: 'Daily saint commemoration',
    importance: Importance.defaultImportance,
  );

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,   // iOS critical alerts
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTapped,
      onDidReceiveBackgroundNotificationResponse: _onTappedBackground,
    );

    // Register Android channels
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(alarmChannel);
      await androidPlugin.createNotificationChannel(feastChannel);
      await androidPlugin.createNotificationChannel(fastingChannel);
      await androidPlugin.createNotificationChannel(dailySaintChannel);
      await androidPlugin.requestNotificationsPermission();
      await androidPlugin.requestExactAlarmsPermission();
    }

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      critical: true,
    );

    _initialized = true;
  }

  static void _onTapped(NotificationResponse r) {
    _handlePayload(r.payload);
  }

  @pragma('vm:entry-point')
  static void _onTappedBackground(NotificationResponse r) {
    _handlePayload(r.payload);
  }

  static void _handlePayload(String? payload) {
    if (payload == null) return;
    try {
      final _ = jsonDecode(payload) as Map<String, dynamic>;
      // Route via global navigator key if needed
    } catch (_) {}
  }

  // ── ID helper ─────────────────────────────────────────────────────────────

  int _idFor(String reminderId) => reminderId.hashCode & 0x7FFFFFFF;

  // ── ALARM-GRADE notification details ──────────────────────────────────────

  NotificationDetails _alarmDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return NotificationDetails(
     android: AndroidNotificationDetails(
  channelId,
  channelName,
  channelDescription: channelDescription,
  importance: Importance.max,
  priority: Priority.max,
  fullScreenIntent: true,
  visibility: NotificationVisibility.public,
  playSound: true,
  sound: const RawResourceAndroidNotificationSound('notification'),
  enableVibration: true,
  autoCancel: true,
  ticker: 'Zemen Reminder',
  category: AndroidNotificationCategory.alarm,
),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        // interruptionLevel makes it break through Focus modes on iOS 15+
        interruptionLevel: InterruptionLevel.timeSensitive,
        sound: 'default',
      ),
    );
  }

  // ── Schedule reminder ─────────────────────────────────────────────────────

  Future<void> scheduleReminder(Reminder reminder) async {
  if (!_initialized) await init();
  if (!reminder.isActive) return;

  final next = RecurrenceEngine.nextOccurrence(reminder, DateTime.now());
  if (next == null) return;
  if (next.isBefore(DateTime.now())) return;

  final id = _idFor(reminder.id);
  final scheduledDate = tz.TZDateTime.from(next, tz.local);

  final title = reminder.titleAmharic ?? reminder.title;
  final body = reminder.notes?.isNotEmpty == true
      ? reminder.notes!
      : reminder.title;

  // Define payload BEFORE zonedSchedule
  final String payload = jsonEncode({
    'type': 'reminder',
    'id': reminder.id,
    'category': reminder.category.name,
  });

  await _plugin.zonedSchedule(
    id,
    title,
    body,
    scheduledDate,
    _alarmDetails(
      channelId: alarmChannel.id,
      channelName: alarmChannel.name,
      channelDescription: alarmChannel.description,
    ),
    payload: payload,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

  Future<void> cancelReminder(String reminderId) async {
    if (!_initialized) await init();
    await _plugin.cancel(_idFor(reminderId));
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  Future<void> rescheduleAll(List<Reminder> activeReminders) async {
    if (!_initialized) await init();
    for (final r in activeReminders) {
      await scheduleReminder(r);
    }
  }

  // ── Feast notifications ────────────────────────────────────────────────────

  Future<void> scheduleUpcomingFeastNotifications({
    required int advanceDays,
    required bool amharic,
  }) async {
    if (!_initialized) await init();

    final today = CalendarEngine.today();
    final upcoming = HolidayEngine.getUpcomingHolidays(today, count: 10);

    for (final item in upcoming) {
      final daysUntil = item.date.toJdn() - today.toJdn();
      if (daysUntil != advanceDays) continue;

      final notifyDate = CalendarEngine.toGregorian(
          CalendarEngine.jdnToEthiopian(item.date.toJdn() - advanceDays));
      final scheduledDate = tz.TZDateTime(
          tz.local, notifyDate.year, notifyDate.month, notifyDate.day, 8);

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

      final id = 'feast_${item.holiday.nameEnglish}_${item.date.year}'
              .hashCode &
          0x7FFFFFFF;

      final title = amharic
          ? 'ቀጣይ በዓል: ${item.holiday.nameAmharic}'
          : 'Upcoming Feast: ${item.holiday.nameEnglish}';
      final body = amharic
          ? 'በ$advanceDays ቀን ${item.holiday.nameAmharic}'
          : '${item.holiday.nameEnglish} in $advanceDays day(s)';

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _alarmDetails(
          channelId: feastChannel.id,
          channelName: feastChannel.name,
          channelDescription: feastChannel.description,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      break;
    }
  }

  // ── Fasting notifications ──────────────────────────────────────────────────

  Future<void> scheduleFastingStartNotifications({required bool amharic}) async {
    if (!_initialized) await init();

    final today = CalendarEngine.today();
    final periods = BahireHasabEngine.getFastingPeriods(today.year)
      ..addAll(BahireHasabEngine.getFastingPeriods(today.year + 1));

    for (final period in periods) {
      if (period.start.toJdn() <= today.toJdn()) continue;

      final startGreg = CalendarEngine.toGregorian(period.start);
      final scheduledDate = tz.TZDateTime(
          tz.local, startGreg.year, startGreg.month, startGreg.day, 6);

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

      final id =
          'fast_${period.nameEnglish}_${period.start.year}'.hashCode & 0x7FFFFFFF;

      await _plugin.zonedSchedule(
        id,
        amharic ? 'ጾም ይጀምራል' : 'Fasting Begins',
        amharic
            ? '${period.nameAmharic} ዛሬ ይጀምራል — ${period.durationDays} ቀናት'
            : '${period.nameEnglish} begins today — ${period.durationDays} days',
        scheduledDate,
        _alarmDetails(
          channelId: fastingChannel.id,
          channelName: fastingChannel.name,
          channelDescription: fastingChannel.description,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      break;
    }
  }

  // ── Daily saint ────────────────────────────────────────────────────────────

  Future<void> scheduleDailySaintNotification({required bool amharic}) async {
    if (!_initialized) await init();

    final today = CalendarEngine.today();
    final saints = HolidayEngine.getHolidaysForDate(today)
        .where((h) => h.category == HolidayCategory.saintCommemoration)
        .toList();

    if (saints.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 7);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final names = saints
        .map((h) => amharic ? h.nameAmharic : h.nameEnglish)
        .join(', ');

    await _plugin.zonedSchedule(
      999999001,
      amharic ? 'የዕለቱ ቅዱሳን' : "Today's Saints",
      names,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          dailySaintChannel.id,
          dailySaintChannel.name,
          channelDescription: dailySaintChannel.description,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
          interruptionLevel: InterruptionLevel.passive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await init();
    return _plugin.pendingNotificationRequests();
  }
}
