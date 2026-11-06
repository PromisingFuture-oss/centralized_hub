import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:centralized_hub/core/utils/temperature_utils.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';
import 'package:centralized_hub/features/dashboard/providers/card_data_providers.dart';
import 'base_dashboard_card.dart';

class TemperatureTrendCard extends ConsumerWidget {
  final CardSize size;
  final VoidCallback? onRemove;
  final ValueChanged<CardSize>? onResize;

  const TemperatureTrendCard({
    super.key,
    required this.size,
    this.onRemove,
    this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMetrics = ref.watch(temperatureMetricsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BaseDashboardCard(
      title: 'Thermals',
      subtitle: size == CardSize.small ? null : 'Hardware temperature tracking',
      icon: Icons.thermostat_outlined,
      iconColor: const Color(0xFFFF5722),
      size: size,
      onRemove: onRemove,
      onResize: onResize,
      child: asyncMetrics.when(
        data: (metrics) {
          if (metrics.peakTemp == null) {
            return Center(
              child: Text(
                'No temperature samples yet',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final peak = metrics.peakTemp!;
          final avg = metrics.avgTemp ?? peak;
          final severity = TemperatureUtils.getTemperatureLabel(peak);
          final peakColor = _getTempColor(peak);
          final avgColor = _getTempColor(avg);

          // Calculate normalized progress (20C - 50C range)
          final progress = ((peak - 20) / 30).clamp(0.05, 1.0);

          if (size == CardSize.small) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      TemperatureUtils.format(peak),
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: peakColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: peakColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: peakColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        severity.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: peakColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildThermalBar(progress, peakColor),
              ],
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricColumn(
                    label: 'PEAK TEMP',
                    value: TemperatureUtils.format(peak),
                    sublabel: severity.toUpperCase(),
                    color: peakColor,
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  _buildMetricColumn(
                    label: 'AVG TEMP',
                    value: TemperatureUtils.format(avg),
                    sublabel: TemperatureUtils.getTemperatureLabel(avg).toUpperCase(),
                    color: avgColor,
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildThermalBar(progress, peakColor),
              if (metrics.hottestGameName != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: Color(0xFFFF5722),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Peak on: ${metrics.hottestGameName}',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, _) => const Center(child: Text('Error loading thermals')),
      ),
    );
  }

  Color _getTempColor(double celsius) {
    if (celsius < 30) return const Color(0xFF00E5FF);
    if (celsius < 35) return const Color(0xFF00E676);
    if (celsius < 40) return const Color(0xFFFFB300);
    if (celsius < 45) return const Color(0xFFFF5722);
    return const Color(0xFFFF1744);
  }

  Widget _buildMetricColumn({
    required String label,
    required String value,
    required String sublabel,
    required Color color,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Text(
            sublabel,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThermalBar(double progress, Color activeColor) {
    return Column(
      children: [
        Container(
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white.withValues(alpha: 0.08),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00E5FF),
                          Color(0xFF00E676),
                          Color(0xFFFFB300),
                          Color(0xFFFF1744),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
