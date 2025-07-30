import 'package:flutter/material.dart';

class AppTheme {
  // Color Scheme
  static const _primary = Color(0xFF2E7D32);  // Green
  static const _secondary = Color(0xFFD32F2F); // Red
  static const _surface = Color(0xFFFAFAFA);
  static const _background = Color(0xFFFFFFFF);
  
  // Animation Durations
  static const Duration defaultDuration = Duration(milliseconds: 300);
  
  // Spacing
  static const double defaultRadius = 12.0;
  static const double defaultPadding = 10.0;
  static const double cardElevation = 2.0;
  
  // Shadow
  static final BoxShadow defaultShadow = BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: _primary,
        secondary: _secondary,
        surface: _surface,
        // Amount colors
        error: _secondary,  // Used for negative amounts
        onError: Colors.white,
        tertiary: _primary, // Used for positive amounts
        onTertiary: Colors.white,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primary,
        linearTrackColor: _primary.withOpacity(0.1),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: _primary,
        secondary: _secondary,
        surface: Colors.grey[900]!,
        error: _secondary.withOpacity(0.9),
        onError: Colors.white,
        tertiary: _primary.withOpacity(0.9),
        onTertiary: Colors.white,
      ),
      
      cardTheme: CardThemeData(
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Colors.white70,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.4,
          color: Colors.white70,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primary,
        linearTrackColor: _primary.withOpacity(0.2),
      ),
    );
  }

  // Extension methods for common UI patterns
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: _background,
    borderRadius: BorderRadius.circular(defaultRadius),
    boxShadow: [defaultShadow],
  );

  static BoxDecoration achievementBadgeDecoration({required double progress}) => BoxDecoration(
    color: _primary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(defaultRadius),
    border: Border.all(
      color: _primary.withOpacity(progress),
      width: 2,
    ),
  );

  // Common animation configurations
  static Widget fadeTransition({
    required Widget child,
    bool show = true,
  }) {
    return AnimatedOpacity(
      opacity: show ? 1.0 : 0.0,
      duration: defaultDuration,
      child: child,
    );
  }

  static Widget expandTransition({
    required Widget child,
    bool expand = true,
    Axis axis = Axis.vertical,
  }) {
    return AnimatedContainer(
      duration: defaultDuration,
      curve: Curves.easeInOut,
      height: expand ? null : 0.0,
      width: expand ? null : 0.0,
      child: ClipRect(
        child: child,
      ),
    );
  }
}
