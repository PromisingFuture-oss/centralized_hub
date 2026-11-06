import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/dashboard_layouts_table.dart';

part 'dashboard_dao.g.dart';

@DriftAccessor(tables: [DashboardLayouts])
class DashboardDao extends DatabaseAccessor<AppDatabase>
    with _$DashboardDaoMixin {
  DashboardDao(super.db);

  /// Get all layouts ordered by sort order.
  Future<List<DashboardLayout>> getAllLayouts() =>
      (select(dashboardLayouts)
            ..orderBy([
              (l) => OrderingTerm(expression: l.sortOrder, mode: OrderingMode.asc)
            ]))
          .get();

  /// Watch all layouts.
  Stream<List<DashboardLayout>> watchAllLayouts() =>
      (select(dashboardLayouts)
            ..orderBy([
              (l) => OrderingTerm(expression: l.sortOrder, mode: OrderingMode.asc)
            ]))
          .watch();

  /// Get the currently active layout.
  Future<DashboardLayout?> getActiveLayout() =>
      (select(dashboardLayouts)..where((l) => l.isActive.equals(true)))
          .getSingleOrNull();

  /// Watch the active layout.
  Stream<DashboardLayout?> watchActiveLayout() =>
      (select(dashboardLayouts)..where((l) => l.isActive.equals(true)))
          .watchSingleOrNull();

  /// Set a layout as active (deactivates all others).
  Future<void> setActiveLayout(int layoutId) async {
    await transaction(() async {
      // Deactivate all
      await (update(dashboardLayouts)).write(
        const DashboardLayoutsCompanion(isActive: Value(false)),
      );
      // Activate the selected one
      await (update(dashboardLayouts)..where((l) => l.id.equals(layoutId)))
          .write(const DashboardLayoutsCompanion(isActive: Value(true)));
    });
  }

  /// Create a new layout.
  Future<int> createLayout({
    required String name,
    required String cardsJson,
    int sortOrder = 0,
  }) {
    final now = DateTime.now();
    return into(dashboardLayouts).insert(
      DashboardLayoutsCompanion.insert(
        name: name,
        cardsJson: cardsJson,
        sortOrder: Value(sortOrder),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Update layout cards JSON.
  Future<void> updateLayoutCards(int layoutId, String cardsJson) {
    return (update(dashboardLayouts)..where((l) => l.id.equals(layoutId)))
        .write(DashboardLayoutsCompanion(
      cardsJson: Value(cardsJson),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Update layout name.
  Future<void> updateLayoutName(int layoutId, String name) {
    return (update(dashboardLayouts)..where((l) => l.id.equals(layoutId)))
        .write(DashboardLayoutsCompanion(
      name: Value(name),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Delete a layout (cannot delete presets).
  Future<int> deleteLayout(int layoutId) =>
      (delete(dashboardLayouts)
            ..where((l) => l.id.equals(layoutId) & l.isPreset.equals(false)))
          .go();

  /// Reset a preset layout to its default cards.
  Future<void> resetPresetLayout(int layoutId, String defaultCardsJson) {
    return (update(dashboardLayouts)..where((l) => l.id.equals(layoutId)))
        .write(DashboardLayoutsCompanion(
      cardsJson: Value(defaultCardsJson),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
