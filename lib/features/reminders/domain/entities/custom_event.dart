/// ─────────────────────────────────────────────────────────────────────────────
///  CUSTOM EVENT & USER NOTE ENTITIES
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:equatable/equatable.dart';
import '../../../calendar/domain/calendar_engine.dart';

enum EventType {
  event,
  birthday,
  anniversary,
  meeting,
  task,
  other,
}

class CustomEvent extends Equatable {
  final String id;
  final String title;
  final String? titleAmharic;
  final String? description;
  final EthiopianDate ethDate;
  final DateTime gregDate;
  final bool isRecurringYearly;
  final EventType eventType;
  final String? colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomEvent({
    required this.id,
    required this.title,
    this.titleAmharic,
    this.description,
    required this.ethDate,
    required this.gregDate,
    this.isRecurringYearly = false,
    this.eventType = EventType.event,
    this.colorHex,
    required this.createdAt,
    required this.updatedAt,
  });

  CustomEvent copyWith({
    String? id,
    String? title,
    String? titleAmharic,
    String? description,
    EthiopianDate? ethDate,
    DateTime? gregDate,
    bool? isRecurringYearly,
    EventType? eventType,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAmharic: titleAmharic ?? this.titleAmharic,
      description: description ?? this.description,
      ethDate: ethDate ?? this.ethDate,
      gregDate: gregDate ?? this.gregDate,
      isRecurringYearly: isRecurringYearly ?? this.isRecurringYearly,
      eventType: eventType ?? this.eventType,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, title, titleAmharic, description, ethDate, gregDate,
        isRecurringYearly, eventType, colorHex, createdAt, updatedAt,
      ];
}

class UserNote extends Equatable {
  final String id;
  final EthiopianDate ethDate;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserNote({
    required this.id,
    required this.ethDate,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  UserNote copyWith({
    String? id,
    EthiopianDate? ethDate,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserNote(
      id: id ?? this.id,
      ethDate: ethDate ?? this.ethDate,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, ethDate, content, createdAt, updatedAt];
}