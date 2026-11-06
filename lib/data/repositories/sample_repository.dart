import '../database/app_database.dart';
import '../database/daos/samples_dao.dart';

/// Repository for temperature/battery sample data.
class SampleRepository {
  final SamplesDao _samplesDao;

  SampleRepository({required SamplesDao samplesDao})
      : _samplesDao = samplesDao;

  /// Insert a new sample.
  Future<int> insertSample({
    required int sessionId,
    required DateTime timestamp,
    int? batteryLevel,
    double? batteryTempC,
    bool isCharging = false,
    int? thermalStatus,
  }) =>
      _samplesDao.insertSample(
        sessionId: sessionId,
        timestamp: timestamp,
        batteryLevel: batteryLevel,
        batteryTempC: batteryTempC,
        isCharging: isCharging,
        thermalStatus: thermalStatus,
      );

  /// Get all samples for a session.
  Future<List<Sample>> getSamplesForSession(int sessionId) =>
      _samplesDao.getSamplesForSession(sessionId);

  /// Watch samples for a session (live updates).
  Stream<List<Sample>> watchSamplesForSession(int sessionId) =>
      _samplesDao.watchSamplesForSession(sessionId);

  /// Get temperature statistics for a session.
  Future<({double? min, double? avg, double? max})> getTemperatureStats(
          int sessionId) =>
      _samplesDao.getTemperatureStats(sessionId);

  /// Delete all samples for a session.
  Future<int> deleteSamplesForSession(int sessionId) =>
      _samplesDao.deleteSamplesForSession(sessionId);
}
