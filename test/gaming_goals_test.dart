import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:centralized_hub/data/database/app_database.dart';
import 'package:centralized_hub/data/repositories/gaming_goals_repository.dart';
import 'package:centralized_hub/domain/models/gaming_goal.dart';

void main() {
  group('GamingGoal Model', () {
    test('creates goal with generated UUID and valid defaults', () {
      final goal = GamingGoal.create(
        title: 'Defeat Malenia',
        notes: 'Bleed katana build',
        gameId: 42,
        gameName: 'Elden Ring',
      );

      expect(goal.id, isNotEmpty);
      expect(goal.title, 'Defeat Malenia');
      expect(goal.notes, 'Bleed katana build');
      expect(goal.gameId, 42);
      expect(goal.gameName, 'Elden Ring');
      expect(goal.isCompleted, isFalse);
    });

    test('toJson and fromJson roundtrip serialization', () {
      final original = GamingGoal.create(
        title: 'Hit Diamond Rank',
        notes: 'Duo queue only',
        gameId: 10,
        gameName: 'Valorant',
      );

      final json = original.toJson();
      final reconstructed = GamingGoal.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.notes, original.notes);
      expect(reconstructed.gameId, original.gameId);
      expect(reconstructed.gameName, original.gameName);
      expect(reconstructed.isCompleted, original.isCompleted);
    });

    test('copyWith updates specified fields', () {
      final goal = GamingGoal.create(title: 'Farm 50 Primogems');
      final updated = goal.copyWith(isCompleted: true, notes: 'Completed daily quests');

      expect(updated.id, goal.id);
      expect(updated.title, 'Farm 50 Primogems');
      expect(updated.isCompleted, isTrue);
      expect(updated.notes, 'Completed daily quests');
    });
  });

  group('GamingGoalsRepository', () {
    late AppDatabase db;
    late GamingGoalsRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = GamingGoalsRepository(settingsDao: db.settingsDao);
    });

    tearDown(() async {
      await db.close();
    });

    test('initial state returns empty list', () async {
      final goals = await repo.getGoals();
      expect(goals, isEmpty);
    });

    test('addGoal prepends new goals', () async {
      final goal1 = GamingGoal.create(title: 'Quest 1');
      final goal2 = GamingGoal.create(title: 'Quest 2');

      await repo.addGoal(goal1);
      await repo.addGoal(goal2);

      final goals = await repo.getGoals();
      expect(goals.length, 2);
      expect(goals[0].title, 'Quest 2');
      expect(goals[1].title, 'Quest 1');
    });

    test('toggleGoal flips completion status', () async {
      final goal = GamingGoal.create(title: 'Boss Battle');
      await repo.addGoal(goal);

      expect((await repo.getGoals()).first.isCompleted, isFalse);

      await repo.toggleGoal(goal.id);
      expect((await repo.getGoals()).first.isCompleted, isTrue);

      await repo.toggleGoal(goal.id);
      expect((await repo.getGoals()).first.isCompleted, isFalse);
    });

    test('deleteGoal removes target goal', () async {
      final goal1 = GamingGoal.create(title: 'Target 1');
      final goal2 = GamingGoal.create(title: 'Target 2');

      await repo.addGoal(goal1);
      await repo.addGoal(goal2);

      await repo.deleteGoal(goal1.id);

      final goals = await repo.getGoals();
      expect(goals.length, 1);
      expect(goals.first.id, goal2.id);
    });

    test('watchGoals emits updates reactively', () async {
      final goal = GamingGoal.create(title: 'Reactive Quest');
      await repo.addGoal(goal);

      final firstEvent = await repo.watchGoals().first;
      expect(firstEvent.length, 1);
      expect(firstEvent.first.title, 'Reactive Quest');
    });
  });
}
