import '../../data/database/app_database.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/app_repository.dart';
import '../../domain/enums/time_range.dart';

/// A generated insight about the user's gaming behavior.
class Insight {
  final String title;
  final String description;
  final InsightType type;
  final String? gamePackageName;
  final double? value;
  final String? badgeText;

  const Insight({
    required this.title,
    required this.description,
    required this.type,
    this.gamePackageName,
    this.value,
    this.badgeText,
  });
}

enum InsightType {
  hotGame,
  batteryDrain,
  longestSession,
  mostPlayed,
  streak,
  temperatureAlert,
  timeHabit,
  batteryFriendly,
}

/// Rule-based insight engine that generates observations from session data.
class InsightEngine {
  final SessionRepository _sessionRepository;
  final AppRepository _appRepository;

  InsightEngine({
    required SessionRepository sessionRepository,
    required AppRepository appRepository,
  })  : _sessionRepository = sessionRepository,
        _appRepository = appRepository;

  /// Generate all insights for the given time range.
  Future<List<Insight>> generateInsights({
    TimeRange timeRange = TimeRange.week,
  }) async {
    final insights = <Insight>[];
    final start = timeRange.startDate;
    final end = DateTime.now();

    final sessions =
        await _sessionRepository.getSessionsInRange(start, end);
    if (sessions.isEmpty) return insights;

    final apps = await _appRepository.getAllApps();
    final appMap = {for (final a in apps) a.id: a};

    // --- 1. Consecutive Gaming Streak ---
    insights.addAll(_findStreak(sessions));

    // --- 2. High Heat / Thermal Alerts ---
    insights.addAll(_findTemperatureAlerts(sessions, appMap));

    // --- 3. Hottest Game ---
    insights.addAll(await _findHottestGame(sessions, appMap));

    // --- 4. Biggest Battery Drain ---
    insights.addAll(await _findBiggestBatteryDrain(sessions, appMap));

    // --- 5. Battery Efficiency Champion ---
    insights.addAll(await _findBatteryFriendlyGame(sessions, appMap));

    // --- 6. Longest Session ---
    insights.addAll(_findLongestSession(sessions, appMap));

    // --- 7. Most Played Game ---
    insights.addAll(_findMostPlayed(sessions, appMap));

    // --- 8. Time of Day & Habits ---
    insights.addAll(_findTimeOfDayHabits(sessions));

    return insights;
  }

  List<Insight> _findStreak(List<Session> sessions) {
    final results = <Insight>[];
    if (sessions.isEmpty) return results;

    final uniqueDates = sessions
        .map((s) => DateTime(s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) return results;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Check if the streak is currently active
    final latest = uniqueDates.first;
    if (latest != today && latest != yesterday) {
      return results;
    }

    int streak = 1;
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    if (streak >= 2) {
      results.add(Insight(
        title: '$streak-Day Gaming Streak 🔥',
        description:
            'You have logged gaming sessions across $streak consecutive days. Keep the momentum going!',
        type: InsightType.streak,
        badgeText: 'STREAK',
        value: streak.toDouble(),
      ));
    }

    return results;
  }

  List<Insight> _findTemperatureAlerts(
      List<Session> sessions, Map<int, App> appMap) {
    final results = <Insight>[];

    // Find highest peak temp session
    Session? hottestSession;
    for (final s in sessions) {
      if (s.tempMaxC != null) {
        if (hottestSession == null || s.tempMaxC! > hottestSession.tempMaxC!) {
          hottestSession = s;
        }
      }
    }

    if (hottestSession != null && (hottestSession.tempMaxC ?? 0) >= 39.0) {
      final app = appMap[hottestSession.appId];
      if (app != null) {
        final peak = hottestSession.tempMaxC!;
        results.add(Insight(
          title: 'High Heat Alert: ${app.appName}',
          description:
              '${app.appName} hit a peak temperature of ${peak.toStringAsFixed(1)}°C. High temperatures can cause thermal throttling and increase battery degradation.',
          type: InsightType.temperatureAlert,
          badgeText: 'HEAT ALERT',
          gamePackageName: app.packageName,
          value: peak,
        ));
      }
    }

    return results;
  }

  Future<List<Insight>> _findHottestGame(
      List<Session> sessions, Map<int, App> appMap) async {
    final results = <Insight>[];

    // Compute average temp per game
    final avgTemps = <int, List<double>>{};
    for (final s in sessions) {
      if (s.tempAvgC != null) {
        avgTemps.putIfAbsent(s.appId, () => []).add(s.tempAvgC!);
      }
    }

    if (avgTemps.length < 2) return results;

    // Overall average
    final allTemps = avgTemps.values.expand((t) => t).toList();
    final overallAvg = allTemps.reduce((a, b) => a + b) / allTemps.length;

    // Find games hotter than average
    for (final entry in avgTemps.entries) {
      final gameAvg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      final diff = gameAvg - overallAvg;
      if (diff > 2.0) {
        final app = appMap[entry.key];
        if (app != null) {
          results.add(Insight(
            title: '${app.appName} runs hot',
            description:
                '${app.appName} runs ${diff.toStringAsFixed(1)}°C hotter than your average game.',
            type: InsightType.hotGame,
            badgeText: 'HOT GAME',
            gamePackageName: app.packageName,
            value: diff,
          ));
        }
      }
    }

    return results;
  }

  Future<List<Insight>> _findBiggestBatteryDrain(
      List<Session> sessions, Map<int, App> appMap) async {
    final results = <Insight>[];

    // Compute drain per hour per game (only non-charging sessions)
    final drainRates = <int, List<double>>{};
    for (final s in sessions) {
      if (s.hadChargingDuring || s.batteryDrop == null || s.durationMs == null) {
        continue;
      }
      if (s.durationMs! < 300000) continue; // need at least 5 min
      final hours = s.durationMs! / 3600000;
      final drainPerHour = s.batteryDrop! / hours;
      if (drainPerHour > 0) {
        drainRates.putIfAbsent(s.appId, () => []).add(drainPerHour);
      }
    }

    if (drainRates.isEmpty) return results;

    // Find highest drain rate
    double maxRate = 0;
    int? maxAppId;
    for (final entry in drainRates.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg > maxRate) {
        maxRate = avg;
        maxAppId = entry.key;
      }
    }

    if (maxAppId != null) {
      final app = appMap[maxAppId];
      if (app != null) {
        results.add(Insight(
          title: 'Battery drains fastest in ${app.appName}',
          description:
              '${app.appName} drains ${maxRate.toStringAsFixed(1)}% battery per hour of play.',
          type: InsightType.batteryDrain,
          badgeText: 'HIGH DRAIN',
          gamePackageName: app.packageName,
          value: maxRate,
        ));
      }
    }

    return results;
  }

  Future<List<Insight>> _findBatteryFriendlyGame(
      List<Session> sessions, Map<int, App> appMap) async {
    final results = <Insight>[];
    final drainRates = <int, List<double>>{};

    for (final s in sessions) {
      if (s.hadChargingDuring || s.batteryDrop == null || s.durationMs == null) {
        continue;
      }
      if (s.durationMs! < 300000) continue; // at least 5 min
      final hours = s.durationMs! / 3600000;
      final drainPerHour = s.batteryDrop! / hours;
      if (drainPerHour > 0) {
        drainRates.putIfAbsent(s.appId, () => []).add(drainPerHour);
      }
    }

    if (drainRates.length < 2) return results;

    double minRate = double.infinity;
    int? minAppId;
    for (final entry in drainRates.entries) {
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avg < minRate && avg <= 15.0) {
        minRate = avg;
        minAppId = entry.key;
      }
    }

    if (minAppId != null) {
      final app = appMap[minAppId];
      if (app != null) {
        results.add(Insight(
          title: 'Battery Champion: ${app.appName}',
          description:
              '${app.appName} is your most power-efficient game, consuming only ${minRate.toStringAsFixed(1)}% battery per hour.',
          type: InsightType.batteryFriendly,
          badgeText: 'EFFICIENCY',
          gamePackageName: app.packageName,
          value: minRate,
        ));
      }
    }

    return results;
  }

  List<Insight> _findLongestSession(
      List<Session> sessions, Map<int, App> appMap) {
    final results = <Insight>[];
    Session? longest;
    for (final s in sessions) {
      if (s.durationMs != null &&
          (longest == null || s.durationMs! > (longest.durationMs ?? 0))) {
        longest = s;
      }
    }
    if (longest != null && longest.durationMs != null) {
      final app = appMap[longest.appId];
      if (app != null) {
        final hours = longest.durationMs! / 3600000;
        results.add(Insight(
          title: 'Longest session: ${app.appName}',
          description:
              'Your longest session was ${hours.toStringAsFixed(1)} hours in ${app.appName}.',
          type: InsightType.longestSession,
          badgeText: 'RECORD',
          gamePackageName: app.packageName,
          value: hours,
        ));
      }
    }
    return results;
  }

  List<Insight> _findMostPlayed(
      List<Session> sessions, Map<int, App> appMap) {
    final results = <Insight>[];
    final playtimes = <int, int>{};
    for (final s in sessions) {
      if (s.durationMs != null) {
        playtimes[s.appId] = (playtimes[s.appId] ?? 0) + s.durationMs!;
      }
    }
    if (playtimes.isEmpty) return results;

    final sorted = playtimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = sorted.first;
    final app = appMap[top.key];
    if (app != null) {
      final hours = top.value / 3600000;
      results.add(Insight(
        title: 'Most played: ${app.appName}',
        description:
            '${app.appName} has ${hours.toStringAsFixed(1)} hours of playtime this period.',
        type: InsightType.mostPlayed,
        badgeText: 'TOP GAME',
        gamePackageName: app.packageName,
        value: hours,
      ));
    }
    return results;
  }

  List<Insight> _findTimeOfDayHabits(List<Session> sessions) {
    final results = <Insight>[];
    if (sessions.length < 3) return results;

    int nightCount = 0; // 22:00 - 04:00
    int eveningCount = 0; // 18:00 - 21:59
    int weekendPlaytimeMs = 0;
    int totalPlaytimeMs = 0;

    for (final s in sessions) {
      final hour = s.startTime.hour;
      final dur = s.durationMs ?? 0;
      totalPlaytimeMs += dur;

      if (hour >= 22 || hour < 4) {
        nightCount++;
      } else if (hour >= 18 && hour < 22) {
        eveningCount++;
      }

      final weekday = s.startTime.weekday;
      if (weekday == DateTime.saturday || weekday == DateTime.sunday) {
        weekendPlaytimeMs += dur;
      }
    }

    final totalSessions = sessions.length;
    final nightRatio = nightCount / totalSessions;
    final weekendRatio =
        totalPlaytimeMs > 0 ? (weekendPlaytimeMs / totalPlaytimeMs) : 0.0;

    if (nightRatio >= 0.4) {
      final percent = (nightRatio * 100).round();
      results.add(Insight(
        title: 'Night Owl Gamer 🌙',
        description:
            '$percent% of your gaming sessions take place between 10 PM and 4 AM. Make sure to take screen breaks and rest your eyes!',
        type: InsightType.timeHabit,
        badgeText: 'HABIT',
      ));
    } else if (weekendRatio >= 0.6) {
      final percent = (weekendRatio * 100).round();
      results.add(Insight(
        title: 'Weekend Warrior ⚔️',
        description:
            '$percent% of your playtime is logged on Saturdays and Sundays. Weekdays are light while weekends are for grinding.',
        type: InsightType.timeHabit,
        badgeText: 'HABIT',
      ));
    } else if ((eveningCount / totalSessions) >= 0.5) {
      final percent = ((eveningCount / totalSessions) * 100).round();
      results.add(Insight(
        title: 'Evening Relaxer 🌆',
        description:
            '$percent% of your gaming happens during evening wind-down hours (6 PM – 10 PM).',
        type: InsightType.timeHabit,
        badgeText: 'HABIT',
      ));
    }

    return results;
  }
}
