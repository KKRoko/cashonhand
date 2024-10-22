// lib/ui/cash_on_hand/widgets/cash_on_hand_tile.dart

import 'package:flutter/material.dart';
import '../../../utils/formatters.dart';


class CashOnHandTile extends StatelessWidget {
  final String title;
  final Map<String, double> amounts;
  final DateTime date;

  const CashOnHandTile({
    super.key,
    required this.title,
    required this.amounts,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final positiveAmount = amounts['positive'] ?? 0;
    final negativeAmount = amounts['negative'] ?? 0;
    final totalAmount = positiveAmount - negativeAmount;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(formatDate(date), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            _buildAmountRow('Total Positive Cashflow', positiveAmount, Colors.green),
            _buildAmountRow('Total Negative Cashflow', negativeAmount, Colors.red),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cash on hand', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  formatCurrency(totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: totalAmount >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          formatCurrency(amount),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
