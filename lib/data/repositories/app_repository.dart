import 'dart:typed_data';
import '../database/app_database.dart';
import '../database/daos/apps_dao.dart';
import '../platform/usage_stats_channel.dart';
import '../platform/tracking_service_channel.dart';

/// Repository for app management, abstracting DB + platform layer.
/// Firebase sync can be added here later.
class AppRepository {
  final AppsDao _appsDao;
  final UsageStatsChannel _usageStatsChannel;
  final TrackingServiceChannel? _trackingChannel;

  AppRepository({
    required AppsDao appsDao,
    required UsageStatsChannel usageStatsChannel,
    TrackingServiceChannel? trackingChannel,
  })  : _appsDao = appsDao,
        _usageStatsChannel = usageStatsChannel,
        _trackingChannel = trackingChannel;

  /// Get all tracked apps.
  Future<List<App>> getAllApps() => _appsDao.getAllApps();

  /// Get only games.
  Future<List<App>> getGames() => _appsDao.getGames();

  /// Watch all games (reactive).
  Stream<List<App>> watchGames() => _appsDao.watchGames();

  /// Get only media apps.
  Future<List<App>> getMediaApps() => _appsDao.getMediaApps();

  /// Watch all media apps (reactive).
  Stream<List<App>> watchMediaApps() => _appsDao.watchMediaApps();

  /// Watch all apps.
  Stream<List<App>> watchAllApps() => _appsDao.watchAllApps();

  /// Find app by package name.
  Future<App?> findByPackageName(String packageName) =>
      _appsDao.findByPackageName(packageName);

  /// Get app by ID.
  Future<App?> getById(int id) => _appsDao.getById(id);

  /// Launch an app by package name directly from Centralized Hub.
  Future<bool> launchApp(String packageName) =>
      _usageStatsChannel.launchApp(packageName);

  /// Toggle game status for an app.
  Future<void> toggleGameStatus(int appId, bool isGame) async {
    await _appsDao.toggleGameStatus(appId, isGame);
    await _syncGamePackagesToNative();
  }

  /// Toggle media status for an app.
  Future<void> toggleMediaStatus(int appId, bool isMedia) async {
    await _appsDao.toggleMediaStatus(appId, isMedia);
  }

  /// Sync installed apps from the device.
  /// Fetches apps via platform channel and upserts them into the DB in a single fast transaction.
  Future<void> syncInstalledApps() async {
    final installedApps = await _usageStatsChannel.getInstalledApps();
    await _appsDao.transaction(() async {
      for (final appData in installedApps) {
        final packageName = appData['packageName'] as String;
        final appName = appData['appName'] as String;
        var isGame = appData['isGame'] as bool? ?? false;
        var isMedia = appData['isMedia'] as bool? ?? false;
        final iconBase64 = appData['iconBase64'] as String?;

        // If not flagged by manifest, apply keyword heuristics for casual games
        if (!isGame) {
          final lowerPkg = packageName.toLowerCase();
          final lowerName = appName.toLowerCase();
          const gameKeywords = [
            'game', 'blast', 'block', 'puzzle', 'arcade', 'racer',
            'craft', 'simulator', 'sudoku', 'candy', 'play', 'clash',
            'quest', 'hero', 'battle', 'race', 'runner', 'chess'
          ];
          if (gameKeywords.any((k) => lowerPkg.contains(k) || lowerName.contains(k))) {
            isGame = true;
          }
        }

        // Apply keyword heuristics for media apps if not flagged
        if (!isMedia && !isGame) {
          final lowerPkg = packageName.toLowerCase();
          final lowerName = appName.toLowerCase();
          const mediaKeywords = [
            'youtube', 'vanced', 'revanced', 'newpipe', 'netflix', 'twitch',
            'crunchyroll', 'disney', 'primevideo', 'hulu', 'bilibili', 'aniwave',
            'kick', 'plex', 'jellyfin', 'vlc', 'mxplayer', 'stream', 'video',
            'cinema', 'tv', 'dailymotion', 'mihon', 'tachiyomi', 'webtoon',
            'reader', 'comic', 'manga', 'tapas', 'lezhin', 'shonen', 'viz',
            'kindle', 'kobo', 'moonreader', 'spotify', 'soundcloud', 'music',
            'podcast', 'deezer', 'tidal', 'audible', 'pocketcasts', 'radio'
          ];
          if (mediaKeywords.any((k) => lowerPkg.contains(k) || lowerName.contains(k))) {
            isMedia = true;
          }
        }

        // Check if user has manually overridden this app
        final existing = await _appsDao.findByPackageName(packageName);
        final effectiveIsGame =
            (existing?.isUserOverride ?? false) ? existing!.isGame : isGame;
        final effectiveIsMedia = existing != null ? existing.isMedia : isMedia;

        await _appsDao.upsertApp(
          packageName: packageName,
          appName: appName,
          iconBytes: UsageStatsChannel.parseIcon(iconBase64),
          isGame: effectiveIsGame,
          isMedia: effectiveIsMedia,
          isAutoDetected: isGame,
        );
      }
    });

    await _syncGamePackagesToNative();
  }

  Future<void> _syncGamePackagesToNative() async {
    final tracking = _trackingChannel;
    if (tracking == null) return;
    try {
      final games = await _appsDao.getGames();
      final packages = games.map((g) => g.packageName).toList();
      await tracking.updateGamePackages(packages);
    } catch (_) {}
  }

  /// Ensure an app exists in the DB. Returns the app's DB ID.
  Future<int> ensureApp({
    required String packageName,
    required String appName,
    bool isGame = false,
    bool isMedia = false,
    Uint8List? iconBytes,
  }) async {
    final existing = await _appsDao.findByPackageName(packageName);
    if (existing != null) return existing.id;

    return _appsDao.upsertApp(
      packageName: packageName,
      appName: appName,
      iconBytes: iconBytes,
      isGame: isGame,
      isMedia: isMedia,
      isAutoDetected: isGame,
    );
  }
}
