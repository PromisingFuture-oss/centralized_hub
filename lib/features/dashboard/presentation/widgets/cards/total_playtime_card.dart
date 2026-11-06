import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';
import 'package:centralized_hub/features/dashboard/providers/card_data_providers.dart';
import '../games_breakdown_sheet.dart';
import 'base_dashboard_card.dart';

class TotalPlaytimeCard extends ConsumerWidget {
  final CardSize size;
  final VoidCallback? onRemove;
  final ValueChanged<CardSize>? onResize;

  const TotalPlaytimeCard({
    super.key,
    required this.size,
    this.onRemove,
    this.onResize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(totalPlaytimeMetricsProvider);
    final topGamesAsync = ref.watch(topGamesMetricsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return BaseDashboardCard(
      title: 'Total Playtime',
      subtitle: size == CardSize.small ? null : '${metrics.sessionCount} sessions • Tap for details',
      icon: Icons.timer_outlined,
      iconColor: colorScheme.primary,
      size: size,
      onRemove: onRemove,
      onResize: onResize,
      onTap: () => GamesBreakdownSheet.show(context),
      child: Center(
        child: _buildBody(context, metrics, topGamesAsync.value ?? [], colorScheme, textTheme),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TotalPlaytimeMetrics metrics,
    List<TopGameItem> topGames,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    if (size == CardSize.small) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              metrics.formatted,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${metrics.sessionCount} sess • ${metrics.avgSessionFormatted}/avg',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (size == CardSize.large) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              metrics.formatted,
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Top game icon avatars
          if (topGames.isNotEmpty) ...[
            _buildGameIconRow(topGames, colorScheme),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatBox(
                icon: Icons.speed,
                label: 'Avg / Session',
                value: metrics.avgSessionFormatted,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              _buildStatBox(
                icon: Icons.sports_esports,
                label: 'Total Sessions',
                value: '${metrics.sessionCount}',
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ],
      );
    }

    // Medium (default)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            metrics.formatted,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Avg: ${metrics.avgSessionFormatted}/session',
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (topGames.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildGameIconRow(topGames, colorScheme),
        ],
      ],
    );
  }

  Widget _buildGameIconRow(List<TopGameItem> topGames, ColorScheme colorScheme) {
    final displayGames = topGames.take(4).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < displayGames.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: displayGames[i].app.iconBytes != null
                ? Image.memory(
                    displayGames[i].app.iconBytes!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 24,
                    height: 24,
                    color: colorScheme.primaryContainer,
                    child: Icon(Icons.sports_esports, size: 14, color: colorScheme.primary),
                  ),
          ),
        ],
        if (topGames.length > 4) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${topGames.length - 4}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
