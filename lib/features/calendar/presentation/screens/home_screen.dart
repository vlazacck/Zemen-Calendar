import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/zemen_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../domain/calendar_engine.dart';
import '../providers/calendar_providers.dart';
import '../../../../main.dart' show ZemenSearchButton;
import '../../../../features/holidays/domain/holiday_engine.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calState = ref.watch(calendarProvider);
    final isAmharic = ref.watch(isAmharicProvider);
    final settings = ref.watch(settingsProvider);
    final today = calState.today;
    final now = calState.now;

    // Derived values
    final monthName = isAmharic
        ? CalendarEngine.monthNamesAmharic[today.month - 1]
        : CalendarEngine.monthNamesEnglish[today.month - 1];
    final dayGeez = CalendarEngine.toGeezNumeral(today.day);
    final weekdayIdx = CalendarEngine.ethiopianWeekday(today);
    final weekdayAm = CalendarEngine.weekdayNamesAmharic[weekdayIdx];
    final weekdayEn = CalendarEngine.weekdayNamesEnglish[weekdayIdx];
    final evangelist = CalendarEngine.evangelistForYear(today.year, amharic: isAmharic);
    final moonName = ref.watch(currentMoonPhaseNameProvider(isAmharic));
    final season = ref.watch(currentSeasonProvider(isAmharic));
    final ethTime = CalendarEngine.toEthiopianTime(now, amharic: isAmharic);
    final gregorianStr = _formatGregorian(CalendarEngine.toGregorian(today));
    final upcomingHolidays = ref.watch(upcomingHolidaysProvider);
    final currentFasting = ref.watch(currentFastingPeriodProvider);
    final isWeeklyFast = ref.watch(isWeeklyFastDayProvider);

    return Scaffold(
      backgroundColor: ZemenColors.background,
      body: Stack(
        children: [
          // Background ambient gradient
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ZemenColors.primaryGold.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ZemenColors.feastBlue.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main scrollable content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top Navigation Bar ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ZemenSpacing.md, ZemenSpacing.md, ZemenSpacing.md, 0),
                    child: Row(
                      children: [
                        // App logo / brand
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: ZemenColors.primaryGoldGlow,
                                borderRadius: ZemenRadius.smBR,
                                border: Border.all(
                                  color: ZemenColors.primaryGoldDim,
                                ),
                              ),
                              child: const Center(
                                child: Text('ዘ', style: TextStyle(
                                  color: ZemenColors.primaryGold,
                                  fontFamily: 'Benaiah',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                )),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Zemen',
                              style: ZemenTextStyles.bodyMedium().copyWith(
                                fontSize: 18,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Language toggle
                        _LanguageToggle(
                          isAmharic: isAmharic,
                          onToggle: () => ref
                              .read(isAmharicProvider.notifier)
                              .state = !isAmharic,
                        ),

                        const SizedBox(width: ZemenSpacing.sm),

                        // Search button — opens full-screen search overlay
                        const ZemenSearchButton(),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: ZemenSpacing.md)),

                // ── Hero Calendar Card ───────────────────────────────────
                SliverToBoxAdapter(
                  child: HeroCalendarCard(
                    ethiopianDateAmharic: '$dayGeez $monthName',
                    ethiopianDayAmharic: dayGeez,
                    monthNameAmharic: monthName,
                    gregorianDate: gregorianStr,
                    weekdayAmharic: weekdayAm,
                    weekdayEnglish: weekdayEn,
                    evangelistAmharic: isAmharic
                        ? 'ዓ/$evangelist'
                        : 'Year of $evangelist',
                    moonPhase: moonName,
                    ethiopianTime: ethTime,
                    season: season,
                    isAmharic: isAmharic,
                  )
                      .animate()
                      .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic)
                      .fadeIn(duration: 600.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: ZemenSpacing.md)),

                // ── Bento Grid Row 1: Month nav + Today button ───────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ZemenSpacing.md),
                    child: Row(
                      children: [
                        Text(
                          isAmharic
                              ? CalendarEngine.monthNamesAmharic[
                                  calState.viewMonth - 1]
                              : CalendarEngine.monthNamesEnglish[
                                  calState.viewMonth - 1],
                          style: ZemenTextStyles.sectionHeader(
                              amharic: isAmharic),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CalendarEngine.toGeezNumeral(calState.viewYear),
                          style: ZemenTextStyles.sectionHeader(
                            amharic: true,
                            color: ZemenColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        _MonthNavButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: () =>
                              ref.read(calendarProvider.notifier).navigateMonth(-1),
                        ),
                        const SizedBox(width: 4),
                        _MonthNavButton(
                          icon: Icons.chevron_right_rounded,
                          onTap: () =>
                              ref.read(calendarProvider.notifier).navigateMonth(1),
                        ),
                        const SizedBox(width: 8),
                        _TodayButton(
                          isAmharic: isAmharic,
                          onTap: () =>
                              ref.read(calendarProvider.notifier).goToToday(),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: ZemenSpacing.sm)),

                // ── Month Grid ───────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ZemenSpacing.md),
                    child: Consumer(
                      builder: (context, ref, _) {
                        final feastDays = ref.watch(feastDaysForMonthProvider(
                            (calState.viewYear, calState.viewMonth)));
                        final fastingDays =
                            ref.watch(fastingDaysForMonthProvider(
                                (calState.viewYear, calState.viewMonth)));

                        return ZemenMonthGrid(
                          year: calState.viewYear,
                          month: calState.viewMonth,
                          selectedDay: calState.selectedDate.year ==
                                  calState.viewYear &&
                              calState.selectedDate.month == calState.viewMonth
                              ? calState.selectedDate.day
                              : null,
                          feastDays: feastDays,
                          fastingDays: fastingDays,
                          isAmharic: isAmharic,
                          onDateTap: (date) {
                            ref
                                .read(calendarProvider.notifier)
                                .selectDate(date);
                          },
                        );
                      },
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: ZemenSpacing.sm)),

                // ── Selected Date Gregorian Indicator ────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ZemenSpacing.md),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.15),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: _SelectedDateGregorianCard(
                        key: ValueKey(calState.selectedDate),
                        selectedDate: calState.selectedDate,
                        isAmharic: isAmharic,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: ZemenSpacing.md)),

                // ── Bento Row: Fasting + Upcoming Feast ─────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ZemenSpacing.md),
                    child: Row(
                      children: [
                        // Fasting status
                        Expanded(
                          child: ZemenFastingCard(
                            fastingName: currentFasting?.nameEnglish ??
                                (isWeeklyFast
                                    ? 'Weekly Fast'
                                    : 'No Fasting'),
                            fastingNameAmharic:
                                currentFasting?.nameAmharic ??
                                    (isWeeklyFast
                                        ? 'ሳምናዊ ጾም'
                                        : 'ጾም የለም'),
                            isFasting:
                                currentFasting != null || isWeeklyFast,
                            morningStatus: true,
                            eveningStatus: true,
                            daysRemaining: currentFasting != null
                                ? today.differenceInDays(
                                    currentFasting.end)
                                : 0,
                            nextFastName: 'ዐቢይ ጾም',
                            isAmharic: isAmharic,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: ZemenSpacing.md)),

                // ── Upcoming Feasts / Holidays ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: ZemenSpacing.md),
                    child: Text(
                      isAmharic ? 'ቀጣይ ክብረ-በዓሎች' : 'Upcoming Feasts',
                      style: ZemenTextStyles.sectionHeader(
                          amharic: isAmharic),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: ZemenSpacing.sm)),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i >= upcomingHolidays.length) return null;
                      final item = upcomingHolidays[i];
                      final daysUntil = item.date.toJdn() - today.toJdn();
                      final label = daysUntil == 0
                          ? (isAmharic ? 'ዛሬ' : 'Today')
                          : daysUntil == 1
                              ? (isAmharic ? 'ነገ' : 'Tomorrow')
                              : (isAmharic
                                  ? 'በ$daysUntil ቀናት'
                                  : 'In $daysUntil days');

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ZemenSpacing.md,
                          vertical: 4,
                        ),
                        child: ZemenHolidayCard(
                          name: item.holiday.nameEnglish,
                          nameAmharic: item.holiday.nameAmharic,
                          daysUntil: label,
                          description: item.holiday.descriptionEnglish ?? '',
                          importanceIndicator: _importanceEmoji(
                              item.holiday.importanceLevel),
                          accentColor: _categoryColor(item.holiday.category),
                          isAmharic: isAmharic,
                        ).animate().slideX(
                          begin: 0.2,
                          end: 0,
                          delay: (400 + i * 80).ms,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                      );
                    },
                    childCount: upcomingHolidays.length,
                  ),
                ),

                // ── Timeline Stream ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ZemenSpacing.md,
                      ZemenSpacing.lg,
                      ZemenSpacing.md,
                      ZemenSpacing.sm,
                    ),
                    child: Text(
                      isAmharic ? 'የቀን ዝርዝር' : 'Day Stream',
                      style: ZemenTextStyles.sectionHeader(
                          amharic: isAmharic),
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: ZemenSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      _buildTimelineItems(isAmharic, today),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                    child: SizedBox(height: ZemenSpacing.xxxl)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineItems(bool isAmharic, EthiopianDate today) {
    final items = [
      (
        title: 'Today',
        titleAm: 'ዛሬ',
        sub: CalendarEngine.monthNamesEnglish[today.month - 1],
        emoji: '📅',
        color: ZemenColors.primaryGold,
      ),
      (
        title: 'Tuesday Fast',
        titleAm: 'ሰዑ ጾም',
        sub: 'Weekly observance',
        emoji: '🕊',
        color: ZemenColors.crimson,
      ),
      (
        title: 'Saint Gabriel',
        titleAm: 'ቅዱስ ገብርኤል',
        sub: 'Monthly commemoration',
        emoji: '✨',
        color: ZemenColors.feastBlue,
      ),
      (
        title: 'Timket Season',
        titleAm: 'ጥምቀት',
        sub: 'Coming soon',
        emoji: '💧',
        color: ZemenColors.success,
      ),
    ];

    return items.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final dayStr = CalendarEngine.toGeezNumeral(today.day);
      return ZemenTimelineItem(
        title: item.title,
        titleAmharic: item.titleAm,
        subtitle: item.sub,
        date: dayStr,
        emoji: item.emoji,
        dotColor: item.color,
        isFirst: i == 0,
        isLast: i == items.length - 1,
        isAmharic: isAmharic,
      );
    }).toList();
  }

  String _formatGregorian(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _importanceEmoji(int level) {
    return switch (level) {
      5 => '⭐',
      4 => '🔆',
      3 => '✦',
      _ => '·',
    };
  }

  Color _categoryColor(HolidayCategory category) {
    return switch (category) {
      HolidayCategory.orthodoxFeast => ZemenColors.primaryGold,
      HolidayCategory.marianFeast => ZemenColors.feastBlue,
      HolidayCategory.nationalHoliday => ZemenColors.success,
      HolidayCategory.saintCommemoration => ZemenColors.moonWhite,
      HolidayCategory.historicalEvent => ZemenColors.crimson,
    };
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

/// Shows the selected Ethiopian date + its Gregorian equivalent below the grid.
class _SelectedDateGregorianCard extends StatelessWidget {
  final EthiopianDate selectedDate;
  final bool isAmharic;

  const _SelectedDateGregorianCard({
    super.key,
    required this.selectedDate,
    required this.isAmharic,
  });

  String _formatGregorian(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final gregorian = CalendarEngine.toGregorian(selectedDate);
    final ethMonthName = isAmharic
        ? CalendarEngine.monthNamesAmharic[selectedDate.month - 1]
        : CalendarEngine.monthNamesEnglish[selectedDate.month - 1];
    final ethLabel = isAmharic
        ? '${CalendarEngine.toGeezNumeral(selectedDate.day)} $ethMonthName ${CalendarEngine.toGeezNumeral(selectedDate.year)}'
        : '$ethMonthName ${selectedDate.day}, ${selectedDate.year}';
    final gregLabel = _formatGregorian(gregorian);
    final isToday = CalendarEngine.today() == selectedDate;

    return Container(
      decoration: BoxDecoration(
        borderRadius: ZemenRadius.lgBR,
        boxShadow: [
          BoxShadow(
            color: ZemenColors.primaryGold.withValues(alpha: 0.10),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: ZemenRadius.lgBR,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ZemenSpacing.md,
            vertical: ZemenSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: ZemenRadius.lgBR,
            color: const Color(0xFF1A1D26),
            border: Border.all(
              color: ZemenColors.primaryGoldDim,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Gold calendar icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ZemenColors.primaryGoldGlow,
                  borderRadius: ZemenRadius.smBR,
                  border: Border.all(color: ZemenColors.primaryGoldDim),
                ),
                child: const Center(
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: ZemenColors.primaryGold,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: ZemenSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ethLabel,
                            style: ZemenTextStyles.goldLabel(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ZemenColors.primaryGoldGlow,
                              borderRadius: ZemenRadius.fullBR,
                              border: Border.all(
                                  color: ZemenColors.primaryGoldDim),
                            ),
                            child: Text(
                              isAmharic ? 'ዛሬ' : 'Today',
                              style: ZemenTextStyles.goldLabel(fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          isAmharic ? 'የፈረንጆች ቀን፦ ' : 'Gregorian: ',
                          style: ZemenTextStyles.metadata(
                            color: ZemenColors.textTertiary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            gregLabel,
                            style: ZemenTextStyles.metadata(
                              color: ZemenColors.textSecondary,
                            ).copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {

  final bool isAmharic;
  final VoidCallback onToggle;

  const _LanguageToggle({required this.isAmharic, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: ZemenColors.surfaceElevated,
          borderRadius: ZemenRadius.fullBR,
          border: Border.all(color: ZemenColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Tab(label: 'አማ', active: isAmharic),
            const SizedBox(width: 2),
            _Tab(label: 'EN', active: !isAmharic),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;

  const _Tab({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? ZemenColors.primaryGold : Colors.transparent,
        borderRadius: ZemenRadius.fullBR,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? ZemenColors.background : ZemenColors.textSecondary,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ZemenColors.surfaceElevated,
          borderRadius: ZemenRadius.smBR,
          border: Border.all(color: ZemenColors.glassBorder),
        ),
        child: Icon(icon, color: ZemenColors.textSecondary, size: 18),
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: ZemenColors.surfaceElevated,
          borderRadius: ZemenRadius.smBR,
          border: Border.all(color: ZemenColors.glassBorder),
        ),
        child: Icon(icon, color: ZemenColors.textSecondary, size: 18),
      ),
    );
  }
}

class _TodayButton extends StatelessWidget {
  final bool isAmharic;
  final VoidCallback onTap;

  const _TodayButton({required this.isAmharic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: ZemenColors.primaryGoldGlow,
          borderRadius: ZemenRadius.fullBR,
          border: Border.all(color: ZemenColors.primaryGoldDim),
        ),
        child: Text(
          isAmharic ? 'ዛሬ' : 'Today',
          style: ZemenTextStyles.goldLabel(fontSize: 12),
        ),
      ),
    );
  }
}