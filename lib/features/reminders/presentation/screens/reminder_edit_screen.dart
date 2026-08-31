import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/zemen_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../../calendar/domain/calendar_engine.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminder_providers.dart';
import '../widgets/reminder_card.dart';

class ReminderEditScreen extends ConsumerStatefulWidget {
  final Reminder? reminder;
  const ReminderEditScreen({super.key, this.reminder});

  @override
  ConsumerState<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends ConsumerState<ReminderEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _titleAmharicController;
  late TextEditingController _notesController;

  late CalendarSystem _calendarSystem;
  late EthiopianDate _ethDate;
  late DateTime _gregDate;
  late int _hour;
  late int _minute;
  late RecurrenceType _recurrenceType;
  late int _recurrenceInterval;
  late ReminderCategory _category;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    final today = CalendarEngine.today();

    _titleController = TextEditingController(text: r?.title ?? '');
    _titleAmharicController =
        TextEditingController(text: r?.titleAmharic ?? '');
    _notesController = TextEditingController(text: r?.notes ?? '');

    _calendarSystem = r?.calendarSystem ?? CalendarSystem.ethiopian;
    _ethDate = r?.ethDate ?? today;
    _gregDate = r?.gregDate ?? CalendarEngine.toGregorian(today);
    _hour = r?.hour ?? 9;
    _minute = r?.minute ?? 0;
    _recurrenceType = r?.recurrenceType ?? RecurrenceType.once;
    _recurrenceInterval = r?.recurrenceInterval ?? 1;
    _category = r?.category ?? ReminderCategory.personal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleAmharicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAmharic = ref.watch(isAmharicProvider);

    return Scaffold(
      backgroundColor: ZemenColors.background,
      // In build(), find the AppBar and replace:
appBar: AppBar(
  title: Text(
    _isEditing
        ? (isAmharic ? 'ማስታወሻ አርትዕ' : 'Edit Reminder')
        : (isAmharic ? 'አዲስ ማስታወሻ' : 'New Reminder'),
    style: ZemenTextStyles.sectionHeader(amharic: isAmharic),
  ),
  actions: [
    if (_isEditing)
      IconButton(
        icon: const Icon(Icons.delete_outline_rounded,
            color: ZemenColors.crimson),
        onPressed: () => _confirmDelete(context, isAmharic),
      ),

    // ADD THIS — save button always visible in app bar:
    TextButton(
      onPressed: () => _save(isAmharic),
      child: Text(
        isAmharic ? 'አስቀምጥ' : 'Save',
        style: ZemenTextStyles.goldLabel(fontSize: 14),
      ),
    ),
  ],
),
     body: SafeArea(
  child: ListView(
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
    padding: EdgeInsets.fromLTRB(
        ZemenSpacing.md, 0, ZemenSpacing.md,
        MediaQuery.of(context).viewInsets.bottom + ZemenSpacing.xxxl),
          children: [
            // ── Title fields ──────────────────────────────────────────────
            _SectionLabel(
                text: isAmharic ? 'ርዕስ' : 'Title', isAmharic: isAmharic),
            ZemenGlassCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: ZemenSpacing.md, vertical: 4),
              child: Column(
                children: [
                  _GlassTextField(
                    controller: _titleController,
                    hint: 'Reminder title',
                  ),
                  const Divider(height: 1, color: ZemenColors.divider),
                  _GlassTextField(
                    controller: _titleAmharicController,
                    hint: 'የማስታወሻ ርዕስ (አማርኛ)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: ZemenSpacing.md),

            // ── Notes ─────────────────────────────────────────────────────
            _SectionLabel(
                text: isAmharic ? 'ማስታወሻ' : 'Notes', isAmharic: isAmharic),
            ZemenGlassCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: ZemenSpacing.md, vertical: 4),
              child: _GlassTextField(
                controller: _notesController,
                hint: isAmharic
                    ? 'ተጨማሪ ማስታወሻ (አማራጭ)'
                    : 'Additional notes (optional)',
                maxLines: 3,
              ),
            ),

            const SizedBox(height: ZemenSpacing.md),

            // ── Category ──────────────────────────────────────────────────
            _SectionLabel(
                text: isAmharic ? 'ምድብ' : 'Category', isAmharic: isAmharic),
            _CategorySelector(
              selected: _category,
              isAmharic: isAmharic,
              onChanged: (c) => setState(() => _category = c),
            ),

            const SizedBox(height: ZemenSpacing.md),

            // ── Calendar System ───────────────────────────────────────────
            _SectionLabel(
                text: isAmharic ? 'የቀን አቆጣጠር ስርዓት' : 'Calendar System',
                isAmharic: isAmharic),
            _CalendarSystemSelector(
              selected: _calendarSystem,
              isAmharic: isAmharic,
              onChanged: (sys) => setState(() => _calendarSystem = sys),
            ),

            const SizedBox(height: ZemenSpacing.md),

            // ── Date Picker ───────────────────────────────────────────────
            _SectionLabel(
                text: isAmharic ? 'ቀን' : 'Date', isAmharic: isAmharic),
            _DateSelector(
              calendarSystem: _calendarSystem,
              ethDate: _ethDate,
              gregDate: _gregDate,
              isAmharic: isAmharic,
              onEthDateChanged: (d) => setState(() {
                _ethDate = d;
                _gregDate = CalendarEngine.toGregorian(d);
              }),
              onGregDateChanged: (d) => setState(() {
                _gregDate = d;
                _ethDate = CalendarEngine.fromGregorian(d);
              }),
            ),

            const SizedBox(height: ZemenSpacing.md),

            // ── Time Picker ───────────────────────────────────────────────
            _SectionLabel(
                text: isAmharic ? 'ሰዓት' : 'Time', isAmharic: isAmharic),
            _TimeSelector(
              hour: _hour,
              minute: _minute,
              isAmharic: isAmharic,
              onChanged: (h, m) => setState(() {
                _hour = h;
                _minute = m;
              }),
            ),

            const SizedBox(height: ZemenSpacing.md),

            // ── Recurrence ────────────────────────────────────────────────
            _SectionLabel(
                text: isAmharic ? 'ድግግሞሽ' : 'Recurrence', isAmharic: isAmharic),
            _RecurrenceSelector(
              recurrenceType: _recurrenceType,
              recurrenceInterval: _recurrenceInterval,
              calendarSystem: _calendarSystem,
              isAmharic: isAmharic,
              onTypeChanged: (t) => setState(() => _recurrenceType = t),
              onIntervalChanged: (i) => setState(() => _recurrenceInterval = i),
            ),

            const SizedBox(height: ZemenSpacing.xl),

            // ── Save Button ───────────────────────────────────────────────
            _SaveButton(
              isAmharic: isAmharic,
              onPressed: () => _save(isAmharic),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(bool isAmharic) async {
    final title = _titleController.text.trim();
    final titleAm = _titleAmharicController.text.trim();

    // Use whichever is filled, require at least one
    if (title.isEmpty && titleAm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAmharic ? 'ርዕስ ያስፈልጋል' : 'Please enter a title'),
          backgroundColor: ZemenColors.crimson,
        ),
      );
      return;
    }

    // Both are saved independently, title falls back to Amharic if empty
    final effectiveTitle = title.isNotEmpty ? title : titleAm;
    final effectiveTitleAm = titleAm.isNotEmpty ? titleAm : null;

    if (_isEditing) {
      final updated = widget.reminder!.copyWith(
        title: effectiveTitle,
        titleAmharic: effectiveTitleAm,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        calendarSystem: _calendarSystem,
        ethDate: _calendarSystem == CalendarSystem.ethiopian ? _ethDate : null,
        gregDate:
            _calendarSystem == CalendarSystem.gregorian ? _gregDate : null,
        hour: _hour,
        minute: _minute,
        recurrenceType: _recurrenceType,
        recurrenceInterval: _recurrenceInterval,
        category: _category,
      );
      await ref.read(remindersProvider.notifier).editReminder(updated);
    } else {
      await ref.read(remindersProvider.notifier).addReminder(
            title: effectiveTitle,
            titleAmharic: effectiveTitleAm,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            calendarSystem: _calendarSystem,
            ethDate:
                _calendarSystem == CalendarSystem.ethiopian ? _ethDate : null,
            gregDate:
                _calendarSystem == CalendarSystem.gregorian ? _gregDate : null,
            hour: _hour,
            minute: _minute,
            recurrenceType: _recurrenceType,
            recurrenceInterval: _recurrenceInterval,
            category: _category,
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context, bool isAmharic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ZemenColors.surfaceSolid,
        shape: const RoundedRectangleBorder(borderRadius: ZemenRadius.lgBR),
        title: Text(
          isAmharic ? 'ማስታወሻ ይሰረዝ?' : 'Delete Reminder?',
          style: ZemenTextStyles.sectionHeader(amharic: isAmharic),
        ),
        content: Text(
          isAmharic
              ? 'ይህ ድርጊት መልሰው ማድረግ አይቻልም።'
              : 'This action cannot be undone.',
          style: ZemenTextStyles.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isAmharic ? 'ይቅር' : 'Cancel',
                style: const TextStyle(color: ZemenColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isAmharic ? 'ሰርዝ' : 'Delete',
                style: const TextStyle(color: ZemenColors.crimson)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(remindersProvider.notifier)
          .deleteReminder(widget.reminder!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }
}

// ─── Shared small widgets ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isAmharic;
  const _SectionLabel({required this.text, required this.isAmharic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: ZemenSpacing.sm, top: ZemenSpacing.xs),
      child: Text(
        text.toUpperCase(),
        style: ZemenTextStyles.caption(color: ZemenColors.textTertiary)
            .copyWith(letterSpacing: 1.5),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _GlassTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: ZemenTextStyles.body(),
      cursorColor: ZemenColors.primaryGold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ZemenTextStyles.body(color: ZemenColors.textTertiary),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: ZemenSpacing.sm),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isAmharic;
  final VoidCallback onPressed;
  const _SaveButton({required this.isAmharic, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: ZemenRadius.lgBR,
        gradient: ZemenGradients.goldLinear,
        boxShadow: ZemenShadows.goldGlow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: ZemenRadius.lgBR,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: ZemenSpacing.md),
            child: Center(
              child: Text(
                isAmharic ? 'አስቀምጥ' : 'Save Reminder',
                style: ZemenTextStyles.bodyMedium(color: ZemenColors.background)
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category Selector ──────────────────────────────────────────────────────

class _CategorySelector extends StatelessWidget {
  final ReminderCategory selected;
  final bool isAmharic;
  final ValueChanged<ReminderCategory> onChanged;

  const _CategorySelector({
    required this.selected,
    required this.isAmharic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ReminderCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: ZemenSpacing.sm),
        itemBuilder: (ctx, i) {
          final category = ReminderCategory.values[i];
          final style = ReminderCategoryStyle.of(category);
          final isSelected = category == selected;

          return GestureDetector(
            onTap: () => onChanged(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 76,
              padding: const EdgeInsets.symmetric(vertical: ZemenSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? style.color.withValues(alpha: 0.14)
                    : ZemenColors.surfaceElevated,
                borderRadius: ZemenRadius.mdBR,
                border: Border.all(
                  color: isSelected
                      ? style.color.withValues(alpha: 0.4)
                      : ZemenColors.glassBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(style.icon,
                      color:
                          isSelected ? style.color : ZemenColors.textSecondary,
                      size: 22),
                  const SizedBox(height: 6),
                  Text(
                    ReminderCategoryStyle.label(category, isAmharic),
                    style: ZemenTextStyles.metadata(
                      color:
                          isSelected ? style.color : ZemenColors.textSecondary,
                    ).copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Calendar System Selector ──────────────────────────────────────────────

class _CalendarSystemSelector extends StatelessWidget {
  final CalendarSystem selected;
  final bool isAmharic;
  final ValueChanged<CalendarSystem> onChanged;

  const _CalendarSystemSelector({
    required this.selected,
    required this.isAmharic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SegmentButton(
            label: isAmharic ? 'የኢትዮጵያ' : 'Ethiopian',
            selected: selected == CalendarSystem.ethiopian,
            onTap: () => onChanged(CalendarSystem.ethiopian),
          ),
        ),
        const SizedBox(width: ZemenSpacing.sm),
        Expanded(
          child: _SegmentButton(
            label: isAmharic ? 'ጎርጎሪያን' : 'Gregorian',
            selected: selected == CalendarSystem.gregorian,
            onTap: () => onChanged(CalendarSystem.gregorian),
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: ZemenSpacing.sm + 2),
        decoration: BoxDecoration(
          color: selected
              ? ZemenColors.primaryGoldGlow
              : ZemenColors.surfaceElevated,
          borderRadius: ZemenRadius.mdBR,
          border: Border.all(
            color:
                selected ? ZemenColors.primaryGoldDim : ZemenColors.glassBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: ZemenTextStyles.bodyMedium(
              color: selected
                  ? ZemenColors.primaryGold
                  : ZemenColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Date Selector ──────────────────────────────────────────────────────────

class _DateSelector extends StatelessWidget {
  final CalendarSystem calendarSystem;
  final EthiopianDate ethDate;
  final DateTime gregDate;
  final bool isAmharic;
  final ValueChanged<EthiopianDate> onEthDateChanged;
  final ValueChanged<DateTime> onGregDateChanged;

  const _DateSelector({
    required this.calendarSystem,
    required this.ethDate,
    required this.gregDate,
    required this.isAmharic,
    required this.onEthDateChanged,
    required this.onGregDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (calendarSystem == CalendarSystem.ethiopian) {
      return _EthiopianDateRow(
        date: ethDate,
        isAmharic: isAmharic,
        onChanged: onEthDateChanged,
      );
    }
    return _GregorianDateRow(date: gregDate, onChanged: onGregDateChanged);
  }
}

class _EthiopianDateRow extends StatelessWidget {
  final EthiopianDate date;
  final bool isAmharic;
  final ValueChanged<EthiopianDate> onChanged;

  const _EthiopianDateRow({
    required this.date,
    required this.isAmharic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = isAmharic
        ? CalendarEngine.monthNamesAmharic[date.month - 1]
        : CalendarEngine.monthNamesEnglish[date.month - 1];

    return ZemenGlassCard(
      padding: const EdgeInsets.all(ZemenSpacing.md),
      onTap: () => _showEthiopianDatePicker(context),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: ZemenColors.primaryGold, size: 18),
          const SizedBox(width: ZemenSpacing.sm),
          Expanded(
            child: Text(
              '${date.day} $monthName ${date.year}',
              style: ZemenTextStyles.bodyMedium(amharic: isAmharic),
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: ZemenColors.textTertiary),
        ],
      ),
    );
  }

  void _showEthiopianDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _EthiopianDatePickerDialog(
        initialDate: date,
        isAmharic: isAmharic,
        onDateSelected: (selectedDate) {
          onChanged(selectedDate);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _EthiopianDatePickerDialog extends StatefulWidget {
  final EthiopianDate initialDate;
  final bool isAmharic;
  final ValueChanged<EthiopianDate> onDateSelected;

  const _EthiopianDatePickerDialog({
    required this.initialDate,
    required this.isAmharic,
    required this.onDateSelected,
  });

  @override
  State<_EthiopianDatePickerDialog> createState() =>
      _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState
    extends State<_EthiopianDatePickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final monthName = widget.isAmharic
        ? CalendarEngine.monthNamesAmharic[_selectedMonth - 1]
        : CalendarEngine.monthNamesEnglish[_selectedMonth - 1];

    final maxDay =
        CalendarEngine.daysInEthiopianMonth(_selectedYear, _selectedMonth);

    return Dialog(
      backgroundColor: ZemenColors.surfaceSolid,
      child: Container(
        padding: const EdgeInsets.all(ZemenSpacing.lg),
        decoration: BoxDecoration(
          color: ZemenColors.surfaceSolid,
          border: Border.all(color: ZemenColors.glassBorder),
          borderRadius: ZemenRadius.lgBR,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.isAmharic ? 'ቀን ምረጥ' : 'Select Date',
              style: ZemenTextStyles.sectionHeader(amharic: widget.isAmharic),
            ),
            const SizedBox(height: ZemenSpacing.lg),
            // Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_rounded),
                  onPressed: () =>
                      setState(() => _selectedYear = _selectedYear - 1),
                ),
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Text(
                      _selectedYear.toString(),
                      style: ZemenTextStyles.heroAmharic(fontSize: 24),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () =>
                      setState(() => _selectedYear = _selectedYear + 1),
                ),
              ],
            ),
            const SizedBox(height: ZemenSpacing.md),
            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = _selectedMonth - 1;
                      if (_selectedMonth < 1) {
                        _selectedMonth = 13;
                        _selectedYear -= 1;
                      }
                      // Ensure day is valid for new month
                      final newMaxDay = CalendarEngine.daysInEthiopianMonth(
                          _selectedYear, _selectedMonth);
                      if (_selectedDay > newMaxDay) {
                        _selectedDay = newMaxDay;
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 120,
                  child: Center(
                    child: Text(
                      monthName,
                      style: ZemenTextStyles.heroAmharic(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedMonth = _selectedMonth + 1;
                      if (_selectedMonth > 13) {
                        _selectedMonth = 1;
                        _selectedYear += 1;
                      }
                      // Ensure day is valid for new month
                      final newMaxDay = CalendarEngine.daysInEthiopianMonth(
                          _selectedYear, _selectedMonth);
                      if (_selectedDay > newMaxDay) {
                        _selectedDay = newMaxDay;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: ZemenSpacing.md),
            // Day selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_rounded),
                  onPressed: () {
                    setState(() {
                      _selectedDay = _selectedDay - 1;
                      if (_selectedDay < 1) {
                        _selectedMonth -= 1;
                        if (_selectedMonth < 1) {
                          _selectedMonth = 13;
                          _selectedYear -= 1;
                        }
                        _selectedDay = CalendarEngine.daysInEthiopianMonth(
                            _selectedYear, _selectedMonth);
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 80,
                  child: Center(
                    child: Text(
                      _selectedDay.toString().padLeft(2, '0'),
                      style: ZemenTextStyles.heroAmharic(fontSize: 24),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () {
                    setState(() {
                      final maxDay = CalendarEngine.daysInEthiopianMonth(
                          _selectedYear, _selectedMonth);
                      _selectedDay = _selectedDay + 1;
                      if (_selectedDay > maxDay) {
                        _selectedDay = 1;
                        _selectedMonth += 1;
                        if (_selectedMonth > 13) {
                          _selectedMonth = 1;
                          _selectedYear += 1;
                        }
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: ZemenSpacing.lg),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZemenColors.textTertiary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    widget.isAmharic ? 'ይቅር' : 'Cancel',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZemenColors.primaryGold,
                  ),
                  onPressed: () {
                    widget.onDateSelected(
                      EthiopianDate(
                        year: _selectedYear,
                        month: _selectedMonth,
                        day: _selectedDay,
                      ),
                    );
                  },
                  child: Text(
                    widget.isAmharic ? 'ይሁን' : 'OK',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GregorianDateRow extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _GregorianDateRow({required this.date, required this.onChanged});

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return ZemenGlassCard(
      padding: const EdgeInsets.all(ZemenSpacing.md),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: ZemenColors.primaryGold,
                surface: ZemenColors.surfaceSolid,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              color: ZemenColors.primaryGold, size: 18),
          const SizedBox(width: ZemenSpacing.sm),
          Expanded(
            child: Text(
              '${_months[date.month - 1]} ${date.day}, ${date.year}',
              style: ZemenTextStyles.bodyMedium(),
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: ZemenColors.textTertiary),
        ],
      ),
    );
  }
}

// ─── Time Selector ──────────────────────────────────────────────────────────

class _TimeSelector extends StatelessWidget {
  final int hour;
  final int minute;
  final bool isAmharic;
  final void Function(int hour, int minute) onChanged;

  const _TimeSelector({
    required this.hour,
    required this.minute,
    required this.isAmharic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return ZemenGlassCard(
      padding: const EdgeInsets.all(ZemenSpacing.md),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: ZemenColors.primaryGold,
                surface: ZemenColors.surfaceSolid,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked.hour, picked.minute);
      },
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              color: ZemenColors.primaryGold, size: 18),
          const SizedBox(width: ZemenSpacing.sm),
          Expanded(
            child: Text(timeStr, style: ZemenTextStyles.bodyMedium()),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: ZemenColors.textTertiary),
        ],
      ),
    );
  }
}

// ─── Recurrence Selector ────────────────────────────────────────────────────

class _RecurrenceSelector extends StatelessWidget {
  final RecurrenceType recurrenceType;
  final int recurrenceInterval;
  final CalendarSystem calendarSystem;
  final bool isAmharic;
  final ValueChanged<RecurrenceType> onTypeChanged;
  final ValueChanged<int> onIntervalChanged;

  const _RecurrenceSelector({
    required this.recurrenceType,
    required this.recurrenceInterval,
    required this.calendarSystem,
    required this.isAmharic,
    required this.onTypeChanged,
    required this.onIntervalChanged,
  });

  String _label(RecurrenceType type) {
    return switch (type) {
      RecurrenceType.once => isAmharic ? 'አንድ ጊዜ' : 'Once',
      RecurrenceType.daily => isAmharic ? 'ዕለታዊ' : 'Daily',
      RecurrenceType.weekly => isAmharic ? 'ሳምንታዊ' : 'Weekly',
      RecurrenceType.monthly => isAmharic ? 'ወራዊ' : 'Monthly',
      RecurrenceType.yearly => isAmharic ? 'ዓመታዊ' : 'Yearly',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ZemenGlassCard(
          padding: const EdgeInsets.all(ZemenSpacing.sm),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: RecurrenceType.values.map((type) {
              final isSelected = type == recurrenceType;
              return GestureDetector(
                onTap: () => onTypeChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ZemenColors.primaryGoldGlow
                        : ZemenColors.surfaceElevated,
                    borderRadius: ZemenRadius.fullBR,
                    border: Border.all(
                      color: isSelected
                          ? ZemenColors.primaryGoldDim
                          : ZemenColors.glassBorder,
                    ),
                  ),
                  child: Text(
                    _label(type),
                    style: ZemenTextStyles.metadata(
                      color: isSelected
                          ? ZemenColors.primaryGold
                          : ZemenColors.textSecondary,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (recurrenceType != RecurrenceType.once) ...[
          const SizedBox(height: ZemenSpacing.sm),
          ZemenGlassCard(
            padding: const EdgeInsets.symmetric(
                horizontal: ZemenSpacing.md, vertical: ZemenSpacing.sm),
            child: Row(
              children: [
                Text(
                  isAmharic ? 'በየ' : 'Every',
                  style: ZemenTextStyles.body(amharic: isAmharic),
                ),
                const Spacer(),
                _StepperGroup(
                  onMinus: () {
                    if (recurrenceInterval > 1) {
                      onIntervalChanged(recurrenceInterval - 1);
                    }
                  },
                  onPlus: () => onIntervalChanged(recurrenceInterval + 1),
                  centerLabel: '$recurrenceInterval',
                ),
                const SizedBox(width: ZemenSpacing.sm),
                Text(
                  _unitLabel(),
                  style: ZemenTextStyles.body(amharic: isAmharic),
                ),
              ],
            ),
          ),
          if (recurrenceType == RecurrenceType.monthly ||
              recurrenceType == RecurrenceType.yearly) ...[
            const SizedBox(height: ZemenSpacing.sm),
            Container(
              padding: const EdgeInsets.all(ZemenSpacing.sm),
              decoration: BoxDecoration(
                color: ZemenColors.feastBlue.withValues(alpha: 0.08),
                borderRadius: ZemenRadius.mdBR,
                border: Border.all(
                    color: ZemenColors.feastBlue.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: ZemenColors.feastBlue),
                  const SizedBox(width: ZemenSpacing.sm),
                  Expanded(
                    child: Text(
                      calendarSystem == CalendarSystem.ethiopian
                          ? (isAmharic
                              ? 'በኢትዮጵያ ቀን አቆጣጠር መሰረት ይደገማል'
                              : 'Recurs based on the Ethiopian calendar')
                          : (isAmharic
                              ? 'በጎርጎሪያን ቀን አቆጣጠር መሰረት ይደገማል'
                              : 'Recurs based on the Gregorian calendar'),
                      style: ZemenTextStyles.metadata(
                          color: ZemenColors.feastBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  String _unitLabel() {
    final plural = recurrenceInterval != 1;
    return switch (recurrenceType) {
      RecurrenceType.daily => isAmharic ? 'ቀናት' : (plural ? 'days' : 'day'),
      RecurrenceType.weekly =>
        isAmharic ? 'ሳምንታት' : (plural ? 'weeks' : 'week'),
      RecurrenceType.monthly =>
        isAmharic ? 'ወራት' : (plural ? 'months' : 'month'),
      RecurrenceType.yearly => isAmharic ? 'ዓመታት' : (plural ? 'years' : 'year'),
      RecurrenceType.once => '',
    };
  }
}

// ─── Stepper Group ──────────────────────────────────────────────────────────

class _StepperGroup extends StatelessWidget {
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final String? centerLabel;

  const _StepperGroup({
    required this.onMinus,
    required this.onPlus,
    this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZemenColors.surfaceElevated,
        borderRadius: ZemenRadius.fullBR,
        border: Border.all(color: ZemenColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(icon: Icons.remove_rounded, onTap: onMinus),
          if (centerLabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                centerLabel!,
                style: ZemenTextStyles.bodyMedium().copyWith(fontSize: 14),
              ),
            ),
          _StepperButton(icon: Icons.add_rounded, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: ZemenColors.textSecondary),
      ),
    );
  }
}
