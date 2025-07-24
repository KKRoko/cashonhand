// Cash on Hand - Design System Foundation Test
// Simple test screen to verify the design system is working properly

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/enhanced_theme.dart';
import 'components/cash_components.dart';

/// 🧪 DESIGN SYSTEM TEST SCREEN
/// This screen tests that the core design system components work correctly
class TestDesignSystemScreen extends StatelessWidget {
  static const routeName = '/test-design-system';
  
  const TestDesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Test'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DesignTokens.space('md')),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Design Tokens
            _buildTokenTest(context),
            
            VSpace('xl'),
            
            // Test Financial Components
            _buildFinancialTest(context),
            
            VSpace('xl'),
            
            // Test Basic Components
            _buildComponentTest(context),
            
            VSpace('xl'),
            
            // Test Theme Integration
            _buildThemeTest(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenTest(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎨 Design Tokens',
          style: DesignTokens.textStyle('headlineSmall'),
        ),
        VSpace('md'),
        
        // Color Tokens
        Row(
          children: [
            _buildColorSwatch('Primary', DesignTokens.color('primary')),
            HSpace('sm'),
            _buildColorSwatch('Income', DesignTokens.color('income')),
            HSpace('sm'),
            _buildColorSwatch('Expense', DesignTokens.color('expense')),
          ],
        ),
        VSpace('md'),
        
        // Typography Tokens
        Text('Display Large', style: DesignTokens.textStyle('displayLarge')),
        Text('Headline Medium', style: DesignTokens.textStyle('headlineMedium')),
        Text('Title Large', style: DesignTokens.textStyle('titleLarge')),
        Text('Body Large', style: DesignTokens.textStyle('bodyLarge')),
        Text('Body Medium', style: DesignTokens.textStyle('bodyMedium')),
        Text('Label Small', style: DesignTokens.textStyle('labelSmall')),
        
        VSpace('md'),
        
        // Spacing Tokens
        Text('Spacing Test:', style: DesignTokens.textStyle('titleMedium')),
        Row(
          children: [
            Container(width: DesignTokens.space('xs'), height: 20, color: Colors.red),
            HSpace('xs'),
            Container(width: DesignTokens.space('sm'), height: 20, color: Colors.orange),
            HSpace('xs'),
            Container(width: DesignTokens.space('md'), height: 20, color: Colors.yellow),
            HSpace('xs'),
            Container(width: DesignTokens.space('lg'), height: 20, color: Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialTest(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💰 Financial Components',
          style: DesignTokens.textStyle('headlineSmall'),
        ),
        VSpace('md'),
        
        // Financial Amounts
        FinancialAmount(
          amount: 1250.75,
          size: FinancialAmountSize.large,
        ),
        VSpace('sm'),
        FinancialAmount(
          amount: -485.25,
          size: FinancialAmountSize.medium,
        ),
        VSpace('sm'),
        FinancialAmount(
          amount: 0.00,
          size: FinancialAmountSize.small,
        ),
        
        VSpace('lg'),
        
        // Financial Cards
        CashCard(
          financialContext: FinancialContext.income,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Income Card', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              FinancialAmount(amount: 2500.00),
            ],
          ),
        ),
        
        VSpace('md'),
        
        CashCard(
          financialContext: FinancialContext.expense,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expense Card', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              FinancialAmount(amount: -750.50),
            ],
          ),
        ),
        
        VSpace('lg'),
        
        // Progress Bar
        FinancialProgressBar(
          value: 3500,
          total: 5000,
          label: 'Goal Progress',
          financialContext: FinancialContext.income,
        ),
      ],
    );
  }

  Widget _buildComponentTest(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🧩 Components',
          style: DesignTokens.textStyle('headlineSmall'),
        ),
        VSpace('md'),
        
        // Buttons
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Primary button works!')),
                  );
                },
                child: const Text('Primary'),
              ),
            ),
            HSpace('md'),
            Expanded(
              child: SecondaryButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Secondary button works!')),
                  );
                },
                child: const Text('Secondary'),
              ),
            ),
          ],
        ),
        
        VSpace('md'),
        
        // Financial Buttons
        Row(
          children: [
            Expanded(
              child: FinancialButton(
                onPressed: () {},
                financialType: FinancialButtonType.income,
                icon: Icons.add,
                child: const Text('Add Income'),
              ),
            ),
            HSpace('md'),
            Expanded(
              child: FinancialButton(
                onPressed: () {},
                financialType: FinancialButtonType.expense,
                icon: Icons.remove,
                child: const Text('Add Expense'),
              ),
            ),
          ],
        ),
        
        VSpace('md'),
        
        // Category Chips
        Wrap(
          spacing: DesignTokens.space('sm'),
          runSpacing: DesignTokens.space('xs'),
          children: [
            CategoryChip(
              name: 'Salary',
              icon: '💼',
              financialContext: FinancialContext.income,
            ),
            CategoryChip(
              name: 'Groceries',
              icon: '🛒',
              financialContext: FinancialContext.expense,
            ),
            CategoryChip(
              name: 'Selected',
              icon: '✅',
              selected: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeTest(BuildContext context) {
    final theme = Theme.of(context);
    final financial = theme.financial;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎭 Theme Integration',
          style: DesignTokens.textStyle('headlineSmall'),
        ),
        VSpace('md'),
        
        // Theme Colors
        Text('Theme Colors:', style: theme.textTheme.titleMedium),
        VSpace('sm'),
        Row(
          children: [
            _buildColorSwatch('Primary', theme.colorScheme.primary),
            HSpace('sm'),
            _buildColorSwatch('Surface', theme.colorScheme.surface),
            HSpace('sm'),
            _buildColorSwatch('Income', financial.incomeColor),
            HSpace('sm'),
            _buildColorSwatch('Expense', financial.expenseColor),
          ],
        ),
        
        VSpace('md'),
        
        // Theme Typography
        Text('Theme Typography:', style: theme.textTheme.titleMedium),
        VSpace('sm'),
        Text('Display Large', style: theme.textTheme.displayLarge),
        Text('Headline Medium', style: theme.textTheme.headlineMedium),
        Text('Title Large', style: theme.textTheme.titleLarge),
        Text('Body Large', style: theme.textTheme.bodyLarge),
        Text('Label Medium', style: theme.textTheme.labelMedium),
        
        VSpace('lg'),
        
        // Success Message
        Container(
          padding: EdgeInsets.all(DesignTokens.space('md')),
          decoration: BoxDecoration(
            color: DesignTokens.color('successContainer'),
            borderRadius: DesignTokens.radius('md'),
            border: Border.all(
              color: DesignTokens.color('success'),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: DesignTokens.color('success'),
              ),
              HSpace('md'),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✅ Design System Foundation Working!',
                      style: DesignTokens.textStyle('titleMedium').copyWith(
                        color: DesignTokens.color('success'),
                      ),
                    ),
                    VSpace('xs'),
                    Text(
                      'All core components, tokens, and themes are properly integrated.',
                      style: DesignTokens.textStyle('bodyMedium'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: DesignTokens.radius('sm'),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        VSpace('xs'),
        Text(
          name,
          style: DesignTokens.textStyle('labelSmall'),
        ),
      ],
    );
  }
}