import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/games/presentation/screens/games_list_screen.dart';
import '../../features/games/presentation/screens/game_detail_screen.dart';
import '../../features/sessions/presentation/screens/session_detail_screen.dart';
import '../../features/insights/presentation/screens/insights_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/games/presentation/screens/game_comparison_screen.dart';
import '../../shared/widgets/adaptive_scaffold.dart';

/// Application route paths.
class AppRoutes {
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const games = '/games';
  static const gameDetail = '/games/:id';
  static const gameCompare = '/games/compare';
  static const sessionDetail = '/sessions/:id';
  static const insights = '/insights';
  static const settings = '/settings';
}

/// Creates the GoRouter instance for the app.
GoRouter createRouter({bool onboardingComplete = false}) {
  return GoRouter(
    initialLocation:
        onboardingComplete ? AppRoutes.dashboard : AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Shell route for the main app scaffold with navigation
      ShellRoute(
        builder: (context, state, child) =>
            AdaptiveScaffold(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const DashboardScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.games,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const GamesListScreen(),
              transitionsBuilder: _fadeTransition,
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return GameDetailScreen(appId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.insights,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const InsightsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              child: const SettingsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/games/compare',
        builder: (context, state) {
          final appA =
              int.tryParse(state.uri.queryParameters['appA'] ?? '');
          final appB =
              int.tryParse(state.uri.queryParameters['appB'] ?? '');
          return GameComparisonScreen(
            initialAppAId: appA,
            initialAppBId: appB,
          );
        },
      ),
      GoRoute(
        path: '/sessions/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return SessionDetailScreen(sessionId: id);
        },
      ),
    ],
  );
}

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}
