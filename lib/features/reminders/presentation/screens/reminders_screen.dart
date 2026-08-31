import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/zemen_theme.dart';
import '../../../calendar/presentation/providers/calendar_providers.dart';
import '../providers/reminder_providers.dart';
import '../widgets/reminder_card.dart';
import 'reminder_edit_screen.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmharic = ref.watch(isAmharicProvider);
    final remindersAsync = ref.watch(remindersProvider);

    return Scaffold(
      backgroundColor: ZemenColors.background,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -100,
            right: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ZemenColors.primaryGold.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: remindersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: ZemenColors.primaryGold),
              ),
              error: (err, st) => Center(
                child: Text(
                  isAmharic ? 'ስህተት ተከስቷል' : 'Something went wrong',
                  style: ZemenTextStyles.body(color: ZemenColors.textSecondary),
                ),
              ),
              data: (reminders) {
                if (reminders.isEmpty) {
                  return _EmptyState(isAmharic: isAmharic);
                }

                // Sort: active first, then by next occurrence
                final sorted = [...reminders]..sort((a, b) {
                    if (a.isActive != b.isActive) {
                      return a.isActive ? -1 : 1;
                    }
                    return a.title.compareTo(b.title);
                  });

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            ZemenSpacing.md, ZemenSpacing.md, ZemenSpacing.md, 0),
                        child: Text(
                          isAmharic ? 'ማስታወሻዎች' : 'Reminders',
                          style: ZemenTextStyles.pageHeader(amharic: isAmharic),
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            ZemenSpacing.md, ZemenSpacing.sm, ZemenSpacing.md, ZemenSpacing.md),
                        child: Text(
                          isAmharic
                              ? '${sorted.length} ማስታወሻዎች'
                              : '${sorted.length} reminders',
                          style: ZemenTextStyles.metadata(),
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: ZemenSpacing.md),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final reminder = sorted[i];
                            return ZemenReminderCard(
                              reminder: reminder,
                              isAmharic: isAmharic,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ReminderEditScreen(reminder: reminder),
                                ),
                              ),
                              onToggleActive: (val) => ref
                                  .read(remindersProvider.notifier)
                                  .toggleActive(reminder.id, val),
                              onDelete: () => ref
                                  .read(remindersProvider.notifier)
                                  .deleteReminder(reminder.id),
                            ).animate().fadeIn(
                                delay: (i * 50).ms, duration: 300.ms);
                          },
                          childCount: sorted.length,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _NewReminderFab(isAmharic: isAmharic),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isAmharic;
  const _EmptyState({required this.isAmharic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ZemenSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ZemenColors.primaryGoldGlow,
                shape: BoxShape.circle,
                border: Border.all(color: ZemenColors.primaryGoldDim),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: ZemenColors.primaryGold,
                size: 36,
              ),
            ),
            const SizedBox(height: ZemenSpacing.lg),
            Text(
              isAmharic ? 'ምንም ማስታወሻ የለም' : 'No reminders yet',
              style: ZemenTextStyles.sectionHeader(amharic: isAmharic),
            ),
            const SizedBox(height: ZemenSpacing.sm),
            Text(
              isAmharic
                  ? 'ለክብረ-በዓል፣ ጾም ወይም ግል ለማስታወስ + ይጫኑ'
                  : 'Tap + to create a reminder for feasts, fasting, or personal events',
              style: ZemenTextStyles.metadata(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class _NewReminderFab extends StatelessWidget {
  final bool isAmharic;
  const _NewReminderFab({required this.isAmharic});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: ZemenRadius.fullBR,
        boxShadow: ZemenShadows.goldGlow,
      ),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReminderEditScreen()),
        ),
        backgroundColor: ZemenColors.primaryGold,
        foregroundColor: ZemenColors.background,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          isAmharic ? 'አዲስ' : 'New',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}