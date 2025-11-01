import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/enums/bucket_type.dart';
import '../../../theme/design_tokens.dart';

class BudgetPieChart extends StatelessWidget {
  final Map<BucketType, double> bucketAmounts;
  final String centerText;
  final String? subtitle;
  final bool showLegend;
  final bool isActualView;

  const BudgetPieChart({
    super.key,
    required this.bucketAmounts,
    required this.centerText,
    this.subtitle,
    this.showLegend = true,
    this.isActualView = false,
  });

  Color _getBucketColor(BuildContext context, BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return Theme.of(context).colorScheme.primary; // Green
      case BucketType.wants:
        return DesignTokens.color('info'); // Blue
      case BucketType.savings:
        return DesignTokens.color('warning'); // Orange
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

  @override
  Widget build(BuildContext context) {
    final total = bucketAmounts.values.fold<double>(0.0, (sum, amount) => sum + amount);

    if (total == 0) {
      return _buildEmptyState(context);
    }

    final sections = bucketAmounts.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
      final percentage = (entry.value / total) * 100;

      return PieChartSectionData(
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        color: _getBucketColor(context, entry.key),
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                  startDegreeOffset: -90,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerText,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 24),
          _buildLegend(context, total),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActualView ? Icons.receipt_long_outlined : Icons.pie_chart_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  isActualView ? 'No spending recorded yet' : 'No budget data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isActualView) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Transactions will appear here\nas you add them',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context, double total) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: bucketAmounts.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total) * 100 : 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getBucketColor(context, entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_getBucketLabel(entry.key)}: \$${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
