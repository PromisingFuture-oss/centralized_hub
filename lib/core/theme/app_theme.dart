import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Predefined gaming accent theme presets.
class AccentThemePreset {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final String hex;
  final String description;

  const AccentThemePreset({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.hex,
    required this.description,
  });
}

/// Builds high-performance gaming telemetry themes for the app.
class AppTheme {
  AppTheme._();

  /// Curated gaming accent presets.
  static const List<AccentThemePreset> presets = [
    AccentThemePreset(
      id: 'cyber_cyan',
      name: 'Cyber Cyan',
      primary: Color(0xFF00E5FF),
      secondary: Color(0xFF7B2CBF),
      hex: '#00E5FF',
      description: 'Luminous electric cyan and neon violet',
    ),
    AccentThemePreset(
      id: 'rog_crimson',
      name: 'ROG Crimson',
      primary: Color(0xFFFF1E56),
      secondary: Color(0xFFFFAA00),
      hex: '#FF1E56',
      description: 'High-octane gamer red and performance amber',
    ),
    AccentThemePreset(
      id: 'matrix_emerald',
      name: 'Matrix Emerald',
      primary: Color(0xFF00E676),
      secondary: Color(0xFF00B0FF),
      hex: '#00E676',
      description: 'High-contrast cyber emerald green',
    ),
    AccentThemePreset(
      id: 'electric_violet',
      name: 'Electric Violet',
      primary: Color(0xFF9D4EDD),
      secondary: Color(0xFF00F5D4),
      hex: '#9D4EDD',
      description: 'Deep synthwave violet and glowing turquoise',
    ),
    AccentThemePreset(
      id: 'solar_amber',
      name: 'Solar Amber',
      primary: Color(0xFFFF9100),
      secondary: Color(0xFFFF3D00),
      hex: '#FF9100',
      description: 'Radiant thermal blaze and solar gold',
    ),
    AccentThemePreset(
      id: 'classic_indigo',
      name: 'Classic Indigo',
      primary: Color(0xFF6750A4),
      secondary: Color(0xFF625B71),
      hex: '#6750A4',
      description: 'Classic balanced Material deep purple',
    ),
  ];

  static const Color defaultSeedColor = Color(0xFF00E5FF);

  static ThemeData light({Color seedColor = defaultSeedColor}) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final colorScheme = baseScheme.copyWith(
      surface: const Color(0xFFF7F9FC),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFEFF2F8),
      surfaceContainer: const Color(0xFFE6EBF3),
      surfaceContainerHigh: const Color(0xFFDCE2ED),
      surfaceContainerHighest: const Color(0xFFD2D9E6),
      outlineVariant: const Color(0xFFCCD4E0),
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData dark({Color seedColor = defaultSeedColor}) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    final colorScheme = baseScheme.copyWith(
      surface: const Color(0xFF0D1016),
      onSurface: const Color(0xFFEFF3F8),
      surfaceContainerLowest: const Color(0xFF080A0E),
      surfaceContainerLow: const Color(0xFF131720),
      surfaceContainer: const Color(0xFF181E29),
      surfaceContainerHigh: const Color(0xFF1F2634),
      surfaceContainerHighest: const Color(0xFF283142),
      outlineVariant: const Color(0xFF2E384C),
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData amoled({Color seedColor = defaultSeedColor}) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    final colorScheme = baseScheme.copyWith(
      surface: Colors.black,
      onSurface: const Color(0xFFF8FAFC),
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: const Color(0xFF08090C),
      surfaceContainer: const Color(0xFF101217),
      surfaceContainerHigh: const Color(0xFF161921),
      surfaceContainerHighest: const Color(0xFF1F232D),
      outlineVariant: const Color(0xFF282E3B),
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isLight = colorScheme.brightness == Brightness.light;
    final baseTextTheme =
        isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme;

    final outfitTheme = GoogleFonts.outfitTextTheme(baseTextTheme);
    final interTheme = GoogleFonts.interTextTheme(baseTextTheme);

    // Merge: Outfit for display/headlines/metrics, Inter for body/labels
    final textTheme = interTheme.copyWith(
      displayLarge: outfitTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: outfitTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: outfitTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: outfitTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: outfitTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: outfitTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: outfitTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      titleMedium: outfitTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            );
          }
          return textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Parse a hex color string like "#00E5FF" or "00E5FF" to a Color.
  static Color parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return defaultSeedColor;
    }
  }
}
