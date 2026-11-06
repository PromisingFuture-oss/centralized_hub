import 'package:uuid/uuid.dart';

/// Represents a gaming goal, to-do item, or note.
class GamingGoal {
  final String id;
  final String title;
  final String? notes;
  final int? gameId;
  final String? gameName;
  final bool isCompleted;
  final DateTime? targetDate;
  final DateTime createdAt;

  const GamingGoal({
    required this.id,
    required this.title,
    this.notes,
    this.gameId,
    this.gameName,
    this.isCompleted = false,
    this.targetDate,
    required this.createdAt,
  });

  /// Factory to create a new goal with a generated UUID.
  factory GamingGoal.create({
    required String title,
    String? notes,
    int? gameId,
    String? gameName,
    DateTime? targetDate,
  }) {
    return GamingGoal(
      id: const Uuid().v4(),
      title: title,
      notes: notes,
      gameId: gameId,
      gameName: gameName,
      isCompleted: false,
      targetDate: targetDate,
      createdAt: DateTime.now(),
    );
  }

  factory GamingGoal.fromJson(Map<String, dynamic> json) {
    return GamingGoal(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? 'Untitled Goal',
      notes: json['notes'] as String?,
      gameId: json['game_id'] as int?,
      gameName: json['game_name'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      targetDate: json['target_date'] != null
          ? DateTime.tryParse(json['target_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'game_id': gameId,
      'game_name': gameName,
      'is_completed': isCompleted,
      'target_date': targetDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  GamingGoal copyWith({
    String? id,
    String? title,
    String? notes,
    int? gameId,
    String? gameName,
    bool? isCompleted,
    DateTime? targetDate,
    DateTime? createdAt,
  }) {
    return GamingGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      gameId: gameId ?? this.gameId,
      gameName: gameName ?? this.gameName,
      isCompleted: isCompleted ?? this.isCompleted,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
