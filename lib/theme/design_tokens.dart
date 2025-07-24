// Cash on Hand - Design Tokens System
// A comprehensive, scalable design foundation for consistent UI implementation

import 'package:flutter/material.dart';

/// 🎨 DESIGN TOKENS - Single Source of Truth for All Design Decisions
/// This file contains all design decisions as tokens that can be referenced
/// throughout the app to ensure consistency and enable easy theming changes.

class DesignTokens {
  // 🎯 DESIGN PRINCIPLES
  // 1. Financial Clarity - Clear visual hierarchy for financial data
  // 2. Action-Oriented - Easy identification of positive/negative/neutral states
  // 3. Accessible First - WCAG 2.1 AA compliance minimum
  // 4. Responsive - Fluid across all device sizes
  // 5. Consistent - Predictable patterns and behaviors

  /// 🌈 COLOR SYSTEM - Semantic Color Palette
  /// Based on financial app needs with clear positive/negative/neutral states
  
  // Primitive Colors (Base Palette)
  static const _green50 = Color(0xFFE8F5E8);
  static const _green100 = Color(0xFFC8E6C9);
  static const _green200 = Color(0xFFA5D6A7);
  static const _green300 = Color(0xFF81C784);  
  static const _green400 = Color(0xFF66BB6A);
  static const _green500 = Color(0xFF4CAF50);
  static const _green600 = Color(0xFF43A047);  // Primary Green
  static const _green700 = Color(0xFF388E3C);
  static const _green800 = Color(0xFF2E7D32);
  static const _green900 = Color(0xFF1B5E20);

  static const _red50 = Color(0xFFFFEBEE);
  static const _red100 = Color(0xFFFFCDD2);
  static const _red200 = Color(0xFFEF9A9A);
  static const _red300 = Color(0xFFE57373);
  static const _red400 = Color(0xFFEF5350);
  static const _red500 = Color(0xFFF44336);
  static const _red600 = Color(0xFFE53935);   // Primary Red
  static const _red700 = Color(0xFFD32F2F);
  static const _red800 = Color(0xFFC62828);
  static const _red900 = Color(0xFFB71C1C);

  static const _blue50 = Color(0xFFE3F2FD);
  static const _blue100 = Color(0xFFBBDEFB);
  static const _blue200 = Color(0xFF90CAF9);
  static const _blue300 = Color(0xFF64B5F6);
  static const _blue400 = Color(0xFF42A5F5);
  static const _blue500 = Color(0xFF2196F3);
  static const _blue600 = Color(0xFF1E88E5);   // Primary Blue
  static const _blue700 = Color(0xFF1976D2);
  static const _blue800 = Color(0xFF1565C0);
  static const _blue900 = Color(0xFF0D47A1);

  static const _orange50 = Color(0xFFFFF3E0);
  static const _orange100 = Color(0xFFFFE0B2);
  static const _orange200 = Color(0xFFFFCC80);
  static const _orange300 = Color(0xFFFFB74D);
  static const _orange400 = Color(0xFFFFA726);
  static const _orange500 = Color(0xFFFF9800);
  static const _orange600 = Color(0xFFFB8C00);  // Warning Orange
  static const _orange700 = Color(0xFFF57C00);
  static const _orange800 = Color(0xFFEF6C00);
  static const _orange900 = Color(0xFFE65100);

  static const _grey50 = Color(0xFFFAFAFA);
  static const _grey100 = Color(0xFFF5F5F5);
  static const _grey200 = Color(0xFFEEEEEE);
  static const _grey300 = Color(0xFFE0E0E0);
  static const _grey400 = Color(0xFFBDBDBD);
  static const _grey500 = Color(0xFF9E9E9E);
  static const _grey600 = Color(0xFF757575);
  static const _grey700 = Color(0xFF616161);
  static const _grey800 = Color(0xFF424242);
  static const _grey900 = Color(0xFF212121);

  // Semantic Colors (Purpose-Based)
  static const Map<String, Color> colors = {
    // Brand & Primary Actions
    'primary': _green600,
    'primaryLight': _green400,
    'primaryDark': _green800,
    'primaryContainer': _green50,
    'onPrimary': Colors.white,
    'onPrimaryContainer': _green800,

    // Secondary Actions
    'secondary': _blue600,
    'secondaryLight': _blue400, 
    'secondaryDark': _blue800,
    'secondaryContainer': _blue50,
    'onSecondary': Colors.white,
    'onSecondaryContainer': _blue800,

    // Financial States
    'income': _green600,          // Positive cash flow
    'incomeLight': _green100,
    'incomeDark': _green800,
    'expense': _red600,           // Negative cash flow  
    'expenseLight': _red100,
    'expenseDark': _red800,
    'neutral': _grey600,          // Zero/neutral state
    'neutralLight': _grey100,
    'neutralDark': _grey800,

    // Status Colors
    'success': _green600,
    'successContainer': _green50,
    'onSuccess': Colors.white,
    'warning': _orange600,
    'warningContainer': _orange50,
    'onWarning': Colors.white,
    'error': _red600,
    'errorContainer': _red50,
    'onError': Colors.white,
    'info': _blue600,
    'infoContainer': _blue50,
    'onInfo': Colors.white,

    // Surface Colors
    'surface': Colors.white,
    'surfaceVariant': _grey50,
    'surfaceContainer': _grey100,
    'surfaceContainerHigh': _grey200,
    'onSurface': _grey900,
    'onSurfaceVariant': _grey700,
    'background': Colors.white,
    'onBackground': _grey900,

    // Interactive States
    'interactive': _blue600,
    'interactiveHover': _blue700,
    'interactivePressed': _blue800,
    'interactiveDisabled': _grey400,
    'interactiveSurface': _blue50,

    // Text Colors
    'textPrimary': _grey900,
    'textSecondary': _grey700,
    'textTertiary': _grey600,
    'textDisabled': _grey400,
    'textOnDark': Colors.white,
    'textOnColor': Colors.white,

    // Border Colors
    'border': _grey300,
    'borderHover': _grey400,
    'borderFocus': _blue600,
    'borderError': _red600,
    'borderSuccess': _green600,

    // Overlay Colors
    'overlay': Color(0x80000000),
    'scrim': Color(0x1A000000),
    'backdrop': Color(0x60000000),
  };

  /// 📏 SPACING SYSTEM - 8px Base Grid System
  /// Consistent spacing scale for margins, padding, and positioning
  
  static const Map<String, double> spacing = {
    'xs': 4.0,      // 0.25rem - Micro spacing
    'sm': 8.0,      // 0.5rem  - Small spacing  
    'md': 16.0,     // 1rem    - Base spacing
    'lg': 24.0,     // 1.5rem  - Large spacing
    'xl': 32.0,     // 2rem    - Extra large
    '2xl': 48.0,    // 3rem    - Section spacing
    '3xl': 64.0,    // 4rem    - Page spacing
    '4xl': 96.0,    // 6rem    - Hero spacing
  };

  // Component-specific spacing
  static const Map<String, double> componentSpacing = {
    'cardPadding': 16.0,
    'dialogPadding': 24.0,
    'sectionSpacing': 32.0,
    'buttonPadding': 16.0,
    'inputPadding': 12.0,
    'listItemPadding': 16.0,
    'iconTextSpacing': 8.0,
    'formFieldSpacing': 16.0,
  };

  /// 🔤 TYPOGRAPHY SYSTEM - Modular Scale Typography
  /// Type scale based on 1.250 (Major Third) ratio for harmonious proportions
  
  static const String fontFamilyPrimary = 'Inter';
  static const String fontFamilyMono = 'JetBrains Mono';

  static const Map<String, TextStyle> textStyles = {
    // Display Styles (Hero text)
    'displayLarge': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 57.0,     // 3.563rem
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    ),
    'displayMedium': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 45.0,     // 2.813rem
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    ),
    'displaySmall': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 36.0,     // 2.25rem
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    ),

    // Headline Styles (Page titles)
    'headlineLarge': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 32.0,     // 2rem
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    ),
    'headlineMedium': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 28.0,     // 1.75rem
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.29,
    ),
    'headlineSmall': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 24.0,     // 1.5rem
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.33,
    ),

    // Title Styles (Section headers)
    'titleLarge': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 22.0,     // 1.375rem
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      height: 1.27,
    ),
    'titleMedium': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 18.0,     // 1.125rem
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.33,
    ),
    'titleSmall': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 16.0,     // 1rem
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.25,
    ),

    // Body Styles (Main content)
    'bodyLarge': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 16.0,     // 1rem
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
    ),
    'bodyMedium': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 14.0,     // 0.875rem
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    'bodySmall': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 12.0,     // 0.75rem
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    ),

    // Label Styles (UI labels)
    'labelLarge': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 14.0,     // 0.875rem
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    ),
    'labelMedium': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 12.0,     // 0.75rem
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    ),
    'labelSmall': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 11.0,     // 0.688rem
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    ),

    // Financial Number Styles (Special formatting for amounts)
    'amountLarge': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    'amountMedium': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      height: 1.2,
    ),
    'amountSmall': TextStyle(
      fontFamily: fontFamilyPrimary,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.2,
    ),

    // Monospace (For code/IDs)
    'codeLarge': TextStyle(
      fontFamily: fontFamilyMono,
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    'codeMedium': TextStyle(
      fontFamily: fontFamilyMono,
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    'codeSmall': TextStyle(
      fontFamily: fontFamilyMono,
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
  };

  /// 🏔️ ELEVATION SYSTEM - Layered Shadow System
  /// Consistent depth hierarchy using Material Design elevation principles
  
  static const Map<String, List<BoxShadow>> shadows = {
    'none': [],
    'xs': [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 1,
        offset: Offset(0, 1),
      ),
    ],
    'sm': [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 1,
        offset: Offset(0, 1),
      ),
    ],
    'md': [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 2,
        offset: Offset(0, 2),
      ),
    ],
    'lg': [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 3,
        offset: Offset(0, 2),
      ),
    ],
    'xl': [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 6,
        offset: Offset(0, 4),
      ),
    ],
    '2xl': [
      BoxShadow(
        color: Color(0x26000000),
        blurRadius: 40,
        offset: Offset(0, 16),
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 10,
        offset: Offset(0, 8),
      ),
    ],
  };

  /// 🎬 MOTION SYSTEM - Animation & Transition Standards
  /// Consistent timing and easing for all animations
  
  static const Map<String, Duration> durations = {
    'immediate': Duration(milliseconds: 0),
    'fast': Duration(milliseconds: 150),
    'normal': Duration(milliseconds: 250),
    'slow': Duration(milliseconds: 350),
    'slower': Duration(milliseconds: 500),
    'slowest': Duration(milliseconds: 800),
  };

  static const Map<String, Curve> easings = {
    'linear': Curves.linear,
    'easeIn': Curves.easeIn,
    'easeOut': Curves.easeOut,
    'easeInOut': Curves.easeInOut,
    'fastOutSlowIn': Curves.fastOutSlowIn,
    'bounce': Curves.bounceOut,
    'elastic': Curves.elasticOut,
  };

  /// 📐 BORDER RADIUS SYSTEM - Consistent Corner Rounding
  
  static const Map<String, BorderRadius> borderRadius = {
    'none': BorderRadius.zero,
    'xs': BorderRadius.all(Radius.circular(4.0)),
    'sm': BorderRadius.all(Radius.circular(8.0)),
    'md': BorderRadius.all(Radius.circular(12.0)),
    'lg': BorderRadius.all(Radius.circular(16.0)),
    'xl': BorderRadius.all(Radius.circular(24.0)),
    '2xl': BorderRadius.all(Radius.circular(32.0)),
    'full': BorderRadius.all(Radius.circular(9999.0)),
  };

  /// 📱 RESPONSIVE BREAKPOINTS - Device Size Standards
  
  static const Map<String, double> breakpoints = {
    'mobile': 375.0,      // Mobile portrait
    'mobileLarge': 414.0, // Large mobile
    'tablet': 768.0,      // Tablet portrait  
    'tabletLarge': 1024.0,// Tablet landscape
    'desktop': 1280.0,    // Desktop
    'desktopLarge': 1440.0,// Large desktop
    'wide': 1920.0,       // Ultra-wide
  };

  /// 🎯 Z-INDEX SYSTEM - Layering Hierarchy
  
  static const Map<String, int> zIndex = {
    'hide': -1,
    'base': 0,
    'raised': 1,
    'dropdown': 10,
    'sticky': 20,
    'fixed': 30,
    'modalBackdrop': 40,
    'modal': 50,
    'popover': 60,
    'tooltip': 70,
    'toast': 80,
    'system': 90,
  };

  /// 🔧 UTILITY FUNCTIONS - Helper Methods for Token Usage
  
  // Color getter with fallback
  static Color color(String token, [Color? fallback]) {
    return colors[token] ?? fallback ?? colors['textPrimary']!;
  }

  // Spacing getter with fallback  
  static double space(String token, [double? fallback]) {
    return spacing[token] ?? componentSpacing[token] ?? fallback ?? spacing['md']!;
  }

  // Text style getter with fallback
  static TextStyle textStyle(String token, [TextStyle? fallback]) {
    return textStyles[token] ?? fallback ?? textStyles['bodyMedium']!;
  }

  /// 📱 RESPONSIVE TEXT SCALING
  /// Scales text based on screen size and available space
  
  static double getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Define breakpoints
    if (screenWidth < 350) return 0.85; // Small phones
    if (screenWidth < 400) return 0.9;  // Medium phones
    if (screenWidth < 450) return 1.0;  // Large phones
    return 1.1; // Very large phones/tablets
  }
  
  static TextStyle responsiveTextStyle(String token, BuildContext context, [TextStyle? fallback]) {
    final baseStyle = textStyles[token] ?? fallback ?? textStyles['bodyMedium']!;
    final scaleFactor = getScaleFactor(context);
    
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 16.0) * scaleFactor,
    );
  }
  
  static TextStyle adaptiveTextStyle(String token, BuildContext context, {
    double? maxWidth,
    double? minFontSize,
    double? maxFontSize,
  }) {
    final baseStyle = textStyles[token] ?? textStyles['bodyMedium']!;
    final scaleFactor = getScaleFactor(context);
    
    double fontSize = (baseStyle.fontSize ?? 16.0) * scaleFactor;
    
    // Apply constraints if provided
    if (minFontSize != null && fontSize < minFontSize) {
      fontSize = minFontSize;
    }
    if (maxFontSize != null && fontSize > maxFontSize) {
      fontSize = maxFontSize;
    }
    
    return baseStyle.copyWith(fontSize: fontSize);
  }

  // Shadow getter with fallback
  static List<BoxShadow> shadow(String token, [List<BoxShadow>? fallback]) {
    return shadows[token] ?? fallback ?? shadows['sm']!;
  }

  // Border radius getter with fallback  
  static BorderRadius radius(String token, [BorderRadius? fallback]) {
    return borderRadius[token] ?? fallback ?? borderRadius['md']!;
  }

  // Duration getter with fallback
  static Duration duration(String token, [Duration? fallback]) {
    return durations[token] ?? fallback ?? durations['normal']!;
  }

  // Curve getter with fallback
  static Curve curve(String token, [Curve? fallback]) {
    return easings[token] ?? fallback ?? easings['easeInOut']!;
  }

  // Responsive helper - returns appropriate value based on screen width
  static T responsive<T>(BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= breakpoints['desktop']!) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= breakpoints['tablet']!) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  // Financial color helper - returns appropriate color for amount
  static Color amountColor(double amount, [String variant = '']) {
    if (amount > 0) {
      return variant.isEmpty ? color('income') : color('income$variant');
    } else if (amount < 0) {
      return variant.isEmpty ? color('expense') : color('expense$variant');
    } else {
      return variant.isEmpty ? color('neutral') : color('neutral$variant');
    }
  }

  // Component state color helper
  static Color stateColor(String state, String baseColor) {
    switch (state) {
      case 'hover':
        return color('${baseColor}Light');
      case 'pressed':
        return color('${baseColor}Dark');  
      case 'disabled':
        return color('textDisabled');
      default:
        return color(baseColor);
    }
  }
}