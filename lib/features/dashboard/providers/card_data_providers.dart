import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/enums/time_range.dart';
import 'dashboard_filter_provider.dart';

/// Provides filtered sessions based on current DashboardFilter settings.
final filteredSessionsProvider = StreamProvider<List<Session>>((ref) {
  final filter = ref.watch(dashboardFilterProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final startDate = filter.timeRange.startDate;
  // Use end of tomorrow so reactive stream includes current and newly created sessions
  final now = DateTime.now();
  final endDate = DateTime(now.year, now.month, now.day + 1, 23, 59, 59);

  return sessionRepo.watchSessionsInRange(startDate, endDate).map((sessions) {
    return sessions.where((s) {
      if (filter.selectedAppId != null && s.appId != filter.selectedAppId) {
        return false;
      }
      if (filter.chargingOnly != null) {
        final wasCharging = s.hadChargingDuring || s.wasChargingStart;
        if (wasCharging != filter.chargingOnly) return false;
      }
      return true;
    }).toList();
  });
});

/// Metrics for total playtime card.
class TotalPlaytimeMetrics {
  final int totalMs;
  final String formatted;
  final int sessionCount;
  final String avgSessionFormatted;

  const TotalPlaytimeMetrics({
    required this.totalMs,
    required this.formatted,
    required this.sessionCount,
    required this.avgSessionFormatted,
  });
}

final totalPlaytimeMetricsProvider = Provider<TotalPlaytimeMetrics>((ref) {
  final sessions = ref.watch(filteredSessionsProvider).value ?? [];
  final now = DateTime.now();

  final totalMs = sessions.fold<int>(
    0,
    (sum, s) {
      final dur = s.durationMs ??
          (s.endTime != null
              ? s.endTime!.difference(s.startTime).inMilliseconds
              : now.difference(s.startTime).inMilliseconds);
      return sum + (dur > 0 ? dur : 0);
    },
  );

  final sessionCount = sessions.length;
  final avgMs = sessionCount > 0 ? (totalMs / sessionCount).round() : 0;

  return TotalPlaytimeMetrics(
    totalMs: totalMs,
    formatted: DurationFormatter.formatMs(totalMs),
    sessionCount: sessionCount,
    avgSessionFormatted: DurationFormatter.formatMs(avgMs),
  );
});

/// Metrics for a top game item.
class TopGameItem {
  final App app;
  final int totalPlaytimeMs;
  final int sessionCount;
  final double percentage;

  const TopGameItem({
    required this.app,
    required this.totalPlaytimeMs,
    required this.sessionCount,
    required this.percentage,
  });
}

final topGamesMetricsProvider = FutureProvider<List<TopGameItem>>((ref) async {
  final sessions = ref.watch(filteredSessionsProvider).value ?? [];
  final appRepo = ref.watch(appRepositoryProvider);
  final apps = await appRepo.getAllApps();
  final appMap = {for (final a in apps) a.id: a};

  final Map<int, int> playtimes = {};
  final Map<int, int> counts = {};
  int grandTotal = 0;

  final now = DateTime.now();
  for (final s in sessions) {
    final dur = s.durationMs ??
        (s.endTime != null
            ? s.endTime!.difference(s.startTime).inMilliseconds
            : now.difference(s.startTime).inMilliseconds);
    if (dur <= 0) continue;
    playtimes[s.appId] = (playtimes[s.appId] ?? 0) + dur;
    counts[s.appId] = (counts[s.appId] ?? 0) + 1;
    grandTotal += dur;
  }

  final items = <TopGameItem>[];
  for (final entry in playtimes.entries) {
    final app = appMap[entry.key];
    if (app == null) continue;
    final pct = grandTotal > 0 ? (entry.value / grandTotal) * 100 : 0.0;
    items.add(TopGameItem(
      app: app,
      totalPlaytimeMs: entry.value,
      sessionCount: counts[entry.key] ?? 0,
      percentage: pct,
    ));
  }

  items.sort((a, b) => b.totalPlaytimeMs.compareTo(a.totalPlaytimeMs));
  return items;
});

/// Range selection for Top 5 Games card (Discord recap style).
final selectedTopGamesRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.week);

/// Stream of sessions for the selected Top 5 range.
final top5SessionsProvider = StreamProvider<List<Session>>((ref) {
  final range = ref.watch(selectedTopGamesRangeProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final startDate = range.startDate;
  final now = DateTime.now();
  final endDate = DateTime(now.year, now.month, now.day + 1, 23, 59, 59);
  return sessionRepo.watchSessionsInRange(startDate, endDate);
});

/// Computes the Top 5 games played within the selected timeframe.
final top5GamesByRangeProvider = FutureProvider<List<TopGameItem>>((ref) async {
  final sessions = ref.watch(top5SessionsProvider).value ?? [];
  final appRepo = ref.watch(appRepositoryProvider);
  final apps = await appRepo.getAllApps();
  final appMap = {for (final a in apps) a.id: a};

  final Map<int, int> playtimes = {};
  final Map<int, int> counts = {};
  int grandTotal = 0;

  final now = DateTime.now();
  for (final s in sessions) {
    final dur = s.durationMs ??
        (s.endTime != null
            ? s.endTime!.difference(s.startTime).inMilliseconds
            : now.difference(s.startTime).inMilliseconds);
    if (dur <= 0) continue;
    playtimes[s.appId] = (playtimes[s.appId] ?? 0) + dur;
    counts[s.appId] = (counts[s.appId] ?? 0) + 1;
    grandTotal += dur;
  }

  final items = <TopGameItem>[];
  for (final entry in playtimes.entries) {
    final app = appMap[entry.key];
    if (app == null) continue;
    final pct = grandTotal > 0 ? (entry.value / grandTotal) * 100 : 0.0;
    items.add(TopGameItem(
      app: app,
      totalPlaytimeMs: entry.value,
      sessionCount: counts[entry.key] ?? 0,
      percentage: pct,
    ));
  }

  items.sort((a, b) => b.totalPlaytimeMs.compareTo(a.totalPlaytimeMs));
  return items.take(5).toList();
});

/// Temperature metrics for the dashboard.
class TemperatureMetrics {
  final double? avgTemp;
  final double? peakTemp;
  final String? hottestGameName;

  const TemperatureMetrics({
    this.avgTemp,
    this.peakTemp,
    this.hottestGameName,
  });
}

final temperatureMetricsProvider = FutureProvider<TemperatureMetrics>((ref) async {
  final sessions = ref.watch(filteredSessionsProvider).value ?? [];
  final sampleRepo = ref.watch(sampleRepositoryProvider);

  double totalAvg = 0;
  int avgCount = 0;
  double peak = 0;
  int? peakAppId;

  for (final s in sessions) {
    double? sMax = s.tempMaxC;
    double? sAvg = s.tempAvgC;

    // Fallback: check raw samples if session aggregates not yet computed
    if (sMax == null || sAvg == null) {
      final stats = await sampleRepo.getTemperatureStats(s.id);
      sMax ??= stats.max;
      sAvg ??= stats.avg;
    }

    if (sAvg != null) {
      totalAvg += sAvg;
      avgCount++;
    }
    if (sMax != null && sMax > peak) {
      peak = sMax;
      peakAppId = s.appId;
    }
  }

  String? hottestName;
  if (peakAppId != null) {
    final app = await ref.read(appRepositoryProvider).getById(peakAppId);
    hottestName = app?.appName;
  }

  return TemperatureMetrics(
    avgTemp: avgCount > 0 ? totalAvg / avgCount : null,
    peakTemp: peak > 0 ? peak : null,
    hottestGameName: hottestName,
  );
});

/// Battery metrics for the dashboard.
class BatteryDrainMetrics {
  final double avgDropPercent;
  final double avgDropPerHour;
  final int dischargingSessionsCount;

  const BatteryDrainMetrics({
    required this.avgDropPercent,
    required this.avgDropPerHour,
    required this.dischargingSessionsCount,
  });
}

final batteryDrainMetricsProvider = Provider<BatteryDrainMetrics>((ref) {
  final sessions = ref.watch(filteredSessionsProvider).value ?? [];
  final nonCharging = sessions.where((s) {
    final wasCharging = s.hadChargingDuring || s.wasChargingStart;
    return !wasCharging && s.batteryDrop != null && (s.durationMs ?? 0) > 60000;
  }).toList();

  if (nonCharging.isEmpty) {
    return const BatteryDrainMetrics(
      avgDropPercent: 0,
      avgDropPerHour: 0,
      dischargingSessionsCount: 0,
    );
  }

  double totalDrop = 0;
  double totalDropPerHour = 0;

  for (final s in nonCharging) {
    final drop = (s.batteryDrop ?? 0).toDouble();
    totalDrop += drop;
    final hours = (s.durationMs ?? 0) / 3600000.0;
    if (hours > 0) {
      totalDropPerHour += (drop / hours);
    }
  }

  return BatteryDrainMetrics(
    avgDropPercent: totalDrop / nonCharging.length,
    avgDropPerHour: totalDropPerHour / nonCharging.length,
    dischargingSessionsCount: nonCharging.length,
  );
});

/// Stream provider for live active session.
final activeSessionStreamProvider = StreamProvider<Session?>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return sessionRepo.watchActiveSession();
});
