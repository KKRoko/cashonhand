import 'package:flutter/material.dart';
import '../../../data/models/freezed/saving_goal.dart';
import '../../../utils/formatters.dart';
import '../../../theme/design_tokens.dart';
import '../../components/cash_components.dart';

class GoalListItem extends StatelessWidget {
  final SavingGoal goal;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback? onViewDetails;

  const GoalListItem({
    super.key,
    required this.goal,
    required this.isExpanded,
    required this.onTap,
    required this.onEdit,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.currentAmount / goal.targetAmount;
    final remainingAmount = goal.targetAmount - goal.currentAmount;
    final monthsLeft = goal.deadlineDate!.difference(DateTime.now()).inDays / 30;
    final requiredMonthly = remainingAmount / monthsLeft;

    return AnimatedContainer(
      duration: DesignTokens.duration('normal'),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.radius('md'),
        boxShadow: isExpanded
            ? DesignTokens.shadow('lg')
            : DesignTokens.shadow('sm'),
      ),
      child: Material(
        color: Colors.transparent,
        child: Semantics(
          label: 'Saving goal: ${goal.title}',
          hint: 'Progress: ${(progress * 100).toInt()}% complete. Current amount: ${FormatUtils.formatCurrency(goal.currentAmount)} of ${FormatUtils.formatCurrency(goal.targetAmount)}',
          button: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: DesignTokens.radius('md'),
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.space('lg')),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: DesignTokens.textStyle('titleMedium'),
                            ),
                            Text(
                              'Target: ${FormatUtils.formatCurrency(goal.targetAmount)}',
                              style: DesignTokens.textStyle('bodySmall').copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: onEdit,
                      ),
                      AnimatedRotation(
                        duration: DesignTokens.duration('normal'),
                        turns: isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                  ),
                  VSpace('sm'),
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FinancialProgressBar(
                      value: goal.currentAmount,
                      total: goal.targetAmount,
                      label: 'Progress',
                      financialContext: _getFinancialContext(progress),
                      height: 8,
                    ),
                  ],
                  ),
                  if (isExpanded) ...[
                  VSpace('lg'),
                  _buildDetailRow(
                    context,
                    'Remaining',
                    FormatUtils.formatCurrency(remainingAmount),
                  ),
                  VSpace('sm'),
                  _buildDetailRow(
                    context,
                    'Required Monthly Savings',
                    FormatUtils.formatCurrency(requiredMonthly),
                  ),
                  VSpace('sm'),
                  _buildDetailRow(
                    context,
                    'Deadline Date',
                    goal.deadlineDate != null 
                        ? FormatUtils.formatDate(goal.deadlineDate!)
                        : 'No deadline set',
                  ),
                  VSpace('sm'),
                  _buildDetailRow(
                    context,
                    'Months Left',
                    '${monthsLeft.round()} months',
                  ),
                    if (onViewDetails != null) ...[
                      VSpace('lg'),
                      SecondaryButton(
                        onPressed: onViewDetails!,
                        icon: Icons.visibility,
                        fullWidth: true,
                        child: const Text('View Details & History'),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: DesignTokens.textStyle('bodyMedium'),
        ),
        Text(
          value,
          style: DesignTokens.textStyle('bodyMedium').copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  FinancialContext _getFinancialContext(double progress) {
    // Always use income context (green) for goal progress
    return FinancialContext.income;
  }
}
