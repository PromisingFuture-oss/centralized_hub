import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../domain/enums/permission_type.dart';

/// Onboarding screen with permission request flow.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with WidgetsBindingObserver {
  final _pageController = PageController();
  int _currentPage = 0;
  final Map<PermissionType, bool> _permissionStatuses = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    try {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      if (await settingsRepo.isOnboardingComplete()) {
        if (mounted) {
          context.go(AppRoutes.dashboard);
          return;
        }
      }
    } catch (_) {}
    await _checkPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final permChannel = ref.read(permissionChannelProvider);
      final statuses = await permChannel.checkAllPermissions();
      if (mounted) {
        setState(() {
          _permissionStatuses.addAll(statuses);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3 && _pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final settingsRepo = ref.read(settingsRepositoryProvider);
      await settingsRepo.setOnboardingComplete(true);

      // Sync installed apps (non-fatal if fails)
      try {
        final appRepo = ref.read(appRepositoryProvider);
        await appRepo.syncInstalledApps();
      } catch (e) {
        debugPrint('App sync non-fatal error: $e');
      }

      // Start tracking service (non-fatal if fails)
      try {
        final tracker = ref.read(sessionTrackerServiceProvider);
        await tracker.initialize();
      } catch (e) {
        debugPrint('Tracker init non-fatal error: $e');
      }

      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: index <= _currentPage
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _PermissionPage(
                    type: PermissionType.usageStats,
                    icon: Icons.bar_chart_rounded,
                    isGranted: _permissionStatuses[PermissionType.usageStats] ?? false,
                    onRequest: () => _requestPermission(PermissionType.usageStats),
                    onNext: _nextPage,
                  ),
                  _PermissionPage(
                    type: PermissionType.notification,
                    icon: Icons.notifications_active_rounded,
                    isGranted:
                        _permissionStatuses[PermissionType.notification] ?? false,
                    onRequest: () =>
                        _requestPermission(PermissionType.notification),
                    onNext: _nextPage,
                  ),
                  _PermissionPage(
                    type: PermissionType.batteryOptimization,
                    icon: Icons.battery_saver_rounded,
                    isGranted: _permissionStatuses[
                            PermissionType.batteryOptimization] ??
                        false,
                    onRequest: () =>
                        _requestPermission(PermissionType.batteryOptimization),
                    onNext: _completeOnboarding,
                    isLast: true,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission(PermissionType type) async {
    final permChannel = ref.read(permissionChannelProvider);
    await permChannel.requestPermission(type);
    await _checkPermissions();
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkPermissions();
  }
}

/// Welcome page (first onboarding step).
class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.tertiaryContainer,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hub_rounded,
              size: 64,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to\nCentralized Hub',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Track your gaming sessions, monitor device temperature, '
            'and understand your battery usage — all in one place.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 16, color: colorScheme.tertiary),
                const SizedBox(width: 8),
                Text(
                  'All data stays on your device',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Permission request page.
class _PermissionPage extends StatelessWidget {
  final PermissionType type;
  final IconData icon;
  final bool isGranted;
  final VoidCallback onRequest;
  final VoidCallback onNext;
  final bool isLast;
  final bool isLoading;

  const _PermissionPage({
    required this.type,
    required this.icon,
    required this.isGranted,
    required this.onRequest,
    required this.onNext,
    this.isLast = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isGranted
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGranted ? Icons.check_circle_rounded : icon,
              size: 56,
              color: isGranted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            type.displayName,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            type.explanation,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (type == PermissionType.usageStats)
            Text(
              'This opens Android Settings. Find this app in the list and enable access.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 40),
          if (!isGranted) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRequest,
                child: Text('Grant ${type.displayName}'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onNext,
                child: Text(isLast ? 'Skip & Finish' : 'Skip for Now'),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Permission granted',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : onNext,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isLast ? 'Finish Setup' : 'Continue'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
