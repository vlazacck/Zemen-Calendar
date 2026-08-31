/// ─────────────────────────────────────────────────────────────────────────────
///  REMINDER CARD WIDGET
///  Glassmorphic card representing a single reminder in the list.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/zemen_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../domain/entities/reminder.dart';

class ReminderCategoryStyle {
  final Color color;
  final IconData icon;

  const ReminderCategoryStyle(this.color, this.icon);

  static ReminderCategoryStyle of(ReminderCategory category) {
    return switch (category) {
      ReminderCategory.personal =>
        const ReminderCategoryStyle(ZemenColors.primaryGold, Icons.person_outline_rounded),
      ReminderCategory.feast =>
        const ReminderCategoryStyle(ZemenColors.feastBlue, Icons.celebration_outlined),
      ReminderCategory.fasting =>
        const ReminderCategoryStyle(ZemenColors.crimson, Icons.no_food_outlined),
      ReminderCategory.saint =>
        const ReminderCategoryStyle(ZemenColors.moonWhite, Icons.auto_awesome_outlined),
      ReminderCategory.birthday =>
        const ReminderCategoryStyle(ZemenColors.success, Icons.cake_outlined),
      ReminderCategory.anniversary =>
        const ReminderCategoryStyle(ZemenColors.feastBlue, Icons.favorite_border_rounded),
      ReminderCategory.other =>
        const ReminderCategoryStyle(ZemenColors.textSecondary, Icons.notifications_none_rounded),
    };
  }

  static String label(ReminderCategory category, bool amharic) {
    return switch (category) {
      ReminderCategory.personal => amharic ? 'ግል' : 'Personal',
      ReminderCategory.feast => amharic ? 'ክብረ-በዓል' : 'Feast',
      ReminderCategory.fasting => amharic ? 'ጾም' : 'Fasting',
      ReminderCategory.saint => amharic ? 'ቅዱስ' : 'Saint',
      ReminderCategory.birthday => amharic ? 'የልደት ቀን' : 'Birthday',
      ReminderCategory.anniversary => amharic ? 'መታሰቢያ' : 'Anniversary',
      ReminderCategory.other => amharic ? 'ሌላ' : 'Other',
    };
  }
}

class ZemenReminderCard extends StatelessWidget {
  final Reminder reminder;
  final bool isAmharic;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggleActive;
  final VoidCallback? onDelete;

  const ZemenReminderCard({
    super.key,
    required this.reminder,
    this.isAmharic = true,
    this.onTap,
    this.onToggleActive,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final style = ReminderCategoryStyle.of(reminder.category);
    final timeStr =
        '${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}';
    final recurrenceStr =
        RecurrenceEngine.describeRecurrence(reminder, amharic: isAmharic);

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: ZemenSpacing.lg),
        margin: const EdgeInsets.only(bottom: ZemenSpacing.sm),
        decoration: BoxDecoration(
          color: ZemenColors.crimson.withValues(alpha: 0.15),
          borderRadius: ZemenRadius.lgBR,
          border: Border.all(color: ZemenColors.crimson.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: ZemenColors.crimson),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: ZemenSpacing.lg),
        margin: const EdgeInsets.only(bottom: ZemenSpacing.sm),
        decoration: BoxDecoration(
          color: ZemenColors.crimson.withValues(alpha: 0.15),
          borderRadius: ZemenRadius.lgBR,
          border: Border.all(color: ZemenColors.crimson.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: ZemenColors.crimson),
      ),
      confirmDismiss: (direction) async {
        return true;
      },
      onDismissed: (_) {
        onDelete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAmharic ? 'ማስታወሻ ተሰርዟል' : 'Reminder deleted',
              style: const TextStyle(color: Colors.amber),
            ),
            backgroundColor: ZemenColors.surfaceElevated,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: ZemenSpacing.sm),
        child: ZemenGlassCard(
          onTap: onTap,
          padding: const EdgeInsets.all(ZemenSpacing.md),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.color.withValues(alpha: 0.12),
                  borderRadius: ZemenRadius.mdBR,
                  border: Border.all(color: style.color.withValues(alpha: 0.25)),
                ),
                child: Icon(style.icon, color: style.color, size: 20),
              ),

              const SizedBox(width: ZemenSpacing.md),

              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAmharic
                          ? (reminder.titleAmharic ?? reminder.title)
                          : reminder.title,
                      style: ZemenTextStyles.bodyMedium(amharic: isAmharic).copyWith(
                        color: reminder.isActive
                            ? ZemenColors.textPrimary
                            : ZemenColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 12, color: ZemenColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(timeStr, style: ZemenTextStyles.metadata()),
                        const SizedBox(width: 8),
                        Container(
                          width: 3, height: 3,
                          decoration: const BoxDecoration(
                            color: ZemenColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            recurrenceStr,
                            style: ZemenTextStyles.metadata(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: ZemenSpacing.sm),

              // Active toggle
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: reminder.isActive,
                  onChanged: onToggleActive,
                  activeThumbColor: style.color,
                  activeTrackColor: style.color.withValues(alpha: 0.3),
                  inactiveThumbColor: ZemenColors.textTertiary,
                  inactiveTrackColor: ZemenColors.surfaceElevated,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}