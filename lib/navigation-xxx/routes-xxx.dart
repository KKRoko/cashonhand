// lib/navigation-xxx/routes-xxx.dart
//
// Route name constants for the app.
//
// NOTE: The actual route handler switch lives in app.dart (onGenerateRoute).
// This file is the canonical reference for route name strings — import it
// anywhere you need to push a named route.
//
// Bottom nav tabs are managed by MainNavigationScreen's IndexedStack and do
// not use named route navigation.

// ignore_for_file: constant_identifier_names

/// Central registry of all named route strings used in the app.
class AppRoutes {
  AppRoutes._();

  // ---------------------------------------------------------------------------
  // Bottom navigation tabs (IndexedStack — not navigated via named routes)
  // ---------------------------------------------------------------------------

  /// Tab 0 — Cash on Hand dashboard
  static const cashOnHand = '/cashOnHand';

  /// Tab 1 — Saving Goals list
  static const savingGoals = '/savingGoals';

  /// Tab 2 — Calendar
  static const calendar = '/calendar';

  /// Tab 3 — Budget
  static const budget = '/budget';

  /// Tab 4 — Insights / Suggestions
  static const suggestions = '/suggestions';

  // ---------------------------------------------------------------------------
  // Named routes (pushed via Navigator.pushNamed)
  // ---------------------------------------------------------------------------

  /// Full transaction history
  static const transactions = '/transactions';

  /// Achievements list and progress
  static const achievements = '/achievements';

  /// Auto-allocation rules management
  static const allocationRules = '/allocationRules';

  /// Round-up behaviour configuration
  static const roundUpSettings = '/roundUpSettings';

  /// Round-up allocation history
  static const roundUpHistory = '/roundUpHistory';

  /// App settings (theme, preferences)
  static const settings = '/settings';

  // ---------------------------------------------------------------------------
  // Dev-only routes
  // ---------------------------------------------------------------------------

  /// In-app architecture viewer — dev only, not linked from nav
  static const architecture = '/architecture';
}
