import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';
import 'package:centralized_hub/features/dashboard/providers/card_data_providers.dart';
import 'base_dashboard_card.dart';

class BatteryDrainCard extends ConsumerWidget {
  final CardSize size;
  final VoidCallback? onRemove;
  final ValueChanged<CardSize>? onResize;

  const BatteryDrainCard({
    super.key,
    required this.size,
    this.onRemove,
    this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(batteryDrainMetricsProvider);
    final scheme = Theme.of(context).colorScheme;

    final hasData = metrics.dischargingSessionsCount > 0;
    String fmt(double v) => hasData ? '${v.toStringAsFixed(1)}%' : '—';
    final drainColor = const Color(0xFFFFB300);

    final rateStat = _Stat(
      label: 'DRAIN RATE',
      value: hasData ? '-${metrics.avgDropPerHour.toStringAsFixed(1)}%' : '—',
      caption: 'per hour played',
      color: drainColor,
    );
    final dropStat = _Stat(
      label: 'AVG DROP',
      value: fmt(metrics.avgDropPercent),
      caption: 'per session',
      color: scheme.primary,
    );

    return BaseDashboardCard(
      title: 'Battery Drain',
      subtitle: size == CardSize.small
          ? null
          : '${metrics.dischargingSessionsCount} sessions (unplugged)',
      icon: Icons.battery_charging_full_rounded,
      iconColor: drainColor,
      size: size,
      onRemove: onRemove,
      onResize: onResize,
      child: switch (size) {
        CardSize.small => Center(child: rateStat),
        _ => Row(
            children: [
              Expanded(child: Center(child: dropStat)),
              Container(
                width: 1,
                height: 40,
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
              Expanded(child: Center(child: rateStat)),
            ],
          ),
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color color;

  const _Stat({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.labelSmall?.copyWith(
            color: muted.withValues(alpha: 0.7),
            fontSize: 9,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.labelSmall?.copyWith(
            color: muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}