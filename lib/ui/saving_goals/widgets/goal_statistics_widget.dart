import 'package:flutter/material.dart';
import '../../../utils/formatters.dart';
import '../../../state/saving_goal_notifier.dart';
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
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Monthly Rate',
                    FormatUtils.formatCurrency(monthlyRate),
                    Icons.trending_up,
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
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
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
              const Text('Average Progress'),
              Text(_formatPercentage(averageProgress)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Historical Rate'),
              Text(_formatMonthlyRate(historicalRate)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Flexible(
                child: const Text('Projected Completion'),
              ),
              Flexible(
                child: Text(FormatUtils.formatDate(projectedCompletion)),)
            ],
          ),
        ],
      ),
    );
  }
}
