/// ─────────────────────────────────────────────────────────────────────────────
///  REMINDERS REPOSITORY (Domain Interface)
/// ─────────────────────────────────────────────────────────────────────────────
library;

import '../entities/reminder.dart';
import '../entities/custom_event.dart';

abstract class RemindersRepository {
  // Reminders
  Future<List<Reminder>> getAllReminders();
  Future<List<Reminder>> getActiveReminders();
  Future<Reminder?> getReminderById(String id);
  Future<List<Reminder>> getRemindersForEthiopianDate(int year, int month, int day);
  Future<void> createReminder(Reminder reminder);
  Future<void> updateReminder(Reminder reminder);
  Future<void> deleteReminder(String id);
  Future<void> setReminderActive(String id, bool isActive);

  // Custom Events
  Future<List<CustomEvent>> getAllEvents();
  Future<List<CustomEvent>> getEventsForEthiopianDate(int year, int month, int day);
  Future<List<CustomEvent>> getEventsForEthiopianMonth(int year, int month);
  Future<void> createEvent(CustomEvent event);
  Future<void> updateEvent(CustomEvent event);
  Future<void> deleteEvent(String id);

  // User Notes
  Future<List<UserNote>> getNotesForEthiopianDate(int year, int month, int day);
  Future<List<UserNote>> getAllNotes();
  Future<void> createNote(UserNote note);
  Future<void> updateNote(UserNote note);
  Future<void> deleteNote(String id);
}