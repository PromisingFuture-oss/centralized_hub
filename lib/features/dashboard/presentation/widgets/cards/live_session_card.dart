import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:centralized_hub/core/providers/providers.dart';
import 'package:centralized_hub/core/utils/duration_formatter.dart';
import 'package:centralized_hub/data/database/app_database.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';
import 'package:centralized_hub/features/dashboard/providers/card_data_providers.dart';
import 'base_dashboard_card.dart';

final latestFinishedSessionProvider = StreamProvider<Session?>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return sessionRepo.watchRecentSessions(limit: 1).map((list) => list.firstOrNull);
});

class LiveSessionCard extends ConsumerStatefulWidget {
  final CardSize size;
  final VoidCallback? onRemove;
  final ValueChanged<CardSize>? onResize;

  const LiveSessionCard({
    super.key,
    required this.size,
    this.onRemove,
    this.onResize,
  });

  @override
  ConsumerState<LiveSessionCard> createState() => _LiveSessionCardState();
}

class _LiveSessionCardState extends ConsumerState<LiveSessionCard> {
  Timer? _timer;
  int? _cachedAppId;
  App? _cachedApp;
  int? _cachedLastAppId;
  App? _cachedLastApp;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _loadApp(int appId) {
    if (_cachedAppId == appId) return;
    _cachedAppId = appId;
    ref.read(appRepositoryProvider).getById(appId).then((app) {
      if (mounted) {
        setState(() => _cachedApp = app);
      }
    });
  }

  void _loadLastApp(int appId) {
    if (_cachedLastAppId == appId) return;
    _cachedLastAppId = appId;
    ref.read(appRepositoryProvider).getById(appId).then((app) {
      if (mounted) {
        setState(() => _cachedLastApp = app);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSessionAsync = ref.watch(activeSessionStreamProvider);
    final latestSessionAsync = ref.watch(latestFinishedSessionProvider);
    final isRunningAsync = ref.watch(isTrackingRunningProvider);
    final isRunning = isRunningAsync.value ?? false;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final activeSession = activeSessionAsync.value;
    final lastSession = latestSessionAsync.value;

    VoidCallback? cardTap;
    if (activeSession != null) {
      cardTap = () => context.push('/games/${activeSession.appId}');
    } else if (lastSession != null) {
      cardTap = () => context.push('/sessions/${lastSession.id}');
    }

    return BaseDashboardCard(
      title: 'Live Tracking',
      subtitle: widget.size == CardSize.small ? null : (activeSession != null ? 'Tap for game stats' : 'Tap for last session'),
      icon: Icons.sensors,
      iconColor: Colors.green,
      size: widget.size,
      onRemove: widget.onRemove,
      onResize: widget.onResize,
      onTap: cardTap,
      child: activeSessionAsync.when(
        data: (session) {
          // If a game is actively playing right now
          if (session != null) {
            _loadApp(session.appId);
            final gameTitle = _cachedApp?.appName ?? 'Game';
            final elapsed = DateTime.now().difference(session.startTime);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PLAYING NOW',
                        style: textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF00E676),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _cachedApp?.iconBytes != null
                            ? Image.memory(
                                _cachedApp!.iconBytes!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 24,
                                height: 24,
                                color: colorScheme.primaryContainer,
                                child: Icon(Icons.sports_esports,
                                    size: 14, color: colorScheme.primary),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        gameTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DurationFormatter.formatTimer(elapsed),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            );
          }

          // When no game is currently in the foreground, show monitoring status + last session
          if (lastSession != null) {
            _loadLastApp(lastSession.appId);
          }
          final lastAppName = _cachedLastApp?.appName ?? 'Game';
          final lastDur = DurationFormatter.formatMs(lastSession?.durationMs);
          final lastTemp = lastSession?.tempMaxC != null
              ? ' • ${lastSession!.tempMaxC!.toStringAsFixed(1)}°C'
              : '';

          final monitorColor = isRunning ? const Color(0xFF00E676) : Colors.grey;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: monitorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: monitorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: monitorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isRunning ? 'MONITORING FOR GAMES' : 'TRACKING OFF',
                      style: textTheme.labelSmall?.copyWith(
                        color: monitorColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (lastSession != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _cachedLastApp?.iconBytes != null
                          ? Image.memory(
                              _cachedLastApp!.iconBytes!,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 20,
                              height: 20,
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.sports_esports,
                                  size: 12,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        lastAppName,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$lastDur$lastTemp',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else ...[
                Text(
                  'No Games Tracked Yet',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Launch any game to track',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
