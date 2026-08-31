import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/zemen_theme.dart';
import '../../features/calendar/domain/calendar_engine.dart';

/// ─── ZemenGlassCard ──────────────────────────────────────────────────────────
/// The core glassmorphic surface component.
/// All major UI surfaces are built on this widget.

class ZemenGlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color? glowColor;
  final double glowRadius;
  final double blurSigma;
  final double opacity;
  final Gradient? gradient;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;
  final bool animate;

  const ZemenGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(ZemenSpacing.md),
    this.borderRadius = ZemenRadius.lgBR,
    this.glowColor,
    this.glowRadius = 0,
    this.blurSigma = 35,
    this.opacity = 0.65,
    this.gradient,
    this.shadows,
    this.onTap,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: gradient == null ? const Color(0xFF1A1D26) : null,
            gradient: gradient,
            border: Border.all(color: const Color(0x28FFFFFF), width: 1),
            boxShadow: shadows ?? ZemenShadows.glassSurface,
          ),
          child: child,
        ),
      ),
    );

    if (glowColor != null && glowRadius > 0) {
      card = Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.40),
              blurRadius: glowRadius,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: glowColor!.withValues(alpha: 0.18),
              blurRadius: glowRadius * 2.5,
              spreadRadius: -8,
            ),
          ],
        ),
        child: card,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// ─── Hero Calendar Card ───────────────────────────────────────────────────────
/// The main floating card showing the current Ethiopian date.

class HeroCalendarCard extends StatefulWidget {
  final String ethiopianDateAmharic; // e.g. "የካቲት ፫"
  final String ethiopianDayAmharic; // e.g. "፫"
  final String monthNameAmharic; // e.g. "የካቲት"
  final String gregorianDate; // e.g. "March 11, 2025"
  final String weekdayAmharic; // e.g. "ሰኞ"
  final String weekdayEnglish; // e.g. "Monday"
  final String evangelistAmharic; // e.g. "ዓመተ ዮሐንስ"
  final String moonPhase; // e.g. "🌕 ሙሉ ጨረቃ"
  final String ethiopianTime; // e.g. "፭:30 ቀን"
  final String season; // e.g. "ፀደይ"
  final bool isAmharic;

  const HeroCalendarCard({
    super.key,
    required this.ethiopianDateAmharic,
    required this.ethiopianDayAmharic,
    required this.monthNameAmharic,
    required this.gregorianDate,
    required this.weekdayAmharic,
    required this.weekdayEnglish,
    required this.evangelistAmharic,
    required this.moonPhase,
    required this.ethiopianTime,
    required this.season,
    this.isAmharic = true,
  });

  @override
  State<HeroCalendarCard> createState() => _HeroCalendarCardState();
}

class _HeroCalendarCardState extends State<HeroCalendarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ZemenSpacing.md),
      decoration: BoxDecoration(
        borderRadius: ZemenRadius.xlBR,
        boxShadow: [
          ...ZemenShadows.cardFloat,
          ...ZemenShadows.goldGlow,
        ],
      ),
      child: ClipRRect(
        borderRadius: ZemenRadius.xlBR,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: ZemenRadius.xlBR,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.4, 0.8, 1.0],
                colors: [
                  Color(0xFF222A45),
                  Color(0xFF171C30),
                  Color(0xFF101520),
                  Color(0xFF0A0D16),
                ],
              ),
              border: Border.all(
                color: const Color(0x4DFFFFFF),
                width: 1.0,
              ),
            ),
            child: Stack(
              children: [
                // Ambient gold glow top-left — very large and bright
                Positioned(
                  top: -80,
                  left: -60,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, __) => Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            ZemenColors.primaryGold.withValues(
                                alpha: 0.28 * _pulseAnimation.value),
                            ZemenColors.primaryGold.withValues(
                                alpha: 0.08 * _pulseAnimation.value),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bold blue glow top-right
                Positioned(
                  top: -40,
                  right: -50,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (_, __) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            ZemenColors.feastBlue.withValues(
                                alpha: 0.20 * (1.4 - _pulseAnimation.value)),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Crimson glow bottom-right
                Positioned(
                  bottom: -50,
                  right: -30,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          ZemenColors.crimson.withValues(alpha: 0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(ZemenSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: Weekday + Gold accent line
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: ZemenColors.primaryGold,
                              borderRadius: ZemenRadius.fullBR,
                            ),
                          ),
                          const SizedBox(width: ZemenSpacing.sm),
                          Text(
                            widget.isAmharic
                                ? widget.weekdayAmharic
                                : widget.weekdayEnglish,
                            style: ZemenTextStyles.goldLabel(fontSize: 14),
                          ),
                          const Spacer(),
                          _MiniInfoPill(
                            icon: '🌙',
                            label: widget.moonPhase.split(' ').first +
                                (widget.moonPhase.contains(' ')
                                    ? ' ${widget.moonPhase.split(' ').skip(1).join(' ')}'
                                    : ''),
                          ),
                        ],
                      ),

                      const SizedBox(height: ZemenSpacing.md),

                      // Hero date: Large Ethiopian numeral
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.ethiopianDayAmharic,
                            style: ZemenTextStyles.heroAmharic(fontSize: 88)
                                .copyWith(color: ZemenColors.textPrimary),
                          ),
                          const SizedBox(width: ZemenSpacing.sm),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              widget.monthNameAmharic,
                              style: ZemenTextStyles.heroAmharic(fontSize: 28)
                                  .copyWith(color: ZemenColors.primaryGold),
                            ),
                          ),
                        ],
                      ),

                      // Gregorian equivalent
                      Text(
                        widget.gregorianDate,
                        style: ZemenTextStyles.metadata().copyWith(
                          color: ZemenColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: ZemenSpacing.md),

                      // Bottom row: Info pills
                      Row(
                        children: [
                          _InfoPill(
                            label: widget.evangelistAmharic,
                            color: ZemenColors.feastBlue,
                          ),
                          const SizedBox(width: ZemenSpacing.sm),
                          _InfoPill(
                            label: widget.season,
                            color: ZemenColors.success,
                          ),
                          const Spacer(),
                          _TimePill(time: widget.ethiopianTime),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: ZemenRadius.fullBR,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: ZemenTextStyles.metadata(amharic: true, color: color).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MiniInfoPill extends StatelessWidget {
  final String icon;
  final String label;

  const _MiniInfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ZemenColors.surface,
        borderRadius: ZemenRadius.fullBR,
        border: Border.all(color: ZemenColors.glassBorder),
      ),
      child: Text(
        label,
        style: ZemenTextStyles.metadata(amharic: true).copyWith(fontSize: 12),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String time;

  const _TimePill({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: ZemenColors.primaryGoldGlow,
        borderRadius: ZemenRadius.fullBR,
        border: Border.all(color: ZemenColors.primaryGoldDim),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⏱', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            time,
            style: ZemenTextStyles.metadata(
              amharic: true,
              color: ZemenColors.primaryGold,
            ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// ─── Month Calendar Grid ──────────────────────────────────────────────────────

class ZemenMonthGrid extends StatelessWidget {
  final int year;
  final int month;
  final EthiopianDateCallback? onDateTap;
  final int? selectedDay;
  final Set<int>? eventDays;
  final Set<int>? feastDays;
  final Set<int>? fastingDays;
  final bool isAmharic;

  const ZemenMonthGrid({
    super.key,
    required this.year,
    required this.month,
    this.onDateTap,
    this.selectedDay,
    this.eventDays,
    this.feastDays,
    this.fastingDays,
    this.isAmharic = true,
  });

  @override
  Widget build(BuildContext context) {
    // Weekday header labels: Amharic 1-char or English 1-char
    final weekdayLabels = isAmharic
        ? CalendarEngine.weekdayNamesAmharic
            .map((n) => n.substring(0, 1))
            .toList()
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Container(
      decoration: BoxDecoration(
        borderRadius: ZemenRadius.lgBR,
        boxShadow: [
          BoxShadow(
            color: ZemenColors.primaryGold.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: ZemenColors.primaryGold.withValues(alpha: 0.04),
            blurRadius: 80,
            spreadRadius: -8,
          ),
        ],
      ),
      child: ZemenGlassCard(
        padding: const EdgeInsets.all(ZemenSpacing.md),
        child: Column(
          children: [
            // Weekday headers
            Row(
              children: weekdayLabels
                  .map((label) => Expanded(
                        child: Center(
                          child: Text(
                            label,
                            style: ZemenTextStyles.metadata(
                              amharic: isAmharic,
                              color: ZemenColors.primaryGold,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: ZemenSpacing.sm),
            _buildGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final firstDay = CalendarEngine.ethiopianWeekday(
        EthiopianDate(year: year, month: month, day: 1));
    final daysInMonth = CalendarEngine.daysInEthiopianMonth(year, month);
    final totalCells = firstDay + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day = cellIndex - firstDay + 1;

              if (day < 1 || day > daysInMonth) {
                return const Expanded(child: SizedBox());
              }

              return Expanded(
                  child: _DayCell(
                day: day,
                year: year,
                month: month,
                isSelected: day == selectedDay,
                hasEvent: eventDays?.contains(day) ?? false,
                isFeast: feastDays?.contains(day) ?? false,
                isFasting: fastingDays?.contains(day) ?? false,
                isAmharic: isAmharic,
                onTap: () => onDateTap
                    ?.call(EthiopianDate(year: year, month: month, day: day)),
              ));
            }),
          ),
        );
      }),
    );
  }
}

typedef EthiopianDateCallback = void Function(EthiopianDate date);

class _DayCell extends StatelessWidget {
  final int day;
  final int year;
  final int month;
  final bool isSelected;
  final bool hasEvent;
  final bool isFeast;
  final bool isFasting;
  final bool isAmharic;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.year,
    required this.month,
    required this.isSelected,
    required this.hasEvent,
    required this.isFeast,
    required this.isFasting,
    required this.isAmharic,
    this.onTap,
  });

  bool get _isToday {
    final today = CalendarEngine.today();
    return today.year == year && today.month == month && today.day == day;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      letterSpacing: -0.2,
    ).copyWith(
      fontWeight: isSelected || _isToday ? FontWeight.w700 : FontWeight.w400,
      color: isSelected
          ? ZemenColors.background
          : _isToday
              ? ZemenColors.primaryGold
              : ZemenColors.textPrimary,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? ZemenColors.primaryGold
              : _isToday
                  ? ZemenColors.primaryGoldGlow
                  : Colors.transparent,
          border: _isToday && !isSelected
              ? Border.all(color: ZemenColors.primaryGold, width: 1.5)
              : null,
          boxShadow: isSelected ? ZemenShadows.goldGlow : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: textStyle,
            ),
            if (hasEvent || isFeast || isFasting)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isFeast) _dot(ZemenColors.primaryGold),
                  if (isFasting) _dot(ZemenColors.crimson),
                  if (hasEvent) _dot(ZemenColors.feastBlue),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
}

/// ─── Fasting Status Card ──────────────────────────────────────────────────────

class ZemenFastingCard extends StatelessWidget {
  final String fastingName;
  final String fastingNameAmharic;
  final bool isFasting;
  final bool morningStatus;
  final bool eveningStatus;
  final int daysRemaining;
  final String nextFastName;
  final bool isAmharic;

  const ZemenFastingCard({
    super.key,
    required this.fastingName,
    required this.fastingNameAmharic,
    required this.isFasting,
    required this.morningStatus,
    required this.eveningStatus,
    required this.daysRemaining,
    required this.nextFastName,
    this.isAmharic = true,
  });

  @override
  Widget build(BuildContext context) {
    return ZemenGlassCard(
      glowColor: isFasting ? ZemenColors.crimson : null,
      glowRadius: 40,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isFasting ? ZemenColors.crimson : ZemenColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isFasting
                              ? ZemenColors.crimson
                              : ZemenColors.success)
                          .withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isFasting
                    ? (isAmharic ? 'ዛሬ ጾም ነው' : 'Fasting Today')
                    : (isAmharic ? 'ዛሬ ጾም አይደለም' : 'Not Fasting'),
                style: ZemenTextStyles.goldLabel(fontSize: 12).copyWith(
                  color: isFasting ? ZemenColors.crimson : ZemenColors.success,
                ),
              ),
              const Spacer(),
              if (isFasting)
                Text(
                  isAmharic
                      ? '$daysRemaining ቀን ቀሩ'
                      : '$daysRemaining days left',
                  style: ZemenTextStyles.metadata(
                      color: ZemenColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: ZemenSpacing.sm),
          Text(
            isAmharic ? fastingNameAmharic : fastingName,
            style: ZemenTextStyles.sectionHeader(
              amharic: isAmharic,
              color: isFasting ? ZemenColors.crimson : ZemenColors.textPrimary,
            ),
          ),
          if (isFasting) ...[
            const SizedBox(height: ZemenSpacing.sm),
            Row(
              children: [
                _FastStatus(
                  label: isAmharic ? 'ጥዋት' : 'Morning',
                  active: morningStatus,
                ),
                const SizedBox(width: ZemenSpacing.sm),
                _FastStatus(
                  label: isAmharic ? 'ምሽት' : 'Evening',
                  active: eveningStatus,
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: ZemenSpacing.xs),
            Text(
              isAmharic ? 'ቀጣይ ጾም: $nextFastName' : 'Next fast: $nextFastName',
              style: ZemenTextStyles.metadata(amharic: isAmharic),
            ),
          ],
        ],
      ),
    );
  }
}

class _FastStatus extends StatelessWidget {
  final String label;
  final bool active;

  const _FastStatus({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? ZemenColors.crimsonDim : ZemenColors.surfaceElevated,
        borderRadius: ZemenRadius.smBR,
        border: Border.all(
          color: active ? ZemenColors.crimson : ZemenColors.glassBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14,
            color: active ? ZemenColors.crimson : ZemenColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: ZemenTextStyles.metadata(
              color: active ? ZemenColors.crimson : ZemenColors.textSecondary,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// ─── Holiday Card ─────────────────────────────────────────────────────────────

class ZemenHolidayCard extends StatelessWidget {
  final String name;
  final String nameAmharic;
  final String daysUntil;
  final String description;
  final String importanceIndicator;
  final Color accentColor;
  final bool isAmharic;

  const ZemenHolidayCard({
    super.key,
    required this.name,
    required this.nameAmharic,
    required this.daysUntil,
    required this.description,
    required this.importanceIndicator,
    this.accentColor = ZemenColors.primaryGold,
    this.isAmharic = true,
  });

  @override
  Widget build(BuildContext context) {
    return ZemenGlassCard(
      padding: const EdgeInsets.all(ZemenSpacing.md),
      child: Row(
        children: [
          // Left accent line
          Container(
            width: 3,
            height: 60,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: ZemenRadius.fullBR,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: ZemenSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAmharic ? nameAmharic : name,
                  style: ZemenTextStyles.bodyMedium(amharic: isAmharic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: ZemenTextStyles.metadata(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: ZemenSpacing.md),

          // Countdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                importanceIndicator,
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                daysUntil,
                style: ZemenTextStyles.metadata(color: accentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ─── Timeline Item ────────────────────────────────────────────────────────────

class ZemenTimelineItem extends StatelessWidget {
  final String title;
  final String titleAmharic;
  final String subtitle;
  final String date;
  final String emoji;
  final Color dotColor;
  final bool isFirst;
  final bool isLast;
  final bool isAmharic;
  final VoidCallback? onTap;

  const ZemenTimelineItem({
    super.key,
    required this.title,
    required this.titleAmharic,
    required this.subtitle,
    required this.date,
    required this.emoji,
    this.dotColor = ZemenColors.primaryGold,
    this.isFirst = false,
    this.isLast = false,
    this.isAmharic = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: ZemenColors.glassBorder,
                    ),
                  ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: ZemenColors.glassBorder,
                    ),
                  ),
              ],
            ),
          ),

          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                left: ZemenSpacing.sm,
                bottom: ZemenSpacing.sm,
              ),
              child: ZemenGlassCard(
                onTap: onTap,
                padding: const EdgeInsets.all(ZemenSpacing.md),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: ZemenSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAmharic ? titleAmharic : title,
                            style:
                                ZemenTextStyles.bodyMedium(amharic: isAmharic),
                          ),
                          Text(
                            subtitle,
                            style: ZemenTextStyles.metadata(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      date,
                      style: ZemenTextStyles.metadata(
                          color: ZemenColors.primaryGold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
