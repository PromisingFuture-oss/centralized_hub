import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/enums/time_range.dart';

/// Filter state for dashboard data.
class DashboardFilter {
  final TimeRange timeRange;
  final int? selectedAppId;
  final bool? chargingOnly;

  const DashboardFilter({
    this.timeRange = TimeRange.today,
    this.selectedAppId,
    this.chargingOnly,
  });

  DashboardFilter copyWith({
    TimeRange? timeRange,
    int? Function()? selectedAppId,
    bool? Function()? chargingOnly,
  }) {
    return DashboardFilter(
      timeRange: timeRange ?? this.timeRange,
      selectedAppId:
          selectedAppId != null ? selectedAppId() : this.selectedAppId,
      chargingOnly:
          chargingOnly != null ? chargingOnly() : this.chargingOnly,
    );
  }
}

/// Notifier providing active dashboard filter state.
class DashboardFilterNotifier extends StateNotifier<DashboardFilter> {
  DashboardFilterNotifier() : super(const DashboardFilter());

  void setTimeRange(TimeRange range) {
    state = state.copyWith(timeRange: range);
  }

  void setSelectedApp(int? appId) {
    state = state.copyWith(selectedAppId: () => appId);
  }

  void setChargingOnly(bool? chargingOnly) {
    state = state.copyWith(chargingOnly: () => chargingOnly);
  }

  void reset() {
    state = const DashboardFilter();
  }
}

final dashboardFilterProvider =
    StateNotifierProvider<DashboardFilterNotifier, DashboardFilter>((ref) {
  return DashboardFilterNotifier();
});
