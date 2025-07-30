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
    // Determine colors for dark theme based on value
    Color getValueColor() {
      if (Theme.of(context).brightness != Brightness.dark) {
        return Theme.of(context).textTheme.titleMedium?.color ?? Colors.black;
      }
      
      // Dark theme logic
      if (numericValue == null || numericValue == 0) {
        return Colors.black;
      } else if (numericValue > 0) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }

    Color getLabelColor() {
      if (Theme.of(context).brightness != Brightness.dark) {
        return Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
      }
      
      // Dark theme - make label black when value is zero
      if (numericValue == null || numericValue == 0) {
        return Colors.black;
      } else {
        return Colors.black54;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? DesignTokens.color('incomeLight') 
          : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon, 
                size: 16, 
                color: numericValue == null || numericValue == 0 
                  ? (Theme.of(context).brightness == Brightness.dark 
                      ? DesignTokens.color('textPrimary') 
                      : DesignTokens.color('textTertiary'))
                  : (Theme.of(context).brightness == Brightness.dark 
                      ? DesignTokens.color('textPrimary') 
                      : DesignTokens.color('textTertiary'))
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? DesignTokens.color('textPrimary') 
                    : getLabelColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark 
                ? DesignTokens.color('income') 
                : getValueColor(),
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
    // Helper function to get value color based on numeric value
    Color getValueColor(double value) {
      if (Theme.of(context).brightness != Brightness.dark) {
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
      }
      
      // Dark theme logic
      if (value == 0) {
        return Colors.black;
      } else if (value > 0) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }

    // Helper function for label colors
    Color getLabelColor(double value) {
      if (Theme.of(context).brightness != Brightness.dark) {
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
      }
      
      // Dark theme - make label black when value is zero
      if (value == 0) {
        return Colors.black;
      } else {
        return Colors.black87; // Dark text for light green background
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? DesignTokens.color('incomeLight') 
          : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Statistics',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark 
                ? DesignTokens.color('textPrimary')
                : null,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Average Progress',
                style: TextStyle(color: getLabelColor(averageProgress)),
              ),
              Text(
                _formatPercentage(averageProgress),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? DesignTokens.color('incomeDark') 
                    : getValueColor(averageProgress),
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
                style: TextStyle(color: getLabelColor(historicalRate)),
              ),
              Text(
                _formatMonthlyRate(historicalRate),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? DesignTokens.color('incomeDark') 
                    : getValueColor(historicalRate),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Flexible(
                child: Text(
                  'Projected Completion',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.black87
                      : null,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  FormatUtils.formatDate(projectedCompletion),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? DesignTokens.color('incomeDark')
                      : null,
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
