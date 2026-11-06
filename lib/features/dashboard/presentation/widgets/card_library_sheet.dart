import 'package:flutter/material.dart';
import 'package:centralized_hub/domain/enums/card_type.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';

class CardLibrarySheet extends StatelessWidget {
  final void Function(CardType type, CardSize size) onCardSelected;

  const CardLibrarySheet({super.key, required this.onCardSelected});

  static Future<void> show(
    BuildContext context, {
    required void Function(CardType type, CardSize size) onCardSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => CardLibrarySheet(onCardSelected: onCardSelected),
    );
  }

  IconData _iconForType(CardType type) {
    switch (type) {
      case CardType.totalPlaytime:
        return Icons.timer_outlined;
      case CardType.topGames:
        return Icons.leaderboard_outlined;
      case CardType.recentSessions:
        return Icons.history;
      case CardType.temperatureTrend:
      case CardType.hottestSessions:
        return Icons.thermostat_outlined;
      case CardType.batteryDrain:
      case CardType.avgDrainPerHour:
        return Icons.battery_charging_full;
      case CardType.sessionDistribution:
        return Icons.pie_chart_outline;
      case CardType.playtimeHeatmap:
        return Icons.calendar_view_month;
      case CardType.streaks:
        return Icons.local_fire_department;
      case CardType.liveSession:
        return Icons.sensors;
      case CardType.entertainmentDeck:
        return Icons.play_circle_filled_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final availableTypes = [
      CardType.entertainmentDeck,
      CardType.liveSession,
      CardType.totalPlaytime,
      CardType.topGames,
      CardType.temperatureTrend,
      CardType.batteryDrain,
      CardType.recentSessions,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Add Dashboard Card',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: availableTypes.length,
                  separatorBuilder: (_, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final type = availableTypes[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                        onCardSelected(type, CardSize.medium);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _iconForType(type),
                                color: colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type.displayName,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    type.description,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.add_circle_outline,
                              color: colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
