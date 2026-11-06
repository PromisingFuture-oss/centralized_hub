import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';

/// Navigation destination definition.
class NavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;

  const NavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });
}

const _destinations = [
  NavDestination(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    selectedIcon: Icons.dashboard,
    path: AppRoutes.dashboard,
  ),
  NavDestination(
    label: 'Games',
    icon: Icons.sports_esports_outlined,
    selectedIcon: Icons.sports_esports,
    path: AppRoutes.games,
  ),
  NavDestination(
    label: 'Insights',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
    path: AppRoutes.insights,
  ),
  NavDestination(
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    path: AppRoutes.settings,
  ),
];

/// Responsive scaffold that adapts between BottomNavigationBar (phone)
/// and NavigationRail (tablet).
class AdaptiveScaffold extends StatelessWidget {
  final String currentPath;
  final Widget child;

  const AdaptiveScaffold({
    super.key,
    required this.currentPath,
    required this.child,
  });

  int get _selectedIndex {
    for (int i = 0; i < _destinations.length; i++) {
      if (currentPath.startsWith(_destinations[i].path)) return i;
    }
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    context.go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;
    final isExpanded = width >= 840;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: isExpanded,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) =>
                  _onDestinationSelected(context, i),
              leading: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.hub,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Hub',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Icon(Icons.hub,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28),
                    ),
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Phone layout with bottom navigation
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          elevation: 0,
          backgroundColor: Colors.transparent,
          onDestinationSelected: (i) => _onDestinationSelected(context, i),
          destinations: _destinations
              .map((d) => NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
