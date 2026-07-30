import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../data/models/freezed/financial_suggestion.dart';

class SuggestionDetailDialog extends StatelessWidget {
  final FinancialSuggestion suggestion;

  const SuggestionDetailDialog({
    super.key,
    required this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getPriorityColor(suggestion.priority),
                borderRadius: BorderRadius.vertical(
                    top: (DesignTokens.borderRadius['md']!).topLeft),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconData(suggestion.iconName),
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.typeDisplayName,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          suggestion.title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    icon: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority and savings info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(suggestion.priority),
                            borderRadius: DesignTokens.borderRadius['full']!,
                          ),
                          child: Text(
                            _getPriorityLabel(suggestion.priority),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (suggestion.potentialSavings != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: DesignTokens.color('success')
                                  .withOpacity(0.1),
                              borderRadius: DesignTokens.borderRadius['full']!,
                              border: Border.all(
                                  color: DesignTokens.color('success')
                                      .withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.savings,
                                  size: 14,
                                  color: DesignTokens.color('success'),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '\$${suggestion.potentialSavings!.toStringAsFixed(2)}/month',
                                  style: TextStyle(
                                    color: DesignTokens.color('success'),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestion.description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Additional info sections
                    if (suggestion.potentialSavings != null) ...[
                      _buildInfoSection(
                        context,
                        'Potential Savings',
                        [
                          'Monthly: \$${suggestion.potentialSavings!.toStringAsFixed(2)}',
                          'Annually: \$${(suggestion.potentialSavings! * 12).toStringAsFixed(2)}',
                        ],
                        Icons.trending_up,
                        DesignTokens.color('success'),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Action steps from actionData if available
                    if (suggestion.actionData?['actionSteps'] != null) ...[
                      _buildActionStepsSection(
                        context,
                        suggestion.actionData!['actionSteps'] as List<String>,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Metadata
                    _buildInfoSection(
                      context,
                      'Information',
                      [
                        'Created: ${_formatDateTime(suggestion.createdAt)}',
                        if (suggestion.expiresAt != null)
                          'Expires: ${_formatDateTime(suggestion.expiresAt!)}',
                        'Status: ${suggestion.isActive ? 'Active' : 'Inactive'}',
                      ],
                      Icons.info_outline,
                      DesignTokens.color('info'),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _dismissSuggestion(context),
                      child: const Text('Dismiss'),
                    ),
                  ),
                  if (suggestion.actionText != null &&
                      suggestion.actionRoute != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _takeAction(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _getPriorityColor(suggestion.priority),
                        ),
                        child: Text(suggestion.actionText!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title,
      List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: DesignTokens.borderRadius['sm']!,
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $item',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionStepsSection(
      BuildContext context, List<String> actionSteps) {
    final actionColor = DesignTokens.color('info');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt, size: 18, color: actionColor),
            const SizedBox(width: 8),
            Text(
              'Recommended Actions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: actionColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: actionColor.withOpacity(0.05),
            borderRadius: DesignTokens.borderRadius['sm']!,
            border: Border.all(color: actionColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: actionSteps.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: actionColor,
                        borderRadius: DesignTokens.borderRadius['full']!,
                      ),
                      child: Center(
                        child: Text(
                          index.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _dismissSuggestion(BuildContext context) {
    // TODO: Implement suggestion dismissal
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dismissed: ${suggestion.title}')),
    );
  }

  void _takeAction(BuildContext context) {
    Navigator.of(context).pop();
    if (suggestion.actionRoute != null) {
      Navigator.pushNamed(context, suggestion.actionRoute!);
    }
  }

  Color _getPriorityColor(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return DesignTokens.color('info');
      case SuggestionPriority.medium:
        return DesignTokens.color('primary');
      case SuggestionPriority.high:
        return DesignTokens.color('warning');
      case SuggestionPriority.urgent:
        return DesignTokens.color('error');
    }
  }

  String _getPriorityLabel(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return 'LOW PRIORITY';
      case SuggestionPriority.medium:
        return 'MEDIUM PRIORITY';
      case SuggestionPriority.high:
        return 'HIGH PRIORITY';
      case SuggestionPriority.urgent:
        return 'URGENT';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'warning':
        return Icons.warning;
      case 'flag':
        return Icons.flag;
      case 'analytics':
        return Icons.analytics;
      case 'trending_up':
        return Icons.trending_up;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'celebration':
        return Icons.celebration;
      case 'notification_important':
        return Icons.notification_important;
      default:
        return Icons.lightbulb;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
