import '../database/app_database.dart';
import '../database/daos/sessions_dao.dart';
import '../database/daos/samples_dao.dart';

/// Repository for session management, abstracting DB access.
class SessionRepository {
  final SessionsDao _sessionsDao;
  final SamplesDao _samplesDao;

  SessionRepository({
    required SessionsDao sessionsDao,
    required SamplesDao samplesDao,
  })  : _sessionsDao = sessionsDao,
        _samplesDao = samplesDao;

  /// Create a new session.
  Future<int> createSession({
    required int appId,
    required DateTime startTime,
    int? batteryStart,
    bool wasChargingStart = false,
  }) =>
      _sessionsDao.createSession(
        appId: appId,
        startTime: startTime,
        batteryStart: batteryStart,
        wasChargingStart: wasChargingStart,
      );

  /// End a session with final metrics, computed from samples.
  Future<void> endSession({
    required int sessionId,
    required DateTime endTime,
    int? batteryEnd,
    bool wasChargingEnd = false,
  }) async {
    // Get the session to compute duration
    final session = await _sessionsDao.getById(sessionId);
    if (session == null) return;

    final durationMs =
        endTime.difference(session.startTime).inMilliseconds;

    // Compute temperature stats from samples
    final tempStats = await _samplesDao.getTemperatureStats(sessionId);
    final maxThermal = await _samplesDao.getMaxThermalStatus(sessionId);
    final hadCharging = await _samplesDao.hadChargingDuringSession(sessionId);

    // Compute battery drop
    final batteryStart = session.batteryStart;
    int? batteryDrop;
    if (batteryStart != null && batteryEnd != null) {
      batteryDrop = batteryStart - batteryEnd;
    }

    await _sessionsDao.endSession(
      sessionId: sessionId,
      endTime: endTime,
      durationMs: durationMs,
      batteryEnd: batteryEnd,
      batteryDrop: batteryDrop,
      wasChargingEnd: wasChargingEnd,
      hadChargingDuring: hadCharging,
      tempMinC: tempStats.min,
      tempAvgC: tempStats.avg,
      tempMaxC: tempStats.max,
      thermalStatusMax: maxThermal,
    );
  }

  /// Get the current active session.
  Future<Session?> getActiveSession() => _sessionsDao.getActiveSession();

  /// Watch the active session.
  Stream<Session?> watchActiveSession() =>
      _sessionsDao.watchActiveSession();

  /// Get sessions for a specific app.
  Future<List<Session>> getSessionsForApp(int appId) =>
      _sessionsDao.getSessionsForApp(appId);

  /// Watch sessions for a specific app.
  Stream<List<Session>> watchSessionsForApp(int appId) =>
      _sessionsDao.watchSessionsForApp(appId);

  /// Get sessions in a time range.
  Future<List<Session>> getSessionsInRange(DateTime start, DateTime end) =>
      _sessionsDao.getSessionsInRange(start, end);

  /// Watch sessions in a time range.
  Stream<List<Session>> watchSessionsInRange(
          DateTime start, DateTime end) =>
      _sessionsDao.watchSessionsInRange(start, end);

  /// Get recent sessions.
  Future<List<Session>> getRecentSessions({int limit = 10}) =>
      _sessionsDao.getRecentSessions(limit: limit);

  /// Watch recent sessions.
  Stream<List<Session>> watchRecentSessions({int limit = 10}) =>
      _sessionsDao.watchRecentSessions(limit: limit);

  /// Get session by ID.
  Future<Session?> getById(int id) => _sessionsDao.getById(id);

  /// Watch session by ID.
  Stream<Session?> watchById(int id) => _sessionsDao.watchById(id);

  /// Get total playtime in a range.
  Future<int> getTotalPlaytimeMs({
    required DateTime start,
    required DateTime end,
    int? appId,
  }) =>
      _sessionsDao.getTotalPlaytimeMs(
          start: start, end: end, appId: appId);

  /// Delete a session and its samples.
  Future<void> deleteSession(int sessionId) async {
    await _samplesDao.deleteSamplesForSession(sessionId);
    await _sessionsDao.deleteSession(sessionId);
  }

  /// Delete sessions shorter than the minimum duration.
  Future<int> deleteShortSessions(int minDurationMs) =>
      _sessionsDao.deleteShortSessions(minDurationMs);

  /// Get the last ended session for an app (for resume logic).
  Future<Session?> getLastSessionForApp(int appId) =>
      _sessionsDao.getLastSessionForApp(appId);
}
