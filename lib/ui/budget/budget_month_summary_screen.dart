import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../data/models/freezed/budget.dart';
import '../../state/budget_notifier.dart';
import '../../theme/design_tokens.dart';
import 'surplus_allocation_screen.dart';

class BudgetMonthSummaryScreen extends StatelessWidget {
  final BudgetNotifier budgetNotifier;
  final DateTime month;

  const BudgetMonthSummaryScreen({
    super.key,
    required this.budgetNotifier,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final budget = budgetNotifier.activeBudget;
    if (budget == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Month Summary'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: const Center(child: Text('No budget data available')),
      );
    }

    final monthName = DateFormat('MMMM yyyy').format(month);
    final totalBudget = budget.needsAmount + budget.wantsAmount + budget.savingsAmount;
    final totalSpent = budgetNotifier.actualSpending.values.fold<double>(0.0, (sum, v) => sum + v);
    final totalSurplus = budgetNotifier.totalSurplus;
    final allocatedSurplus = budgetNotifier.allocatedSurplus;
    final availableSurplus = budgetNotifier.availableSurplus;
    final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$monthName Summary'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context, budget, totalBudget, totalSpent, spentPercentage),
            const SizedBox(height: 24),

            if (totalSurplus > 0) ...[
              _buildSurplusSection(context, totalSurplus, allocatedSurplus, availableSurplus),
              const SizedBox(height: 24),
            ],

            _buildBucketBreakdown(context, budget),
            const SizedBox(height: 24),

            if (availableSurplus > 0)
              _buildAllocateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Budget budget, double totalBudget, double totalSpent, double spentPercentage) {
    final isUnderBudget = totalSpent <= totalBudget;
    final difference = totalBudget - totalSpent;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnderBudget
              ? [
                  DesignTokens.color('success').withOpacity(0.1),
                  DesignTokens.color('success').withOpacity(0.05),
                ]
              : [
                  DesignTokens.color('error').withOpacity(0.1),
                  DesignTokens.color('error').withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnderBudget
              ? DesignTokens.color('success').withOpacity(0.3)
              : DesignTokens.color('error').withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isUnderBudget ? Icons.check_circle_outline : Icons.warning_outlined,
            size: 48,
            color: isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
          ),
          const SizedBox(height: 16),
          Text(
            isUnderBudget ? 'Under Budget!' : 'Over Budget',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isUnderBudget
                ? 'You stayed \$${difference.abs().toStringAsFixed(2)} under budget'
                : 'You went \$${difference.abs().toStringAsFixed(2)} over budget',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                context,
                'Budgeted',
                totalBudget,
                isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
                isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
              ),
              Container(
                width: 1,
                height: 40,
                color: isUnderBudget
                    ? DesignTokens.color('success').withOpacity(0.3)
                    : DesignTokens.color('error').withOpacity(0.3),
              ),
              _buildStatColumn(
                context,
                'Spent',
                totalSpent,
                isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
                isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
              ),
              Container(
                width: 1,
                height: 40,
                color: isUnderBudget
                    ? DesignTokens.color('success').withOpacity(0.3)
                    : DesignTokens.color('error').withOpacity(0.3),
              ),
              _buildStatColumn(
                context,
                isUnderBudget ? 'Saved' : 'Over',
                difference.abs(),
                isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
                isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: spentPercentage / 100,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${spentPercentage.toStringAsFixed(1)}% of budget used',
            style: TextStyle(
              fontSize: 12,
              color: isUnderBudget ? DesignTokens.color('success') : DesignTokens.color('error'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, double amount, Color labelColor, Color amountColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSurplusSection(
    BuildContext context,
    double totalSurplus,
    double allocatedSurplus,
    double availableSurplus,
  ) {
    final hasAllocated = allocatedSurplus > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DesignTokens.color('success').withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DesignTokens.color('success').withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DesignTokens.color('success').withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.savings_outlined,
                  color: DesignTokens.color('success'),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unspent Budget',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasAllocated
                          ? 'Some surplus already allocated to goals'
                          : 'Allocate to your savings goals',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${totalSurplus.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.color('success'),
                ),
              ),
            ],
          ),

          // Show allocation breakdown if some surplus is already allocated
          if (hasAllocated) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Already Allocated:',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '-\$${allocatedSurplus.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available to Allocate:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '\$${availableSurplus.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          _buildSurplusBreakdown(context),
        ],
      ),
    );
  }

  Widget _buildSurplusBreakdown(BuildContext context) {
    final bucketSurplus = budgetNotifier.bucketSurplus;
    if (bucketSurplus.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Breakdown by Bucket:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...bucketSurplus.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getBucketColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getBucketLabel(entry.key),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.color('success'),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBucketBreakdown(BuildContext context, Budget budget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bucket Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildBucketCard(context, BucketType.needs, budget.needsAmount),
        const SizedBox(height: 12),
        _buildBucketCard(context, BucketType.wants, budget.wantsAmount),
        const SizedBox(height: 12),
        _buildBucketCard(context, BucketType.savings, budget.savingsAmount),
      ],
    );
  }

  Widget _buildBucketCard(BuildContext context, BucketType bucket, double budgeted) {
    final spent = budgetNotifier.actualSpending[bucket] ?? 0.0;
    final remaining = budgeted - spent;
    final percentage = budgeted > 0 ? (spent / budgeted) * 100 : 0;
    final isOverspent = spent > budgeted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: isOverspent
            ? Border.all(color: DesignTokens.color('error').withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getBucketColor(bucket),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getBucketLabel(bucket),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              if (isOverspent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DesignTokens.color('error').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'OVER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.color('error'),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budgeted',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${budgeted.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${spent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isOverspent ? 'Over' : 'Remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${remaining.abs().toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isOverspent
                          ? DesignTokens.color('error')
                          : DesignTokens.color('success'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverspent ? DesignTokens.color('error') : _getBucketColor(bucket),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${percentage.toStringAsFixed(1)}% used',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToSurplusAllocation(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.color('success'),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.savings_outlined),
            const SizedBox(width: 8),
            Text(
              'Allocate Surplus to Goals',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToSurplusAllocation(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurplusAllocationScreen(budgetNotifier: budgetNotifier),
      ),
    );

    if (result == true) {
      // Reload budget data
      budgetNotifier.loadActiveBudget();
    }
  }

  String _getBucketLabel(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return 'Needs';
      case BucketType.wants:
        return 'Wants';
      case BucketType.savings:
        return 'Savings';
    }
  }

  Color _getBucketColor(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return DesignTokens.color('success'); // Green - keep as semantic color
      case BucketType.wants:
        return DesignTokens.color('info');
      case BucketType.savings:
        return DesignTokens.color('warning');
    }
  }
}
