import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/samples_table.dart';

part 'samples_dao.g.dart';

@DriftAccessor(tables: [Samples])
class SamplesDao extends DatabaseAccessor<AppDatabase>
    with _$SamplesDaoMixin {
  SamplesDao(super.db);

  /// Insert a new sample reading.
  Future<int> insertSample({
    required int sessionId,
    required DateTime timestamp,
    int? batteryLevel,
    double? batteryTempC,
    bool isCharging = false,
    int? thermalStatus,
  }) {
    return into(samples).insert(
      SamplesCompanion.insert(
        sessionId: sessionId,
        timestamp: timestamp,
        batteryLevel: Value(batteryLevel),
        batteryTempC: Value(batteryTempC),
        isCharging: Value(isCharging),
        thermalStatus: Value(thermalStatus),
      ),
    );
  }

  /// Get all samples for a session, ordered by time.
  Future<List<Sample>> getSamplesForSession(int sessionId) =>
      (select(samples)
            ..where((s) => s.sessionId.equals(sessionId))
            ..orderBy([
              (s) => OrderingTerm(expression: s.timestamp, mode: OrderingMode.asc)
            ]))
          .get();

  /// Watch samples for a session (for live updates during active session).
  Stream<List<Sample>> watchSamplesForSession(int sessionId) =>
      (select(samples)
            ..where((s) => s.sessionId.equals(sessionId))
            ..orderBy([
              (s) => OrderingTerm(expression: s.timestamp, mode: OrderingMode.asc)
            ]))
          .watch();

  /// Check if any sample in a session had charging enabled.
  Future<bool> hadChargingDuringSession(int sessionId) async {
    final chargingSamples = await (select(samples)
          ..where(
              (s) => s.sessionId.equals(sessionId) & s.isCharging.equals(true))
          ..limit(1))
        .get();
    return chargingSamples.isNotEmpty;
  }

  /// Compute temperature stats for a session.
  Future<({double? min, double? avg, double? max})> getTemperatureStats(
      int sessionId) async {
    final sessionSamples = await getSamplesForSession(sessionId);
    final temps = sessionSamples
        .where((s) => s.batteryTempC != null)
        .map((s) => s.batteryTempC!)
        .toList();

    if (temps.isEmpty) return (min: null, avg: null, max: null);

    final min = temps.reduce((a, b) => a < b ? a : b);
    final max = temps.reduce((a, b) => a > b ? a : b);
    final avg = temps.reduce((a, b) => a + b) / temps.length;
    return (min: min, avg: avg, max: max);
  }

  /// Get the highest thermal status recorded for a session.
  Future<int?> getMaxThermalStatus(int sessionId) async {
    final sessionSamples = await getSamplesForSession(sessionId);
    final statuses = sessionSamples
        .where((s) => s.thermalStatus != null)
        .map((s) => s.thermalStatus!)
        .toList();

    if (statuses.isEmpty) return null;
    return statuses.reduce((a, b) => a > b ? a : b);
  }

  /// Delete all samples for a session.
  Future<int> deleteSamplesForSession(int sessionId) =>
      (delete(samples)..where((s) => s.sessionId.equals(sessionId))).go();
}
