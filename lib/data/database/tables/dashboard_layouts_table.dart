import 'package:drift/drift.dart';

/// Stores dashboard layout configurations (tabs) with JSON card configs.
class DashboardLayouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isPreset =>
      boolean().withDefault(const Constant(false))();
  TextColumn get cardsJson => text()(); // JSON array of card configurations
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
