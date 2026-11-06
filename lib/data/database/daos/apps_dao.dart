import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/apps_table.dart';

part 'apps_dao.g.dart';

@DriftAccessor(tables: [Apps])
class AppsDao extends DatabaseAccessor<AppDatabase> with _$AppsDaoMixin {
  AppsDao(super.db);

  /// Get all tracked apps.
  Future<List<App>> getAllApps() => select(apps).get();

  /// Get only apps marked as games.
  Future<List<App>> getGames() =>
      (select(apps)..where((a) => a.isGame.equals(true))).get();

  /// Watch all games (reactive stream).
  Stream<List<App>> watchGames() =>
      (select(apps)..where((a) => a.isGame.equals(true))).watch();

  /// Get only apps marked as media.
  Future<List<App>> getMediaApps() =>
      (select(apps)..where((a) => a.isMedia.equals(true))).get();

  /// Watch only media apps (reactive stream).
  Stream<List<App>> watchMediaApps() =>
      (select(apps)..where((a) => a.isMedia.equals(true))).watch();

  /// Watch all apps.
  Stream<List<App>> watchAllApps() => select(apps).watch();

  /// Find app by package name.
  Future<App?> findByPackageName(String packageName) =>
      (select(apps)..where((a) => a.packageName.equals(packageName)))
          .getSingleOrNull();

  /// Insert or update an app.
  Future<int> upsertApp({
    required String packageName,
    required String appName,
    Uint8List? iconBytes,
    required bool isGame,
    bool isMedia = false,
    required bool isAutoDetected,
  }) async {
    final existing = await findByPackageName(packageName);
    if (existing != null) {
      await (update(apps)..where((a) => a.id.equals(existing.id))).write(
        AppsCompanion(
          appName: Value(appName),
          iconBytes: iconBytes != null ? Value(iconBytes) : const Value.absent(),
          isGame: Value(isGame),
          isMedia: Value(isMedia),
          isAutoDetected: Value(isAutoDetected),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return existing.id;
    } else {
      return into(apps).insert(
        AppsCompanion.insert(
          packageName: packageName,
          appName: appName,
          iconBytes: Value(iconBytes),
          isGame: Value(isGame),
          isMedia: Value(isMedia),
          isAutoDetected: Value(isAutoDetected),
          firstSeenAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  /// Toggle the media status for a specific app.
  Future<void> toggleMediaStatus(int appId, bool isMedia) {
    return (update(apps)..where((a) => a.id.equals(appId))).write(
      AppsCompanion(
        isMedia: Value(isMedia),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Toggle the game status for a specific app (user override).
  Future<void> toggleGameStatus(int appId, bool isGame) {
    return (update(apps)..where((a) => a.id.equals(appId))).write(
      AppsCompanion(
        isGame: Value(isGame),
        isUserOverride: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update app icon.
  Future<void> updateIcon(int appId, Uint8List? iconBytes) {
    return (update(apps)..where((a) => a.id.equals(appId))).write(
      AppsCompanion(
        iconBytes: Value(iconBytes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Get app by ID.
  Future<App?> getById(int id) =>
      (select(apps)..where((a) => a.id.equals(id))).getSingleOrNull();
}
