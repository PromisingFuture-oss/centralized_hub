import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/utils/temperature_utils.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Benchmark summary statistics computed for a game.
class GameBenchmarkStats {
  final App app;
  final int sessionCount;
  final int totalDurationMs;
  final double? avgDurationMs;
  final double? avgTempC;
  final double? peakTempC;
  final int overheatingCount; // sessions with tempMax >= 40.0°C
  final double? avgDrainPerHour; // % battery drop per hour
  final double? avgBatteryDrop;

  const GameBenchmarkStats({
    required this.app,
    required this.sessionCount,
    required this.totalDurationMs,
    this.avgDurationMs,
    this.avgTempC,
    this.peakTempC,
    this.overheatingCount = 0,
    this.avgDrainPerHour,
    this.avgBatteryDrop,
  });

  static GameBenchmarkStats compute(App app, List<Session> sessions) {
    if (sessions.isEmpty) {
      return GameBenchmarkStats(
        app: app,
        sessionCount: 0,
        totalDurationMs: 0,
      );
    }

    int totalMs = 0;
    final validTemps = <double>[];
    double? peak;
    int overheat = 0;
    final drainPerHourList = <double>[];
    final validDrops = <int>[];

    for (final s in sessions) {
      if (s.durationMs != null) {
        totalMs += s.durationMs!;
      }
      if (s.tempAvgC != null) {
        validTemps.add(s.tempAvgC!);
      }
      if (s.tempMaxC != null) {
        if (peak == null || s.tempMaxC! > peak) {
          peak = s.tempMaxC!;
        }
        if (s.tempMaxC! >= 40.0) {
          overheat++;
        }
      }
      if (!s.hadChargingDuring && s.batteryDrop != null) {
        validDrops.add(s.batteryDrop!);
        if (s.durationMs != null && s.durationMs! >= 300000) {
          final hours = s.durationMs! / 3600000;
          final rate = s.batteryDrop! / hours;
          if (rate > 0) {
            drainPerHourList.add(rate);
          }
        }
      }
    }

    final avgTemp = validTemps.isNotEmpty
        ? validTemps.reduce((a, b) => a + b) / validTemps.length
        : null;

    final avgDrain = drainPerHourList.isNotEmpty
        ? drainPerHourList.reduce((a, b) => a + b) / drainPerHourList.length
        : null;

    final avgDrop = validDrops.isNotEmpty
        ? validDrops.reduce((a, b) => a + b) / validDrops.length
        : null;

    return GameBenchmarkStats(
      app: app,
      sessionCount: sessions.length,
      totalDurationMs: totalMs,
      avgDurationMs: sessions.isNotEmpty ? totalMs / sessions.length : null,
      avgTempC: avgTemp,
      peakTempC: peak,
      overheatingCount: overheat,
      avgDrainPerHour: avgDrain,
      avgBatteryDrop: avgDrop,
    );
  }
}

/// Head-to-head performance and thermal benchmark comparison screen.
class GameComparisonScreen extends ConsumerStatefulWidget {
  final int? initialAppAId;
  final int? initialAppBId;

  const GameComparisonScreen({
    super.key,
    this.initialAppAId,
    this.initialAppBId,
  });

  /// Opens the comparison screen via Navigator.
  static void open(BuildContext context, {int? appAId, int? appBId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameComparisonScreen(
          initialAppAId: appAId,
          initialAppBId: appBId,
        ),
      ),
    );
  }

  @override
  ConsumerState<GameComparisonScreen> createState() =>
      _GameComparisonScreenState();
}

class _GameComparisonScreenState extends ConsumerState<GameComparisonScreen> {
  int? _selectedAppAId;
  int? _selectedAppBId;

  @override
  void initState() {
    super.initState();
    _selectedAppAId = widget.initialAppAId;
    _selectedAppBId = widget.initialAppBId;
  }

  void _showGamePicker({
    required BuildContext context,
    required List<App> games,
    required int? currentSelectedId,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    const Icon(Icons.sports_esports_rounded, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Select Game to Benchmark',
                      style: Theme.of(ctx)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (ctx, i) {
                    final game = games[i];
                    final isSelected = game.id == currentSelectedId;
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(ctx).colorScheme.primaryContainer,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: game.iconBytes != null
                            ? Image.memory(game.iconBytes!, fit: BoxFit.cover)
                            : const Icon(Icons.sports_esports, size: 20),
                      ),
                      title: Text(
                        game.appName,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded,
                              color: Theme.of(ctx).colorScheme.primary)
                          : null,
                      onTap: () {
                        onSelected(game.id);
                        Navigator.pop(ctx);
                      },
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final gamesAsync = ref.watch(appRepositoryProvider).watchGames();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game Benchmark Comparison',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<App>>(
        stream: gamesAsync,
        builder: (context, snapshot) {
          final games = snapshot.data ?? [];
          if (games.isEmpty) {
            return const EmptyState(
              icon: Icons.sports_esports_outlined,
              title: 'No tracked games',
              subtitle: 'Mark at least two games in Centralized Hub to compare them.',
            );
          }

          // Auto-select games if not initialized
          if (_selectedAppAId == null && games.isNotEmpty) {
            _selectedAppAId = games.first.id;
          }
          if (_selectedAppBId == null && games.length > 1) {
            _selectedAppBId = games[1].id;
          } else if (_selectedAppBId == null && games.isNotEmpty) {
            _selectedAppBId = games.first.id;
          }

          final appA = games.firstWhere(
            (g) => g.id == _selectedAppAId,
            orElse: () => games.first,
          );
          final appB = games.firstWhere(
            (g) => g.id == _selectedAppBId,
            orElse: () => games.length > 1 ? games[1] : games.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Head-to-Head selector cards
                _HeadToHeadHeader(
                  appA: appA,
                  appB: appB,
                  onSelectAppA: () => _showGamePicker(
                    context: context,
                    games: games,
                    currentSelectedId: appA.id,
                    onSelected: (id) => setState(() => _selectedAppAId = id),
                  ),
                  onSelectAppB: () => _showGamePicker(
                    context: context,
                    games: games,
                    currentSelectedId: appB.id,
                    onSelected: (id) => setState(() => _selectedAppBId = id),
                  ),
                ),
                const SizedBox(height: 16),

                // Benchmark comparison body
                _BenchmarkDataSection(appA: appA, appB: appB),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeadToHeadHeader extends ConsumerWidget {
  final App appA;
  final App appB;
  final VoidCallback onSelectAppA;
  final VoidCallback onSelectAppB;

  const _HeadToHeadHeader({
    required this.appA,
    required this.appB,
    required this.onSelectAppA,
    required this.onSelectAppB,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Game A Pill Card
        Expanded(
          child: _GamePickerPill(
            app: appA,
            color: colorScheme.primary,
            label: 'GAME A',
            onTap: onSelectAppA,
          ),
        ),

        // VS Badge
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              'VS',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.5,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),

        // Game B Pill Card
        Expanded(
          child: _GamePickerPill(
            app: appB,
            color: Colors.deepOrangeAccent,
            label: 'GAME B',
            onTap: onSelectAppB,
          ),
        ),
      ],
    );
  }
}

class _GamePickerPill extends StatelessWidget {
  final App app;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _GamePickerPill({
    required this.app,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surfaceContainer,
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    Icon(Icons.unfold_more_rounded,
                        size: 16, color: colorScheme.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color.withValues(alpha: 0.12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: app.iconBytes != null
                      ? Image.memory(app.iconBytes!, fit: BoxFit.cover)
                      : Icon(Icons.sports_esports, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  app.appName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenchmarkDataSection extends ConsumerWidget {
  final App appA;
  final App appB;

  const _BenchmarkDataSection({
    required this.appA,
    required this.appB,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionRepo = ref.watch(sessionRepositoryProvider);

    return StreamBuilder<List<Session>>(
      stream: sessionRepo.watchSessionsForApp(appA.id),
      builder: (context, snapA) {
        return StreamBuilder<List<Session>>(
          stream: sessionRepo.watchSessionsForApp(appB.id),
          builder: (context, snapB) {
            final sessionsA = snapA.data ?? [];
            final sessionsB = snapB.data ?? [];

            final statsA = GameBenchmarkStats.compute(appA, sessionsA);
            final statsB = GameBenchmarkStats.compute(appB, sessionsB);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verdict Banner
                _VerdictCard(statsA: statsA, statsB: statsB),
                const SizedBox(height: 16),

                // Thermals Category
                _SectionTitle(
                  title: 'Thermal Performance',
                  icon: Icons.thermostat_rounded,
                  color: Colors.deepOrangeAccent,
                  subtitle: 'Measured battery temperature (lower is cooler)',
                ),
                const SizedBox(height: 8),
                _ComparisonMetricTile(
                  title: 'Average Temperature',
                  valueA: statsA.avgTempC != null
                      ? TemperatureUtils.format(statsA.avgTempC!)
                      : '—',
                  valueB: statsB.avgTempC != null
                      ? TemperatureUtils.format(statsB.avgTempC!)
                      : '—',
                  numA: statsA.avgTempC,
                  numB: statsB.avgTempC,
                  lowerIsBetter: true,
                ),
                _ComparisonMetricTile(
                  title: 'Peak Temperature',
                  valueA: statsA.peakTempC != null
                      ? TemperatureUtils.format(statsA.peakTempC!)
                      : '—',
                  valueB: statsB.peakTempC != null
                      ? TemperatureUtils.format(statsB.peakTempC!)
                      : '—',
                  numA: statsA.peakTempC,
                  numB: statsB.peakTempC,
                  lowerIsBetter: true,
                ),
                _ComparisonMetricTile(
                  title: 'Overheating Sessions (≥ 40°C)',
                  valueA: '${statsA.overheatingCount}',
                  valueB: '${statsB.overheatingCount}',
                  numA: statsA.overheatingCount.toDouble(),
                  numB: statsB.overheatingCount.toDouble(),
                  lowerIsBetter: true,
                ),
                const SizedBox(height: 16),

                // Battery Category
                _SectionTitle(
                  title: 'Battery Efficiency',
                  icon: Icons.battery_charging_full_rounded,
                  color: Colors.teal,
                  subtitle: 'Power consumption rates (lower is more efficient)',
                ),
                const SizedBox(height: 8),
                _ComparisonMetricTile(
                  title: 'Drain Rate (% per hour)',
                  valueA: statsA.avgDrainPerHour != null
                      ? '${statsA.avgDrainPerHour!.toStringAsFixed(1)}%/h'
                      : '—',
                  valueB: statsB.avgDrainPerHour != null
                      ? '${statsB.avgDrainPerHour!.toStringAsFixed(1)}%/h'
                      : '—',
                  numA: statsA.avgDrainPerHour,
                  numB: statsB.avgDrainPerHour,
                  lowerIsBetter: true,
                ),
                _ComparisonMetricTile(
                  title: 'Avg Battery Drop per Session',
                  valueA: statsA.avgBatteryDrop != null
                      ? '${statsA.avgBatteryDrop!.toStringAsFixed(0)}%'
                      : '—',
                  valueB: statsB.avgBatteryDrop != null
                      ? '${statsB.avgBatteryDrop!.toStringAsFixed(0)}%'
                      : '—',
                  numA: statsA.avgBatteryDrop,
                  numB: statsB.avgBatteryDrop,
                  lowerIsBetter: true,
                ),
                const SizedBox(height: 16),

                // Playtime & Engagement
                _SectionTitle(
                  title: 'Playtime & Sessions',
                  icon: Icons.timer_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  subtitle: 'Usage history across tracked sessions',
                ),
                const SizedBox(height: 8),
                _ComparisonMetricTile(
                  title: 'Total Playtime',
                  valueA: DurationFormatter.formatMs(statsA.totalDurationMs),
                  valueB: DurationFormatter.formatMs(statsB.totalDurationMs),
                  numA: statsA.totalDurationMs.toDouble(),
                  numB: statsB.totalDurationMs.toDouble(),
                  lowerIsBetter: false,
                ),
                _ComparisonMetricTile(
                  title: 'Total Sessions Logged',
                  valueA: '${statsA.sessionCount}',
                  valueB: '${statsB.sessionCount}',
                  numA: statsA.sessionCount.toDouble(),
                  numB: statsB.sessionCount.toDouble(),
                  lowerIsBetter: false,
                ),
                _ComparisonMetricTile(
                  title: 'Average Session Length',
                  valueA: statsA.avgDurationMs != null
                      ? DurationFormatter.formatMs(
                          statsA.avgDurationMs!.toInt())
                      : '—',
                  valueB: statsB.avgDurationMs != null
                      ? DurationFormatter.formatMs(
                          statsB.avgDurationMs!.toInt())
                      : '—',
                  numA: statsA.avgDurationMs,
                  numB: statsB.avgDurationMs,
                  lowerIsBetter: false,
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        );
      },
    );
  }
}

class _VerdictCard extends StatelessWidget {
  final GameBenchmarkStats statsA;
  final GameBenchmarkStats statsB;

  const _VerdictCard({
    required this.statsA,
    required this.statsB,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determine thermal winner
    String? thermalVerdict;
    if (statsA.avgTempC != null && statsB.avgTempC != null) {
      final diff = (statsA.avgTempC! - statsB.avgTempC!).abs();
      if (diff >= 0.5) {
        final winner = statsA.avgTempC! < statsB.avgTempC!
            ? statsA.app.appName
            : statsB.app.appName;
        thermalVerdict =
            '❄️ $winner runs ${diff.toStringAsFixed(1)}°C cooler on average.';
      } else {
        thermalVerdict = '❄️ Both games run at virtually identical temperatures.';
      }
    }

    // Determine battery winner
    String? batteryVerdict;
    if (statsA.avgDrainPerHour != null && statsB.avgDrainPerHour != null) {
      final diff =
          (statsA.avgDrainPerHour! - statsB.avgDrainPerHour!).abs();
      if (diff >= 1.0) {
        final winner = statsA.avgDrainPerHour! < statsB.avgDrainPerHour!
            ? statsA.app.appName
            : statsB.app.appName;
        batteryVerdict =
            '🔋 $winner is more power-friendly, draining ${diff.toStringAsFixed(1)}%/h less battery.';
      } else {
        batteryVerdict = '🔋 Battery drain rates are nearly equal.';
      }
    }

    if (thermalVerdict == null && batteryVerdict == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colorScheme.surfaceContainerHigh,
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Play more sessions in both games to unlock smart benchmark verdicts.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.6),
            colorScheme.surfaceContainer,
          ],
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Benchmark Verdict',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (thermalVerdict != null) ...[
            Text(
              thermalVerdict,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (batteryVerdict != null)
            Text(
              batteryVerdict,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ComparisonMetricTile extends StatelessWidget {
  final String title;
  final String valueA;
  final String valueB;
  final double? numA;
  final double? numB;
  final bool lowerIsBetter;

  const _ComparisonMetricTile({
    required this.title,
    required this.valueA,
    required this.valueB,
    this.numA,
    this.numB,
    required this.lowerIsBetter,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Determine winner highlighting
    bool aIsWinner = false;
    bool bIsWinner = false;
    if (numA != null && numB != null && numA != numB) {
      if (lowerIsBetter) {
        aIsWinner = numA! < numB!;
        bIsWinner = numB! < numA!;
      } else {
        aIsWinner = numA! > numB!;
        bIsWinner = numB! > numA!;
      }
    }

    // Ratio for proportional bar
    double ratioA = 0.5;
    if (numA != null && numB != null && (numA! + numB!) > 0) {
      ratioA = (numA! / (numA! + numB!)).clamp(0.1, 0.9);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Value A
              Row(
                children: [
                  Text(
                    valueA,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: aIsWinner
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  if (aIsWinner) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.star_rounded,
                        size: 16, color: Colors.amber),
                  ],
                ],
              ),

              // Value B
              Row(
                children: [
                  if (bIsWinner) ...[
                    const Icon(Icons.star_rounded,
                        size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    valueB,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: bIsWinner
                          ? Colors.deepOrangeAccent
                          : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Visual side-by-side proportional indicator bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: (ratioA * 100).round(),
                    child: Container(
                      color: colorScheme.primary.withValues(
                        alpha: aIsWinner ? 0.9 : 0.45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: ((1.0 - ratioA) * 100).round(),
                    child: Container(
                      color: Colors.deepOrangeAccent.withValues(
                        alpha: bIsWinner ? 0.9 : 0.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
