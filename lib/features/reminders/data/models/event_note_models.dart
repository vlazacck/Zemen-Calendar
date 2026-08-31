/// ─────────────────────────────────────────────────────────────────────────────
///  CUSTOM EVENT & USER NOTE MODELS
///  Data-layer representations with toMap/fromMap for SQLite persistence.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import '../../domain/entities/custom_event.dart';
import '../../../calendar/domain/calendar_engine.dart';

class CustomEventModel extends CustomEvent {
  const CustomEventModel({
    required super.id,
    required super.title,
    super.titleAmharic,
    super.description,
    required super.ethDate,
    required super.gregDate,
    super.isRecurringYearly = false,
    super.eventType = EventType.event,
    super.colorHex,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CustomEventModel.fromEntity(CustomEvent e) => CustomEventModel(
        id: e.id,
        title: e.title,
        titleAmharic: e.titleAmharic,
        description: e.description,
        ethDate: e.ethDate,
        gregDate: e.gregDate,
        isRecurringYearly: e.isRecurringYearly,
        eventType: e.eventType,
        colorHex: e.colorHex,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  factory CustomEventModel.fromMap(Map<String, dynamic> map) {
    return CustomEventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      titleAmharic: map['title_amharic'] as String?,
      description: map['description'] as String?,
      ethDate: EthiopianDate(
        year: map['eth_year'] as int,
        month: map['eth_month'] as int,
        day: map['eth_day'] as int,
      ),
      gregDate: DateTime.parse(map['greg_date'] as String),
      isRecurringYearly: (map['is_recurring_yearly'] as int? ?? 0) == 1,
      eventType: _typeFromString(map['event_type'] as String?),
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
      'description': description,
      'calendar_system': 'ethiopian',
      'eth_year': ethDate.year,
      'eth_month': ethDate.month,
      'eth_day': ethDate.day,
      'greg_date': gregDate.toIso8601String(),
      'is_recurring_yearly': isRecurringYearly ? 1 : 0,
      'event_type': _typeToString(eventType),
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static EventType _typeFromString(String? value) {
    return switch (value) {
      'birthday' => EventType.birthday,
      'anniversary' => EventType.anniversary,
      'meeting' => EventType.meeting,
      'task' => EventType.task,
      'other' => EventType.other,
      _ => EventType.event,
    };
  }

  static String _typeToString(EventType type) {
    return switch (type) {
      EventType.event => 'event',
      EventType.birthday => 'birthday',
      EventType.anniversary => 'anniversary',
      EventType.meeting => 'meeting',
      EventType.task => 'task',
      EventType.other => 'other',
    };
  }
}

class UserNoteModel extends UserNote {
  const UserNoteModel({
    required super.id,
    required super.ethDate,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserNoteModel.fromEntity(UserNote n) => UserNoteModel(
        id: n.id,
        ethDate: n.ethDate,
        content: n.content,
        createdAt: n.createdAt,
        updatedAt: n.updatedAt,
      );

  factory UserNoteModel.fromMap(Map<String, dynamic> map) {
    return UserNoteModel(
      id: map['id'] as String,
      ethDate: EthiopianDate(
        year: map['eth_year'] as int,
        month: map['eth_month'] as int,
        day: map['eth_day'] as int,
      ),
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eth_year': ethDate.year,
      'eth_month': ethDate.month,
      'eth_day': ethDate.day,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}