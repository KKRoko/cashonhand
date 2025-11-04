import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../data/models/freezed/financial_suggestion.dart';
import '../../components/cash_components.dart';

class SuggestionCard extends StatelessWidget {
  final FinancialSuggestion suggestion;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.onTap,
    this.onDismiss,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return CashCard(
      margin: EdgeInsets.only(bottom: DesignTokens.space('md')),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.space('md')),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Header with icon, type, and priority
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(context, suggestion.priority).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(suggestion.iconName),
                      color: _getPriorityColor(context, suggestion.priority),
                      size: 20,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Type and priority
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.typeDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getPriorityColor(context, suggestion.priority),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _getPriorityColor(context, suggestion.priority),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _getPriorityLabel(suggestion.priority),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (suggestion.potentialSavings != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: DesignTokens.color('success'),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  'Save \$${suggestion.potentialSavings!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Menu button
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleAction(action),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      if (suggestion.actionText != null)
                        PopupMenuItem(
                          value: 'action', 
                          child: Text(suggestion.actionText!),
                        ),
                      const PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                suggestion.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                suggestion.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Footer with timestamp and action button
              Row(
                children: [
                  // Timestamp
                  Text(
                    _formatTimestamp(suggestion.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action button
                  if (suggestion.actionText != null)
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        foregroundColor: _getPriorityColor(context, suggestion.priority),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        suggestion.actionText!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ],
        ),
      ),
    );
  }

  void _handleAction(String action) {
    switch (action) {
      case 'view':
        onTap?.call();
        break;
      case 'action':
        onAction?.call();
        break;
      case 'dismiss':
        onDismiss?.call();
        break;
    }
  }

  Color _getPriorityColor(BuildContext context, SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return DesignTokens.color('neutral');
      case SuggestionPriority.medium:
        return DesignTokens.color('info');
      case SuggestionPriority.high:
        return DesignTokens.color('warning');
      case SuggestionPriority.urgent:
        return DesignTokens.color('error');
    }
  }

  String _getPriorityLabel(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return 'LOW';
      case SuggestionPriority.medium:
        return 'MED';
      case SuggestionPriority.high:
        return 'HIGH';
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

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}