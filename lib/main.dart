import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'core/theme/zemen_theme.dart';
import 'core/database/zemen_database.dart';
import 'core/database/zemen_hive_store.dart';
import 'features/calendar/presentation/screens/home_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/reminders/presentation/screens/reminders_screen.dart';
import 'features/calendar/presentation/providers/calendar_providers.dart';
import 'features/notifications/domain/notification_engine.dart';
import 'features/calendar/domain/calendar_engine.dart';
import 'features/calendar/domain/bahire_hasab_engine.dart';
import 'features/reminders/domain/entities/reminder.dart';
import 'features/reminders/presentation/providers/reminder_providers.dart';
import 'features/holidays/domain/holiday_engine.dart';

// ─── main ─────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ZemenHiveStore.instance.init();
  await ZemenDatabase.instance.database;
  await NotificationEngine.instance.init();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: ZemenColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: ZemenApp()));
}

// ─── Router — 3 tabs only, no /search route ───────────────────────────────────

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => ZemenShell(child: child),
      routes: [
        GoRoute(path: '/',         name: 'home',      builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/reminders',name: 'reminders', builder: (_, __) => const RemindersScreen()),
        GoRoute(path: '/settings', name: 'settings',  builder: (_, __) => const SettingsScreen()),
      ],
    ),
  ],
);

// ─── App Root ─────────────────────────────────────────────────────────────────

class ZemenApp extends ConsumerWidget {
  const ZemenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Zemen Calendar',
      debugShowCheckedModeBanner: false,
      theme: buildZemenTheme(),
      darkTheme: buildZemenTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('am')],
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.noScaling),
        child: child!,
      ),
    );
  }
}

// ─── Shell — 3-tab bottom nav ─────────────────────────────────────────────────

class ZemenShell extends ConsumerWidget {
  final Widget child;
  const ZemenShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final location = GoRouterState.of(context).uri.path;

    const navDefs = [
      (icon: Icons.calendar_today_rounded, labelAm: 'ቤት',    labelEn: 'Home',      path: '/'),
      (icon: Icons.notifications_none_rounded, labelAm: 'ማሳወሻ', labelEn: 'Reminders', path: '/reminders'),
      (icon: Icons.tune_rounded, labelAm: 'ቅንብሮች', labelEn: 'Settings',  path: '/settings'),
    ];

    int selectedIndex = 0;
    for (int i = 0; i < navDefs.length; i++) {
      final p = navDefs[i].path;
      if (p == '/' ? location == '/' : location.startsWith(p)) {
        selectedIndex = i;
        break;
      }
    }

    return Scaffold(
      backgroundColor: ZemenColors.background,
      body: child,
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xCC13151F),
              border: Border(top: BorderSide(color: ZemenColors.glassBorder)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: navDefs.asMap().entries.map((entry) {
                    final i = entry.key;
                    final nav = entry.value;
                    final selected = i == selectedIndex;
                    final label = isAmharic ? nav.labelAm : nav.labelEn;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.go(nav.path),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected
                                    ? ZemenColors.primaryGoldGlow
                                    : Colors.transparent,
                                borderRadius: ZemenRadius.fullBR,
                              ),
                              child: Icon(
                                nav.icon,
                                color: selected
                                    ? ZemenColors.primaryGold
                                    : ZemenColors.textTertiary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: ZemenTextStyles.caption(
                                color: selected
                                    ? ZemenColors.primaryGold
                                    : ZemenColors.textTertiary,
                              ),
                              child: Text(label),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Search Button (place in any AppBar actions[]) ───────────────────────────
// Import and use ZemenSearchButton wherever you need it.

class ZemenSearchButton extends StatelessWidget {
  const ZemenSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSearchOverlay(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ZemenColors.surfaceElevated,
          borderRadius: ZemenRadius.smBR,
          border: Border.all(color: ZemenColors.glassBorder),
        ),
        child: const Icon(Icons.search_rounded,
            color: ZemenColors.textSecondary, size: 18),
      ),
    );
  }

  static void _openSearchOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Search',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (_, __, ___) => const _SearchOverlay(),
      transitionBuilder: (ctx, anim, _, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }
}

// ─── Search Overlay ───────────────────────────────────────────────────────────

class _SearchOverlay extends ConsumerStatefulWidget {
  const _SearchOverlay();

  @override
  ConsumerState<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<_SearchOverlay> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
    _controller.addListener(
        () => setState(() => _query = _controller.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ── Search logic ────────────────────────────────────────────────────────

  List<_SearchResult> get _results {
    if (_query.isEmpty) return [];
    final out = <_SearchResult>[];

    // ── 1. Fixed holidays & saints ────────────────────────────────────────
    for (final h in HolidayEngine.fixedHolidays) {
      final matchEn = h.nameEnglish.toLowerCase().contains(_query);
      final matchAm = h.nameAmharic.contains(_query);
      final matchDesc = h.descriptionEnglish?.toLowerCase().contains(_query) ?? false;
      if (matchEn || matchAm || matchDesc) {
        out.add(_SearchResult(
          titleEn: h.nameEnglish,
          titleAm: h.nameAmharic,
          subtitle: h.descriptionEnglish ?? '',
          emoji: _emoji(h.category),
          type: _RT.holiday,
          tag: _tagForCategory(h.category),
        ));
      }
    }

    // ── 2. Movable feasts (current + next Ethiopian year) ─────────────────
    final today = CalendarEngine.today();
    for (final yr in [today.year, today.year + 1]) {
      for (final f in BahireHasabEngine.getMovableFeasts(yr)) {
        final matchEn = f.nameEnglish.toLowerCase().contains(_query);
        final matchAm = f.nameAmharic.contains(_query);
        final matchDesc = f.descriptionEnglish?.toLowerCase().contains(_query) ?? false;
        if (matchEn || matchAm || matchDesc) {
          final greg = CalendarEngine.toGregorian(f.date);
          final dateStr = '${_monthName(greg.month)} ${greg.day}, ${greg.year}';
          out.add(_SearchResult(
            titleEn: f.nameEnglish,
            titleAm: f.nameAmharic,
            subtitle: dateStr,
            emoji: '✨',
            type: _RT.feast,
            tag: 'Feast',
          ));
        }
      }
    }

    // ── 3. Fasting periods ────────────────────────────────────────────────
    for (final yr in [today.year, today.year + 1]) {
      for (final p in BahireHasabEngine.getFastingPeriods(yr)) {
        final matchEn = p.nameEnglish.toLowerCase().contains(_query);
        final matchAm = p.nameAmharic.contains(_query);
        final matchDesc = p.descriptionAmharic?.contains(_query) ?? false;
        if (matchEn || matchAm || matchDesc) {
          out.add(_SearchResult(
            titleEn: p.nameEnglish,
            titleAm: p.nameAmharic,
            subtitle: '${p.durationDays} days',
            emoji: '🕊',
            type: _RT.fasting,
            tag: 'Fasting',
          ));
        }
      }
    }

    // ── 4. User reminders (from Riverpod state — already loaded) ──────────
    final reminders = ref.read(remindersProvider).valueOrNull ?? [];
    for (final r in reminders) {
      final matchEn = r.title.toLowerCase().contains(_query);
      final matchAm = r.titleAmharic?.contains(_query) ?? false;
      final matchNotes = r.notes?.toLowerCase().contains(_query) ?? false;
      if (matchEn || matchAm || matchNotes) {
        out.add(_SearchResult(
          titleEn: r.title,
          titleAm: r.titleAmharic ?? r.title,
          subtitle: RecurrenceEngine.describeRecurrence(r, amharic: false),
          emoji: '🔔',
          type: _RT.reminder,
          tag: 'Reminder',
        ));
      }
    }

    // De-duplicate by titleEn
    final seen = <String>{};
    final deduped = out.where((r) => seen.add(r.titleEn)).toList();

    return deduped.take(30).toList();
  }

  static String _tagForCategory(HolidayCategory c) => switch (c) {
    HolidayCategory.orthodoxFeast => 'Feast',
    HolidayCategory.marianFeast => 'Mary',
    HolidayCategory.nationalHoliday => 'Holiday',
    HolidayCategory.saintCommemoration => 'Saint',
    HolidayCategory.historicalEvent => 'History',
  };

  static String _emoji(HolidayCategory c) => switch (c) {
    HolidayCategory.orthodoxFeast => '✨',
    HolidayCategory.marianFeast => '🌸',
    HolidayCategory.nationalHoliday => '🇪🇹',
    HolidayCategory.saintCommemoration => '🕊',
    HolidayCategory.historicalEvent => '📜',
  };

  static String _monthName(int m) => const [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ][m - 1];

  @override
  Widget build(BuildContext context) {
    final isAmharic = ref.watch(isAmharicProvider);
    final results = _results;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ClipRRect(
                borderRadius: ZemenRadius.lgBR,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xF01A1D26),
                      borderRadius: ZemenRadius.lgBR,
                      border: Border.all(
                          color: ZemenColors.glassBorderBright),
                      boxShadow: ZemenShadows.goldGlow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded,
                            color: ZemenColors.primaryGold, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            style: ZemenTextStyles.body(),
                            cursorColor: ZemenColors.primaryGold,
                            decoration: InputDecoration(
                              hintText: isAmharic
                                  ? 'ቅዱሳን፣ በዓሎች፣ ጾም ይፈልጉ…'
                                  : 'Search saints, feasts, fasting…',
                              hintStyle: ZemenTextStyles.body(
                                  color: ZemenColors.textTertiary),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.close_rounded,
                                  color: ZemenColors.textTertiary, size: 18),
                            ),
                          ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            isAmharic ? 'ይቅር' : 'Cancel',
                            style: ZemenTextStyles.goldLabel(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().slideY(
                begin: -0.3, end: 0,
                duration: 280.ms, curve: Curves.easeOutCubic),

            // ── Results ─────────────────────────────────────────────
            Expanded(
              child: _query.isEmpty
                  ? _SearchHints(isAmharic: isAmharic)
                  : results.isEmpty
                      ? _NoResults(query: _query, isAmharic: isAmharic)
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (ctx, i) {
                            return _ResultCard(
                              result: results[i],
                              isAmharic: isAmharic,
                              onTap: () => Navigator.of(context).pop(),
                            ).animate().fadeIn(
                                delay: (i * 25).ms, duration: 180.ms);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search result model ──────────────────────────────────────────────────────

enum _RT { holiday, feast, fasting, reminder }

class _SearchResult {
  final String titleEn;
  final String titleAm;
  final String subtitle;
  final String emoji;
  final _RT type;
  final String tag;
  const _SearchResult({
    required this.titleEn,
    required this.titleAm,
    required this.subtitle,
    required this.emoji,
    required this.type,
    this.tag = '',
  });
}

// ─── Result card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final _SearchResult result;
  final bool isAmharic;
  final VoidCallback onTap;
  const _ResultCard(
      {required this.result, required this.isAmharic, required this.onTap});

  Color get _tagColor => switch (result.type) {
    _RT.holiday => ZemenColors.primaryGold,
    _RT.feast => ZemenColors.feastBlue,
    _RT.fasting => ZemenColors.crimson,
    _RT.reminder => ZemenColors.success,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: ZemenRadius.mdBR,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xE61A1D26),
              borderRadius: ZemenRadius.mdBR,
              border: Border.all(color: ZemenColors.glassBorderBright),
            ),
            child: Row(
              children: [
                Text(result.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAmharic ? result.titleAm : result.titleEn,
                        style: ZemenTextStyles.bodyMedium(amharic: isAmharic),
                      ),
                      if (result.subtitle.isNotEmpty)
                        Text(result.subtitle,
                            style: ZemenTextStyles.metadata(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (result.tag.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _tagColor.withValues(alpha: 0.12),
                      borderRadius: ZemenRadius.fullBR,
                      border: Border.all(color: _tagColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      result.tag,
                      style: ZemenTextStyles.caption(color: _tagColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty / no-results states ────────────────────────────────────────────────

class _SearchHints extends StatelessWidget {
  final bool isAmharic;
  const _SearchHints({required this.isAmharic});

  @override
  Widget build(BuildContext context) {
    final chips = isAmharic
        ? ['ፋሲካ', 'ጥምቀት', 'መስቀል', 'ዐቢይ ጾም', 'ሚካኤል', 'ገና']
        : ['Easter', 'Timket', 'Meskel', 'Great Lent', 'Michael', 'Genna'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAmharic ? 'ፈጣን ፍለጋ' : 'Quick search',
            style: ZemenTextStyles.caption(color: ZemenColors.textTertiary)
                .copyWith(letterSpacing: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map((c) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: ZemenColors.surfaceElevated,
                        borderRadius: ZemenRadius.fullBR,
                        border: Border.all(color: ZemenColors.glassBorder),
                      ),
                      child: Text(c, style: ZemenTextStyles.metadata()),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  final bool isAmharic;
  const _NoResults({required this.query, required this.isAmharic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(
            isAmharic ? 'ምንም አልተገኘም' : 'No results found',
            style: ZemenTextStyles.sectionHeader(amharic: isAmharic),
          ),
          const SizedBox(height: 6),
          Text('"$query"',
              style: ZemenTextStyles.metadata(
                  color: ZemenColors.textTertiary)),
        ],
      ),
    );
  }
}