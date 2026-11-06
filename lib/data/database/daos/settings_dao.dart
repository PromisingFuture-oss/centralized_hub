import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Get a setting value by key.
  Future<String?> getValue(String key) async {
    final result = await (select(settings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  /// Watch a setting value reactively.
  Stream<String?> watchValue(String key) {
    return (select(settings)..where((s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  /// Set a setting value (insert or update).
  Future<void> setValue(String key, String value) {
    return into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }

  /// Get all settings as a map.
  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(settings).get();
    return {for (final row in rows) row.key: row.value};
  }

  /// Watch all settings.
  Stream<Map<String, String>> watchAllSettings() {
    return select(settings).watch().map(
        (rows) => {for (final row in rows) row.key: row.value});
  }

  /// Delete a specific setting (revert to default on next read).
  Future<int> deleteSetting(String key) =>
      (delete(settings)..where((s) => s.key.equals(key))).go();
}
