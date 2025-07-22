import 'package:flutter/material.dart';
import '../../../data/models/freezed/saving_goal.dart';
import '../../../utils/formatters.dart';

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
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: _getProgressColor(progress),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isExpanded ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Target: ${FormatUtils.formatCurrency(goal.targetAmount)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEdit,
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress (${(progress * 100).toInt()}%)'),
                        Text(FormatUtils.formatCurrency(goal.currentAmount)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(progress),
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Remaining',
                    FormatUtils.formatCurrency(remainingAmount),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Required Monthly Savings',
                    FormatUtils.formatCurrency(requiredMonthly),
                  ),
                  const SizedBox(height: 8),
                _buildDetailRow(
                  'Deadline Date',
                  goal.deadlineDate != null 
                      ? FormatUtils.formatDate(goal.deadlineDate!)
                      : 'No deadline set',
                ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Months Left',
                    '${monthsLeft.round()} months',
                  ),
                  if (onViewDetails != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onViewDetails,
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details & History'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
