import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:centralized_hub/core/utils/duration_formatter.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';
import 'package:centralized_hub/domain/enums/time_range.dart';
import 'package:centralized_hub/features/dashboard/providers/card_data_providers.dart';
import 'package:centralized_hub/features/dashboard/presentation/screens/gaming_recap_story_screen.dart';
import '../top_5_recap_sheet.dart';
import 'base_dashboard_card.dart';

/// Discord-inspired Top 5 Games Card on Dashboard.
/// Features a quick timeframe selector (Week / Month / Year / All Time)
/// and displays the top games with medals and playtime progress.
class TopGamesCard extends ConsumerWidget {
  final CardSize size;
  final VoidCallback? onRemove;
  final ValueChanged<CardSize>? onResize;

  const TopGamesCard({
    super.key,
    required this.size,
    this.onRemove,
    this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRange = ref.watch(selectedTopGamesRangeProvider);
    final asyncItems = ref.watch(top5GamesByRangeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSmall = size == CardSize.small;

    final rangeSubtitle = switch (selectedRange) {
      TimeRange.week => 'This Week',
      TimeRange.month => 'This Month',
      TimeRange.year => 'This Year',
      _ => 'All Time',
    };

    return BaseDashboardCard(
      title: 'Top 5 Games',
      subtitle: isSmall ? null : '$rangeSubtitle • Tap for Recap & Story',
      icon: Icons.military_tech_rounded,
      iconColor: const Color(0xFFFFD700),
      size: size,
      onRemove: onRemove,
      onResize: onResize,
      onTap: () => Top5RecapSheet.show(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeframe micro-selector row (when not small)
          if (!isSmall)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _MicroFilterChip(
                      label: 'Week',
                      isSelected: selectedRange == TimeRange.week,
                      onTap: () => ref.read(selectedTopGamesRangeProvider.notifier).state = TimeRange.week,
                    ),
                    const SizedBox(width: 4),
                    _MicroFilterChip(
                      label: 'Month',
                      isSelected: selectedRange == TimeRange.month,
                      onTap: () => ref.read(selectedTopGamesRangeProvider.notifier).state = TimeRange.month,
                    ),
                    const SizedBox(width: 4),
                    _MicroFilterChip(
                      label: 'Year',
                      isSelected: selectedRange == TimeRange.year,
                      onTap: () => ref.read(selectedTopGamesRangeProvider.notifier).state = TimeRange.year,
                    ),
                    const SizedBox(width: 4),
                    _MicroFilterChip(
                      label: 'All',
                      isSelected: selectedRange == TimeRange.allTime,
                      onTap: () => ref.read(selectedTopGamesRangeProvider.notifier).state = TimeRange.allTime,
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        final items = asyncItems.value ?? [];
                        if (items.isNotEmpty) {
                          GamingRecapStoryScreen.open(
                            context,
                            items: items,
                            range: selectedRange,
                          );
                        } else {
                          Top5RecapSheet.show(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF9D4EDD)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 12, color: Colors.white),
                            SizedBox(width: 2),
                            Text(
                              'STORY',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: asyncItems.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No games played ($rangeSubtitle)',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
                final displayCount = size == CardSize.small
                    ? 2
                    : (size == CardSize.large ? 5 : 3);
                final topList = isPortrait ? items : items.take(displayCount).toList();

                return ListView.separated(
                  physics: isPortrait || items.length > displayCount
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: topList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = topList[index];
                    final rank = index + 1;
                    final medal = switch (rank) {
                      1 => '🥇',
                      2 => '🥈',
                      3 => '🥉',
                      4 => '4️⃣',
                      5 => '5️⃣',
                      _ => '#$rank',
                    };

                    final rankColor = switch (rank) {
                      1 => const Color(0xFFFFD700),
                      2 => const Color(0xFFC0C0C0),
                      3 => const Color(0xFFCD7F32),
                      _ => colorScheme.primary,
                    };

                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => context.push('/games/${item.app.id}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  medal,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: item.app.iconBytes != null
                                      ? Image.memory(
                                          item.app.iconBytes!,
                                          width: isSmall ? 18 : 20,
                                          height: isSmall ? 18 : 20,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: isSmall ? 18 : 20,
                                          height: isSmall ? 18 : 20,
                                          color: colorScheme.secondaryContainer,
                                          child: Icon(
                                            Icons.sports_esports,
                                            size: isSmall ? 12 : 14,
                                            color: colorScheme.secondary,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.app.appName,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DurationFormatter.formatMs(item.totalPlaytimeMs),
                                  style: textTheme.bodySmall?.copyWith(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w800,
                                    color: rankColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: (item.percentage / 100).clamp(0.0, 1.0),
                                minHeight: 4,
                                backgroundColor: colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (err, _) => const Center(child: Text('Error loading top games')),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicroFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MicroFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.25)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
