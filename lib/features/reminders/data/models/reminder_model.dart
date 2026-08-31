/// ─────────────────────────────────────────────────────────────────────────────
///  REMINDER MODEL
///  Data-layer representation with toMap/fromMap for SQLite persistence.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import '../../domain/entities/reminder.dart';
import '../../../calendar/domain/calendar_engine.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    required super.id,
    required super.title,
    super.titleAmharic,
    super.notes,
    required super.calendarSystem,
    super.ethDate,
    super.gregDate,
    super.hour = 9,
    super.minute = 0,
    super.recurrenceType = RecurrenceType.once,
    super.recurrenceInterval = 1,
    super.isActive = true,
    super.category = ReminderCategory.personal,
    super.colorHex,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReminderModel.fromEntity(Reminder r) => ReminderModel(
        id: r.id,
        title: r.title,
        titleAmharic: r.titleAmharic,
        notes: r.notes,
        calendarSystem: r.calendarSystem,
        ethDate: r.ethDate,
        gregDate: r.gregDate,
        hour: r.hour,
        minute: r.minute,
        recurrenceType: r.recurrenceType,
        recurrenceInterval: r.recurrenceInterval,
        isActive: r.isActive,
        category: r.category,
        colorHex: r.colorHex,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    final calSystem = map['calendar_system'] == 'gregorian'
        ? CalendarSystem.gregorian
        : CalendarSystem.ethiopian;

    EthiopianDate? ethDate;
    if (map['eth_year'] != null &&
        map['eth_month'] != null &&
        map['eth_day'] != null) {
      ethDate = EthiopianDate(
        year: map['eth_year'] as int,
        month: map['eth_month'] as int,
        day: map['eth_day'] as int,
      );
    }

    DateTime? gregDate;
    if (map['greg_date'] != null) {
      gregDate = DateTime.tryParse(map['greg_date'] as String);
    }

    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      titleAmharic: map['title_amharic'] as String?,
      notes: map['notes'] as String?,
      calendarSystem: calSystem,
      ethDate: ethDate,
      gregDate: gregDate,
      hour: map['time_hour'] as int? ?? 9,
      minute: map['time_minute'] as int? ?? 0,
      recurrenceType: _recurrenceFromString(map['recurrence_type'] as String?),
      recurrenceInterval: map['recurrence_interval'] as int? ?? 1,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      category: _categoryFromString(map['category'] as String?),
      colorHex: map['color_hex'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'title_amharic': titleAmharic,
      'notes': notes,
      'calendar_system':
          calendarSystem == CalendarSystem.ethiopian ? 'ethiopian' : 'gregorian',
      'eth_year': ethDate?.year,
      'eth_month': ethDate?.month,
      'eth_day': ethDate?.day,
      'greg_date': gregDate?.toIso8601String(),
      'time_hour': hour,
      'time_minute': minute,
      'recurrence_type': _recurrenceToString(recurrenceType),
      'recurrence_interval': recurrenceInterval,
      'is_active': isActive ? 1 : 0,
      'category': _categoryToString(category),
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static RecurrenceType _recurrenceFromString(String? value) {
    return switch (value) {
      'daily' => RecurrenceType.daily,
      'weekly' => RecurrenceType.weekly,
      'monthly' => RecurrenceType.monthly,
      'yearly' => RecurrenceType.yearly,
      _ => RecurrenceType.once,
    };
  }

  static String _recurrenceToString(RecurrenceType type) {
    return switch (type) {
      RecurrenceType.once => 'once',
      RecurrenceType.daily => 'daily',
      RecurrenceType.weekly => 'weekly',
      RecurrenceType.monthly => 'monthly',
      RecurrenceType.yearly => 'yearly',
    };
  }

  static ReminderCategory _categoryFromString(String? value) {
    return switch (value) {
      'feast' => ReminderCategory.feast,
      'fasting' => ReminderCategory.fasting,
      'saint' => ReminderCategory.saint,
      'birthday' => ReminderCategory.birthday,
      'anniversary' => ReminderCategory.anniversary,
      'other' => ReminderCategory.other,
      _ => ReminderCategory.personal,
    };
  }

  static String _categoryToString(ReminderCategory category) {
    return switch (category) {
      ReminderCategory.personal => 'personal',
      ReminderCategory.feast => 'feast',
      ReminderCategory.fasting => 'fasting',
      ReminderCategory.saint => 'saint',
      ReminderCategory.birthday => 'birthday',
      ReminderCategory.anniversary => 'anniversary',
      ReminderCategory.other => 'other',
    };
  }
}