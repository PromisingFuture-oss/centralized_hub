import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:centralized_hub/core/utils/duration_formatter.dart';
import 'package:centralized_hub/domain/enums/time_range.dart';
import 'package:centralized_hub/features/dashboard/providers/card_data_providers.dart';

/// Full-screen animated slideshow presentation for Top Games recap.
/// Inspired by Spotify Wrapped, Steam Year in Review, and Discord Wrapped.
class GamingRecapStoryScreen extends StatefulWidget {
  final List<TopGameItem> items;
  final TimeRange range;

  const GamingRecapStoryScreen({
    super.key,
    required this.items,
    required this.range,
  });

  /// Opens the animated recap story with a smooth cinematic fade transition.
  static void open(
    BuildContext context, {
    required List<TopGameItem> items,
    required TimeRange range,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.95),
        pageBuilder: (context, anim, _) => GamingRecapStoryScreen(
          items: items,
          range: range,
        ),
        transitionsBuilder: (context, anim, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<GamingRecapStoryScreen> createState() => _GamingRecapStoryScreenState();
}

class _GamingRecapStoryScreenState extends State<GamingRecapStoryScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;
  bool _isPaused = false;

  /// Slide sequence:
  /// 0: Intro slide (Total hours, sessions)
  /// 1..N: Game spotlight slides (in countdown order towards #1 Champion)
  /// N+1: Final Trophy & Shareable recap slide
  late final List<TopGameItem> _countdownItems;
  late final int _totalSlides;

  @override
  void initState() {
    super.initState();
    // Countdown order: lowest rank first, finishing with the #1 Champion
    _countdownItems = widget.items.reversed.toList();
    _totalSlides = _countdownItems.length + 2; // Intro + games + summary

    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goToNextSlide();
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _goToNextSlide() {
    if (_currentIndex < _totalSlides - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      _animController.reset();
      _animController.forward();
    } else {
      // Completed last slide, stop timer
      _animController.stop();
    }
  }

  void _goToPrevSlide() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      _animController.reset();
      _animController.forward();
    }
  }

  void _replay() {
    setState(() {
      _currentIndex = 0;
    });
    _pageController.jumpToPage(0);
    _animController.reset();
    _animController.forward();
  }

  void _pauseTimer() {
    if (!_isPaused) {
      _isPaused = true;
      _animController.stop();
    }
  }

  void _resumeTimer() {
    if (_isPaused) {
      _isPaused = false;
      if (_currentIndex < _totalSlides - 1) {
        _animController.forward();
      }
    }
  }

  String get _rangeTitle {
    return switch (widget.range) {
      TimeRange.week => 'Weekly Recap',
      TimeRange.month => 'Monthly Recap',
      TimeRange.year => 'Year in Review',
      TimeRange.allTime => 'All-Time Recap',
      _ => '${widget.range.displayName} Recap',
    };
  }

  void _shareSummary() {
    final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];
    final buffer = StringBuffer();
    buffer.writeln('🎮 **My Centralized Hub $_rangeTitle**');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    int totalMs = 0;
    for (var i = 0; i < widget.items.length; i++) {
      final it = widget.items[i];
      final medal = i < medals.length ? medals[i] : '${i + 1}.';
      final dur = DurationFormatter.formatMs(it.totalPlaytimeMs);
      final pct = it.percentage.toStringAsFixed(1);
      buffer.writeln('$medal **${it.app.appName}** — $dur ($pct%)');
      totalMs += it.totalPlaytimeMs;
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('⏱️ Total Time: **${DurationFormatter.formatMs(totalMs)}**');
    buffer.writeln('🔥 Tracked with Centralized Hub');

    Share.share(buffer.toString(), subject: 'My $_rangeTitle');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalMs = widget.items.fold<int>(0, (sum, it) => sum + it.totalPlaytimeMs);
    final totalSessions = widget.items.fold<int>(0, (sum, it) => sum + it.sessionCount);

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < screenWidth * 0.35) {
              _goToPrevSlide();
            } else {
              _goToNextSlide();
            }
          },
          onLongPressStart: (_) => _pauseTimer(),
          onLongPressEnd: (_) => _resumeTimer(),
          child: Stack(
            children: [
              // Dynamic glowing background mesh
              Positioned.fill(
                child: _AmbientBackgroundMesh(
                  primaryColor: colorScheme.primary,
                  isChampionSlide: _currentIndex == _totalSlides - 2, // #1 game is second to last
                ),
              ),

              // Slide content
              PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _totalSlides,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _IntroSlide(
                      rangeTitle: _rangeTitle,
                      totalMs: totalMs,
                      totalSessions: totalSessions,
                      gamesCount: widget.items.length,
                    );
                  } else if (index == _totalSlides - 1) {
                    return _FinalRecapSlide(
                      rangeTitle: _rangeTitle,
                      items: widget.items,
                      totalMs: totalMs,
                      onReplay: _replay,
                      onShare: _shareSummary,
                      onClose: () => Navigator.of(context).pop(),
                    );
                  } else {
                    final gameIndex = index - 1;
                    final item = _countdownItems[gameIndex];
                    // Actual rank in descending playtime:
                    final rank = widget.items.indexOf(item) + 1;
                    return _GameSpotlightSlide(
                      item: item,
                      rank: rank,
                      rangeTitle: _rangeTitle,
                    );
                  }
                },
              ),

              // Top overlay: Progress bars + Header info + Close button
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    // Segmented story progress bar
                    Row(
                      children: List.generate(_totalSlides, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: _StoryProgressBar(
                              animController: _animController,
                              isCompleted: index < _currentIndex,
                              isActive: index == _currentIndex,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    // Header Bar
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 14,
                                color: Color(0xFFFFD700),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _rangeTitle.toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom subtle hint
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _currentIndex == _totalSlides - 1
                        ? 'Tap Replay or Share'
                        : 'Tap right to advance • Tap and hold to pause',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Segmented Story Progress Bar ====================

class _StoryProgressBar extends StatelessWidget {
  final AnimationController animController;
  final bool isCompleted;
  final bool isActive;

  const _StoryProgressBar({
    required this.animController,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        height: 3.5,
        color: Colors.white.withValues(alpha: 0.2),
        child: isActive
            ? AnimatedBuilder(
                animation: animController,
                builder: (context, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animController.value,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFFFFD700)],
                        ),
                      ),
                    ),
                  );
                },
              )
            : (isCompleted
                ? Container(
                    color: Colors.white,
                  )
                : const SizedBox.shrink()),
      ),
    );
  }
}

// ==================== Slide 0: Intro Slide ====================

class _IntroSlide extends StatelessWidget {
  final String rangeTitle;
  final int totalMs;
  final int totalSessions;
  final int gamesCount;

  const _IntroSlide({
    required this.rangeTitle,
    required this.totalMs,
    required this.totalSessions,
    required this.gamesCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalHours = totalMs / (1000 * 60 * 60);

    final gamerVibe = totalHours >= 25
        ? '🔥 LEGENDARY GRINDER'
        : (totalHours >= 12
            ? '⚔️ DEDICATED WARRIOR'
            : (totalHours >= 4 ? '🎮 TACTICAL CASUAL' : '🌱 ROOKIE EXPLORER'));

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(28, 76, 28, 48),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 124).clamp(0.0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Crest
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.7, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 36,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Vibe Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            child: Text(
              gamerVibe,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'You spent a total of',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white70,
              fontFamily: 'Outfit',
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Massive formatted playtime
          Text(
            DurationFormatter.formatMs(totalMs),
            style: theme.textTheme.displayMedium?.copyWith(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
              fontSize: 48,
              letterSpacing: 1.0,
              color: Colors.white,
              shadows: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.7),
                  blurRadius: 30,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'gaming across $gamesCount titles in $totalSessions sessions.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white60,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app_rounded, color: Color(0xFF00E5FF), size: 20),
                const SizedBox(width: 10),
                Text(
                  'Tap anywhere to view your Top Games...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
},
);
  }
}

// ==================== Slides 1..N: Game Spotlight ====================

class _GameSpotlightSlide extends StatelessWidget {
  final TopGameItem item;
  final int rank;
  final String rangeTitle;

  const _GameSpotlightSlide({
    required this.item,
    required this.rank,
    required this.rangeTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isChampion = rank == 1;

    final rankColor = switch (rank) {
      1 => const Color(0xFFFFD700), // Gold
      2 => const Color(0xFFC0C0C0), // Silver
      3 => const Color(0xFFCD7F32), // Bronze
      4 => const Color(0xFF00E5FF), // Cyan
      _ => const Color(0xFF9D4EDD), // Violet
    };

    final medal = switch (rank) {
      1 => '👑 #1 CHAMPION',
      2 => '🥈 #2 RUNNER UP',
      3 => '🥉 #3 PODIUM',
      4 => '⚡ #4 FAVORITE',
      _ => '🎯 #5 CONTENDER',
    };

    final punchline = switch (rank) {
      1 => 'Your absolute obsession.',
      2 => 'Your most trusty sidekick.',
      3 => 'A staple of your gaming routine.',
      _ => 'Rounding out your top rotation.',
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 76, 24, 48),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 124).clamp(0.0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rank Badge
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (context, val, child) {
              return Transform.scale(scale: val, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: rankColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Text(
                medal,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: rankColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Big Game Poster / Icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1.0),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: isChampion ? 3.5 : 2.5),
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withValues(alpha: 0.5),
                    blurRadius: 36,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: item.app.iconBytes != null
                    ? Image.memory(
                        item.app.iconBytes!,
                        width: isChampion ? 110 : 96,
                        height: isChampion ? 110 : 96,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: isChampion ? 110 : 96,
                        height: isChampion ? 110 : 96,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.sports_esports,
                          size: 54,
                          color: rankColor,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Game Title
          Text(
            item.app.appName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            punchline,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),

          const SizedBox(height: 24),

          // Massive formatted playtime
          Text(
            'You spent',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DurationFormatter.formatMs(item.totalPlaytimeMs),
            style: theme.textTheme.displaySmall?.copyWith(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w900,
              color: rankColor,
              letterSpacing: 1.0,
              shadows: [
                BoxShadow(
                  color: rankColor.withValues(alpha: 0.6),
                  blurRadius: 24,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stat Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: rankColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  title: 'TIME SHARE',
                  value: '${item.percentage.toStringAsFixed(1)}%',
                  valueColor: rankColor,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                _StatColumn(
                  title: 'SESSIONS',
                  value: '${item.sessionCount}',
                  valueColor: Colors.white,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                _StatColumn(
                  title: 'AVG SESSION',
                  value: DurationFormatter.formatMs(
                    item.sessionCount > 0
                        ? (item.totalPlaytimeMs / item.sessionCount).round()
                        : item.totalPlaytimeMs,
                  ),
                  valueColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
},
);
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _StatColumn({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Slide Final: The Ultimate Recap Card ====================

class _FinalRecapSlide extends StatelessWidget {
  final String rangeTitle;
  final List<TopGameItem> items;
  final int totalMs;
  final VoidCallback onReplay;
  final VoidCallback onShare;
  final VoidCallback onClose;

  const _FinalRecapSlide({
    required this.rangeTitle,
    required this.items,
    required this.totalMs,
    required this.onReplay,
    required this.onShare,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final medals = ['🥇', '🥈', '🥉', '4️⃣', '5️⃣'];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 76, 20, 48),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 124).clamp(0.0, double.infinity),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Recap Card container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF131826),
                  const Color(0xFF0D101A),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'YOUR TOP 5 RECAP',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      DurationFormatter.formatMs(totalMs),
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Colors.white24),
                const SizedBox(height: 14),

                // Games list
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final medal = index < medals.length ? medals[index] : '${index + 1}.';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Text(medal, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: item.app.iconBytes != null
                              ? Image.memory(
                                  item.app.iconBytes!,
                                  width: 26,
                                  height: 26,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 26,
                                  height: 26,
                                  color: Colors.white12,
                                  child: const Icon(Icons.sports_esports, size: 14, color: Colors.white70),
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.app.appName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          DurationFormatter.formatMs(item.totalPlaytimeMs),
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w800,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons: Share & Replay
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: const Text('Replay Story'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share Story'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onClose,
            child: const Text('Close Recap', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    ),
  );
},
);
  }
}

// ==================== Animated Background Mesh ====================

class _AmbientBackgroundMesh extends StatelessWidget {
  final Color primaryColor;
  final bool isChampionSlide;

  const _AmbientBackgroundMesh({
    required this.primaryColor,
    required this.isChampionSlide,
  });

  @override
  Widget build(BuildContext context) {
    final auraColor = isChampionSlide ? const Color(0xFFFFD700) : primaryColor;

    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: auraColor.withValues(alpha: 0.18),
              boxShadow: [
                BoxShadow(
                  color: auraColor.withValues(alpha: 0.25),
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                  blurRadius: 90,
                  spreadRadius: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
