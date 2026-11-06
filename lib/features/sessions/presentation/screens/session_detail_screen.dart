import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/utils/temperature_utils.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Session detail screen showing temperature and battery curves.
class SessionDetailScreen extends ConsumerWidget {
  final int sessionId;
  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Detail'),
      ),
      body: FutureBuilder<Session?>(
        future: ref.read(sessionRepositoryProvider).getById(sessionId),
        builder: (context, sessionSnapshot) {
          if (sessionSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final session = sessionSnapshot.data;
          if (session == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Session not found',
            );
          }

          return StreamBuilder<List<Sample>>(
            stream: ref
                .read(sampleRepositoryProvider)
                .watchSamplesForSession(sessionId),
            builder: (context, samplesSnapshot) {
              final samples = samplesSnapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary header
                    _SummaryCard(session: session),
                    const SizedBox(height: 24),

                    // Battery temperature chart
                    Text('Battery Temperature',
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Measured from the battery sensor — correlates with but is lower than actual SoC temperature.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (samples.where((s) => s.batteryTempC != null).isEmpty)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('No temperature data for this session'),
                        ),
                      )
                    else
                      SizedBox(
                        height: 220,
                        child: _TemperatureChart(
                          samples: samples,
                          sessionStart: session.startTime,
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Battery level chart
                    Text('Battery Level',
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if (samples.where((s) => s.batteryLevel != null).isEmpty)
                      const SizedBox(
                        height: 200,
                        child: Center(
                          child: Text('No battery data for this session'),
                        ),
                      )
                    else
                      SizedBox(
                        height: 220,
                        child: _BatteryChart(
                          samples: samples,
                          sessionStart: session.startTime,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Session session;
  const _SummaryCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.timer_outlined,
                    color: colorScheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Duration',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                DurationFormatter.formatMs(session.durationMs),
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
          // Temperature row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.thermostat_outlined,
                    color: Color(0xFFFF5722), size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Temperature',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (session.tempMinC != null && session.tempMaxC != null)
                Text(
                  '${TemperatureUtils.format(session.tempMinC!)} – ${TemperatureUtils.format(session.tempMaxC!)}',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF5722),
                  ),
                )
              else
                Text('—', style: textTheme.bodyMedium),
            ],
          ),
          Divider(
            height: 24,
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
          // Battery row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.battery_std_outlined,
                    color: Color(0xFFFFB300), size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                'Battery',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (session.hadChargingDuring)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.tertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.power, size: 14, color: colorScheme.tertiary),
                      const SizedBox(width: 4),
                      Text(
                        'Charging',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                )
              else if (session.batteryDrop != null)
                Text(
                  '${session.batteryStart}% → ${session.batteryEnd}% (−${session.batteryDrop}%)',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFB300),
                  ),
                )
              else
                Text('—', style: textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _TemperatureChart extends StatelessWidget {
  final List<Sample> samples;
  final DateTime sessionStart;
  const _TemperatureChart({required this.samples, required this.sessionStart});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tempSamples =
        samples.where((s) => s.batteryTempC != null).toList();

    if (tempSamples.isEmpty) return const SizedBox.shrink();

    final spots = tempSamples.map((s) {
      final minutes =
          s.timestamp.difference(sessionStart).inSeconds / 60.0;
      return FlSpot(minutes, s.batteryTempC!);
    }).toList();

    final minTemp = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxTemp = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}°C',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}m',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: (minTemp - 2).floorToDouble(),
        maxY: (maxTemp + 2).ceilToDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: colorScheme.error,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.error.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryChart extends StatelessWidget {
  final List<Sample> samples;
  final DateTime sessionStart;
  const _BatteryChart({required this.samples, required this.sessionStart});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final battSamples =
        samples.where((s) => s.batteryLevel != null).toList();

    if (battSamples.isEmpty) return const SizedBox.shrink();

    final spots = battSamples.map((s) {
      final minutes =
          s.timestamp.difference(sessionStart).inSeconds / 60.0;
      return FlSpot(minutes, s.batteryLevel!.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}m',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: colorScheme.tertiary,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: colorScheme.tertiary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
