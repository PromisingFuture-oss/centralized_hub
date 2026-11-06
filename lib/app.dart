import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/providers/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root application widget.
class CentralizedHubApp extends ConsumerStatefulWidget {
  const CentralizedHubApp({super.key});

  @override
  ConsumerState<CentralizedHubApp> createState() => _CentralizedHubAppState();
}

class _CentralizedHubAppState extends ConsumerState<CentralizedHubApp> {
  GoRouter? _router;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    bool complete = false;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      complete = await settings.isOnboardingComplete();
      if (complete) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            await ref.read(sessionTrackerServiceProvider).initialize();
          } catch (_) {}
        });
      }
    } catch (_) {
      complete = false;
    }

    if (mounted) {
      setState(() {
        _router = createRouter(onboardingComplete: complete);
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawMode = ref.watch(rawThemeModeProvider).value ?? 'system';
    final accentColor =
        ref.watch(accentColorProvider).value ?? AppTheme.defaultSeedColor;
    final isAmoled = rawMode == 'amoled';

    if (!_isInitialized || _router == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: isAmoled
            ? AppTheme.amoled(seedColor: accentColor)
            : AppTheme.dark(seedColor: accentColor),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final themeMode = ref.watch(themeModeProvider).value ?? ThemeMode.system;

    return MaterialApp.router(
      title: 'Centralized Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seedColor: accentColor),
      darkTheme: isAmoled
          ? AppTheme.amoled(seedColor: accentColor)
          : AppTheme.dark(seedColor: accentColor),
      themeMode: themeMode,
      routerConfig: _router!,
    );
  }
}
