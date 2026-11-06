import 'dart:convert';
import '../../domain/models/gaming_goal.dart';
import '../database/daos/settings_dao.dart';

/// Repository for storing and retrieving user gaming goals and notes.
/// Uses the reactive [SettingsDao] key-value store to persist JSON data.
class GamingGoalsRepository {
  static const String _storageKey = 'gaming_goals_json';
  final SettingsDao _settingsDao;

  GamingGoalsRepository({required SettingsDao settingsDao})
      : _settingsDao = settingsDao;

  /// Watch the list of gaming goals reactively.
  Stream<List<GamingGoal>> watchGoals() {
    return _settingsDao.watchValue(_storageKey).map((raw) => _parseGoals(raw));
  }

  /// Get the current list of gaming goals.
  Future<List<GamingGoal>> getGoals() async {
    final raw = await _settingsDao.getValue(_storageKey);
    return _parseGoals(raw);
  }

  /// Add a new gaming goal to the list.
  Future<void> addGoal(GamingGoal goal) async {
    final current = await getGoals();
    final updated = [goal, ...current];
    await _saveGoals(updated);
  }

  /// Toggle the completed status of a goal by ID.
  Future<void> toggleGoal(String id) async {
    final current = await getGoals();
    final updated = current.map((g) {
      if (g.id == id) {
        return g.copyWith(isCompleted: !g.isCompleted);
      }
      return g;
    }).toList();
    await _saveGoals(updated);
  }

  /// Update an existing goal.
  Future<void> updateGoal(GamingGoal updatedGoal) async {
    final current = await getGoals();
    final updated = current.map((g) {
      return g.id == updatedGoal.id ? updatedGoal : g;
    }).toList();
    await _saveGoals(updated);
  }

  /// Delete a goal by ID.
  Future<void> deleteGoal(String id) async {
    final current = await getGoals();
    final updated = current.where((g) => g.id != id).toList();
    await _saveGoals(updated);
  }

  List<GamingGoal> _parseGoals(String? raw) {
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => GamingGoal.fromJson(item))
            .toList();
      }
    } catch (_) {
      // In case of any corrupt data, return empty list gracefully
    }
    return [];
  }

  Future<void> _saveGoals(List<GamingGoal> goals) async {
    final encoded = jsonEncode(goals.map((g) => g.toJson()).toList());
    await _settingsDao.setValue(_storageKey, encoded);
  }
}
