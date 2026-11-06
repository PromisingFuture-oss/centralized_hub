import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:centralized_hub/core/providers/providers.dart';
import 'package:centralized_hub/core/utils/duration_formatter.dart';
import 'package:centralized_hub/data/database/app_database.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';
import 'base_dashboard_card.dart';

class RecentSessionsCard extends ConsumerWidget {
  final CardSize size;
  final VoidCallback? onRemove;
  final ValueChanged<CardSize>? onResize;

  const RecentSessionsCard({
    super.key,
    required this.size,
    this.onRemove,
    this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionRepo = ref.watch(sessionRepositoryProvider);
    final appRepo = ref.watch(appRepositoryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final timeFormat = DateFormat('h:mm a');

    final isSmall = size == CardSize.small;

    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    final defaultLimit = size == CardSize.small ? 2 : (size == CardSize.large ? 4 : 3);

    return BaseDashboardCard(
      title: 'Recent Sessions',
      subtitle: isSmall ? null : 'Tap a session for details',
      icon: Icons.history,
      iconColor: colorScheme.tertiary,
      size: size,
      onRemove: onRemove,
      onResize: onResize,
      child: StreamBuilder<List<Session>>(
        stream: sessionRepo.watchRecentSessions(
          limit: isPortrait ? 10 : defaultLimit,
        ),
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                'No recent sessions',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return FutureBuilder<List<App>>(
            future: appRepo.getAllApps(),
            builder: (context, appSnapshot) {
              final apps = appSnapshot.data ?? [];
              final appMap = {for (final a in apps) a.id: a};

              return ListView.separated(
                physics: isPortrait || sessions.length > defaultLimit
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: sessions.length,
                separatorBuilder: (_, i) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final s = sessions[index];
                  final app = appMap[s.appId];
                  final title = app?.appName ?? 'Unknown Game';
                  final dur = DurationFormatter.formatMs(s.durationMs);

                  return InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => context.push('/sessions/${s.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: app?.iconBytes != null
                                ? Image.memory(
                                    app!.iconBytes!,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 24,
                                    height: 24,
                                    color: colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.sports_esports,
                                      size: 14,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${timeFormat.format(s.startTime)} • $dur',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (s.batteryDrop != null && s.batteryDrop! > 0)
                            Text(
                              '-${s.batteryDrop}%',
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.amber.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
