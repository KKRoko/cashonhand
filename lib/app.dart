import 'package:flutter/material.dart';
import 'localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection.dart';
import 'state/category_notifier.dart';
import 'state/event_notifier.dart';
import 'theme/enhanced_theme.dart';
import 'theme/design_tokens.dart';
import 'ui/achievements/achievement_screen.dart';
import 'ui/cash_on_hand/cash_on_hand_screen.dart';
import 'ui/calendar/calendar_screen.dart';
import 'ui/saving_goals/saving_goals_screen.dart'; // Add this
import 'ui/budget/budget_screen.dart';
import 'ui/transactions/transactions_screen.dart';
import 'ui/settings/round_up_settings_screen.dart';
import 'ui/round_up/round_up_history_screen.dart';
import 'ui/allocation_rules/allocation_rules_screen.dart';
import 'ui/suggestions/suggestions_screen.dart';
import 'ui/onboarding/goal_integration_onboarding.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';
import 'core/architecture/architecture_screen.dart';
import 'paywall/paywall_screen.dart';
import 'paywall/manage_subscription_screen.dart';

// Global tab change notifier for IndexedStack navigation
class TabChangeNotifier extends ChangeNotifier {
  int _currentTabIndex = 0;
  int _previousTabIndex = 0;

  int get currentTabIndex => _currentTabIndex;
  int get previousTabIndex => _previousTabIndex;

  void changeTab(int newIndex) {
    if (_currentTabIndex != newIndex) {
      _previousTabIndex = _currentTabIndex;
      _currentTabIndex = newIndex;
      notifyListeners();
    }
  }

  bool get isCalendarVisible => _currentTabIndex == 2;
  bool get wasCalendarVisible => _previousTabIndex == 2;
  bool get didNavigateToCalendar => !wasCalendarVisible && isCalendarVisible;
  bool get didNavigateAwayFromCalendar =>
      wasCalendarVisible && !isCalendarVisible;
}

// Global instance
final TabChangeNotifier globalTabNotifier = TabChangeNotifier();

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<CategoryNotifier>(
            create: (_) => getIt<CategoryNotifier>(),
          ),
          ChangeNotifierProvider<EventNotifier>(
            create: (_) => getIt<EventNotifier>(),
          ),
        ],
        child: ListenableBuilder(
          listenable: settingsController,
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              restorationScopeId: 'app',
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''),
              ],
              onGenerateTitle: (BuildContext context) =>
                  AppLocalizations.of(context)!.appTitle,
              theme: EnhancedTheme.lightTheme().copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
                extensions: [
                  FinancialTheme.light(),
                  MotionTokens(),
                ],
              ),
              darkTheme: EnhancedTheme.darkTheme().copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                  },
                ),
                extensions: [
                  FinancialTheme.dark(),
                  MotionTokens(),
                ],
              ),
              themeMode: settingsController.themeMode,
              home: const MainNavigationScreen(),
              onGenerateRoute: (RouteSettings routeSettings) {
                return MaterialPageRoute<void>(
                  settings: routeSettings,
                  builder: (BuildContext context) {
                    switch (routeSettings.name) {
                      case SettingsView.routeName:
                        return SettingsView(controller: settingsController);
                      case CalendarScreen.routeName:
                        return const CalendarScreen();
                      case AchievementsScreen.routeName:
                        return const AchievementsScreen();
                      case SavingGoalsScreen.routeName:
                        return const SavingGoalsScreen();
                      case BudgetScreen.routeName:
                        return const BudgetScreen();
                      case TransactionsScreen.routeName:
                        return const TransactionsScreen();
                      case RoundUpSettingsScreen.routeName:
                        return const RoundUpSettingsScreen();
                      case RoundUpHistoryScreen.routeName:
                        return const RoundUpHistoryScreen();
                      case AllocationRulesScreen.routeName:
                        return const AllocationRulesScreen();
                      case SuggestionsScreen.routeName:
                        return const SuggestionsScreen();
                      case ArchitectureScreen.routeName:
                        return const ArchitectureScreen();
                      case PaywallScreen.routeName:
                        return const PaywallScreen();
                      case ManageSubscriptionScreen.routeName:
                        return const ManageSubscriptionScreen();
                      default:
                        return const MainNavigationScreen();
                    }
                  },
                );
              },
            );
          },
        ));
  }
}

class MainNavigationScreen extends StatefulWidget {
  static const routeName = '/';

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Create screens only once to avoid re-initialization on tab changes
  late final List<Widget> _screens = [
    const CashOnHandScreen(),
    const SavingGoalsScreen(),
    const CalendarScreen(),
    const BudgetScreen(),
    const SuggestionsScreen(),
  ];

  List<NavigationDestination> get _destinations => [
        NavigationDestination(
          icon: Icon(
            Icons.account_balance_wallet_outlined,
            color: DesignTokens.color('textSecondary'),
          ),
          selectedIcon: Icon(
            Icons.account_balance_wallet,
            color: DesignTokens.color('primary'),
          ),
          label: 'Cash',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.savings_outlined,
            color: DesignTokens.color('textSecondary'),
          ),
          selectedIcon: Icon(
            Icons.savings,
            color: DesignTokens.color('primary'),
          ),
          label: 'Goals',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.calendar_today_outlined,
            color: DesignTokens.color('textSecondary'),
          ),
          selectedIcon: Icon(
            Icons.calendar_today,
            color: DesignTokens.color('primary'),
          ),
          label: 'Calendar',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.account_balance_outlined,
            color: DesignTokens.color('textSecondary'),
          ),
          selectedIcon: Icon(
            Icons.account_balance,
            color: DesignTokens.color('primary'),
          ),
          label: 'Budget',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.lightbulb_outline,
            color: DesignTokens.color('textSecondary'),
          ),
          selectedIcon: Icon(
            Icons.lightbulb,
            color: DesignTokens.color('primary'),
          ),
          label: 'Insights',
        ),
      ];

  bool?
      _showOnboarding; // null = checking, true = show onboarding, false = show main app

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  void _checkOnboardingStatus() async {
    try {
      print('🎯 MainNavigation: Checking onboarding status...');

      final completed = await _checkOnboardingFlag();

      print(
          '🎯 MainNavigation: Onboarding completed = $completed, will show onboarding = ${!completed}');

      if (mounted) {
        setState(() {
          _showOnboarding =
              !completed; // true if not completed, false if completed
          print(
              '🎯 MainNavigation: setState called, _showOnboarding = $_showOnboarding');
        });
      } else {
        print('❌ MainNavigation: Widget not mounted, cannot setState');
      }
    } catch (e, stackTrace) {
      print('❌ MainNavigation: Error checking onboarding status: $e');
      print('❌ Stack trace: $stackTrace');
      // Default to showing onboarding on error
      if (mounted) {
        setState(() {
          _showOnboarding = true;
        });
      }
    }
  }

  Future<bool> _checkOnboardingFlag() async {
    // Use the GoalIntegrationOnboarding method which checks the force flag
    // This ensures hot restarts work correctly
    final shouldShow = await GoalIntegrationOnboarding.shouldShowOnboarding();
    return !shouldShow; // Return 'completed' status (inverse of shouldShow)
  }

  void _onOnboardingComplete() {
    print('🎯 MainNavigation: _onOnboardingComplete() called!');
    print('🎯 Stack trace: ${StackTrace.current}');
    setState(() {
      _showOnboarding = false;
    });
  }

  void _onItemTapped(int index) {
    // Notify the global tab change notifier
    globalTabNotifier.changeTab(index);

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if this route is still active
    final route = ModalRoute.of(context);
    final bool isActive = route?.isActive ?? false;

    print(
        '🏗️ MainNavigation build: _showOnboarding = $_showOnboarding, isActive = $isActive');

    // If this widget is building, but its route is NOT active,
    // AND it thinks it should show the main app...
    // then it's the OLD widget. Show a loader to prevent the flash.
    if (!isActive && _showOnboarding == false) {
      print(
          '🏗️ MainNavigation: OLD widget, not active, showing loader to prevent flash');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If still checking onboarding status, show loading screen
    if (_showOnboarding == null) {
      print('🏗️ MainNavigation: Showing loading screen');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If onboarding should be shown, show it instead of main navigation
    if (_showOnboarding == true) {
      print('🏗️ MainNavigation: Showing onboarding');
      // Use a unique key to force a fresh widget instance
      return GoalIntegrationOnboarding(
        key: ValueKey('onboarding_${DateTime.now().millisecondsSinceEpoch}'),
        onComplete: _onOnboardingComplete,
      );
    }

    // Otherwise show the main app
    print('🏗️ MainNavigation: Showing main app');
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _destinations,
        elevation: 0,
        height: 65,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : DesignTokens.color('surface'),
        indicatorColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : DesignTokens.color('primaryContainer'),
        surfaceTintColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : DesignTokens.color('primary'),
      ),
    );
  }
}
