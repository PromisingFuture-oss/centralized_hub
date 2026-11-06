import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sessions_table.dart';
import '../tables/apps_table.dart';

part 'sessions_dao.g.dart';

@DriftAccessor(tables: [Sessions, Apps])
class SessionsDao extends DatabaseAccessor<AppDatabase>
    with _$SessionsDaoMixin {
  SessionsDao(super.db);

  /// Create a new session. Returns the inserted session ID.
  Future<int> createSession({
    required int appId,
    required DateTime startTime,
    int? batteryStart,
    bool wasChargingStart = false,
  }) {
    return into(sessions).insert(
      SessionsCompanion.insert(
        appId: appId,
        startTime: startTime,
        batteryStart: Value(batteryStart),
        wasChargingStart: Value(wasChargingStart),
      ),
    );
  }

  /// End an active session with final data.
  Future<void> endSession({
    required int sessionId,
    required DateTime endTime,
    required int durationMs,
    int? batteryEnd,
    int? batteryDrop,
    bool wasChargingEnd = false,
    bool hadChargingDuring = false,
    double? tempMinC,
    double? tempAvgC,
    double? tempMaxC,
    int? thermalStatusMax,
  }) {
    return (update(sessions)..where((s) => s.id.equals(sessionId))).write(
      SessionsCompanion(
        endTime: Value(endTime),
        durationMs: Value(durationMs),
        batteryEnd: Value(batteryEnd),
        batteryDrop: Value(batteryDrop),
        wasChargingEnd: Value(wasChargingEnd),
        hadChargingDuring: Value(hadChargingDuring),
        tempMinC: Value(tempMinC),
        tempAvgC: Value(tempAvgC),
        tempMaxC: Value(tempMaxC),
        thermalStatusMax: Value(thermalStatusMax),
      ),
    );
  }

  /// Get the current active (un-ended) session if any.
  Future<Session?> getActiveSession() =>
      (select(sessions)..where((s) => s.endTime.isNull())).getSingleOrNull();

  /// Watch the active session reactively.
  Stream<Session?> watchActiveSession() =>
      (select(sessions)..where((s) => s.endTime.isNull()))
          .watchSingleOrNull();

  /// Get all sessions for a specific app, newest first.
  Future<List<Session>> getSessionsForApp(int appId) =>
      (select(sessions)
            ..where((s) => s.appId.equals(appId))
            ..orderBy([
              (s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)
            ]))
          .get();

  /// Watch all sessions for a specific app.
  Stream<List<Session>> watchSessionsForApp(int appId) =>
      (select(sessions)
            ..where((s) => s.appId.equals(appId))
            ..orderBy([
              (s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)
            ]))
          .watch();

  /// Get sessions within a time range.
  Future<List<Session>> getSessionsInRange(DateTime start, DateTime end) =>
      (select(sessions)
            ..where((s) =>
                s.startTime.isBiggerOrEqualValue(start) &
                s.startTime.isSmallerOrEqualValue(end))
            ..orderBy([
              (s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)
            ]))
          .get();

  /// Watch sessions in a time range.
  Stream<List<Session>> watchSessionsInRange(DateTime start, DateTime end) =>
      (select(sessions)
            ..where((s) =>
                s.startTime.isBiggerOrEqualValue(start) &
                s.startTime.isSmallerOrEqualValue(end))
            ..orderBy([
              (s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)
            ]))
          .watch();

  /// Get recent sessions (limit-based).
  Future<List<Session>> getRecentSessions({int limit = 10}) =>
      (select(sessions)
            ..where((s) => s.endTime.isNotNull())
            ..orderBy([
              (s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)
            ])
            ..limit(limit))
          .get();

  /// Watch recent sessions.
  Stream<List<Session>> watchRecentSessions({int limit = 10}) =>
      (select(sessions)
            ..where((s) => s.endTime.isNotNull())
            ..orderBy([
              (s) => OrderingTerm(expression: s.startTime, mode: OrderingMode.desc)
            ])
            ..limit(limit))
          .watch();

  /// Get session by ID.
  Future<Session?> getById(int id) =>
      (select(sessions)..where((s) => s.id.equals(id))).getSingleOrNull();

  /// Watch a single session by ID.
  Stream<Session?> watchById(int id) =>
      (select(sessions)..where((s) => s.id.equals(id))).watchSingleOrNull();

  /// Get total playtime in ms for a time range, optionally filtered by app.
  Future<int> getTotalPlaytimeMs({
    required DateTime start,
    required DateTime end,
    int? appId,
  }) async {
    final query = select(sessions)
      ..where((s) =>
          s.endTime.isNotNull() &
          s.startTime.isBiggerOrEqualValue(start) &
          s.startTime.isSmallerOrEqualValue(end));
    if (appId != null) {
      query.where((s) => s.appId.equals(appId));
    }
    final results = await query.get();
    return results.fold<int>(0, (sum, s) => sum + (s.durationMs ?? 0));
  }

  /// Delete a session and its samples.
  Future<void> deleteSession(int sessionId) async {
    await (delete(sessions)..where((s) => s.id.equals(sessionId))).go();
  }

  /// Delete sessions that are too short (cleanup).
  Future<int> deleteShortSessions(int minDurationMs) async {
    return (delete(sessions)
          ..where((s) =>
              s.endTime.isNotNull() &
              s.durationMs.isSmallerThanValue(minDurationMs)))
        .go();
  }

  /// Get the most recent ended session for a specific app.
  Future<Session?> getLastSessionForApp(int appId) =>
      (select(sessions)
            ..where(
                (s) => s.appId.equals(appId) & s.endTime.isNotNull())
            ..orderBy([
              (s) => OrderingTerm(expression: s.endTime, mode: OrderingMode.desc)
            ])
            ..limit(1))
          .getSingleOrNull();
}
