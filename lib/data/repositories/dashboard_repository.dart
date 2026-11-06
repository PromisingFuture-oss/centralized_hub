import '../database/app_database.dart';
import '../database/daos/dashboard_dao.dart';

/// Repository for dashboard layout management.
class DashboardRepository {
  final DashboardDao _dashboardDao;

  DashboardRepository({required DashboardDao dashboardDao})
      : _dashboardDao = dashboardDao;

  Future<List<DashboardLayout>> getAllLayouts() =>
      _dashboardDao.getAllLayouts();

  Stream<List<DashboardLayout>> watchAllLayouts() =>
      _dashboardDao.watchAllLayouts();

  Future<DashboardLayout?> getActiveLayout() =>
      _dashboardDao.getActiveLayout();

  Stream<DashboardLayout?> watchActiveLayout() =>
      _dashboardDao.watchActiveLayout();

  Future<void> setActiveLayout(int layoutId) =>
      _dashboardDao.setActiveLayout(layoutId);

  Future<int> createLayout({
    required String name,
    required String cardsJson,
    int sortOrder = 0,
  }) =>
      _dashboardDao.createLayout(
        name: name,
        cardsJson: cardsJson,
        sortOrder: sortOrder,
      );

  Future<void> updateLayoutCards(int layoutId, String cardsJson) =>
      _dashboardDao.updateLayoutCards(layoutId, cardsJson);

  Future<void> updateLayoutName(int layoutId, String name) =>
      _dashboardDao.updateLayoutName(layoutId, name);

  Future<int> deleteLayout(int layoutId) =>
      _dashboardDao.deleteLayout(layoutId);

  Future<void> resetPresetLayout(
          int layoutId, String defaultCardsJson) =>
      _dashboardDao.resetPresetLayout(layoutId, defaultCardsJson);
}
