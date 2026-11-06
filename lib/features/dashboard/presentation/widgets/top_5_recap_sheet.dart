import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:centralized_hub/core/utils/duration_formatter.dart';
import 'package:centralized_hub/domain/enums/time_range.dart';
import 'package:centralized_hub/features/dashboard/providers/card_data_providers.dart';
import '../screens/gaming_recap_story_screen.dart';

/// Discord-inspired Top 5 Games Recap modal sheet.
/// Provides timeframe switching (Week / Month / Year / All Time),
/// #1 champion spotlight hero card, podium ranks 2-5, and shareable summary.
class Top5RecapSheet extends ConsumerWidget {
  const Top5RecapSheet({super.key});

  /// Displays the Top 5 Recap modal sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const Top5RecapSheet(),
    );
  }

  void _shareRecap(BuildContext context, List<TopGameItem> items, TimeRange range) {
    if (items.isEmpty) return;

    final rangeLabel = switch (range) {
      TimeRange.week => 'This Week',
      TimeRange.month => 'This Month',
      TimeRange.year => 'This Year',
      TimeRange.allTime => 'All Time',
      _ => range.displayName,
    };

    final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
    final buffer = StringBuffer();
    buffer.writeln('🎮 **My Top 5 Games Recap ($rangeLabel)**');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    int totalMs = 0;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final medal = i < medals.length ? medals[i] : '${i + 1}.';
      final dur = DurationFormatter.formatMs(item.totalPlaytimeMs);
      final pct = item.percentage.toStringAsFixed(1);
      buffer.writeln('$medal **${item.app.appName}** — $dur ($pct%) • ${item.sessionCount} sessions');
      totalMs += item.totalPlaytimeMs;
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('⏱️ Total Top 5 Time: **${DurationFormatter.formatMs(totalMs)}**');
    buffer.writeln('🔥 Tracked with Centralized Hub');

    Share.share(
      buffer.toString(),
      subject: 'My Top 5 Games Recap ($rangeLabel)',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedRange = ref.watch(selectedTopGamesRangeProvider);
    final top5Async = ref.watch(top5GamesByRangeProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withValues(alpha: 0.25),
                            colorScheme.primary.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Text('👑', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOP 5 GAMES RECAP',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Discord Wrapped style activity recap',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Timeframe Switcher Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _TimeRangeTab(
                        label: 'Week',
                        isSelected: selectedRange == TimeRange.week,
                        onTap: () => ref.read(selectedTopGamesRangeProvider.notifier).state = TimeRange.week,
                      ),
                      _TimeRangeTab(
                        label: 'Month',
                        isSelected: selectedRange == TimeRange.month,
                        onTap: () => ref.read(selectedTopGamesRangeProvider.notifier).state = TimeRange.month,
                      ),
                      _TimeRangeTab(
                        label: 'Year',
                        isSelected: selectedRange == TimeRange.year,
                        onTap: () => ref.read(selectedTopGamesRangeProvider.notifier).state = TimeRange.year,
                      ),
                      _TimeRangeTab(
                        label: 'All Time',
                        isSelected: selectedRange == TimeRange.allTime,
                        onTap: () => ref.read(selectedTopGamesRangeProvider.notifier).state = TimeRange.allTime,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 16),

              // Content
              Expanded(
                child: top5Async.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.sports_esports_outlined,
                                  size: 48,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No gaming data for this timeframe',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Play some games or switch to Month, Year, or All Time above.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final champion = items.first;
                    final runnersUp = items.skip(1).toList();
                    final totalMs = items.fold<int>(0, (sum, it) => sum + it.totalPlaytimeMs);

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        // Watch Animated Recap Story Banner
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            GamingRecapStoryScreen.open(
                              context,
                              items: items,
                              range: selectedRange,
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00E5FF), Color(0xFF9D4EDD), Color(0xFFFF1E56)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'WATCH ANIMATED RECAP',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          fontFamily: 'Outfit',
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Slideshow story presentation like Spotify Wrapped',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Total time stat bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary.withValues(alpha: 0.15),
                                colorScheme.tertiary.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Top 5 Total Playtime',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                DurationFormatter.formatMs(totalMs),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // #1 Champion Hero Spotlight Card
                        _ChampionHeroCard(item: champion),

                        // Ranks #2 through #5
                        if (runnersUp.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'RUNNERS UP (PODIUM 2 - 5)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          ...runnersUp.asMap().entries.map((entry) {
                            final rank = entry.key + 2; // Rank 2, 3, 4, 5
                            final item = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _RankCard(rank: rank, item: item),
                            );
                          }),
                        ],

                        const SizedBox(height: 20),

                        // Share Recap Button
                        ElevatedButton.icon(
                          onPressed: () => _shareRecap(context, items, selectedRange),
                          icon: const Icon(Icons.share_rounded, size: 20),
                          label: const Text(
                            'SHARE RECAP (DISCORD / SOCIALS)',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 4,
                            shadowColor: colorScheme.primary.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error loading recap: $err')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimeRangeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeRangeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChampionHeroCard extends StatelessWidget {
  final TopGameItem item;

  const _ChampionHeroCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const goldColor = Color(0xFFFFD700);

    return InkWell(
      onTap: () => context.push('/games/${item.app.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              goldColor.withValues(alpha: 0.2),
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              colorScheme.primary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: goldColor.withValues(alpha: 0.6),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: goldColor.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                // Gold crown badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: goldColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: goldColor.withValues(alpha: 0.7)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('👑', style: TextStyle(fontSize: 14)),
                      SizedBox(width: 6),
                      Text(
                        '#1 MOST PLAYED',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: goldColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.percentage.toStringAsFixed(1)}% Share',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: goldColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // Big Game Icon with glowing border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: goldColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: goldColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: item.app.iconBytes != null
                        ? Image.memory(
                            item.app.iconBytes!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 56,
                            height: 56,
                            color: colorScheme.secondaryContainer,
                            child: const Icon(Icons.sports_esports, size: 32, color: goldColor),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Game Name & Playtime
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.app.appName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DurationFormatter.formatMs(item.totalPlaytimeMs),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w900,
                          color: goldColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.sessionCount} sessions logged',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: goldColor.withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RankCard extends StatelessWidget {
  final int rank;
  final TopGameItem item;

  const _RankCard({
    required this.rank,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final rankColor = switch (rank) {
      2 => const Color(0xFFC0C0C0), // Silver
      3 => const Color(0xFFCD7F32), // Bronze
      4 => const Color(0xFF00E5FF), // Cyber Cyan
      _ => const Color(0xFF9D4EDD), // Electric Violet
    };

    final medalEmoji = switch (rank) {
      2 => '🥈',
      3 => '🥉',
      4 => '4',
      _ => '5',
    };

    return InkWell(
      onTap: () => context.push('/games/${item.app.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: rankColor.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: rankColor.withValues(alpha: 0.6)),
              ),
              child: Center(
                child: rank <= 3
                    ? Text(medalEmoji, style: const TextStyle(fontSize: 16))
                    : Text(
                        '#$rank',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: rankColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Game icon
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.app.iconBytes != null
                  ? Image.memory(
                      item.app.iconBytes!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 36,
                      height: 36,
                      color: colorScheme.secondaryContainer,
                      child: Icon(Icons.sports_esports, size: 20, color: rankColor),
                    ),
            ),
            const SizedBox(width: 12),
            // Title & Progress Bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.app.appName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DurationFormatter.formatMs(item.totalPlaytimeMs),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w800,
                          color: rankColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (item.percentage / 100).clamp(0.0, 1.0),
                            minHeight: 5,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
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
    );
  }
}
