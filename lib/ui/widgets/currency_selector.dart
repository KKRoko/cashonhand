import 'package:flutter/material.dart';
import '../../data/models/enums/currency.dart';
import '../../theme/design_tokens.dart';
import '../components/cash_components.dart';

class CurrencySelector extends StatelessWidget {
  final Currency selectedCurrency;
  final Function(Currency) onCurrencySelected;
  final String? title;
  final String? subtitle;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          ResponsiveText(
            title!,
            styleToken: 'titleMedium',
            style: DesignTokens.textStyle('titleMedium').copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : DesignTokens.color('textPrimary'),
              fontWeight: FontWeight.w600,
            ),
          ),
          VSpace('xs'),
        ],
        if (subtitle != null) ...[
          ResponsiveText(
            subtitle!,
            styleToken: 'bodyMedium',
            style: DesignTokens.textStyle('bodyMedium').copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : DesignTokens.color('textSecondary'),
            ),
          ),
          VSpace('md'),
        ],

        // Current selection display
        CashCard(
          onTap: () => _showCurrencyPicker(context),
          child: Padding(
            padding: EdgeInsets.all(DesignTokens.space('md')),
            child: Row(
              children: [
                // Currency symbol and info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ResponsiveText(
                            selectedCurrency.symbol,
                            styleToken: 'titleLarge',
                            style: DesignTokens.textStyle('titleLarge').copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : DesignTokens.color('primaryDark'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          HSpace('sm'),
                          ResponsiveText(
                            selectedCurrency.code,
                            styleToken: 'titleMedium',
                            style: DesignTokens.textStyle('titleMedium').copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : DesignTokens.color('textSecondary'),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      VSpace('xs'),
                      ResponsiveText(
                        selectedCurrency.name,
                        styleToken: 'bodyMedium',
                        style: DesignTokens.textStyle('bodyMedium').copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : DesignTokens.color('textSecondary'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron indicator
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : DesignTokens.color('textSecondary'),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(DesignTokens.space('lg')),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : null,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            ResponsiveText(
              'Select Currency',
              styleToken: 'titleLarge',
              style: DesignTokens.textStyle('titleLarge').copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : DesignTokens.color('textPrimary'),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            VSpace('lg'),

            // Currency list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Currency.values.length,
                itemBuilder: (context, index) {
                  final currency = Currency.values[index];
                  final isSelected = currency == selectedCurrency;

                  return ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? DesignTokens.color('income')
                            : Colors.white,
                        border: isSelected
                            ? null
                            : Border.all(
                                color: DesignTokens.color('incomeLight'),
                                width: 2,
                              ),
                      ),
                      width: 40,
                      height: 40,
                      child: Center(
                        child: ResponsiveText(
                          currency.symbol,
                          styleToken: 'titleMedium',
                          style: DesignTokens.textStyle('titleMedium').copyWith(
                            color: isSelected
                                ? Colors.white
                                : DesignTokens.color('income'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: ResponsiveText(
                      currency.name,
                      styleToken: 'bodyLarge',
                      style: DesignTokens.textStyle('bodyLarge').copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : DesignTokens.color('textPrimary'),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: ResponsiveText(
                      '${currency.symbol} (${currency.code})',
                      styleToken: 'bodyMedium',
                      style: DesignTokens.textStyle('bodyMedium').copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : DesignTokens.color('textSecondary'),
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: DesignTokens.color('income'),
                          )
                        : null,
                    onTap: () {
                      onCurrencySelected(currency);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),

            VSpace('lg'),
            SecondaryButton(
              onPressed: () => Navigator.pop(context),
              child: ResponsiveText(
                'Cancel',
                styleToken: 'labelLarge',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
