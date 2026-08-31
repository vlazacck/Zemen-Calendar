/// ─────────────────────────────────────────────────────────────────────────────
///  REMINDER ENTITY
///  Domain model for user-created reminders. Supports recurrence in either
///  the Ethiopian or Gregorian calendar system.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:equatable/equatable.dart';
import '../../../calendar/domain/calendar_engine.dart';

enum CalendarSystem { ethiopian, gregorian }

enum RecurrenceType {
  once,
  daily,
  weekly,
  monthly,
  yearly,
}

enum ReminderCategory {
  personal,
  feast,
  fasting,
  saint,
  birthday,
  anniversary,
  other,
}

class Reminder extends Equatable {
  final String id;
  final String title;
  final String? titleAmharic;
  final String? notes;
  final CalendarSystem calendarSystem;

  /// Anchor date — for Ethiopian system this is the Ethiopian date;
  /// for Gregorian system this is the Gregorian date. The recurrence
  /// engine uses this as the starting point.
  final EthiopianDate? ethDate;
  final DateTime? gregDate;

  final int hour;
  final int minute;

  final RecurrenceType recurrenceType;
  final int recurrenceInterval; // e.g. every 2 weeks
  final bool isActive;
  final ReminderCategory category;
  final String? colorHex;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.title,
    this.titleAmharic,
    this.notes,
    required this.calendarSystem,
    this.ethDate,
    this.gregDate,
    this.hour = 9,
    this.minute = 0,
    this.recurrenceType = RecurrenceType.once,
    this.recurrenceInterval = 1,
    this.isActive = true,
    this.category = ReminderCategory.personal,
    this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  Reminder copyWith({
    String? id,
    String? title,
    String? titleAmharic,
    String? notes,
    CalendarSystem? calendarSystem,
    EthiopianDate? ethDate,
    DateTime? gregDate,
    int? hour,
    int? minute,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
    bool? isActive,
    ReminderCategory? category,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAmharic: titleAmharic ?? this.titleAmharic,
      notes: notes ?? this.notes,
      calendarSystem: calendarSystem ?? this.calendarSystem,
      ethDate: ethDate ?? this.ethDate,
      gregDate: gregDate ?? this.gregDate,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the "base" Gregorian DateTime (date + time-of-day) this reminder
  /// is anchored to, regardless of calendar system.
  DateTime get baseGregorianDateTime {
    DateTime baseDate;
    if (calendarSystem == CalendarSystem.ethiopian && ethDate != null) {
      baseDate = CalendarEngine.toGregorian(ethDate!);
    } else {
      baseDate = gregDate ?? DateTime.now();
    }
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      hour,
      minute,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleAmharic,
        notes,
        calendarSystem,
        ethDate,
        gregDate,
        hour,
        minute,
        recurrenceType,
        recurrenceInterval,
        isActive,
        category,
        colorHex,
        createdAt,
        updatedAt,
      ];
}

/// ─── Recurrence Engine ─────────────────────────────────────────────────────
/// Calculates the next N occurrences of a reminder, handling both Ethiopian
/// and Gregorian recurrence rules correctly (including Pagume edge cases).

class RecurrenceEngine {
  RecurrenceEngine._();

  /// Get the next occurrence on or after [from] for the given reminder.
  static DateTime? nextOccurrence(Reminder reminder, DateTime from) {
    final occurrences = nextOccurrences(reminder, from, count: 1);
    return occurrences.isEmpty ? null : occurrences.first;
  }

  /// Get the next [count] occurrences on or after [from].
  static List<DateTime> nextOccurrences(
    Reminder reminder,
    DateTime from, {
    int count = 5,
  }) {
    final results = <DateTime>[];

    switch (reminder.recurrenceType) {
      case RecurrenceType.once:
        final dt = reminder.baseGregorianDateTime;
        if (!dt.isBefore(from)) results.add(dt);
        break;

      case RecurrenceType.daily:
        _addDailyOccurrences(reminder, from, count, results);
        break;

      case RecurrenceType.weekly:
        _addWeeklyOccurrences(reminder, from, count, results);
        break;

      case RecurrenceType.monthly:
        if (reminder.calendarSystem == CalendarSystem.ethiopian) {
          _addEthiopianMonthlyOccurrences(reminder, from, count, results);
        } else {
          _addGregorianMonthlyOccurrences(reminder, from, count, results);
        }
        break;

      case RecurrenceType.yearly:
        if (reminder.calendarSystem == CalendarSystem.ethiopian) {
          _addEthiopianYearlyOccurrences(reminder, from, count, results);
        } else {
          _addGregorianYearlyOccurrences(reminder, from, count, results);
        }
        break;
    }

    return results;
  }

  // ── Daily ───────────────────────────────────────────────────────────────

  static void _addDailyOccurrences(
      Reminder reminder, DateTime from, int count, List<DateTime> out) {
    final interval = reminder.recurrenceInterval.clamp(1, 365);
    var base = reminder.baseGregorianDateTime;

    // Fast-forward base to be >= from
    if (base.isBefore(from)) {
      final daysDiff = from.difference(base).inDays;
      final steps = (daysDiff / interval).ceil();
      base = base.add(Duration(days: steps * interval));
    }

    var current = base;
    while (out.length < count) {
      if (!current.isBefore(from)) out.add(current);
      current = current.add(Duration(days: interval));
    }
  }

  // ── Weekly ──────────────────────────────────────────────────────────────

  static void _addWeeklyOccurrences(
      Reminder reminder, DateTime from, int count, List<DateTime> out) {
    final interval = reminder.recurrenceInterval.clamp(1, 52);
    var base = reminder.baseGregorianDateTime;

    if (base.isBefore(from)) {
      final daysDiff = from.difference(base).inDays;
      final weeksDiff = (daysDiff / (7 * interval)).ceil();
      base = base.add(Duration(days: weeksDiff * 7 * interval));
    }

    var current = base;
    while (out.length < count) {
      if (!current.isBefore(from)) out.add(current);
      current = current.add(Duration(days: 7 * interval));
    }
  }

  // ── Monthly (Gregorian) ────────────────────────────────────────────────

  static void _addGregorianMonthlyOccurrences(
      Reminder reminder, DateTime from, int count, List<DateTime> out) {
    final interval = reminder.recurrenceInterval.clamp(1, 12);
    final base = reminder.baseGregorianDateTime;
    final targetDay = base.day;

    var year = from.year;
    var month = from.month;

    // Align month offset with the original anchor month modulo interval
    while (out.length < count) {
      final daysInMonth = DateTime(year, month + 1, 0).day;
      final day = targetDay.clamp(1, daysInMonth);
      final candidate = DateTime(year, month, day, base.hour, base.minute);

      if (!candidate.isBefore(from) || out.isNotEmpty) {
        if (!candidate.isBefore(from)) out.add(candidate);
      }

      month += interval;
      while (month > 12) {
        month -= 12;
        year++;
      }

      // Safety break
      if (year > from.year + 50) break;
    }
  }

  // ── Monthly (Ethiopian) ────────────────────────────────────────────────
  // Recurs on the same Ethiopian day-of-month each month.
  // Handles Pagume (month 13, only 5-6 days) by clamping.

  static void _addEthiopianMonthlyOccurrences(
      Reminder reminder, DateTime from, int count, List<DateTime> out) {
    final interval = reminder.recurrenceInterval.clamp(1, 13);
    final anchorEth = reminder.ethDate ?? CalendarEngine.fromGregorian(from);
    final targetDay = anchorEth.day;

    var ethYear = CalendarEngine.fromGregorian(from).year;
    var ethMonth = anchorEth.month;

    int safety = 0;
    while (out.length < count && safety < 200) {
      safety++;
      final maxDay = CalendarEngine.daysInEthiopianMonth(ethYear, ethMonth);
      final day = targetDay.clamp(1, maxDay);
      final ethCandidate =
          EthiopianDate(year: ethYear, month: ethMonth, day: day);
      final gregCandidate = CalendarEngine.toGregorian(ethCandidate);
      final candidate = DateTime(
        gregCandidate.year,
        gregCandidate.month,
        gregCandidate.day,
        reminder.hour,
        reminder.minute,
      );

      if (!candidate.isBefore(from)) out.add(candidate);

      ethMonth += interval;
      while (ethMonth > 13) {
        ethMonth -= 13;
        ethYear++;
      }
    }
  }

  // ── Yearly (Gregorian) ─────────────────────────────────────────────────

  static void _addGregorianYearlyOccurrences(
      Reminder reminder, DateTime from, int count, List<DateTime> out) {
    final interval = reminder.recurrenceInterval.clamp(1, 50);
    final base = reminder.baseGregorianDateTime;

    var year = from.year;
    // Handle Feb 29 anchors gracefully
    int safety = 0;
    while (out.length < count && safety < 200) {
      safety++;
      final daysInMonth = DateTime(year, base.month + 1, 0).day;
      final day = base.day.clamp(1, daysInMonth);
      final candidate =
          DateTime(year, base.month, day, base.hour, base.minute);

      if (!candidate.isBefore(from)) out.add(candidate);
      year += interval;
    }
  }

  // ── Yearly (Ethiopian) ─────────────────────────────────────────────────
  // Recurs on the same Ethiopian month/day each year. If the anchor date
  // is Pagume 6 (only exists in leap years), clamps to Pagume 5 in
  // non-leap years.

  static void _addEthiopianYearlyOccurrences(
      Reminder reminder, DateTime from, int count, List<DateTime> out) {
    final interval = reminder.recurrenceInterval.clamp(1, 50);
    final anchorEth = reminder.ethDate ?? CalendarEngine.fromGregorian(from);

    var ethYear = CalendarEngine.fromGregorian(from).year;

    int safety = 0;
    while (out.length < count && safety < 200) {
      safety++;
      final maxDay =
          CalendarEngine.daysInEthiopianMonth(ethYear, anchorEth.month);
      final day = anchorEth.day.clamp(1, maxDay);
      final ethCandidate =
          EthiopianDate(year: ethYear, month: anchorEth.month, day: day);
      final gregCandidate = CalendarEngine.toGregorian(ethCandidate);
      final candidate = DateTime(
        gregCandidate.year,
        gregCandidate.month,
        gregCandidate.day,
        reminder.hour,
        reminder.minute,
      );

      if (!candidate.isBefore(from)) out.add(candidate);
      ethYear += interval;
    }
  }

  /// Human-readable description of the recurrence rule.
  static String describeRecurrence(Reminder r, {bool amharic = true}) {
    final interval = r.recurrenceInterval;
    switch (r.recurrenceType) {
      case RecurrenceType.once:
        return amharic ? 'አንድ ጊዜ' : 'Once';
      case RecurrenceType.daily:
        return interval == 1
            ? (amharic ? 'ዕለታዊ' : 'Daily')
            : (amharic ? 'በ$interval ቀናት' : 'Every $interval days');
      case RecurrenceType.weekly:
        return interval == 1
            ? (amharic ? 'ሳምንታዊ' : 'Weekly')
            : (amharic ? 'በ$interval ሳምንት' : 'Every $interval weeks');
      case RecurrenceType.monthly:
        final cal = r.calendarSystem == CalendarSystem.ethiopian
            ? (amharic ? 'ኢትዮ' : 'ETH')
            : (amharic ? 'ጎርጎ' : 'GREG');
        return interval == 1
            ? (amharic ? 'ወራዊ ($cal)' : 'Monthly ($cal)')
            : (amharic ? 'በ$interval ወር ($cal)' : 'Every $interval months ($cal)');
      case RecurrenceType.yearly:
        final cal = r.calendarSystem == CalendarSystem.ethiopian
            ? (amharic ? 'ኢትዮ' : 'ETH')
            : (amharic ? 'ጎርጎ' : 'GREG');
        return interval == 1
            ? (amharic ? 'ዓመታዊ ($cal)' : 'Yearly ($cal)')
            : (amharic ? 'በ$interval ዓመት ($cal)' : 'Every $interval years ($cal)');
    }
  }
}