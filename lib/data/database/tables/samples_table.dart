import 'package:drift/drift.dart';
import 'sessions_table.dart';

/// Time-series samples of battery level and temperature during a session.
@TableIndex(name: 'idx_samples_session_time', columns: {#sessionId, #timestamp})
class Samples extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get batteryLevel => integer().nullable()();
  RealColumn get batteryTempC => real().nullable()();
  BoolColumn get isCharging =>
      boolean().withDefault(const Constant(false))();
  IntColumn get thermalStatus => integer().nullable()();
}
