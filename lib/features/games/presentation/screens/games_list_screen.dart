import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../data/database/app_database.dart';
import '../../../../shared/widgets/empty_state.dart';

/// Reactive provider that watches only games.
final gamesListProvider = StreamProvider<List<App>>((ref) {
  return ref.watch(appRepositoryProvider).watchGames();
});

/// Reactive provider that watches all installed apps.
final allAppsListProvider = StreamProvider<List<App>>((ref) {
  return ref.watch(appRepositoryProvider).watchAllApps();
});

/// Games list screen with tabs for Games and All Installed Apps.
class GamesListScreen extends ConsumerStatefulWidget {
  const GamesListScreen({super.key});

  @override
  ConsumerState<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends ConsumerState<GamesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshApps() async {
    setState(() => _isRefreshing = true);
    try {
      await ref.read(appRepositoryProvider).syncInstalledApps();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apps synchronized successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesListProvider);
    final allAppsAsync = ref.watch(allAppsListProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final gameCount = gamesAsync.value?.length ?? 0;
    final allCount = allAppsAsync.value?.length ?? 0;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Games & Apps',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.compare_arrows_rounded),
              tooltip: 'Compare Games',
              onPressed: () => context.push('/games/compare'),
            ),
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                size: 22,
              ),
              tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.sync_rounded),
                tooltip: 'Scan installed apps',
                onPressed: _refreshApps,
              ),
          ],
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            tabs: [
              Tab(
                text: 'Tracked Games ($gameCount)',
                icon: const Icon(Icons.sports_esports_outlined, size: 20),
              ),
              Tab(
                text: 'All Apps ($allCount)',
                icon: const Icon(Icons.apps_outlined, size: 20),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Games
            _buildGamesTab(gamesAsync),

            // Tab 2: All Apps
            _buildAllAppsTab(allAppsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesTab(AsyncValue<List<App>> gamesAsync) {
    return gamesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => EmptyState(
        icon: Icons.error_outline,
        title: 'Error loading games',
        subtitle: error.toString(),
      ),
      data: (games) {
        if (games.isEmpty) {
          return EmptyState(
            icon: Icons.sports_esports_outlined,
            title: 'No games detected yet',
            subtitle:
                'Switch to the "All Apps" tab to manually mark any game (like Block Blast), '
                'or tap "Scan Apps" below.',
            actionLabel: 'Scan Installed Apps',
            onAction: _refreshApps,
          );
        }

        if (_isGridView) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return _GamePosterCard(
                app: game,
                onToggleGame: (isGame) => ref
                    .read(appRepositoryProvider)
                    .toggleGameStatus(game.id, isGame),
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return _AppCard(
              app: game,
              onToggleGame: (isGame) => ref
                  .read(appRepositoryProvider)
                  .toggleGameStatus(game.id, isGame),
            );
          },
        );
      },
    );
  }

  Widget _buildAllAppsTab(AsyncValue<List<App>> allAppsAsync) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search apps (e.g. Block Blast)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (query) =>
                setState(() => _searchQuery = query.trim().toLowerCase()),
          ),
        ),
        Expanded(
          child: allAppsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading apps',
              subtitle: error.toString(),
            ),
            data: (allApps) {
              final filtered = _searchQuery.isEmpty
                  ? allApps
                  : allApps.where((a) {
                      return a.appName.toLowerCase().contains(_searchQuery) ||
                          a.packageName.toLowerCase().contains(_searchQuery);
                    }).toList();

              if (filtered.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No apps found',
                  subtitle: allApps.isEmpty
                      ? 'No apps scanned yet. Tap "Scan Apps" to import.'
                      : 'No apps match "$_searchQuery".',
                  actionLabel: allApps.isEmpty ? 'Scan Apps' : null,
                  onAction: allApps.isEmpty ? _refreshApps : null,
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final app = filtered[index];
                  return _AppCard(
                    app: app,
                    onToggleGame: (isGame) => ref
                        .read(appRepositoryProvider)
                        .toggleGameStatus(app.id, isGame),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Poster card for games grid view.
class _GamePosterCard extends ConsumerWidget {
  final App app;
  final ValueChanged<bool> onToggleGame;

  const _GamePosterCard({
    required this.app,
    required this.onToggleGame,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainer,
            colorScheme.surfaceContainerLow,
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (app.isGame) {
              context.go('/games/${app.id}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game icon with soft glow
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.22),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: app.iconBytes != null
                        ? Image.memory(
                            app.iconBytes!,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.sports_esports,
                              color: colorScheme.primary,
                              size: 32,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  app.appName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'TRACKED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final launched = await ref
                            .read(appRepositoryProvider)
                            .launchApp(app.packageName);
                        if (!launched && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not launch ${app.appName}'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primaryContainer,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 14,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppCard extends ConsumerWidget {
  final App app;
  final ValueChanged<bool> onToggleGame;

  const _AppCard({
    required this.app,
    required this.onToggleGame,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainer,
            colorScheme.surfaceContainerLow,
          ],
        ),
        border: Border.all(
          color: app.isGame
              ? colorScheme.primary.withValues(alpha: 0.25)
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (app.isGame) {
              context.go('/games/${app.id}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // App icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: app.isGame
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    boxShadow: app.isGame
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: app.iconBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            app.iconBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          app.isGame ? Icons.sports_esports : Icons.apps,
                          color: app.isGame
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                ),
                const SizedBox(width: 14),
                // App name & package
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              app.appName,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (app.isGame) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'GAME',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        app.packageName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (app.isGame)
                  IconButton(
                    icon: Icon(
                      Icons.play_circle_fill_rounded,
                      color: colorScheme.primary,
                      size: 26,
                    ),
                    tooltip: 'Launch ${app.appName}',
                    onPressed: () async {
                      final launched = await ref
                          .read(appRepositoryProvider)
                          .launchApp(app.packageName);
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Could not launch ${app.appName}')),
                        );
                      }
                    },
                  ),
                // Game toggle switch
                Switch(
                  value: app.isGame,
                  onChanged: onToggleGame,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
