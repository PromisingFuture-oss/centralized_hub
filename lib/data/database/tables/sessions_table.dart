import 'package:drift/drift.dart';
import 'apps_table.dart';

/// Table for game sessions with battery and temperature aggregates.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get appId => integer().references(Apps, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get batteryStart => integer().nullable()();
  IntColumn get batteryEnd => integer().nullable()();
  IntColumn get batteryDrop => integer().nullable()();
  BoolColumn get wasChargingStart =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get wasChargingEnd =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get hadChargingDuring =>
      boolean().withDefault(const Constant(false))();
  RealColumn get tempMinC => real().nullable()();
  RealColumn get tempAvgC => real().nullable()();
  RealColumn get tempMaxC => real().nullable()();
  IntColumn get thermalStatusMax => integer().nullable()();
}
