import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/utils/temperature_utils.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Game detail screen showing session history and stats.
class GameDetailScreen extends ConsumerWidget {
  final int appId;
  const GameDetailScreen({super.key, required this.appId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/games');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded),
            tooltip: 'Benchmark Compare',
            onPressed: () => context.push('/games/compare?appA=$appId'),
          ),
        ],
      ),
      body: FutureBuilder<App?>(
        future: ref.read(appRepositoryProvider).getById(appId),
        builder: (context, appSnapshot) {
          if (!appSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final app = appSnapshot.data;
          if (app == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Game not found',
            );
          }

          return StreamBuilder<List<Session>>(
            stream: ref.read(sessionRepositoryProvider).watchSessionsForApp(appId),
            builder: (context, sessionsSnapshot) {
              final sessions = sessionsSnapshot.data ?? [];

              return CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // App icon with ambient glow
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: colorScheme.primaryContainer,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.28),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: app.iconBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(app.iconBytes!,
                                        fit: BoxFit.cover),
                                  )
                                : Icon(Icons.sports_esports,
                                    size: 38,
                                    color: colorScheme.onPrimaryContainer),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            app.appName,
                            style: textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${sessions.length} sessions',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () async {
                              final launched = await ref
                                  .read(appRepositoryProvider)
                                  .launchApp(app.packageName);
                              if (!launched && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Could not launch ${app.appName}. Please ensure it is installed.'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.play_arrow_rounded, size: 22),
                            label: const Text(
                              'Play Game',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Stats row
                          _StatsRow(sessions: sessions),
                        ],
                      ),
                    ),
                  ),
                  // Session history header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                      child: Text('Session History',
                          style: textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  // Sessions list
                  if (sessions.isEmpty)
                    const SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.history,
                        title: 'No sessions yet',
                        subtitle: 'Play this game to start tracking.',
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final session = sessions[index];
                          return _SessionTile(session: session);
                        },
                        childCount: sessions.length,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<Session> sessions;
  const _StatsRow({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final totalMs =
        sessions.fold<int>(0, (sum, s) => sum + (s.durationMs ?? 0));
    final avgTempValues = sessions
        .where((s) => s.tempAvgC != null)
        .map((s) => s.tempAvgC!)
        .toList();
    final avgTemp = avgTempValues.isNotEmpty
        ? avgTempValues.reduce((a, b) => a + b) / avgTempValues.length
        : null;
    final avgDrop = sessions
        .where((s) => s.batteryDrop != null && !s.hadChargingDuring)
        .map((s) => s.batteryDrop!)
        .toList();
    final avgBatteryDrop = avgDrop.isNotEmpty
        ? avgDrop.reduce((a, b) => a + b) / avgDrop.length
        : null;

    return Row(
      children: [
        _StatCard(
          label: 'Total Time',
          value: DurationFormatter.formatMs(totalMs),
          icon: Icons.timer_outlined,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Avg Temp',
          value: avgTemp != null
              ? TemperatureUtils.format(avgTemp)
              : '—',
          icon: Icons.thermostat_outlined,
          color: colorScheme.error,
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Avg Drain',
          value: avgBatteryDrop != null
              ? '${avgBatteryDrop.toStringAsFixed(0)}%'
              : '—',
          icon: Icons.battery_3_bar,
          color: colorScheme.tertiary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceContainer,
              colorScheme.surfaceContainerLow,
            ],
          ),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isActive = session.endTime == null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isActive
            ? null
            : () => context.go('/sessions/${session.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Duration
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isActive ? 'LIVE' : DurationFormatter.formatMs(session.durationMs),
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isActive ? colorScheme.primary : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Date + info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(session.startTime),
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (session.tempMaxC != null) ...[
                          Icon(Icons.thermostat, size: 14,
                              color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            TemperatureUtils.format(session.tempMaxC!),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (session.batteryDrop != null &&
                            !session.hadChargingDuring) ...[
                          Icon(Icons.battery_alert, size: 14,
                              color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            '-${session.batteryDrop}%',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ] else if (session.hadChargingDuring) ...[
                          Icon(Icons.power, size: 14,
                              color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            'Charging',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (!isActive)
                Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDay = DateTime(date.year, date.month, date.day);

    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (sessionDay == today) return 'Today at $time';
    if (sessionDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $time';
    }
    return '${date.day}/${date.month}/${date.year} at $time';
  }
}
