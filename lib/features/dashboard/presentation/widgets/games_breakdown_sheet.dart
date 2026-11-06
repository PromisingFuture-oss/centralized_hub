import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../providers/card_data_providers.dart';

/// Modal bottom sheet showing all games played, their icons, playtime, and sessions count.
class GamesBreakdownSheet extends ConsumerWidget {
  const GamesBreakdownSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GamesBreakdownSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final topGamesAsync = ref.watch(topGamesMetricsProvider);
    final totalMetrics = ref.watch(totalPlaytimeMetricsProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sports_esports_rounded,
                        color: colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Games Breakdown',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${totalMetrics.formatted} total across ${totalMetrics.sessionCount} sessions',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),

              // Game list
              Expanded(
                child: topGamesAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sports_esports_outlined,
                                size: 56,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No game records yet',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Play a tracked game to see playtime breakdown and analytics here.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final rank = index + 1;

                        Color rankBadgeColor;
                        Color rankTextColor;
                        BoxShadow? rankGlow;

                        if (rank == 1) {
                          rankBadgeColor = const Color(0xFFFFD700).withValues(alpha: 0.18);
                          rankTextColor = const Color(0xFFFFD700);
                          rankGlow = const BoxShadow(
                            color: Color(0x55FFD700),
                            blurRadius: 8,
                          );
                        } else if (rank == 2) {
                          rankBadgeColor = const Color(0xFFE0E0E0).withValues(alpha: 0.18);
                          rankTextColor = const Color(0xFFE0E0E0);
                          rankGlow = const BoxShadow(
                            color: Color(0x33E0E0E0),
                            blurRadius: 6,
                          );
                        } else if (rank == 3) {
                          rankBadgeColor = const Color(0xFFCD7F32).withValues(alpha: 0.18);
                          rankTextColor = const Color(0xFFCD7F32);
                          rankGlow = const BoxShadow(
                            color: Color(0x33CD7F32),
                            blurRadius: 6,
                          );
                        } else {
                          rankBadgeColor = colorScheme.surfaceContainerHighest;
                          rankTextColor = colorScheme.onSurfaceVariant;
                        }

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/games/${item.app.id}');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.surfaceContainer,
                                  colorScheme.surfaceContainerLow,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: rank == 1
                                    ? const Color(0xFFFFD700).withValues(alpha: 0.35)
                                    : colorScheme.outlineVariant.withValues(alpha: 0.35),
                                width: rank == 1 ? 1.3 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Rank Badge
                                    Container(
                                      width: 26,
                                      height: 26,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: rankBadgeColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: rankTextColor.withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                        boxShadow: rankGlow != null ? [rankGlow] : null,
                                      ),
                                      child: Text(
                                        '$rank',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: rankTextColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // App Icon
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: item.app.iconBytes != null
                                          ? Image.memory(
                                              item.app.iconBytes!,
                                              width: 42,
                                              height: 42,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 42,
                                              height: 42,
                                              color: colorScheme.primaryContainer,
                                              child: Icon(
                                                Icons.sports_esports,
                                                color: colorScheme.primary,
                                                size: 24,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Game name and session count
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.app.appName,
                                            style: textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: -0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '${item.sessionCount} sessions • ${(item.percentage).toStringAsFixed(1)}% share',
                                            style: textTheme.labelSmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Playtime & chevron
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          DurationFormatter.formatMs(item.totalPlaytimeMs),
                                          style: textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Percentage Progress Bar with Gradient
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final fillRatio = (item.percentage / 100).clamp(0.02, 1.0);
                                    return Container(
                                      height: 6,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(3),
                                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: constraints.maxWidth * fillRatio,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(3),
                                          gradient: LinearGradient(
                                            colors: [
                                              colorScheme.primary,
                                              rank == 1
                                                  ? const Color(0xFFFFD700)
                                                  : colorScheme.tertiary,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorScheme.primary.withValues(alpha: 0.4),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error loading games: $e')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
