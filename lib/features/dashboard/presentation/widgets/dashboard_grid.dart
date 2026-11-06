import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:centralized_hub/domain/enums/card_type.dart';
import 'package:centralized_hub/domain/enums/card_size.dart';
import 'package:centralized_hub/domain/models/dashboard_card_config.dart';
import 'package:centralized_hub/features/dashboard/providers/dashboard_provider.dart';
import 'cards/total_playtime_card.dart';
import 'cards/top_games_card.dart';
import 'cards/temperature_trend_card.dart';
import 'cards/battery_drain_card.dart';
import 'cards/recent_sessions_card.dart';
import 'cards/live_session_card.dart';
import 'cards/entertainment_deck_card.dart';

class DashboardGrid extends ConsumerWidget {
  final List<DashboardCardConfig> cards;
  const DashboardGrid({super.key, required this.cards});

  static const double _gap = 12;

  int _span(CardSize size, bool isTablet) => switch (size) {
        CardSize.small => 1,
        CardSize.medium => 2,
        CardSize.large => isTablet ? 4 : 2,
      };

  // Height scales with cell width, never drops below the old fixed value.
  double _height(CardSize size, double cellWidth) => switch (size) {
        CardSize.small => (cellWidth * 1.05).clamp(170, 240),
        CardSize.medium => (cellWidth * 1.0).clamp(210, 260),
        CardSize.large => (cellWidth * 1.3).clamp(290, 380),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 560;
          final columns = isTablet ? 4 : 2;
          final cellWidth =
              (constraints.maxWidth - _gap * (columns - 1)) / columns;

          return StaggeredGrid.count(
            crossAxisCount: columns,
            mainAxisSpacing: _gap,
            crossAxisSpacing: _gap,
            children: [
              for (final config in cards)
                StaggeredGridTile.extent(
                  key: ValueKey(config.id),
                  crossAxisCellCount: _span(config.size, isTablet),
                  mainAxisExtent: _height(config.size, cellWidth),
                  child: RepaintBoundary(
                    child: _buildCard(config, controller),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(DashboardCardConfig config, DashboardController c) {
    void remove() => c.removeCard(config.id);
    void resize(CardSize s) => c.updateCardSize(config.id, s);

    return switch (config.cardType) {
      CardType.totalPlaytime => TotalPlaytimeCard(size: config.size, onRemove: remove, onResize: resize),
      CardType.topGames => TopGamesCard(size: config.size, onRemove: remove, onResize: resize),
      CardType.temperatureTrend ||
      CardType.hottestSessions => TemperatureTrendCard(size: config.size, onRemove: remove, onResize: resize),
      CardType.batteryDrain ||
      CardType.avgDrainPerHour => BatteryDrainCard(size: config.size, onRemove: remove, onResize: resize),
      CardType.recentSessions => RecentSessionsCard(size: config.size, onRemove: remove, onResize: resize),
      CardType.liveSession => LiveSessionCard(size: config.size, onRemove: remove, onResize: resize),
      CardType.entertainmentDeck => EntertainmentDeckCard(size: config.size, onRemove: remove, onResize: resize),
      _ => TotalPlaytimeCard(size: config.size, onRemove: remove, onResize: resize),
    };
  }
}
