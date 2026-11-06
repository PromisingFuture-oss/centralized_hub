import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../data/platform/usage_stats_channel.dart';
import '../../data/platform/battery_channel.dart';
import '../../data/platform/thermal_channel.dart';
import '../../data/platform/permission_channel.dart';
import '../../data/platform/tracking_service_channel.dart';
import '../../data/repositories/app_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/sample_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/gaming_goals_repository.dart';
import '../../domain/models/gaming_goal.dart';
import '../../domain/services/session_tracker_service.dart';
import '../../domain/services/export_service.dart';
import '../../domain/services/insight_engine.dart';
import '../theme/app_theme.dart';

// ==================== Database ====================

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ==================== Platform Channels ====================

final usageStatsChannelProvider = Provider<UsageStatsChannel>((ref) {
  return UsageStatsChannel();
});

final batteryChannelProvider = Provider<BatteryChannel>((ref) {
  return BatteryChannel();
});

final thermalChannelProvider = Provider<ThermalChannel>((ref) {
  return ThermalChannel();
});

final permissionChannelProvider = Provider<PermissionChannel>((ref) {
  return PermissionChannel();
});

final trackingServiceChannelProvider = Provider<TrackingServiceChannel>((ref) {
  return TrackingServiceChannel();
});

// ==================== Repositories ====================

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return AppRepository(
    appsDao: ref.watch(databaseProvider).appsDao,
    usageStatsChannel: ref.watch(usageStatsChannelProvider),
    trackingChannel: ref.watch(trackingServiceChannelProvider),
  );
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(
    sessionsDao: ref.watch(databaseProvider).sessionsDao,
    samplesDao: ref.watch(databaseProvider).samplesDao,
  );
});

final sampleRepositoryProvider = Provider<SampleRepository>((ref) {
  return SampleRepository(
    samplesDao: ref.watch(databaseProvider).samplesDao,
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(
    dashboardDao: ref.watch(databaseProvider).dashboardDao,
  );
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    settingsDao: ref.watch(databaseProvider).settingsDao,
  );
});

final gamingGoalsRepositoryProvider = Provider<GamingGoalsRepository>((ref) {
  return GamingGoalsRepository(
    settingsDao: ref.watch(databaseProvider).settingsDao,
  );
});

final gamingGoalsStreamProvider = StreamProvider<List<GamingGoal>>((ref) {
  return ref.watch(gamingGoalsRepositoryProvider).watchGoals();
});

final pendingGoalsCountProvider = Provider<int>((ref) {
  final goals = ref.watch(gamingGoalsStreamProvider).value ?? [];
  return goals.where((g) => !g.isCompleted).length;
});

// ==================== Domain Services ====================

final sessionTrackerServiceProvider = Provider<SessionTrackerService>((ref) {
  final service = SessionTrackerService(
    appRepository: ref.watch(appRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
    sampleRepository: ref.watch(sampleRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    trackingChannel: ref.watch(trackingServiceChannelProvider),
    batteryChannel: ref.watch(batteryChannelProvider),
    thermalChannel: ref.watch(thermalChannelProvider),
  );
  ref.onDispose(() => service.dispose());
  return service;
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    appRepository: ref.watch(appRepositoryProvider),
    sessionRepository: ref.watch(sessionRepositoryProvider),
    sampleRepository: ref.watch(sampleRepositoryProvider),
  );
});

final insightEngineProvider = Provider<InsightEngine>((ref) {
  return InsightEngine(
    sessionRepository: ref.watch(sessionRepositoryProvider),
    appRepository: ref.watch(appRepositoryProvider),
  );
});

final isTrackingRunningProvider = FutureProvider<bool>((ref) async {
  final tracker = ref.watch(sessionTrackerServiceProvider);
  return await tracker.isRunning();
});

final themeModeProvider = StreamProvider<ThemeMode>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return settings.watchThemeMode().map((mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
      case 'amoled':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  });
});

final rawThemeModeProvider = StreamProvider<String>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return settings.watchThemeMode();
});

final accentColorProvider = StreamProvider<Color>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return settings.watchAccentColor().map((hex) => AppTheme.parseHexColor(hex));
});
