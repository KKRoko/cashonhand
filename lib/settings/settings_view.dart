import 'package:flutter/material.dart';
import 'settings_controller.dart';
import '../theme/design_tokens.dart';
import '../ui/components/cash_components.dart';
import '../ui/settings/round_up_settings_screen.dart';
import '../ui/allocation_rules/allocation_rules_screen.dart';
import '../ui/widgets/currency_selector.dart';
import '../services/currency_service.dart';
import '../core/di/injection.dart';

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
              style: DesignTokens.textStyle('titleLarge'),
            ),
            content: Text(
              'This action will permanently delete all your data including transactions, '
              'categories, and savings goals. This cannot be undone. Are you sure you '
              'want to proceed?',
              style: DesignTokens.textStyle('bodyMedium'),
            ),
            actions: [
              SecondaryButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              HSpace('sm'),
              FinancialButton(
                onPressed: () async {
                  // Capture the navigator and scaffold messenger before popping dialog
                  final navigator = Navigator.of(context, rootNavigator: true);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // Close dialog
                  Navigator.of(context).pop();

                  try {
                    await controller.resetAllData();

                    // Navigate to home using the captured navigator
                    navigator.pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );

                    // Show success message
                    await Future.delayed(const Duration(milliseconds: 100));
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('All data has been reset successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error resetting data: $e'),
                        backgroundColor: Colors.red,
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
                style: DesignTokens.textStyle('titleMedium').copyWith(
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
                      style: DesignTokens.textStyle('bodyMedium').copyWith(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? DesignTokens.color('onPrimary') 
                          : null,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text(
                      'Light Theme',
                      style: DesignTokens.textStyle('bodyMedium').copyWith(
                        color: Theme.of(context).brightness == Brightness.dark 
                          ? DesignTokens.color('onPrimary') 
                          : null,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text(
                      'Dark Theme',
                      style: DesignTokens.textStyle('bodyMedium').copyWith(
                        color: Theme.of(context).brightness == Brightness.dark 
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
                            content: Text('Currency updated to ${currency.name}'),
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
                style: DesignTokens.textStyle('titleMedium').copyWith(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? DesignTokens.color('onPrimary') 
                    : null,
                ),
              ),
              subtitle: Text(
                'Automatically round up purchases and save the difference',
                style: DesignTokens.textStyle('bodySmall').copyWith(
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
                style: DesignTokens.textStyle('titleMedium').copyWith(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? DesignTokens.color('onPrimary') 
                    : null,
                ),
              ),
              subtitle: Text(
                'Create rules to automatically allocate money to goals',
                style: DesignTokens.textStyle('bodySmall').copyWith(
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
                style: DesignTokens.textStyle('titleMedium'),
              ),
              subtitle: Text(
                'Delete all transactions, categories, and savings goals',
                style: DesignTokens.textStyle('bodySmall').copyWith(
                  color: DesignTokens.color('textSecondary'),
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