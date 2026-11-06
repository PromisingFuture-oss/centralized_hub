import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:centralized_hub/core/providers/providers.dart';
import 'package:centralized_hub/data/database/app_database.dart';
import 'package:centralized_hub/domain/models/gaming_goal.dart';
import 'package:centralized_hub/features/games/presentation/screens/games_list_screen.dart';

enum _GoalFilter { all, active, completed }

/// Discord-inspired gaming notepad & quest tracker modal sheet.
/// Allows gamers to track their to-dos, boss targets, daily quests, and game-specific notes.
class GamingNotepadSheet extends ConsumerStatefulWidget {
  const GamingNotepadSheet({super.key});

  /// Displays the notepad modal sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GamingNotepadSheet(),
    );
  }

  @override
  ConsumerState<GamingNotepadSheet> createState() => _GamingNotepadSheetState();
}

class _GamingNotepadSheetState extends ConsumerState<GamingNotepadSheet> {
  _GoalFilter _filter = _GoalFilter.all;
  bool _isAdding = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  App? _selectedGame;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitGoal() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final notes = _notesController.text.trim();

    final newGoal = GamingGoal.create(
      title: title,
      notes: notes.isNotEmpty ? notes : null,
      gameId: _selectedGame?.id,
      gameName: _selectedGame?.appName,
    );

    await ref.read(gamingGoalsRepositoryProvider).addGoal(newGoal);

    _titleController.clear();
    _notesController.clear();
    setState(() {
      _selectedGame = null;
      _isAdding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final goalsAsync = ref.watch(gamingGoalsStreamProvider);
    final gamesAsync = ref.watch(gamesListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.25),
                            colorScheme.tertiary.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'GAMING NOTEPAD & GOALS',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Quests, boss targets & game milestones',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 16),

              // Filter Chips
              goalsAsync.when(
                data: (goals) {
                  final totalCount = goals.length;
                  final activeCount = goals.where((g) => !g.isCompleted).length;
                  final completedCount = goals.where((g) => g.isCompleted).length;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _FilterChip(
                                  label: 'All ($totalCount)',
                                  isSelected: _filter == _GoalFilter.all,
                                  onSelected: () => setState(() => _filter = _GoalFilter.all),
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Active ($activeCount)',
                                  isSelected: _filter == _GoalFilter.active,
                                  onSelected: () => setState(() => _filter = _GoalFilter.active),
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                _FilterChip(
                                  label: 'Completed ($completedCount)',
                                  isSelected: _filter == _GoalFilter.completed,
                                  onSelected: () => setState(() => _filter = _GoalFilter.completed),
                                  color: const Color(0xFF00E676),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!_isAdding) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _isAdding = true),
                            icon: const Icon(Icons.add_rounded, size: 16),
                            label: const Text('Add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),

              // Add Goal Form (when _isAdding is true)
              if (_isAdding)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.add_task_rounded, color: colorScheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'NEW GOAL / QUEST',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => setState(() => _isAdding = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'e.g. Defeat Malenia, Hit Diamond rank, Daily quests...',
                          labelText: 'Goal Title',
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Notes, strategies, or build details (optional)...',
                          labelText: 'Notes',
                          filled: true,
                          fillColor: colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Game selector dropdown
                      gamesAsync.when(
                        data: (games) {
                          return DropdownButtonFormField<App?>(
                            initialValue: _selectedGame,
                            decoration: InputDecoration(
                              labelText: 'Link to Game (Optional)',
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withValues(alpha: 0.3),
                                ),
                              ),
                              isDense: true,
                              prefixIcon: const Icon(Icons.sports_esports_rounded, size: 20),
                            ),
                            items: [
                              const DropdownMenuItem<App?>(
                                value: null,
                                child: Text('General / All Games'),
                              ),
                              ...games.map((game) {
                                return DropdownMenuItem<App?>(
                                  value: game,
                                  child: Text(
                                    game.appName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) => setState(() => _selectedGame = val),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => setState(() => _isAdding = false),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _submitGoal,
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Save Goal'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Goals List
              Expanded(
                child: goalsAsync.when(
                  data: (goals) {
                    final filteredGoals = goals.where((g) {
                      switch (_filter) {
                        case _GoalFilter.all:
                          return true;
                        case _GoalFilter.active:
                          return !g.isCompleted;
                        case _GoalFilter.completed:
                          return g.isCompleted;
                      }
                    }).toList();

                    if (filteredGoals.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.primary.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  _filter == _GoalFilter.completed
                                      ? Icons.military_tech_outlined
                                      : Icons.checklist_rtl_rounded,
                                  size: 48,
                                  color: colorScheme.primary.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _filter == _GoalFilter.completed
                                    ? 'No completed goals yet'
                                    : 'No gaming goals found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _filter == _GoalFilter.completed
                                    ? 'Check off your active quests to see them here!'
                                    : 'Add boss fights, build goals, or daily quests to conquer.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (!_isAdding && _filter != _GoalFilter.completed) ...[
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: () => setState(() => _isAdding = true),
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add Your First Goal'),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: colorScheme.primary),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: filteredGoals.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final goal = filteredGoals[index];
                        return _GoalCard(
                          goal: goal,
                          onToggle: () {
                            ref.read(gamingGoalsRepositoryProvider).toggleGoal(goal.id);
                          },
                          onDelete: () {
                            ref.read(gamingGoalsRepositoryProvider).deleteGoal(goal.id);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error loading goals: $err')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GamingGoal goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDone = goal.isCompleted;

    return Container(
      decoration: BoxDecoration(
        color: isDone
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone
              ? Colors.transparent
              : colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox toggle
          GestureDetector(
            onTap: onToggle,
            child: Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: isDone
                    ? const Color(0xFF00E676)
                    : colorScheme.surface,
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF00E676)
                      : colorScheme.primary.withValues(alpha: 0.6),
                  width: 1.8,
                ),
                boxShadow: isDone
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.black,
                    )
                  : null,
            ),
          ),

          // Title, game badge, notes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone
                              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                              : colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                if (goal.gameName != null || (goal.notes != null && goal.notes!.isNotEmpty)) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (goal.gameName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sports_esports_rounded,
                                size: 12,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                goal.gameName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (goal.notes != null && goal.notes!.isNotEmpty)
                        Text(
                          goal.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                            fontStyle: FontStyle.italic,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Delete button
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
