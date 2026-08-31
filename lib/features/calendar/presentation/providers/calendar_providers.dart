import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/calendar_engine.dart';
import '../../domain/bahire_hasab_engine.dart';
import '../../../holidays/domain/holiday_engine.dart';

// ─── Current Date State ───────────────────────────────────────────────────────

class CalendarState {
  final EthiopianDate today;
  final EthiopianDate selectedDate;
  final int viewYear;
  final int viewMonth;
  final DateTime now;

  const CalendarState({
    required this.today,
    required this.selectedDate,
    required this.viewYear,
    required this.viewMonth,
    required this.now,
  });

  CalendarState copyWith({
    EthiopianDate? today,
    EthiopianDate? selectedDate,
    int? viewYear,
    int? viewMonth,
    DateTime? now,
  }) =>
      CalendarState(
        today: today ?? this.today,
        selectedDate: selectedDate ?? this.selectedDate,
        viewYear: viewYear ?? this.viewYear,
        viewMonth: viewMonth ?? this.viewMonth,
        now: now ?? this.now,
      );
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier()
      : super(_buildInitialState()) {
    // Refresh every minute for time display
    Future.doWhile(() async {
      await Future.delayed(const Duration(minutes: 1));
      if (!mounted) return false;
      state = state.copyWith(now: DateTime.now());
      return true;
    });
  }

  static CalendarState _buildInitialState() {
    final now = DateTime.now();
    final today = CalendarEngine.fromGregorian(now);
    return CalendarState(
      today: today,
      selectedDate: today,
      viewYear: today.year,
      viewMonth: today.month,
      now: now,
    );
  }

  void selectDate(EthiopianDate date) {
    state = state.copyWith(
      selectedDate: date,
      viewYear: date.year,
      viewMonth: date.month,
    );
  }

  void goToToday() {
    final today = CalendarEngine.today();
    state = state.copyWith(
      selectedDate: today,
      viewYear: today.year,
      viewMonth: today.month,
    );
  }

  void navigateMonth(int delta) {
    int newMonth = state.viewMonth + delta;
    int newYear = state.viewYear;

    while (newMonth > 13) {
      newMonth -= 13;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 13;
      newYear--;
    }

    state = state.copyWith(viewYear: newYear, viewMonth: newMonth);
  }

  void navigateToMonth(int year, int month) {
    state = state.copyWith(viewYear: year, viewMonth: month);
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});

// ─── Movable Feasts ───────────────────────────────────────────────────────────

final movableFeastsProvider = Provider.family<List<MovableFeast>, int>((ref, year) {
  return BahireHasabEngine.getMovableFeasts(year);
});

final fastingPeriodsProvider =
    Provider.family<List<FastingPeriod>, int>((ref, year) {
  return BahireHasabEngine.getFastingPeriods(year);
});

// ─── Today's Status Providers ─────────────────────────────────────────────────

final todayEthiopianProvider = Provider<EthiopianDate>((ref) {
  return ref.watch(calendarProvider).today;
});

final selectedDateProvider = Provider<EthiopianDate>((ref) {
  return ref.watch(calendarProvider).selectedDate;
});

final todayGregorianProvider = Provider<DateTime>((ref) {
  return ref.watch(calendarProvider).now;
});

final currentMoonPhaseProvider = Provider<double>((ref) {
  final now = ref.watch(todayGregorianProvider);
  return CalendarEngine.moonPhase(now);
});

final currentMoonPhaseNameProvider = Provider.family<String, bool>((ref, amharic) {
  final phase = ref.watch(currentMoonPhaseProvider);
  return CalendarEngine.moonPhaseName(phase, amharic: amharic);
});

final currentSeasonProvider = Provider.family<String, bool>((ref, amharic) {
  final today = ref.watch(todayEthiopianProvider);
  return CalendarEngine.currentSeason(today, amharic: amharic);
});

final evangelistProvider = Provider.family<String, bool>((ref, amharic) {
  final today = ref.watch(todayEthiopianProvider);
  return CalendarEngine.evangelistForYear(today.year, amharic: amharic);
});

final ethiopianTimeProvider = Provider.family<String, bool>((ref, amharic) {
  final now = ref.watch(todayGregorianProvider);
  return CalendarEngine.toEthiopianTime(now, amharic: amharic);
});

// ─── Selected date holidays/feasts ───────────────────────────────────────────

final selectedDateHolidaysProvider =
    Provider<List<Holiday>>((ref) {
  final selected = ref.watch(selectedDateProvider);
  return HolidayEngine.getHolidaysForDate(selected);
});

final selectedDateFeastProvider =
    Provider<MovableFeast?>((ref) {
  final selected = ref.watch(selectedDateProvider);
  final feasts = ref.watch(movableFeastsProvider(selected.year));
  try {
    return feasts.firstWhere((f) =>
        f.date.year == selected.year &&
        f.date.month == selected.month &&
        f.date.day == selected.day);
  } catch (_) {
    return null;
  }
});

final currentFastingPeriodProvider = Provider<FastingPeriod?>((ref) {
  final today = ref.watch(todayEthiopianProvider);
  final periods = ref.watch(fastingPeriodsProvider(today.year));
  return BahireHasabEngine.getFastingPeriodForDate(today, periods);
});

final isWeeklyFastDayProvider = Provider<bool>((ref) {
  final today = ref.watch(todayEthiopianProvider);
  return BahireHasabEngine.isWeeklyFastDay(today);
});

// ─── Feast days for current month (for calendar dots) ───────────────────────

final feastDaysForMonthProvider =
    Provider.family<Set<int>, (int year, int month)>((ref, args) {
  final (year, month) = args;
  final feasts = ref.watch(movableFeastsProvider(year));
  final fixedHolidays = HolidayEngine.getHolidaysForMonth(month);

  final days = <int>{};
  for (final f in feasts) {
    if (f.date.year == year && f.date.month == month) {
      days.add(f.date.day);
    }
  }
  for (final h in fixedHolidays) {
    days.add(h.day);
  }
  return days;
});

final fastingDaysForMonthProvider =
    Provider.family<Set<int>, (int year, int month)>((ref, args) {
  final (year, month) = args;
  final periods = ref.watch(fastingPeriodsProvider(year));
  final days = <int>{};

  for (final period in periods) {
    final startJdn = period.start.toJdn();
    final endJdn = period.end.toJdn();

    for (var jdn = startJdn; jdn <= endJdn; jdn++) {
      final d = CalendarEngine.jdnToEthiopian(jdn);
      if (d.year == year && d.month == month) {
        days.add(d.day);
      }
    }
  }

  return days;
});

// ─── Upcoming Holidays ────────────────────────────────────────────────────────

final upcomingHolidaysProvider =
    Provider<List<({Holiday holiday, EthiopianDate date})>>((ref) {
  final today = ref.watch(todayEthiopianProvider);
  return HolidayEngine.getUpcomingHolidays(today, count: 5);
});

// ─── Language / Locale State ──────────────────────────────────────────────────

final isAmharicProvider = StateProvider<bool>((ref) => true);

// ─── Settings State ───────────────────────────────────────────────────────────

class AppSettings {
  final bool showGregorianDates;
  final bool showMoonPhase;
  final bool showEthiopianTime;
  final bool enableFeastReminders;
  final bool enableFastingReminders;
  final bool enableDailySaint;
  final int reminderAdvanceDays;

  const AppSettings({
    this.showGregorianDates = true,
    this.showMoonPhase = true,
    this.showEthiopianTime = true,
    this.enableFeastReminders = true,
    this.enableFastingReminders = true,
    this.enableDailySaint = false,
    this.reminderAdvanceDays = 1,
  });

  AppSettings copyWith({
    bool? showGregorianDates,
    bool? showMoonPhase,
    bool? showEthiopianTime,
    bool? enableFeastReminders,
    bool? enableFastingReminders,
    bool? enableDailySaint,
    int? reminderAdvanceDays,
  }) =>
      AppSettings(
        showGregorianDates: showGregorianDates ?? this.showGregorianDates,
        showMoonPhase: showMoonPhase ?? this.showMoonPhase,
        showEthiopianTime: showEthiopianTime ?? this.showEthiopianTime,
        enableFeastReminders: enableFeastReminders ?? this.enableFeastReminders,
        enableFastingReminders:
            enableFastingReminders ?? this.enableFastingReminders,
        enableDailySaint: enableDailySaint ?? this.enableDailySaint,
        reminderAdvanceDays: reminderAdvanceDays ?? this.reminderAdvanceDays,
      );
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void toggle(String key) {
    state = switch (key) {
      'showGregorianDates' =>
        state.copyWith(showGregorianDates: !state.showGregorianDates),
      'showMoonPhase' => state.copyWith(showMoonPhase: !state.showMoonPhase),
      'showEthiopianTime' =>
        state.copyWith(showEthiopianTime: !state.showEthiopianTime),
      'enableFeastReminders' =>
        state.copyWith(enableFeastReminders: !state.enableFeastReminders),
      'enableFastingReminders' =>
        state.copyWith(enableFastingReminders: !state.enableFastingReminders),
      'enableDailySaint' =>
        state.copyWith(enableDailySaint: !state.enableDailySaint),
      _ => state,
    };
  }
}