import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:centralized_hub/core/providers/providers.dart';
import 'package:centralized_hub/data/database/app_database.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';
import 'package:centralized_hub/features/dashboard/providers/entertainment_deck_provider.dart';
import 'base_dashboard_card.dart';

/// Dashboard card displaying pinned and auto-detected Media, Video, and Reader apps.
/// Allows direct 1-tap launching and custom app pinning.
class EntertainmentDeckCard extends ConsumerWidget {
  final CardSize size;
  final VoidCallback? onRemove;
  final ValueChanged<CardSize>? onResize;

  const EntertainmentDeckCard({
    super.key,
    required this.size,
    this.onRemove,
    this.onResize,
  });

  static const Color _accentColor = Color(0xFFFF2A6D);

  void _showPinDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PinAppsModalSheet(ref: ref),
    );
  }

  Future<void> _launchApp(BuildContext context, WidgetRef ref, App app) async {
    final success = await ref.read(appRepositoryProvider).launchApp(app.packageName);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not launch ${app.appName}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(entertainmentDeckAppsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSmall = size == CardSize.small;

    return BaseDashboardCard(
      title: 'Media & Entertainment',
      subtitle: isSmall ? null : 'Quick Launch Deck • Videos & Readers',
      icon: Icons.play_circle_filled_rounded,
      iconColor: _accentColor,
      size: size,
      onRemove: onRemove,
      onResize: onResize,
      child: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return _buildEmptyState(context, ref, colorScheme, textTheme, isSmall);
          }

          if (isSmall) {
            return _buildSmallView(context, ref, apps, colorScheme);
          } else if (size == CardSize.medium) {
            return _buildMediumView(context, ref, apps, colorScheme, textTheme);
          } else {
            return _buildLargeView(context, ref, apps, colorScheme, textTheme);
          }
        },
        loading: () => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: _accentColor),
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Failed to load media apps',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isSmall,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.movie_filter_outlined,
            size: isSmall ? 28 : 36,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: isSmall ? 4 : 8),
          Text(
            'No media apps detected',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () => _showPinDialog(context, ref),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Pin Apps', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallView(
    BuildContext context,
    WidgetRef ref,
    List<App> apps,
    ColorScheme colorScheme,
  ) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return _AppTile(
          app: app,
          isCompact: true,
          onTap: () => _launchApp(context, ref, app),
        );
      },
    );
  }

  Widget _buildMediumView(
    BuildContext context,
    WidgetRef ref,
    List<App> apps,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${apps.length} entertainment apps ready',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showPinDialog(context, ref),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tune_rounded, size: 14, color: _accentColor),
                    const SizedBox(width: 4),
                    Text(
                      'Manage',
                      style: textTheme.labelSmall?.copyWith(
                        color: _accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _AppTile(
                app: app,
                isCompact: false,
                onTap: () => _launchApp(context, ref, app),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLargeView(
    BuildContext context,
    WidgetRef ref,
    List<App> apps,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Launch & Companion Deck',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              onPressed: () => _showPinDialog(context, ref),
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Add Apps', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _AppTile(
                app: app,
                isCompact: false,
                onTap: () => _launchApp(context, ref, app),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AppTile extends StatelessWidget {
  final App app;
  final bool isCompact;
  final VoidCallback onTap;

  const _AppTile({
    required this.app,
    required this.isCompact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0xFFFF2A6D).withValues(alpha: 0.15),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          padding: EdgeInsets.all(isCompact ? 4 : 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isCompact ? 32 : 38,
                height: isCompact ? 32 : 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: app.iconBytes != null
                    ? Image.memory(
                        app.iconBytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.play_arrow_rounded,
                          color: Color(0xFFFF2A6D),
                        ),
                      )
                    : const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFFFF2A6D),
                      ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  app.appName,
                  style: (isCompact ? textTheme.labelSmall : textTheme.bodySmall)?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isCompact ? 10 : 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet to allow user to check/uncheck apps to pin in the Entertainment Deck.
class _PinAppsModalSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _PinAppsModalSheet({required this.ref});

  @override
  ConsumerState<_PinAppsModalSheet> createState() => _PinAppsModalSheetState();
}

class _PinAppsModalSheetState extends ConsumerState<_PinAppsModalSheet> {
  String _search = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final allAppsAsync = ref.watch(databaseProvider).appsDao.watchAllApps();
    final pinnedAsync = ref.watch(pinnedMediaPackagesProvider);
    final pinnedPackages = pinnedAsync.value ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: Color(0xFFFF2A6D)),
                    const SizedBox(width: 10),
                    Text(
                      'Manage Entertainment Deck',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Search installed apps...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) => setState(() => _search = val.toLowerCase()),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<App>>(
                  stream: allAppsAsync,
                  builder: (context, snapshot) {
                    final apps = snapshot.data ?? [];
                    final filtered = apps.where((a) {
                      if (_search.isEmpty) return true;
                      return a.appName.toLowerCase().contains(_search) ||
                          a.packageName.toLowerCase().contains(_search);
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'No apps found',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final app = filtered[index];
                        final isPinned = pinnedPackages.contains(app.packageName);

                        return CheckboxListTile(
                          value: isPinned,
                          activeColor: const Color(0xFFFF2A6D),
                          secondary: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: app.iconBytes != null
                                ? Image.memory(app.iconBytes!, fit: BoxFit.cover)
                                : const Icon(Icons.apps, size: 24),
                          ),
                          title: Text(
                            app.appName,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            app.packageName,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onChanged: (_) {
                            ref
                                .read(pinnedMediaControllerProvider)
                                .togglePin(app.packageName);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
