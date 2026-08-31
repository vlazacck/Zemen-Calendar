/// ─────────────────────────────────────────────────────────────────────────────
///  REMINDERS REPOSITORY IMPLEMENTATION
///  Wires the local SQLite datasource to the domain layer, and triggers
///  notification (re)scheduling whenever reminders change.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import '../../domain/entities/reminder.dart';
import '../../domain/entities/custom_event.dart';
import '../../domain/repositories/reminders_repository.dart';
import '../datasources/reminders_local_datasource.dart';
import '../models/reminder_model.dart';
import '../models/event_note_models.dart';
import '../../../notifications/domain/notification_engine.dart';

class RemindersRepositoryImpl implements RemindersRepository {
  final RemindersLocalDataSource _local;
  final NotificationEngine? _notificationEngine;

  RemindersRepositoryImpl({
    RemindersLocalDataSource? local,
    NotificationEngine? notificationEngine,
  })  : _local = local ?? RemindersLocalDataSource(),
        _notificationEngine = notificationEngine;

  // ── Reminders ────────────────────────────────────────────────────────────

  @override
  Future<List<Reminder>> getAllReminders() => _local.getAllReminders();

  @override
  Future<List<Reminder>> getActiveReminders() => _local.getActiveReminders();

  @override
  Future<Reminder?> getReminderById(String id) => _local.getReminderById(id);

  @override
  Future<List<Reminder>> getRemindersForEthiopianDate(
          int year, int month, int day) =>
      _local.getRemindersForEthiopianDate(year, month, day);

  @override
  Future<void> createReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _local.insertReminder(model);
    if (reminder.isActive) {
      await _notificationEngine?.scheduleReminder(reminder);
    }
  }

  @override
  Future<void> updateReminder(Reminder reminder) async {
    final model = ReminderModel.fromEntity(reminder);
    await _local.updateReminder(model);
    await _local.clearNotificationsForReminder(reminder.id);
    await _notificationEngine?.cancelReminder(reminder.id);
    if (reminder.isActive) {
      await _notificationEngine?.scheduleReminder(reminder);
    }
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _notificationEngine?.cancelReminder(id);
    await _local.clearNotificationsForReminder(id);
    await _local.deleteReminder(id);
  }

  @override
  Future<void> setReminderActive(String id, bool isActive) async {
    await _local.setReminderActive(id, isActive);
    final reminder = await _local.getReminderById(id);
    if (reminder == null) return;

    if (isActive) {
      await _notificationEngine?.scheduleReminder(reminder);
    } else {
      await _notificationEngine?.cancelReminder(id);
      await _local.clearNotificationsForReminder(id);
    }
  }

  // ── Custom Events ───────────────────────────────────────────────────────

  @override
  Future<List<CustomEvent>> getAllEvents() => _local.getAllEvents();

  @override
  Future<List<CustomEvent>> getEventsForEthiopianDate(
          int year, int month, int day) =>
      _local.getEventsForEthiopianDate(year, month, day);

  @override
  Future<List<CustomEvent>> getEventsForEthiopianMonth(int year, int month) =>
      _local.getEventsForEthiopianMonth(year, month);

  @override
  Future<void> createEvent(CustomEvent event) =>
      _local.insertEvent(CustomEventModel.fromEntity(event));

  @override
  Future<void> updateEvent(CustomEvent event) =>
      _local.updateEvent(CustomEventModel.fromEntity(event));

  @override
  Future<void> deleteEvent(String id) => _local.deleteEvent(id);

  // ── User Notes ──────────────────────────────────────────────────────────

  @override
  Future<List<UserNote>> getNotesForEthiopianDate(int year, int month, int day) =>
      _local.getNotesForEthiopianDate(year, month, day);

  @override
  Future<List<UserNote>> getAllNotes() => _local.getAllNotes();

  @override
  Future<void> createNote(UserNote note) =>
      _local.insertNote(UserNoteModel.fromEntity(note));

  @override
  Future<void> updateNote(UserNote note) =>
      _local.updateNote(UserNoteModel.fromEntity(note));

  @override
  Future<void> deleteNote(String id) => _local.deleteNote(id);
}
