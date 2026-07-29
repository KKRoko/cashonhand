import 'package:flutter/material.dart';
import 'settings_controller.dart';
import '../theme/design_tokens.dart';
import '../ui/components/cash_components.dart';
import '../ui/settings/round_up_settings_screen.dart';
import '../ui/allocation_rules/allocation_rules_screen.dart';
import '../ui/widgets/currency_selector.dart';
import '../services/currency_service.dart';
import '../core/di/injection.dart';
import '../ui/onboarding/goal_integration_onboarding.dart';
import '../paywall/subscription_service.dart';
import '../paywall/models/subscription_plan.dart';
import '../paywall/paywall_screen.dart';
import '../paywall/manage_subscription_screen.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.controller,
  });

  static const routeName = '/settings';
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    Future<void> showResetConfirmation() async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Reset All Data?',
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            content: Text(
              'This action will permanently delete all your data including transactions, '
              'categories, and savings goals. This cannot be undone. Are you sure you '
              'want to proceed?',
              style: Theme.of(context).textTheme.bodyMedium!,
            ),
            actions: [
              SecondaryButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              HSpace('sm'),
              FinancialButton(
                onPressed: () async {
                  // Close confirmation dialog first
                  Navigator.of(context).pop();

                  // Capture navigator and messenger before showing new dialog
                  final navigator = Navigator.of(context, rootNavigator: true);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // Show a new, non-dismissible loading dialog immediately
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Padding(
                          padding: EdgeInsets.all(DesignTokens.space('lg')),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              HSpace('md'),
                              Text(
                                'Resetting data...',
                                style: Theme.of(context).textTheme.bodyMedium!,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  // Give the UI a frame to draw the dialog
                  await Future.delayed(const Duration(milliseconds: 50));

                  try {
                    print('🔄 RESET: Starting reset operation...');

                    // Now the UI is showing a loader while this heavy task runs
                    await controller.resetAllData();

                    print(
                        '✅ RESET: Reset complete, waiting before navigation...');

                    // CRITICAL: For hot restarts (VSCode), SharedPreferences singleton persists
                    // We need to wait even longer and force a complete reload
                    await Future.delayed(const Duration(milliseconds: 800));

                    print(
                        '✅ RESET: Closing dialog and preparing navigation...');

                    // Close the loading dialog first
                    navigator.pop();

                    // Wait to ensure dialog is fully closed
                    await Future.delayed(const Duration(milliseconds: 100));

                    // Force onboarding to show even if SharedPreferences is cached (hot restart)
                    // This static flag persists across hot restarts and bypasses SharedPreferences
                    GoalIntegrationOnboarding.forceShowOnboarding();
                    print('✅ RESET: Force flag set, triggering navigation...');

                    // Navigate to home, which will create a fresh MainNavigationScreen
                    // The force flag will ensure onboarding shows even with cached SharedPreferences
                    navigator.pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );

                    // Show success message after a brief delay
                    await Future.delayed(const Duration(milliseconds: 500));
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('All data has been reset successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e, stackTrace) {
                    print('❌ RESET: Error during reset: $e');
                    print('❌ RESET: Stack trace: $stackTrace');

                    // If an error happens, close the loading dialog
                    navigator.pop(); // This closes the loading dialog

                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error resetting data: $e'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                financialType: FinancialButtonType.expense,
                child: const Text('Reset'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(DesignTokens.space('lg')),
        children: [
          CashCard(
            child: ListTile(
              title: Text(
                'Theme',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DesignTokens.color('onPrimary')
                          : null,
                    ),
              ),
              trailing: DropdownButton<ThemeMode>(
                value: controller.themeMode,
                onChanged: controller.updateThemeMode,
                dropdownColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : null,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text(
                      'System Theme',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? DesignTokens.color('onPrimary')
                                    : null,
                          ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(
                      'Light Theme',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? DesignTokens.color('onPrimary')
                                    : null,
                          ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(
                      'Dark Theme',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? DesignTokens.color('onPrimary')
                                    : null,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          VSpace('lg'),
          CashCard(
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.space('md')),
              child: ListenableBuilder(
                listenable: getIt<CurrencyService>(),
                builder: (context, _) {
                  final currencyService = getIt<CurrencyService>();
                  return CurrencySelector(
                    selectedCurrency: currencyService.selectedCurrency,
                    onCurrencySelected: (currency) async {
                      await currencyService.updateCurrency(currency);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Currency updated to ${currency.name}'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
          VSpace('lg'),
          ListenableBuilder(
            listenable: SubscriptionService.instance,
            builder: (context, _) {
              final subscription = SubscriptionService.instance;
              return CashCard(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    subscription.isPremium
                        ? ManageSubscriptionScreen.routeName
                        : PaywallScreen.routeName,
                  );
                },
                child: ListTile(
                  leading: Icon(
                    Icons.workspace_premium,
                    color: DesignTokens.color('primary'),
                  ),
                  title: Text(
                    'Cash on Hand Premium',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? DesignTokens.color('onPrimary')
                              : null,
                        ),
                  ),
                  subtitle: Text(
                    subscription.isPremium
                        ? '${subscription.activeProductId == SubscriptionPlan.monthlyProductId ? SubscriptionPlan.monthly.displayName : SubscriptionPlan.annual.displayName} — manage your subscription'
                        : 'Unlock unlimited budgets, savings challenges & advanced insights',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? DesignTokens.color('onPrimary')
                              : DesignTokens.color('textSecondary'),
                        ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: DesignTokens.color('textSecondary'),
                  ),
                ),
              );
            },
          ),
          VSpace('lg'),
          CashCard(
            onTap: () {
              Navigator.of(context).pushNamed(RoundUpSettingsScreen.routeName);
            },
            child: ListTile(
              leading: Icon(
                Icons.auto_awesome,
                color: DesignTokens.color('info'),
              ),
              title: Text(
                'Round-Up Savings',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DesignTokens.color('onPrimary')
                          : null,
                    ),
              ),
              subtitle: Text(
                'Automatically round up purchases and save the difference',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DesignTokens.color('onPrimary')
                          : DesignTokens.color('textSecondary'),
                    ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: DesignTokens.color('textSecondary'),
              ),
            ),
          ),
          VSpace('lg'),
          CashCard(
            onTap: () {
              Navigator.of(context).pushNamed(AllocationRulesScreen.routeName);
            },
            child: ListTile(
              leading: Icon(
                Icons.rule,
                color: DesignTokens.color('secondary'),
              ),
              title: Text(
                'Auto-Allocation Rules',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DesignTokens.color('onPrimary')
                          : null,
                    ),
              ),
              subtitle: Text(
                'Create rules to automatically allocate money to goals',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DesignTokens.color('onPrimary')
                          : DesignTokens.color('textSecondary'),
                    ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: DesignTokens.color('textSecondary'),
              ),
            ),
          ),
          VSpace('lg'),
          CashCard(
            financialContext: FinancialContext.expense,
            onTap: showResetConfirmation,
            child: ListTile(
              title: Text(
                'Reset All Data',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DesignTokens.color('onPrimary')
                          : null,
                    ),
              ),
              subtitle: Text(
                'Delete all transactions, categories, and savings goals',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? DesignTokens.color('onPrimary')
                          : DesignTokens.color('textSecondary'),
                    ),
              ),
              trailing: Icon(
                Icons.warning,
                color: DesignTokens.color('error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
