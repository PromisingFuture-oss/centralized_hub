import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:centralized_hub/domain/enums/time_range.dart';
import 'package:centralized_hub/features/dashboard/providers/dashboard_filter_provider.dart';

class DashboardFiltersBar extends ConsumerWidget {
  const DashboardFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(dashboardFilterProvider);
    final notifier = ref.read(dashboardFilterProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final ranges = [
      TimeRange.today,
      TimeRange.week,
      TimeRange.month,
      TimeRange.allTime,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (final range in ranges) ...[
            ChoiceChip(
              label: Text(range.displayName),
              selected: filter.timeRange == range,
              onSelected: (selected) {
                if (selected) notifier.setTimeRange(range);
              },
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: filter.timeRange == range
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: filter.timeRange == range
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
          ],
          FilterChip(
            avatar: Icon(
              filter.chargingOnly == false
                  ? Icons.battery_alert
                  : Icons.battery_charging_full,
              size: 16,
            ),
            label: Text(
              filter.chargingOnly == false
                  ? 'Unplugged'
                  : filter.chargingOnly == true
                      ? 'Charging'
                      : 'Power: All',
            ),
            selected: filter.chargingOnly != null,
            onSelected: (selected) {
              if (filter.chargingOnly == null) {
                notifier.setChargingOnly(false); // unplugged
              } else if (filter.chargingOnly == false) {
                notifier.setChargingOnly(true); // charging
              } else {
                notifier.setChargingOnly(null); // all
              }
            },
          ),
        ],
      ),
    );
  }
}
