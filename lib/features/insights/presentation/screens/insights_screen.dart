import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../../../domain/enums/time_range.dart';
import '../../../../domain/services/insight_engine.dart';
import '../../../../shared/widgets/empty_state.dart';

final selectedInsightRangeProvider =
    StateProvider<TimeRange>((ref) => TimeRange.week);

final insightsListProvider = FutureProvider<List<Insight>>((ref) async {
  final engine = ref.watch(insightEngineProvider);
  final range = ref.watch(selectedInsightRangeProvider);
  return engine.generateInsights(timeRange: range);
});

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  IconData _iconForType(InsightType type) {
    switch (type) {
      case InsightType.hotGame:
        return Icons.local_fire_department;
      case InsightType.temperatureAlert:
        return Icons.warning_amber_rounded;
      case InsightType.batteryDrain:
        return Icons.battery_alert;
      case InsightType.batteryFriendly:
        return Icons.battery_saver_rounded;
      case InsightType.longestSession:
        return Icons.hourglass_top;
      case InsightType.mostPlayed:
        return Icons.emoji_events;
      case InsightType.streak:
        return Icons.bolt;
      case InsightType.timeHabit:
        return Icons.nights_stay_rounded;
    }
  }

  Color _colorForType(InsightType type, ColorScheme colorScheme) {
    switch (type) {
      case InsightType.hotGame:
        return Colors.deepOrange;
      case InsightType.temperatureAlert:
        return Colors.redAccent;
      case InsightType.batteryDrain:
        return Colors.amber.shade800;
      case InsightType.batteryFriendly:
        return Colors.teal;
      case InsightType.longestSession:
        return colorScheme.tertiary;
      case InsightType.mostPlayed:
        return colorScheme.primary;
      case InsightType.streak:
        return Colors.amber.shade700;
      case InsightType.timeHabit:
        return Colors.indigoAccent;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final selectedRange = ref.watch(selectedInsightRangeProvider);
    final asyncInsights = ref.watch(insightsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Insights & Trends',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Insights',
            onPressed: () => ref.refresh(insightsListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Time range filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final range in [
                    TimeRange.week,
                    TimeRange.month,
                    TimeRange.allTime
                  ]) ...[
                    ChoiceChip(
                      label: Text(range.displayName),
                      selected: selectedRange == range,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(selectedInsightRangeProvider.notifier)
                              .state = range;
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),

          Expanded(
            child: asyncInsights.when(
              data: (insights) {
                if (insights.isEmpty) {
                  return const EmptyState(
                    icon: Icons.lightbulb_outline,
                    title: 'No insights yet',
                    subtitle:
                        'Play a few games with tracking active to discover patterns about device heat, battery drain, and session habits.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: insights.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final insight = insights[index];
                    final color = _colorForType(insight.type, colorScheme);

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.surfaceContainer,
                            colorScheme.surfaceContainerLow,
                          ],
                        ),
                        border: Border.all(
                          color: color.withValues(alpha: 0.28),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: color.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.22),
                                    blurRadius: 8,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _iconForType(insight.type),
                                color: color,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          insight.title,
                                          style:
                                              textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color:
                                              color.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color:
                                                color.withValues(alpha: 0.25),
                                          ),
                                        ),
                                        child: Text(
                                          insight.badgeText ?? 'TREND',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    insight.description,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                  if (insight.gamePackageName != null) ...[
                                    const SizedBox(height: 10),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () async {
                                        final launched = await ref
                                            .read(appRepositoryProvider)
                                            .launchApp(
                                                insight.gamePackageName!);
                                        if (!launched && context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Could not launch game'),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color:
                                              color.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color:
                                                color.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.play_arrow_rounded,
                                                size: 14, color: color),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Play Game',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
