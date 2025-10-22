import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class BudgetScreen extends StatefulWidget {
  static const routeName = '/budget';
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: DesignTokens.color('surface'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 80,
              color: DesignTokens.color('textSecondary'),
            ),
            const SizedBox(height: 24),
            Text(
              'Budget',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: DesignTokens.color('textPrimary'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon...',
              style: TextStyle(
                fontSize: 16,
                color: DesignTokens.color('textSecondary'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
