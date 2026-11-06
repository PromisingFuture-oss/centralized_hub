import 'package:drift/drift.dart';

/// Table for tracked apps (games and non-games).
class Apps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get packageName => text().unique()();
  TextColumn get appName => text()();
  BlobColumn get iconBytes => blob().nullable()();
  BoolColumn get isGame => boolean().withDefault(const Constant(false))();
  BoolColumn get isMedia => boolean().withDefault(const Constant(false))();
  BoolColumn get isAutoDetected => boolean().withDefault(const Constant(false))();
  BoolColumn get isUserOverride => boolean().withDefault(const Constant(false))();
  DateTimeColumn get firstSeenAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
