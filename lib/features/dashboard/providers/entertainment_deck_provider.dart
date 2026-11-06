import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';

const String _pinnedMediaKey = 'pinned_media_packages';

/// List of keywords used to identify entertainment, video, reading, and audio apps.
const List<String> entertainmentKeywords = [
  // Video & Streaming
  'youtube', 'vanced', 'revanced', 'newpipe', 'netflix', 'twitch',
  'crunchyroll', 'disney', 'primevideo', 'hulu', 'bilibili', 'aniwave',
  'kick', 'plex', 'jellyfin', 'vlc', 'mxplayer', 'stream', 'video',
  'cinema', 'tv', 'dailymotion',
  // Manga, Comics & Reading
  'mihon', 'tachiyomi', 'webtoon', 'reader', 'comic', 'manga',
  'tapas', 'lezhin', 'shonen', 'viz', 'kindle', 'kobo', 'moonreader',
  // Audio & Podcasts
  'spotify', 'soundcloud', 'music', 'podcast', 'deezer', 'tidal',
  'audible', 'pocketcasts', 'radio'
];

/// Watches the list of user-pinned media package names from persistent settings.
final pinnedMediaPackagesProvider = StreamProvider<List<String>>((ref) {
  final settingsDao = ref.watch(databaseProvider).settingsDao;
  return settingsDao.watchValue(_pinnedMediaKey).map((val) {
    if (val == null || val.isEmpty) return <String>[];
    try {
      final decoded = jsonDecode(val);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return <String>[];
  });
});

/// Controller to pin or unpin media packages.
class PinnedMediaController {
  final Ref _ref;
  PinnedMediaController(this._ref);

  Future<void> togglePin(String packageName) async {
    final settingsDao = _ref.read(databaseProvider).settingsDao;
    final currentVal = await settingsDao.getValue(_pinnedMediaKey);
    List<String> currentList = [];
    if (currentVal != null && currentVal.isNotEmpty) {
      try {
        final decoded = jsonDecode(currentVal);
        if (decoded is List) {
          currentList = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    if (currentList.contains(packageName)) {
      currentList.remove(packageName);
    } else {
      currentList.add(packageName);
    }

    await settingsDao.setValue(_pinnedMediaKey, jsonEncode(currentList));
  }

  Future<void> setPinned(List<String> packages) async {
    final settingsDao = _ref.read(databaseProvider).settingsDao;
    await settingsDao.setValue(_pinnedMediaKey, jsonEncode(packages));
  }
}

final pinnedMediaControllerProvider = Provider<PinnedMediaController>((ref) {
  return PinnedMediaController(ref);
});

/// Stream of all apps from the database.
final _allAppsDbStreamProvider = StreamProvider<List<App>>((ref) {
  return ref.watch(databaseProvider).appsDao.watchAllApps();
});

/// Returns apps that should be displayed in the Entertainment Deck:
/// 1. User-pinned packages (shown first).
/// 2. Auto-detected media/entertainment apps (non-games matching keywords).
final entertainmentDeckAppsProvider = Provider<AsyncValue<List<App>>>((ref) {
  final allAppsAsync = ref.watch(_allAppsDbStreamProvider);
  final pinnedAsync = ref.watch(pinnedMediaPackagesProvider);

  return allAppsAsync.when(
    data: (allApps) {
      final pinnedPackages = pinnedAsync.value ?? [];
      final result = <App>[];

      // 1. Add pinned apps first in the saved order
      for (final pkg in pinnedPackages) {
        final match = allApps.where((a) => a.packageName == pkg).firstOrNull;
        if (match != null && !result.any((a) => a.packageName == match.packageName)) {
          result.add(match);
        }
      }

      // 2. Add media apps (either flagged as isMedia in DB or matching keywords)
      for (final app in allApps) {
        if (app.isGame) continue; // Keep pure games in gaming section
        if (result.any((a) => a.packageName == app.packageName)) continue;

        if (app.isMedia) {
          result.add(app);
          continue;
        }

        final lowerPkg = app.packageName.toLowerCase();
        final lowerName = app.appName.toLowerCase();

        final isMatch = entertainmentKeywords.any(
          (k) => lowerPkg.contains(k) || lowerName.contains(k),
        );

        if (isMatch) {
          result.add(app);
        }
      }

      return AsyncValue.data(result);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
