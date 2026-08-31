/// ─────────────────────────────────────────────────────────────────────────────
///  REMINDERS LOCAL DATASOURCE
///  Raw SQLite CRUD operations for user_reminders, custom_events, user_notes,
///  and notification_queue tables.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../../../../core/database/zemen_database.dart';
import '../models/reminder_model.dart';
import '../models/event_note_models.dart';

class RemindersLocalDataSource {
  final ZemenDatabase _db;

  Box? _remindersBox;
  Box? _eventsBox;
  Box? _notesBox;
  Box? _notificationsBox;

  Future<Box> _getRemindersBox() async {
    _remindersBox ??= await Hive.openBox('web_reminders');
    return _remindersBox!;
  }

  Future<Box> _getEventsBox() async {
    _eventsBox ??= await Hive.openBox('web_custom_events');
    return _eventsBox!;
  }

  Future<Box> _getNotesBox() async {
    _notesBox ??= await Hive.openBox('web_user_notes');
    return _notesBox!;
  }

  Future<Box> _getNotificationsBox() async {
    _notificationsBox ??= await Hive.openBox('web_notification_queue');
    return _notificationsBox!;
  }

  RemindersLocalDataSource({ZemenDatabase? db})
      : _db = db ?? ZemenDatabase.instance;

  // ── Reminders ────────────────────────────────────────────────────────────

  Future<List<ReminderModel>> getAllReminders() async {
    if (kIsWeb) {
      final box = await _getRemindersBox();
      final list = box.values
          .map((e) => ReminderModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    final db = await _db.database;
    final rows = await db.query(
      'user_reminders',
      orderBy: 'created_at DESC',
    );
    return rows.map(ReminderModel.fromMap).toList();
  }

  Future<List<ReminderModel>> getActiveReminders() async {
    if (kIsWeb) {
      final box = await _getRemindersBox();
      final list = box.values
          .map((e) => ReminderModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .where((r) => r.isActive)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    final db = await _db.database;
    final rows = await db.query(
      'user_reminders',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return rows.map(ReminderModel.fromMap).toList();
  }

  Future<ReminderModel?> getReminderById(String id) async {
    if (kIsWeb) {
      final box = await _getRemindersBox();
      final val = box.get(id);
      if (val == null) return null;
      return ReminderModel.fromMap(Map<String, dynamic>.from(val as Map));
    }
    final db = await _db.database;
    final rows = await db.query(
      'user_reminders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ReminderModel.fromMap(rows.first);
  }

  /// Get reminders anchored to a specific Ethiopian date
  Future<List<ReminderModel>> getRemindersForEthiopianDate(
      int year, int month, int day) async {
    if (kIsWeb) {
      final box = await _getRemindersBox();
      return box.values
          .map((e) => ReminderModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .where((r) =>
              r.ethDate?.year == year &&
              r.ethDate?.month == month &&
              r.ethDate?.day == day &&
              r.isActive)
          .toList();
    }
    final db = await _db.database;
    final rows = await db.query(
      'user_reminders',
      where: 'eth_year = ? AND eth_month = ? AND eth_day = ? AND is_active = 1',
      whereArgs: [year, month, day],
    );
    return rows.map(ReminderModel.fromMap).toList();
  }

  Future<void> insertReminder(ReminderModel reminder) async {
    if (kIsWeb) {
      final box = await _getRemindersBox();
      await box.put(reminder.id, reminder.toMap());
      return;
    }
    final db = await _db.database;
    await db.insert('user_reminders', reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    if (kIsWeb) {
      final box = await _getRemindersBox();
      await box.put(reminder.id, reminder.toMap());
      return;
    }
    final db = await _db.database;
    await db.update(
      'user_reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<void> deleteReminder(String id) async {
    if (kIsWeb) {
      final box = await _getRemindersBox();
      await box.delete(id);
      return;
    }
    final db = await _db.database;
    await db.delete('user_reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setReminderActive(String id, bool isActive) async {
    if (kIsWeb) {
      final box = await _getRemindersBox();
      final val = box.get(id);
      if (val != null) {
        final map = Map<String, dynamic>.from(val as Map);
        map['is_active'] = isActive ? 1 : 0;
        map['updated_at'] = DateTime.now().toIso8601String();
        await box.put(id, map);
      }
      return;
    }
    final db = await _db.database;
    await db.update(
      'user_reminders',
      {
        'is_active': isActive ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String()
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── Custom Events ───────────────────────────────────────────────────────

  Future<List<CustomEventModel>> getAllEvents() async {
    if (kIsWeb) {
      final box = await _getEventsBox();
      final list = box.values
          .map((e) => CustomEventModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) {
        if (a.ethDate.year != b.ethDate.year) {
          return a.ethDate.year.compareTo(b.ethDate.year);
        }
        if (a.ethDate.month != b.ethDate.month) {
          return a.ethDate.month.compareTo(b.ethDate.month);
        }
        return a.ethDate.day.compareTo(b.ethDate.day);
      });
      return list;
    }
    final db = await _db.database;
    final rows = await db.query('custom_events',
        orderBy: 'eth_year, eth_month, eth_day');
    return rows.map(CustomEventModel.fromMap).toList();
  }

  Future<List<CustomEventModel>> getEventsForEthiopianDate(
      int year, int month, int day) async {
    if (kIsWeb) {
      final box = await _getEventsBox();
      return box.values
          .map((e) => CustomEventModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .where((e) =>
              (e.ethDate.year == year &&
                  e.ethDate.month == month &&
                  e.ethDate.day == day) ||
              (e.isRecurringYearly &&
                  e.ethDate.month == month &&
                  e.ethDate.day == day))
          .toList();
    }
    final db = await _db.database;

    // Include non-recurring events on exact date, plus yearly-recurring
    // events that match month/day regardless of year.
    final rows = await db.query(
      'custom_events',
      where: '(eth_year = ? AND eth_month = ? AND eth_day = ?) '
          'OR (is_recurring_yearly = 1 AND eth_month = ? AND eth_day = ?)',
      whereArgs: [year, month, day, month, day],
    );
    return rows.map(CustomEventModel.fromMap).toList();
  }

  Future<List<CustomEventModel>> getEventsForEthiopianMonth(
      int year, int month) async {
    if (kIsWeb) {
      final box = await _getEventsBox();
      return box.values
          .map((e) => CustomEventModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .where((e) =>
              (e.ethDate.year == year && e.ethDate.month == month) ||
              (e.isRecurringYearly && e.ethDate.month == month))
          .toList();
    }
    final db = await _db.database;
    final rows = await db.query(
      'custom_events',
      where:
          '(eth_year = ? AND eth_month = ?) OR (is_recurring_yearly = 1 AND eth_month = ?)',
      whereArgs: [year, month, month],
    );
    return rows.map(CustomEventModel.fromMap).toList();
  }

  Future<void> insertEvent(CustomEventModel event) async {
    if (kIsWeb) {
      final box = await _getEventsBox();
      await box.put(event.id, event.toMap());
      return;
    }
    final db = await _db.database;
    await db.insert('custom_events', event.toMap());
  }

  Future<void> updateEvent(CustomEventModel event) async {
    if (kIsWeb) {
      final box = await _getEventsBox();
      await box.put(event.id, event.toMap());
      return;
    }
    final db = await _db.database;
    await db.update(
      'custom_events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  Future<void> deleteEvent(String id) async {
    if (kIsWeb) {
      final box = await _getEventsBox();
      await box.delete(id);
      return;
    }
    final db = await _db.database;
    await db.delete('custom_events', where: 'id = ?', whereArgs: [id]);
  }

  // ── User Notes ──────────────────────────────────────────────────────────

  Future<List<UserNoteModel>> getNotesForEthiopianDate(
      int year, int month, int day) async {
    if (kIsWeb) {
      final box = await _getNotesBox();
      final list = box.values
          .map((e) => UserNoteModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .where((n) =>
              n.ethDate.year == year &&
              n.ethDate.month == month &&
              n.ethDate.day == day)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    final db = await _db.database;
    final rows = await db.query(
      'user_notes',
      where: 'eth_year = ? AND eth_month = ? AND eth_day = ?',
      whereArgs: [year, month, day],
      orderBy: 'created_at DESC',
    );
    return rows.map(UserNoteModel.fromMap).toList();
  }

  Future<List<UserNoteModel>> getAllNotes() async {
    if (kIsWeb) {
      final box = await _getNotesBox();
      final list = box.values
          .map((e) => UserNoteModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    }
    final db = await _db.database;
    final rows = await db.query('user_notes', orderBy: 'updated_at DESC');
    return rows.map(UserNoteModel.fromMap).toList();
  }

  Future<void> insertNote(UserNoteModel note) async {
    if (kIsWeb) {
      final box = await _getNotesBox();
      await box.put(note.id, note.toMap());
      return;
    }
    final db = await _db.database;
    await db.insert('user_notes', note.toMap());
  }

  Future<void> updateNote(UserNoteModel note) async {
    if (kIsWeb) {
      final box = await _getNotesBox();
      await box.put(note.id, note.toMap());
      return;
    }
    final db = await _db.database;
    await db.update(
      'user_notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> deleteNote(String id) async {
    if (kIsWeb) {
      final box = await _getNotesBox();
      await box.delete(id);
      return;
    }
    final db = await _db.database;
    await db.delete('user_notes', where: 'id = ?', whereArgs: [id]);
  }

  // ── Notification Queue ──────────────────────────────────────────────────

  Future<void> enqueueNotification({
    required String id,
    String? reminderId,
    required int notificationId,
    required String title,
    required String body,
    required DateTime scheduledFor,
    String? payload,
  }) async {
    if (kIsWeb) {
      final box = await _getNotificationsBox();
      await box.put(id, {
        'id': id,
        'reminder_id': reminderId,
        'notification_id': notificationId,
        'title': title,
        'body': body,
        'scheduled_for': scheduledFor.toIso8601String(),
        'status': 'pending',
        'payload': payload,
        'created_at': DateTime.now().toIso8601String(),
      });
      return;
    }
    final db = await _db.database;
    await db.insert('notification_queue', {
      'id': id,
      'reminder_id': reminderId,
      'notification_id': notificationId,
      'title': title,
      'body': body,
      'scheduled_for': scheduledFor.toIso8601String(),
      'status': 'pending',
      'payload': payload,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingNotifications() async {
    if (kIsWeb) {
      final box = await _getNotificationsBox();
      final list = box.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((n) => n['status'] == 'pending')
          .toList();
      list.sort((a, b) => (a['scheduled_for'] as String)
          .compareTo(b['scheduled_for'] as String));
      return list;
    }
    final db = await _db.database;
    return db.query(
      'notification_queue',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'scheduled_for ASC',
    );
  }

  Future<void> markNotificationStatus(String id, String status) async {
    if (kIsWeb) {
      final box = await _getNotificationsBox();
      final val = box.get(id);
      if (val != null) {
        final map = Map<String, dynamic>.from(val as Map);
        map['status'] = status;
        await box.put(id, map);
      }
      return;
    }
    final db = await _db.database;
    await db.update(
      'notification_queue',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearNotificationsForReminder(String reminderId) async {
    if (kIsWeb) {
      final box = await _getNotificationsBox();
      final keysToDelete = <dynamic>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val != null) {
          final map = Map<String, dynamic>.from(val as Map);
          if (map['reminder_id'] == reminderId) {
            keysToDelete.add(key);
          }
        }
      }
      for (final key in keysToDelete) {
        await box.delete(key);
      }
      return;
    }
    final db = await _db.database;
    await db.delete(
      'notification_queue',
      where: 'reminder_id = ?',
      whereArgs: [reminderId],
    );
  }

  Future<void> deleteOldNotifications(DateTime before) async {
    if (kIsWeb) {
      final box = await _getNotificationsBox();
      final beforeIso = before.toIso8601String();
      final keysToDelete = <dynamic>[];
      for (final key in box.keys) {
        final val = box.get(key);
        if (val != null) {
          final map = Map<String, dynamic>.from(val as Map);
          final scheduledFor = map['scheduled_for'] as String;
          final status = map['status'] as String;
          if (scheduledFor.compareTo(beforeIso) < 0 && status != 'pending') {
            keysToDelete.add(key);
          }
        }
      }
      for (final key in keysToDelete) {
        await box.delete(key);
      }
      return;
    }
    final db = await _db.database;
    await db.delete(
      'notification_queue',
      where: 'scheduled_for < ? AND status != ?',
      whereArgs: [before.toIso8601String(), 'pending'],
    );
  }
}
