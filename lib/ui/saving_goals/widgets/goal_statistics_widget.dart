import 'package:flutter/material.dart';
import '../../../utils/formatters.dart';
import '../../../state/saving_goal_notifier.dart';
import '../../../theme/design_tokens.dart';
import 'package:provider/provider.dart';

class GoalStatisticsWidget extends StatelessWidget {
  const GoalStatisticsWidget({super.key});

  String _formatPercentage(double value) {
    if (value.isNaN || value.isInfinite) return '0%';
    return '${(value * 100).clamp(0, 100).toInt()}%';
  }

  String _formatMonthlyRate(double value) {
    if (value.isNaN || value.isInfinite) return '0% / month';
    return '${(value * 100).clamp(0, 1000).toInt()}% / month';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingGoalNotifier>(
      builder: (context, notifier, child) {
        final totalSaved = notifier.getTotalSaved();
        final averageProgress = notifier.getAverageProgress();
        final monthlyRate = notifier.getMonthlyRate();
        final projectedCompletion = notifier.getProjectedCompletion();
        final historicalRate = notifier.getHistoricalRate();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Saved',
                    FormatUtils.formatCurrency(totalSaved),
                    Icons.savings,
                    totalSaved,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Monthly Rate',
                    FormatUtils.formatCurrency(monthlyRate),
                    Icons.trending_up,
                    monthlyRate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildProgressStats(
              context,
              averageProgress,
              historicalRate,
              projectedCompletion,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    [double? numericValue]
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['sm']!,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.color('income'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStats(
    BuildContext context,
    double averageProgress,
    double historicalRate,
    DateTime projectedCompletion,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['sm']!,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Statistics',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Average Progress',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                _formatPercentage(averageProgress),
                style: TextStyle(
                  color: DesignTokens.color('income'),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historical Rate',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                _formatMonthlyRate(historicalRate),
                style: TextStyle(
                  color: DesignTokens.color('income'),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text('Projected Completion'),
              ),
              Flexible(
                child: Text(
                  FormatUtils.formatDate(projectedCompletion),
                  style: TextStyle(
                    color: DesignTokens.color('income'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
