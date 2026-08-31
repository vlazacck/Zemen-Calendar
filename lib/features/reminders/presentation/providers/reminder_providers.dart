/// ─────────────────────────────────────────────────────────────────────────────
///  REMINDERS PROVIDERS
///  Riverpod state management for reminders, custom events, and user notes.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/entities/custom_event.dart';
import '../../domain/repositories/reminders_repository.dart';
import '../../data/repositories/reminders_repository_impl.dart';
import '../../../notifications/domain/notification_engine.dart';
import '../../../calendar/domain/calendar_engine.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';

const _uuid = Uuid();

// ─── Repository Provider ───────────────────────────────────────────────────

final remindersRepositoryProvider = Provider<RemindersRepository>((ref) {
  return RemindersRepositoryImpl(
    notificationEngine: NotificationEngine.instance,
  );
});

// ─── All Reminders ──────────────────────────────────────────────────────────

class RemindersNotifier extends AsyncNotifier<List<Reminder>> {
 @override
  Future<List<Reminder>> build() async {
    try {
      final repo = ref.read(remindersRepositoryProvider);
      return await repo.getAllReminders();
    } catch (e) {
      // Return empty list on first launch instead of error state
      return [];
    }
  }
  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(remindersRepositoryProvider);
    state = AsyncData(await repo.getAllReminders());
  }

  Future<void> addReminder({
    required String title,
    String? titleAmharic,
    String? notes,
    required CalendarSystem calendarSystem,
    EthiopianDate? ethDate,
    DateTime? gregDate,
    required int hour,
    required int minute,
    RecurrenceType recurrenceType = RecurrenceType.once,
    int recurrenceInterval = 1,
    ReminderCategory category = ReminderCategory.personal,
    String? colorHex,
  }) async {
    final repo = ref.read(remindersRepositoryProvider);
    final now = DateTime.now();

    final reminder = Reminder(
      id: _uuid.v4(),
      title: title,
      titleAmharic: titleAmharic,
      notes: notes,
      calendarSystem: calendarSystem,
      ethDate: ethDate,
      gregDate: gregDate,
      hour: hour,
      minute: minute,
      recurrenceType: recurrenceType,
      recurrenceInterval: recurrenceInterval,
      isActive: true,
      category: category,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );

    await repo.createReminder(reminder);
    await refresh();
  }

  Future<void> editReminder(Reminder updated) async {
    final repo = ref.read(remindersRepositoryProvider);
    await repo.updateReminder(updated.copyWith(updatedAt: DateTime.now()));
    await refresh();
  }

  Future<void> deleteReminder(String id) async {
    final repo = ref.read(remindersRepositoryProvider);
    await repo.deleteReminder(id);
    await refresh();
  }

  Future<void> toggleActive(String id, bool isActive) async {
    final repo = ref.read(remindersRepositoryProvider);
    await repo.setReminderActive(id, isActive);
    await refresh();
  }
}

final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, List<Reminder>>(
  RemindersNotifier.new,
);

// ─── Active Reminders Only ──────────────────────────────────────────────────

final activeRemindersProvider = Provider<List<Reminder>>((ref) {
  final all = ref.watch(remindersProvider).valueOrNull ?? [];
  return all.where((r) => r.isActive).toList();
});

// ─── Reminders for Selected Date ───────────────────────────────────────────

final remindersForSelectedDateProvider = FutureProvider<List<Reminder>>((ref) async {
  final selected = ref.watch(selectedDateProvider);
  final repo = ref.read(remindersRepositoryProvider);

  // Direct anchor matches
  final direct = await repo.getRemindersForEthiopianDate(
      selected.year, selected.month, selected.day);

  // Also include recurring reminders whose next occurrence falls on this date
  final all = ref.watch(remindersProvider).valueOrNull ?? [];
  final selectedGreg = CalendarEngine.toGregorian(selected);

  final recurring = all.where((r) {
    if (r.recurrenceType == RecurrenceType.once) return false;
    if (!r.isActive) return false;

    final occurrences = RecurrenceEngine.nextOccurrences(
      r,
      DateTime(selectedGreg.year, selectedGreg.month, selectedGreg.day),
      count: 1,
    );
    if (occurrences.isEmpty) return false;
    final occ = occurrences.first;
    return occ.year == selectedGreg.year &&
        occ.month == selectedGreg.month &&
        occ.day == selectedGreg.day;
  }).toList();

  // De-duplicate
  final ids = <String>{};
  final result = <Reminder>[];
  for (final r in [...direct, ...recurring]) {
    if (ids.add(r.id)) result.add(r);
  }
  return result;
});

// ─── Custom Events ──────────────────────────────────────────────────────────

class EventsNotifier extends AsyncNotifier<List<CustomEvent>> {
  @override
  Future<List<CustomEvent>> build() async {
    final repo = ref.read(remindersRepositoryProvider);
    return repo.getAllEvents();
  }

  Future<void> refresh() async {
    final repo = ref.read(remindersRepositoryProvider);
    state = AsyncData(await repo.getAllEvents());
  }

  Future<void> addEvent({
    required String title,
    String? titleAmharic,
    String? description,
    required EthiopianDate ethDate,
    bool isRecurringYearly = false,
    EventType eventType = EventType.event,
    String? colorHex,
  }) async {
    final repo = ref.read(remindersRepositoryProvider);
    final now = DateTime.now();
    final event = CustomEvent(
      id: _uuid.v4(),
      title: title,
      titleAmharic: titleAmharic,
      description: description,
      ethDate: ethDate,
      gregDate: CalendarEngine.toGregorian(ethDate),
      isRecurringYearly: isRecurringYearly,
      eventType: eventType,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );
    await repo.createEvent(event);
    await refresh();
  }

  Future<void> deleteEvent(String id) async {
    final repo = ref.read(remindersRepositoryProvider);
    await repo.deleteEvent(id);
    await refresh();
  }
}

final eventsProvider =
    AsyncNotifierProvider<EventsNotifier, List<CustomEvent>>(
  EventsNotifier.new,
);

final eventsForSelectedDateProvider = FutureProvider<List<CustomEvent>>((ref) async {
  final selected = ref.watch(selectedDateProvider);
  final repo = ref.read(remindersRepositoryProvider);
  return repo.getEventsForEthiopianDate(selected.year, selected.month, selected.day);
});

final eventDaysForMonthProvider =
    FutureProvider.family<Set<int>, (int year, int month)>((ref, args) async {
  final (year, month) = args;
  final repo = ref.read(remindersRepositoryProvider);
  final events = await repo.getEventsForEthiopianMonth(year, month);
  return events.map((e) => e.ethDate.day).toSet();
});

// ─── User Notes ─────────────────────────────────────────────────────────────

class NotesNotifier extends AsyncNotifier<List<UserNote>> {
  @override
  Future<List<UserNote>> build() async {
    final repo = ref.read(remindersRepositoryProvider);
    return repo.getAllNotes();
  }

  Future<void> refresh() async {
    final repo = ref.read(remindersRepositoryProvider);
    state = AsyncData(await repo.getAllNotes());
  }

  Future<void> addNote(EthiopianDate date, String content) async {
    final repo = ref.read(remindersRepositoryProvider);
    final now = DateTime.now();
    await repo.createNote(UserNote(
      id: _uuid.v4(),
      ethDate: date,
      content: content,
      createdAt: now,
      updatedAt: now,
    ));
    await refresh();
  }

  Future<void> deleteNote(String id) async {
    final repo = ref.read(remindersRepositoryProvider);
    await repo.deleteNote(id);
    await refresh();
  }
}

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<UserNote>>(
  NotesNotifier.new,
);

final notesForSelectedDateProvider = FutureProvider<List<UserNote>>((ref) async {
  final selected = ref.watch(selectedDateProvider);
  final repo = ref.read(remindersRepositoryProvider);
  return repo.getNotesForEthiopianDate(selected.year, selected.month, selected.day);
});