import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/zemen_theme.dart';
import '../../../../shared/widgets/glass_components.dart';
import '../../calendar/presentation/providers/calendar_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: ZemenColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(ZemenSpacing.md),
                child: Row(
                  children: [
                    Text(
                      isAmharic ? 'ቅንብሮች' : 'Settings',
                      style: ZemenTextStyles.pageHeader(amharic: isAmharic),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: ZemenSpacing.md),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Language ─────────────────────────────────────────
                  _SettingsSection(
                    title: isAmharic ? 'ቋንቋ' : 'Language',
                    children: [
                      _LanguageSelector(isAmharic: isAmharic, ref: ref),
                    ],
                  ),

                  const SizedBox(height: ZemenSpacing.md),

                  // ── Calendar ─────────────────────────────────────────
                  _SettingsSection(
                    title: isAmharic ? 'ቀን አቆጣጠር' : 'Calendar',
                    children: [
                      _ToggleRow(
                        title: isAmharic ? 'ጎርጎሪያን ቀን አሳይ' : 'Show Gregorian Date',
                        subtitle: isAmharic
                            ? 'ሁለቱንም ቀን አቆጣጠሮች አሳይ'
                            : 'Display both calendar systems',
                        value: settings.showGregorianDates,
                        onChanged: (_) => ref
                            .read(settingsProvider.notifier)
                            .toggle('showGregorianDates'),
                      ),
                      _ToggleRow(
                        title: isAmharic ? 'ጨረቃ አሳይ' : 'Show Moon Phase',
                        subtitle: isAmharic
                            ? 'ጨረቃ ሁኔታ አሳይ'
                            : 'Display current moon phase',
                        value: settings.showMoonPhase,
                        onChanged: (_) => ref
                            .read(settingsProvider.notifier)
                            .toggle('showMoonPhase'),
                      ),
                      _ToggleRow(
                        title: isAmharic ? 'የኢትዮጵያ ሰዓት' : 'Ethiopian Time',
                        subtitle: isAmharic
                            ? 'የኢትዮጵያ ሰዓት ቆጠራ ስርዓት'
                            : 'Use Ethiopian time system',
                        value: settings.showEthiopianTime,
                        onChanged: (_) => ref
                            .read(settingsProvider.notifier)
                            .toggle('showEthiopianTime'),
                      ),
                    ],
                  ),

                  const SizedBox(height: ZemenSpacing.md),

                  // ── Notifications ─────────────────────────────────────
                  _SettingsSection(
                    title: isAmharic ? 'ማሳወቂያዎች' : 'Notifications',
                    children: [
                      _ToggleRow(
                        title: isAmharic ? 'ክብረ-በዓሎች' : 'Feast Reminders',
                        subtitle: isAmharic
                            ? 'ሰኞ ዕለት ለሚሆኑ ክብረ-በዓሎች አስታውስ'
                            : 'Remind me of upcoming feasts',
                        value: settings.enableFeastReminders,
                        onChanged: (_) => ref
                            .read(settingsProvider.notifier)
                            .toggle('enableFeastReminders'),
                        accentColor: ZemenColors.primaryGold,
                      ),
                      _ToggleRow(
                        title: isAmharic ? 'ጾም ማሳወቂያ' : 'Fasting Reminders',
                        subtitle: isAmharic
                            ? 'ጾም ሲጀምር አሳውቅ'
                            : 'Notify at fasting start',
                        value: settings.enableFastingReminders,
                        onChanged: (_) => ref
                            .read(settingsProvider.notifier)
                            .toggle('enableFastingReminders'),
                        accentColor: ZemenColors.crimson,
                      ),
                      _ToggleRow(
                        title: isAmharic ? 'ዕለታዊ ቅዱሳን' : 'Daily Saints',
                        subtitle: isAmharic
                            ? 'ዕለቱ ቅዱስ ነቢዩ አሳውቅ'
                            : 'Daily saint notification',
                        value: settings.enableDailySaint,
                        onChanged: (_) => ref
                            .read(settingsProvider.notifier)
                            .toggle('enableDailySaint'),
                      ),
                    ],
                  ),

                  const SizedBox(height: ZemenSpacing.md),

                  // ── About ─────────────────────────────────────────────
                  _SettingsSection(
                    title: isAmharic ? 'ስለ' : 'About',
                    children: [
                      _InfoRow(
                        title: isAmharic ? 'ስሪት' : 'Version',
                        value: '1.0.0',
                      ),
                      _InfoRow(
                        title: isAmharic ? 'ቋንቋ' : 'Framework',
                        value: 'Flutter 3.19',
                      ),
                      _ActionRow(
                        title: isAmharic ? 'ግምገማ ይስጡ' : 'Rate the App',
                        icon: Icons.star_rounded,
                        color: ZemenColors.primaryGold,
                        onTap: () {},
                      ),
                      _ActionRow(
                        title: isAmharic ? 'ፕራይቬሲ' : 'Privacy Policy',
                        icon: Icons.shield_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: ZemenSpacing.xl),

                  // Footer brand
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'ዘመን Calendar',
                          style: ZemenTextStyles.body(amharic: true).copyWith(
                            color: ZemenColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Made with ❤️‍🩹MK for Ethiopia',
                          style: ZemenTextStyles.metadata(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: ZemenSpacing.xxxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: ZemenSpacing.xs, bottom: ZemenSpacing.sm),
          child: Text(
            title.toUpperCase(),
            style: ZemenTextStyles.caption(color: ZemenColors.textTertiary)
                .copyWith(letterSpacing: 1.5),
          ),
        ),
        ZemenGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: children.asMap().entries.map((entry) {
              final i = entry.key;
              final w = entry.value;
              return Column(
                children: [
                  w,
                  if (i < children.length - 1)
                    const Divider(
                      height: 1,
                      color: ZemenColors.divider,
                      indent: ZemenSpacing.md,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accentColor;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.accentColor = ZemenColors.primaryGold,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ZemenSpacing.md, vertical: ZemenSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ZemenTextStyles.bodyMedium()),
                const SizedBox(height: 2),
                Text(subtitle, style: ZemenTextStyles.metadata()),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.3),
            inactiveThumbColor: ZemenColors.textTertiary,
            inactiveTrackColor: ZemenColors.surfaceElevated,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: ZemenSpacing.md, vertical: ZemenSpacing.md),
      child: Row(
        children: [
          Text(title, style: ZemenTextStyles.bodyMedium()),
          const Spacer(),
          Text(value, style: ZemenTextStyles.metadata()),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionRow({
    required this.title,
    required this.icon,
    this.color = ZemenColors.textSecondary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: ZemenSpacing.md, vertical: ZemenSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: ZemenSpacing.sm),
            Text(title, style: ZemenTextStyles.bodyMedium(color: color)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: ZemenColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final bool isAmharic;
  final WidgetRef ref;

  const _LanguageSelector({required this.isAmharic, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ZemenSpacing.md),
      child: Row(
        children: [
          _LangOption(
            label: 'አማርኛ',
            sublabel: 'Amharic',
            selected: isAmharic,
            onTap: () =>
                ref.read(isAmharicProvider.notifier).state = true,
          ),
          const SizedBox(width: ZemenSpacing.sm),
          _LangOption(
            label: 'English',
            sublabel: 'English',
            selected: !isAmharic,
            onTap: () =>
                ref.read(isAmharicProvider.notifier).state = false,
          ),
        ],
      ),
    );
  }
}

class _LangOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  const _LangOption({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(ZemenSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? ZemenColors.primaryGoldGlow
                : ZemenColors.surfaceElevated,
            borderRadius: ZemenRadius.mdBR,
            border: Border.all(
              color: selected
                  ? ZemenColors.primaryGoldDim
                  : ZemenColors.glassBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: ZemenTextStyles.bodyMedium(
                  color: selected
                      ? ZemenColors.primaryGold
                      : ZemenColors.textPrimary,
                ),
              ),
              Text(
                sublabel,
                style: ZemenTextStyles.metadata(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}