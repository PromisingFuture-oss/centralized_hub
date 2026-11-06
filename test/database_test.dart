import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centralized_hub/data/database/app_database.dart';
import 'package:centralized_hub/data/repositories/app_repository.dart';
import 'package:centralized_hub/data/repositories/session_repository.dart';
import 'package:centralized_hub/data/repositories/sample_repository.dart';
import 'package:centralized_hub/data/repositories/settings_repository.dart';
import 'package:centralized_hub/data/platform/usage_stats_channel.dart';
import 'package:mocktail/mocktail.dart';

class MockUsageStatsChannel extends Mock implements UsageStatsChannel {}

void main() {
  late AppDatabase db;
  late MockUsageStatsChannel mockUsageStatsChannel;
  late AppRepository appRepo;
  late SessionRepository sessionRepo;
  late SampleRepository sampleRepo;
  late SettingsRepository settingsRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockUsageStatsChannel = MockUsageStatsChannel();
    appRepo = AppRepository(
      appsDao: db.appsDao,
      usageStatsChannel: mockUsageStatsChannel,
    );
    sessionRepo = SessionRepository(
      sessionsDao: db.sessionsDao,
      samplesDao: db.samplesDao,
    );
    sampleRepo = SampleRepository(
      samplesDao: db.samplesDao,
    );
    settingsRepo = SettingsRepository(
      settingsDao: db.settingsDao,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('AppRepository & AppsDao', () {
    test('upsert and query tracked app', () async {
      final appId = await db.appsDao.upsertApp(
        packageName: 'com.example.game',
        appName: 'Epic Game',
        isGame: true,
        isAutoDetected: true,
      );
      expect(appId, isPositive);

      final app = await appRepo.findByPackageName('com.example.game');
      expect(app, isNotNull);
      expect(app!.appName, 'Epic Game');
      expect(app.isGame, isTrue);

      final games = await appRepo.getGames();
      expect(games.length, 1);
      expect(games.first.packageName, 'com.example.game');
    });

    test('toggle game status', () async {
      final appId = await db.appsDao.upsertApp(
        packageName: 'com.example.tool',
        appName: 'Tool App',
        isGame: false,
        isAutoDetected: false,
      );

      var app = await appRepo.getById(appId);
      expect(app!.isGame, isFalse);

      await appRepo.toggleGameStatus(appId, true);
      app = await appRepo.getById(appId);
      expect(app!.isGame, isTrue);
    });

    test('upsert and query media apps', () async {
      final appId = await db.appsDao.upsertApp(
        packageName: 'com.google.android.youtube',
        appName: 'YouTube',
        isGame: false,
        isMedia: true,
        isAutoDetected: false,
      );

      final app = await appRepo.getById(appId);
      expect(app, isNotNull);
      expect(app!.isMedia, isTrue);
      expect(app.isGame, isFalse);

      final mediaApps = await appRepo.getMediaApps();
      expect(mediaApps.length, 1);
      expect(mediaApps.first.packageName, 'com.google.android.youtube');

      await appRepo.toggleMediaStatus(appId, false);
      final updatedApp = await appRepo.getById(appId);
      expect(updatedApp!.isMedia, isFalse);
    });

    test('syncInstalledApps recognizes media apps and heuristics', () async {
      when(() => mockUsageStatsChannel.getInstalledApps()).thenAnswer(
        (_) async => [
          {
            'packageName': 'com.netflix.mediaclient',
            'appName': 'Netflix',
            'isGame': false,
            'isMedia': true,
            'iconBase64': null,
          },
          {
            'packageName': 'eu.kanade.tachiyomi',
            'appName': 'Tachiyomi',
            'isGame': false,
            'isMedia': false, // Heuristic should catch this
            'iconBase64': null,
          },
        ],
      );

      await appRepo.syncInstalledApps();

      final mediaApps = await appRepo.getMediaApps();
      expect(mediaApps.length, 2);
      expect(mediaApps.any((a) => a.packageName == 'com.netflix.mediaclient'), isTrue);
      expect(mediaApps.any((a) => a.packageName == 'eu.kanade.tachiyomi'), isTrue);
    });
  });

  group('SessionRepository & SampleRepository', () {
    test('track full session with samples and verify metrics', () async {
      final appId = await db.appsDao.upsertApp(
        packageName: 'com.game.rpg',
        appName: 'RPG Master',
        isGame: true,
        isAutoDetected: true,
      );

      final startTime = DateTime.now().subtract(const Duration(minutes: 30));
      final sessionId = await sessionRepo.createSession(
        appId: appId,
        startTime: startTime,
        batteryStart: 90,
        wasChargingStart: false,
      );

      // Verify active session lookup
      final active = await sessionRepo.getActiveSession();
      expect(active, isNotNull);
      expect(active!.id, sessionId);

      // Add samples
      await sampleRepo.insertSample(
        sessionId: sessionId,
        timestamp: startTime.add(const Duration(minutes: 10)),
        batteryLevel: 88,
        batteryTempC: 36.5,
        isCharging: false,
      );

      await sampleRepo.insertSample(
        sessionId: sessionId,
        timestamp: startTime.add(const Duration(minutes: 20)),
        batteryLevel: 85,
        batteryTempC: 39.0,
        isCharging: false,
      );

      final samples = await sampleRepo.getSamplesForSession(sessionId);
      expect(samples.length, 2);

      // End session
      final endTime = DateTime.now();
      await sessionRepo.endSession(
        sessionId: sessionId,
        endTime: endTime,
        batteryEnd: 82,
        wasChargingEnd: false,
      );

      final closedSession = await sessionRepo.getById(sessionId);
      expect(closedSession, isNotNull);
      expect(closedSession!.endTime, isNotNull);
      expect(closedSession.batteryDrop, 8); // 90 - 82
      expect(closedSession.tempMaxC, 39.0);
    });
  });

  group('SettingsRepository', () {
    test('read and update settings', () async {
      expect(await settingsRepo.getSampleIntervalMs(), 30000);
      await settingsRepo.setSampleIntervalMs(15000);
      expect(await settingsRepo.getSampleIntervalMs(), 15000);

      expect(await settingsRepo.isOnboardingComplete(), isFalse);
      await settingsRepo.setOnboardingComplete(true);
      expect(await settingsRepo.isOnboardingComplete(), isTrue);
    });
  });
}
