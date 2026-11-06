import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/app_constants.dart';
import 'tables/apps_table.dart';
import 'tables/sessions_table.dart';
import 'tables/samples_table.dart';
import 'tables/dashboard_layouts_table.dart';
import 'tables/settings_table.dart';
import 'daos/apps_dao.dart';
import 'daos/sessions_dao.dart';
import 'daos/samples_dao.dart';
import 'daos/dashboard_dao.dart';
import 'daos/settings_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Apps, Sessions, Samples, DashboardLayouts, Settings],
  daos: [AppsDao, SessionsDao, SamplesDao, DashboardDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with a provided executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Insert default settings
          await _insertDefaultSettings();
          // Insert default dashboard layouts
          await _insertDefaultLayouts();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(apps, apps.isMedia);
          }
        },
      );

  Future<void> _insertDefaultSettings() async {
    final defaults = {
      'theme_mode': '"system"',
      'accent_color': '"#6750A4"',
      'temp_unit': '"celsius"',
      'sample_interval_ms': '${AppConstants.defaultSampleIntervalMs}',
      'min_session_duration_ms': '${AppConstants.minSessionDurationMs}',
      'onboarding_complete': 'false',
      'temp_alert_threshold_c': 'null',
      'tracking_enabled': 'true',
    };

    for (final entry in defaults.entries) {
      await into(settings).insert(
        SettingsCompanion.insert(key: entry.key, value: entry.value),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  Future<void> _insertDefaultLayouts() async {
    final now = DateTime.now();
    // Overview preset
    await into(dashboardLayouts).insert(
      DashboardLayoutsCompanion.insert(
        name: 'Overview',
        isActive: const Value(true),
        isPreset: const Value(true),
        cardsJson: '''[
          {"card_type":"totalPlaytime","size":"medium","position":0,"settings":{"time_range":"today"}},
          {"card_type":"topGames","size":"medium","position":1,"settings":{"time_range":"week","chart_type":"bar"}},
          {"card_type":"recentSessions","size":"large","position":2,"settings":{"limit":5}},
          {"card_type":"liveSession","size":"medium","position":3,"settings":{}}
        ]''',
        sortOrder: const Value(0),
        createdAt: now,
        updatedAt: now,
      ),
    );
    // Thermals preset
    await into(dashboardLayouts).insert(
      DashboardLayoutsCompanion.insert(
        name: 'Thermals',
        isActive: const Value(false),
        isPreset: const Value(true),
        cardsJson: '''[
          {"card_type":"temperatureTrend","size":"large","position":0,"settings":{"time_range":"week","chart_type":"line"}},
          {"card_type":"hottestSessions","size":"medium","position":1,"settings":{"limit":5}},
          {"card_type":"batteryDrain","size":"medium","position":2,"settings":{"time_range":"week","chart_type":"bar"}}
        ]''',
        sortOrder: const Value(1),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Deletes all user data (sessions, samples, apps) but preserves settings.
  Future<void> deleteAllData() async {
    await transaction(() async {
      await delete(samples).go();
      await delete(sessions).go();
      await delete(apps).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}
