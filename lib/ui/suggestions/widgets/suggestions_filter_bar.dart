import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import '../../../data/models/freezed/financial_suggestion.dart';

class SuggestionsFilterBar extends StatelessWidget {
  final Set<SuggestionType> selectedTypes;
  final Set<SuggestionPriority> selectedPriorities;
  final bool showOnlyActive;
  final ValueChanged<Set<SuggestionType>> onTypesChanged;
  final ValueChanged<Set<SuggestionPriority>> onPrioritiesChanged;
  final ValueChanged<bool> onActiveFilterChanged;

  const SuggestionsFilterBar({
    super.key,
    required this.selectedTypes,
    required this.selectedPriorities,
    required this.showOnlyActive,
    required this.onTypesChanged,
    required this.onPrioritiesChanged,
    required this.onActiveFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filter title and clear button
          Row(
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Clear All'),
                ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Type filters row
          Row(
            children: [
              Text(
                'TYPE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: SuggestionType.values.map((type) {
                      final isSelected = selectedTypes.contains(type);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            _getTypeLabel(type),
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            final newTypes = Set<SuggestionType>.from(selectedTypes);
                            if (selected) {
                              newTypes.add(type);
                            } else {
                              newTypes.remove(type);
                            }
                            onTypesChanged(newTypes);
                          },
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          selectedColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          checkmarkColor: _getTypeColor(type),
                          side: isSelected ? BorderSide(color: _getTypeColor(type), width: 1.5) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Priority and Status row
          Row(
            children: [
              Text(
                'PRIORITY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Priority filters
                      ...SuggestionPriority.values.map((priority) {
                        final isSelected = selectedPriorities.contains(priority);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              _getPriorityLabel(priority),
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              final newPriorities = Set<SuggestionPriority>.from(selectedPriorities);
                              if (selected) {
                                newPriorities.add(priority);
                              } else {
                                newPriorities.remove(priority);
                              }
                              onPrioritiesChanged(newPriorities);
                            },
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            selectedColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            checkmarkColor: _getPriorityColor(context, priority),
                            side: isSelected ? BorderSide(color: _getPriorityColor(context, priority), width: 1.5) : null,
                          ),
                        );
                      }).toList(),

                      const SizedBox(width: 8),

                      // Active only filter
                      FilterChip(
                        label: Text(
                          'Active Only',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        selected: showOnlyActive,
                        onSelected: onActiveFilterChanged,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        selectedColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        checkmarkColor: DesignTokens.color('success'),
                        side: showOnlyActive ? BorderSide(color: DesignTokens.color('success'), width: 1.5) : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      selectedTypes.isNotEmpty || selectedPriorities.isNotEmpty || !showOnlyActive;

  void _clearAllFilters() {
    onTypesChanged({});
    onPrioritiesChanged({});
    onActiveFilterChanged(true);
  }

  String _getTypeLabel(SuggestionType type) {
    switch (type) {
      case SuggestionType.savingsOpportunity:
        return 'Savings';
      case SuggestionType.budgetWarning:
        return 'Budget Alert';
      case SuggestionType.goalRecommendation:
        return 'Goal';
      case SuggestionType.spendingPattern:
        return 'Spending';
      case SuggestionType.roundUpOptimization:
        return 'Round-Up';
      case SuggestionType.allocationImprovement:
        return 'Allocation';
      case SuggestionType.goalMilestone:
        return 'Milestone';
      case SuggestionType.unusualActivity:
        return 'Activity';
    }
  }

  Color _getTypeColor(SuggestionType type) {
    switch (type) {
      case SuggestionType.savingsOpportunity:
        return DesignTokens.color('success');
      case SuggestionType.budgetWarning:
        return DesignTokens.color('warning');
      case SuggestionType.goalRecommendation:
        return DesignTokens.color('info');
      case SuggestionType.spendingPattern:
        return DesignTokens.color('expense');
      case SuggestionType.roundUpOptimization:
        return DesignTokens.color('income');
      case SuggestionType.allocationImprovement:
        return DesignTokens.color('primary');
      case SuggestionType.goalMilestone:
        return DesignTokens.color('warning');
      case SuggestionType.unusualActivity:
        return DesignTokens.color('error');
    }
  }

  String _getPriorityLabel(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return 'Low';
      case SuggestionPriority.medium:
        return 'Medium';
      case SuggestionPriority.high:
        return 'High';
      case SuggestionPriority.urgent:
        return 'Urgent';
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
}