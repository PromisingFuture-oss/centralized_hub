import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/providers.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/enums/card_size.dart';
import '../../../domain/enums/card_type.dart';
import '../../../domain/models/dashboard_card_config.dart';

final allLayoutsProvider = StreamProvider<List<DashboardLayout>>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchAllLayouts();
});

final activeLayoutProvider = StreamProvider<DashboardLayout?>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.watchActiveLayout();
});

final activeCardsProvider = Provider<List<DashboardCardConfig>>((ref) {
  final activeLayout = ref.watch(activeLayoutProvider).value;
  if (activeLayout == null) return [];

  try {
    final list = jsonDecode(activeLayout.cardsJson) as List<dynamic>;
    return list.asMap().entries.map((entry) {
      final json = entry.value as Map<String, dynamic>;
      return DashboardCardConfig.fromJson(
        json,
        fallbackId: '${json['card_type']}_${entry.key}',
      );
    }).toList();
  } catch (_) {
    return [];
  }
});

class DashboardController {
  final Ref _ref;

  DashboardController(this._ref);

  Future<void> setActiveLayout(int layoutId) async {
    final repo = _ref.read(dashboardRepositoryProvider);
    await repo.setActiveLayout(layoutId);
  }

  Future<void> addCard(CardType type, {CardSize size = CardSize.medium}) async {
    final layout = _ref.read(activeLayoutProvider).value;
    if (layout == null) return;

    final currentCards = List<DashboardCardConfig>.from(_ref.read(activeCardsProvider));
    final newCard = DashboardCardConfig(
      id: const Uuid().v4(),
      cardType: type,
      size: size,
      position: currentCards.length,
    );

    currentCards.add(newCard);
    await _saveCards(layout.id, currentCards);
  }

  Future<void> removeCard(String cardId) async {
    final layout = _ref.read(activeLayoutProvider).value;
    if (layout == null) return;

    final currentCards = List<DashboardCardConfig>.from(_ref.read(activeCardsProvider))
      ..removeWhere((c) => c.id == cardId);

    // Re-index positions
    final reindexed = [
      for (int i = 0; i < currentCards.length; i++)
        currentCards[i].copyWith(position: i),
    ];

    await _saveCards(layout.id, reindexed);
  }

  Future<void> reorderCards(int oldIndex, int newIndex) async {
    final layout = _ref.read(activeLayoutProvider).value;
    if (layout == null) return;

    final currentCards = List<DashboardCardConfig>.from(_ref.read(activeCardsProvider));
    if (oldIndex < 0 || oldIndex >= currentCards.length || newIndex < 0 || newIndex >= currentCards.length) {
      return;
    }

    final item = currentCards.removeAt(oldIndex);
    currentCards.insert(newIndex, item);

    final reindexed = [
      for (int i = 0; i < currentCards.length; i++)
        currentCards[i].copyWith(position: i),
    ];

    await _saveCards(layout.id, reindexed);
  }

  Future<void> updateCardSize(String cardId, CardSize size) async {
    final layout = _ref.read(activeLayoutProvider).value;
    if (layout == null) return;

    final currentCards = List<DashboardCardConfig>.from(_ref.read(activeCardsProvider));
    final index = currentCards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;

    currentCards[index] = currentCards[index].copyWith(size: size);
    await _saveCards(layout.id, currentCards);
  }

  Future<void> createLayout(String name) async {
    final repo = _ref.read(dashboardRepositoryProvider);
    final defaultCards = [
      DashboardCardConfig(
        id: const Uuid().v4(),
        cardType: CardType.totalPlaytime,
        size: CardSize.medium,
        position: 0,
      ),
      DashboardCardConfig(
        id: const Uuid().v4(),
        cardType: CardType.topGames,
        size: CardSize.medium,
        position: 1,
      ),
      DashboardCardConfig(
        id: const Uuid().v4(),
        cardType: CardType.recentSessions,
        size: CardSize.large,
        position: 2,
      ),
    ];

    final jsonStr = jsonEncode(defaultCards.map((c) => c.toJson()).toList());
    final newId = await repo.createLayout(name: name, cardsJson: jsonStr);
    await repo.setActiveLayout(newId);
  }

  Future<void> deleteLayout(int layoutId) async {
    final repo = _ref.read(dashboardRepositoryProvider);
    await repo.deleteLayout(layoutId);
  }

  Future<void> _saveCards(int layoutId, List<DashboardCardConfig> cards) async {
    final repo = _ref.read(dashboardRepositoryProvider);
    final jsonStr = jsonEncode(cards.map((c) => c.toJson()).toList());
    await repo.updateLayoutCards(layoutId, jsonStr);
  }
}

final dashboardControllerProvider = Provider<DashboardController>((ref) {
  return DashboardController(ref);
});
