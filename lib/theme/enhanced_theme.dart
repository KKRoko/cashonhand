// Cash on Hand - Enhanced Theme System
// Comprehensive theming system built on design tokens for consistent UI implementation

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

/// 🎨 ENHANCED THEME SYSTEM
/// Transforms design tokens into comprehensive Flutter themes with full component coverage
class EnhancedTheme {
  
  /// 🌞 LIGHT THEME - Primary app theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme from Design Tokens
      colorScheme: ColorScheme.light(
        // Primary Colors
        primary: DesignTokens.color('primary'),
        onPrimary: DesignTokens.color('onPrimary'),
        primaryContainer: DesignTokens.color('primaryContainer'),
        onPrimaryContainer: DesignTokens.color('onPrimaryContainer'),
        
        // Secondary Colors  
        secondary: DesignTokens.color('secondary'),
        onSecondary: DesignTokens.color('onSecondary'),
        secondaryContainer: DesignTokens.color('secondaryContainer'),
        onSecondaryContainer: DesignTokens.color('onSecondaryContainer'),
        
        // Surface Colors
        surface: DesignTokens.color('surface'),
        onSurface: DesignTokens.color('onSurface'),
        surfaceContainerHighest: DesignTokens.color('surfaceVariant'),
        onSurfaceVariant: DesignTokens.color('onSurfaceVariant'),
        
        // Status Colors
        error: DesignTokens.color('error'),
        onError: DesignTokens.color('onError'),
        errorContainer: DesignTokens.color('errorContainer'),
        
        // Financial Colors (using tertiary for income)
        tertiary: DesignTokens.color('income'),      // Positive amounts
        onTertiary: DesignTokens.color('onSuccess'),
        
        // Interactive Colors
        outline: DesignTokens.color('border'),
        outlineVariant: DesignTokens.color('borderHover'),
        scrim: DesignTokens.color('scrim'),
      ),

      // 🔤 Typography Theme from Design Tokens
      textTheme: TextTheme(
        displayLarge: DesignTokens.textStyle('displayLarge').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        displayMedium: DesignTokens.textStyle('displayMedium').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        displaySmall: DesignTokens.textStyle('displaySmall').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        headlineLarge: DesignTokens.textStyle('headlineLarge').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        headlineMedium: DesignTokens.textStyle('headlineMedium').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        headlineSmall: DesignTokens.textStyle('headlineSmall').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        titleLarge: DesignTokens.textStyle('titleLarge').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        titleMedium: DesignTokens.textStyle('titleMedium').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        titleSmall: DesignTokens.textStyle('titleSmall').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        bodyLarge: DesignTokens.textStyle('bodyLarge').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        bodyMedium: DesignTokens.textStyle('bodyMedium').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        bodySmall: DesignTokens.textStyle('bodySmall').copyWith(
          color: DesignTokens.color('textSecondary'),
        ),
        labelLarge: DesignTokens.textStyle('labelLarge').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        labelMedium: DesignTokens.textStyle('labelMedium').copyWith(
          color: DesignTokens.color('textSecondary'),
        ),
        labelSmall: DesignTokens.textStyle('labelSmall').copyWith(
          color: DesignTokens.color('textTertiary'),
        ),
      ),

      // 🃏 Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radius('md'),
          side: BorderSide(
            color: DesignTokens.color('border'),
            width: 1,
          ),
        ),
        color: DesignTokens.color('surface'),
        margin: EdgeInsets.all(DesignTokens.space('xs')),
      ),

      // 🔘 Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: DesignTokens.color('primary'),
          foregroundColor: DesignTokens.color('onPrimary'),
          disabledBackgroundColor: DesignTokens.color('interactiveDisabled'),
          disabledForegroundColor: DesignTokens.color('textDisabled'),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space('lg'),
            vertical: DesignTokens.space('md'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.radius('md'),
          ),
          textStyle: DesignTokens.textStyle('labelLarge'),
          minimumSize: const Size(88, 48),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignTokens.color('primary'),
          foregroundColor: DesignTokens.color('onPrimary'),
          disabledBackgroundColor: DesignTokens.color('interactiveDisabled'),
          disabledForegroundColor: DesignTokens.color('textDisabled'),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space('lg'),
            vertical: DesignTokens.space('md'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.radius('md'),
          ),
          textStyle: DesignTokens.textStyle('labelLarge'),
          minimumSize: const Size(88, 48),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.color('primary'),
          disabledForegroundColor: DesignTokens.color('textDisabled'),
          side: BorderSide(
            color: DesignTokens.color('border'),
            width: 1,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space('lg'),
            vertical: DesignTokens.space('md'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.radius('md'),
          ),
          textStyle: DesignTokens.textStyle('labelLarge'),
          minimumSize: const Size(88, 48),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.color('primary'),
          disabledForegroundColor: DesignTokens.color('textDisabled'),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space('md'),
            vertical: DesignTokens.space('sm'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: DesignTokens.radius('sm'),
          ),
          textStyle: DesignTokens.textStyle('labelLarge'),
          minimumSize: const Size(64, 40),
        ),
      ),

      // 📝 Input Field Themes
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.color('surfaceVariant'),
        border: OutlineInputBorder(
          borderRadius: DesignTokens.radius('md'),
          borderSide: BorderSide(
            color: DesignTokens.color('border'),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radius('md'),
          borderSide: BorderSide(
            color: DesignTokens.color('border'),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radius('md'),
          borderSide: BorderSide(
            color: DesignTokens.color('borderFocus'),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radius('md'),
          borderSide: BorderSide(
            color: DesignTokens.color('borderError'),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radius('md'),
          borderSide: BorderSide(
            color: DesignTokens.color('borderError'),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: DesignTokens.radius('md'),
          borderSide: BorderSide(
            color: DesignTokens.color('textDisabled'),
            width: 1,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.space('md'),
          vertical: DesignTokens.space('md'),
        ),
        hintStyle: DesignTokens.textStyle('bodyMedium').copyWith(
          color: DesignTokens.color('textTertiary'),
        ),
        labelStyle: DesignTokens.textStyle('labelMedium').copyWith(
          color: DesignTokens.color('textSecondary'),
        ),
        errorStyle: DesignTokens.textStyle('bodySmall').copyWith(
          color: DesignTokens.color('error'),
        ),
      ),

      // 📋 List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.space('md'),
          vertical: DesignTokens.space('xs'),
        ),
        minVerticalPadding: DesignTokens.space('xs'),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radius('md'),
        ),
        tileColor: DesignTokens.color('surface'),
        selectedTileColor: DesignTokens.color('primaryContainer'),
        iconColor: DesignTokens.color('textSecondary'),
        textColor: DesignTokens.color('textPrimary'),
      ),

      // 🗃️ App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: DesignTokens.color('surface'),
        foregroundColor: DesignTokens.color('textPrimary'),
        titleTextStyle: DesignTokens.textStyle('titleLarge').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        iconTheme: IconThemeData(
          color: DesignTokens.color('textSecondary'),
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: DesignTokens.color('textSecondary'),
          size: 24,
        ),
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // 🎯 Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: DesignTokens.color('primary'),
        linearTrackColor: DesignTokens.color('primaryContainer'),
        circularTrackColor: DesignTokens.color('primaryContainer'),
      ),

      // 🎛 Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignTokens.color('onPrimary');
          }
          return DesignTokens.color('surface');
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignTokens.color('primary');
          }
          return DesignTokens.color('border');
        }),
      ),

      // ☑️ Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignTokens.color('primary');
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(DesignTokens.color('onPrimary')),
        side: BorderSide(
          color: DesignTokens.color('border'),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radius('xs'),
        ),
      ),

      // 🔘 Radio Theme  
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignTokens.color('primary');
          }
          return DesignTokens.color('border');
        }),
      ),

      // 📝 Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.color('surfaceContainer'),
        selectedColor: DesignTokens.color('primaryContainer'),
        disabledColor: DesignTokens.color('interactiveDisabled'),
        deleteIconColor: DesignTokens.color('textSecondary'),
        labelStyle: DesignTokens.textStyle('labelMedium').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        secondaryLabelStyle: DesignTokens.textStyle('labelSmall').copyWith(
          color: DesignTokens.color('textSecondary'),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.space('sm'),
          vertical: DesignTokens.space('xs'),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radius('full'),
          side: BorderSide(
            color: DesignTokens.color('border'),
            width: 1,
          ),
        ),
      ),

      // 🏷 Tab Bar Theme
      tabBarTheme: TabBarTheme(
        indicatorColor: DesignTokens.color('primary'),
        labelColor: DesignTokens.color('primary'),
        unselectedLabelColor: DesignTokens.color('textSecondary'),
        labelStyle: DesignTokens.textStyle('labelLarge'),
        unselectedLabelStyle: DesignTokens.textStyle('labelMedium'),
        indicatorSize: TabBarIndicatorSize.label,
      ),

      // 🎪 Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: DesignTokens.color('surface'),
        surfaceTintColor: DesignTokens.color('surface'),
        elevation: 8,
        shadowColor: DesignTokens.color('overlay'),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radius('lg'),
        ),
        titleTextStyle: DesignTokens.textStyle('headlineSmall').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        contentTextStyle: DesignTokens.textStyle('bodyMedium').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        insetPadding: EdgeInsets.all(DesignTokens.space('lg')),
      ),

      // 🍕 Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignTokens.color('surface'),
        contentTextStyle: DesignTokens.textStyle('bodyMedium').copyWith(
          color: DesignTokens.color('textPrimary'),
        ),
        actionTextColor: DesignTokens.color('primary'),
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.radius('md'),
          side: BorderSide(
            color: DesignTokens.color('border'),
            width: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // 📱 Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: DesignTokens.color('surface'),
        surfaceTintColor: DesignTokens.color('surface'),
        modalBackgroundColor: DesignTokens.color('surface'),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: DesignTokens.radius('lg').topLeft,
            topRight: DesignTokens.radius('lg').topRight,
          ),
        ),
      ),

      // ⚙️ Icon Theme
      iconTheme: IconThemeData(
        color: DesignTokens.color('textSecondary'),
        size: 24,
      ),
      primaryIconTheme: IconThemeData(
        color: DesignTokens.color('primary'),
        size: 24,
      ),

      // 🎨 Material Theme
      splashColor: DesignTokens.color('primary').withOpacity(0.1),
      highlightColor: DesignTokens.color('primary').withOpacity(0.05),
      hoverColor: DesignTokens.color('primary').withOpacity(0.05),
      focusColor: DesignTokens.color('primary').withOpacity(0.1),
      
      // Animation Durations
      extensions: [
        MotionTokens(),
      ],
    );
  }

  /// 🌙 DARK THEME - Dark mode implementation
  static ThemeData darkTheme() {
    // Dark theme implementation with design tokens
    return lightTheme().copyWith(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: DesignTokens.color('primary'),
        onPrimary: DesignTokens.color('onPrimary'),
        primaryContainer: DesignTokens.color('primary').withOpacity(0.2),
        onPrimaryContainer: DesignTokens.color('primary'),
        
        secondary: DesignTokens.color('secondary'),
        onSecondary: DesignTokens.color('onSecondary'),
        secondaryContainer: DesignTokens.color('secondary').withOpacity(0.2),
        onSecondaryContainer: DesignTokens.color('secondary'),
        
        surface: const Color(0xFF121212),
        onSurface: const Color(0xFFE0E0E0),
        surfaceContainerHighest: const Color(0xFF1E1E1E),
        onSurfaceVariant: const Color(0xFFBDBDBD),
        
        error: DesignTokens.color('error'),
        onError: DesignTokens.color('onError'),
        errorContainer: DesignTokens.color('error').withOpacity(0.2),
        
        tertiary: DesignTokens.color('income'),
        onTertiary: DesignTokens.color('onSuccess'),
        
        outline: const Color(0xFF3E3E3E),
        outlineVariant: const Color(0xFF4E4E4E),
        scrim: DesignTokens.color('scrim'),
      ),
      
      // Override specific themes for dark mode
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: const Color(0xFFE0E0E0),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}

/// 🎬 Motion Tokens Extension
/// Provides access to animation tokens through theme extensions
class MotionTokens extends ThemeExtension<MotionTokens> {
  final Duration fast = DesignTokens.duration('fast');
  final Duration normal = DesignTokens.duration('normal');
  final Duration slow = DesignTokens.duration('slow');
  final Curve easeInOut = DesignTokens.curve('easeInOut');
  final Curve fastOutSlowIn = DesignTokens.curve('fastOutSlowIn');

  @override
  MotionTokens copyWith() => MotionTokens();

  @override
  MotionTokens lerp(ThemeExtension<MotionTokens>? other, double t) => MotionTokens();
}

/// 🎨 Financial Theme Extension  
/// Specialized theme extension for financial UI components
class FinancialTheme extends ThemeExtension<FinancialTheme> {
  const FinancialTheme({
    required this.incomeColor,
    required this.expenseColor,
    required this.neutralColor,
    required this.incomeBackground,
    required this.expenseBackground,
    required this.neutralBackground,
    required this.amountTextStyle,
  });

  final Color incomeColor;
  final Color expenseColor;
  final Color neutralColor;
  final Color incomeBackground;
  final Color expenseBackground;
  final Color neutralBackground;
  final TextStyle amountTextStyle;

  static FinancialTheme light() {
    return FinancialTheme(
      incomeColor: DesignTokens.color('income'),
      expenseColor: DesignTokens.color('expense'),
      neutralColor: DesignTokens.color('neutral'),
      incomeBackground: DesignTokens.color('incomeLight'),
      expenseBackground: DesignTokens.color('expenseLight'),
      neutralBackground: DesignTokens.color('neutralLight'),
      amountTextStyle: DesignTokens.textStyle('amountMedium'),
    );
  }

  static FinancialTheme dark() {
    return FinancialTheme(
      incomeColor: DesignTokens.color('income'),
      expenseColor: DesignTokens.color('expense'),
      neutralColor: DesignTokens.color('neutral'),
      incomeBackground: DesignTokens.color('income').withOpacity(0.1),
      expenseBackground: DesignTokens.color('expense').withOpacity(0.1),
      neutralBackground: DesignTokens.color('neutral').withOpacity(0.1),
      amountTextStyle: DesignTokens.textStyle('amountMedium').copyWith(
        color: const Color(0xFFE0E0E0),
      ),
    );
  }

  @override
  FinancialTheme copyWith({
    Color? incomeColor,
    Color? expenseColor,
    Color? neutralColor,
    Color? incomeBackground,
    Color? expenseBackground,
    Color? neutralBackground,
    TextStyle? amountTextStyle,
  }) {
    return FinancialTheme(
      incomeColor: incomeColor ?? this.incomeColor,
      expenseColor: expenseColor ?? this.expenseColor,
      neutralColor: neutralColor ?? this.neutralColor,
      incomeBackground: incomeBackground ?? this.incomeBackground,
      expenseBackground: expenseBackground ?? this.expenseBackground,
      neutralBackground: neutralBackground ?? this.neutralBackground,
      amountTextStyle: amountTextStyle ?? this.amountTextStyle,
    );
  }

  @override
  FinancialTheme lerp(ThemeExtension<FinancialTheme>? other, double t) {
    if (other is! FinancialTheme) return this;
    
    return FinancialTheme(
      incomeColor: Color.lerp(incomeColor, other.incomeColor, t)!,
      expenseColor: Color.lerp(expenseColor, other.expenseColor, t)!,
      neutralColor: Color.lerp(neutralColor, other.neutralColor, t)!,
      incomeBackground: Color.lerp(incomeBackground, other.incomeBackground, t)!,
      expenseBackground: Color.lerp(expenseBackground, other.expenseBackground, t)!,
      neutralBackground: Color.lerp(neutralBackground, other.neutralBackground, t)!,
      amountTextStyle: TextStyle.lerp(amountTextStyle, other.amountTextStyle, t)!,
    );
  }
}

/// 🔧 Theme Utility Extensions
/// Convenient extensions for accessing theme tokens in widgets
extension ThemeTokens on ThemeData {
  // Financial theme accessor
  FinancialTheme get financial => extension<FinancialTheme>()!;
  
  // Motion tokens accessor  
  MotionTokens get motion => extension<MotionTokens>()!;
  
  // Quick color accessors
  Color get incomeColor => financial.incomeColor;
  Color get expenseColor => financial.expenseColor;
  Color get neutralColor => financial.neutralColor;
}

extension BuildContextTheme on BuildContext {
  // Quick theme access
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  FinancialTheme get financial => Theme.of(this).financial;
  MotionTokens get motion => Theme.of(this).motion;
}