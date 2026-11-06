import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:centralized_hub/core/providers/providers.dart';
import 'package:centralized_hub/domain/enums/permission_type.dart';
import 'package:centralized_hub/shared/widgets/empty_state.dart';
import 'package:centralized_hub/features/dashboard/providers/dashboard_provider.dart';
import '../widgets/card_library_sheet.dart';
import '../widgets/dashboard_filters.dart';
import '../widgets/dashboard_grid.dart';
import 'package:centralized_hub/features/goals/presentation/widgets/gaming_notepad_sheet.dart';

final hasUsagePermissionProvider = FutureProvider.autoDispose<bool>((ref) async {
  final permChannel = ref.watch(permissionChannelProvider);
  return await permChannel.checkPermission(PermissionType.usageStats);
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  void _openCardLibrary() {
    final controller = ref.read(dashboardControllerProvider);
    CardLibrarySheet.show(
      context,
      onCardSelected: (type, size) {
        controller.addCard(type, size: size);
      },
    );
  }

  void _showNewLayoutDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Dashboard Layout'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Layout Name',
            hintText: 'e.g. Battery Focus',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(dashboardControllerProvider).createLayout(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final layoutsAsync = ref.watch(allLayoutsProvider);
    final activeLayoutAsync = ref.watch(activeLayoutProvider);
    final activeCards = ref.watch(activeCardsProvider);
    final controller = ref.read(dashboardControllerProvider);
    final isRunningAsync = ref.watch(isTrackingRunningProvider);
    final isRunning = isRunningAsync.value ?? false;
    final hasPermAsync = ref.watch(hasUsagePermissionProvider);
    final hasPermission = hasPermAsync.value ?? true;
    final pendingGoalsCount = ref.watch(pendingGoalsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: pendingGoalsCount > 0
                ? Badge.count(
                    count: pendingGoalsCount,
                    backgroundColor: colorScheme.primary,
                    textColor: colorScheme.onPrimary,
                    child: const Icon(Icons.edit_note_rounded),
                  )
                : const Icon(Icons.edit_note_rounded),
            tooltip: 'Gaming Notepad & Goals',
            onPressed: () => GamingNotepadSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add Card',
            onPressed: _openCardLibrary,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: _LivePulsePill(
                isRunning: isRunning,
                onTap: () async {
                  final tracker = ref.read(sessionTrackerServiceProvider);
                  if (isRunning) {
                    await tracker.stopTracking();
                  } else {
                    await tracker.startTracking();
                  }
                  ref.invalidate(isTrackingRunningProvider);
                },
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Missing permission warning banner
          if (!hasPermission)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Usage Access Required',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                          Text(
                            'Centralized Hub cannot detect games without this permission.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () async {
                        await ref
                            .read(permissionChannelProvider)
                            .requestPermission(PermissionType.usageStats);
                        ref.invalidate(hasUsagePermissionProvider);
                      },
                      child: const Text('Grant'),
                    ),
                  ],
                ),
              ),
            ),
          // Layout tabs
          SliverToBoxAdapter(
            child: layoutsAsync.when(
              data: (layouts) {
                if (layouts.isEmpty) return const SizedBox.shrink();
                final activeLayout = activeLayoutAsync.value;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      for (final layout in layouts) ...[
                        ChoiceChip(
                          label: Text(layout.name),
                          selected: activeLayout?.id == layout.id,
                          onSelected: (selected) {
                            if (selected) controller.setActiveLayout(layout.id);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      IconButton.outlined(
                        icon: const Icon(Icons.add, size: 18),
                        tooltip: 'New Layout',
                        onPressed: _showNewLayoutDialog,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, _) => const SizedBox.shrink(),
            ),
          ),

          // Filters bar
          const SliverToBoxAdapter(
            child: DashboardFiltersBar(),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 8),
          ),

          // Cards grid or empty state
          if (activeCards.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.dashboard_customize_outlined,
                title: 'No cards in this layout',
                subtitle: 'Customize your dashboard by adding cards from the library.',
                actionLabel: 'Add Card',
                onAction: _openCardLibrary,
              ),
            )
          else
            SliverToBoxAdapter(
              child: DashboardGrid(cards: activeCards),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}

/// Pulsating telemetry indicator pill for active background tracking.
class _LivePulsePill extends StatefulWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _LivePulsePill({
    required this.isRunning,
    required this.onTap,
  });

  @override
  State<_LivePulsePill> createState() => _LivePulsePillState();
}

class _LivePulsePillState extends State<_LivePulsePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = widget.isRunning;
    final color = isRunning ? const Color(0xFF00E676) : Colors.grey;

    return Tooltip(
      message: isRunning
          ? 'Telemetry Tracking Live (Tap to toggle)'
          : 'Telemetry Tracking Inactive (Tap to start)',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            final pulseValue = isRunning ? _animController.value : 0.0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isRunning ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(
                      alpha: isRunning ? 0.4 + (0.35 * pulseValue) : 0.25),
                  width: 1.2,
                ),
                boxShadow: isRunning
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.28 * pulseValue),
                          blurRadius: 8 * pulseValue,
                          spreadRadius: 1 * pulseValue,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: isRunning
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.8),
                                blurRadius: 4 + (4 * pulseValue),
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isRunning ? 'LIVE' : 'OFF',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
