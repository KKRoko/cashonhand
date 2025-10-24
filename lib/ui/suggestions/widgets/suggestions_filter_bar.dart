import 'package:flutter/material.dart';
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
        color: Theme.of(context).brightness == Brightness.dark 
          ? Colors.black 
          : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade800 
              : Colors.grey.shade200,
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
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters)
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : null,
                    ),
                  ),
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
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87,
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
                              color: Theme.of(context).brightness == Brightness.dark
                                ? (isSelected ? Colors.black : Colors.white)
                                : null,
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
                          selectedColor: _getTypeColor(type).withOpacity(0.2),
                          checkmarkColor: _getTypeColor(type),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade800
                            : null,
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
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black87,
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
                                color: Theme.of(context).brightness == Brightness.dark
                                  ? (isSelected ? Colors.black : Colors.white)
                                  : null,
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
                            selectedColor: _getPriorityColor(priority).withOpacity(0.2),
                            checkmarkColor: _getPriorityColor(priority),
                            backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade800
                              : null,
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
                            color: Theme.of(context).brightness == Brightness.dark
                              ? (showOnlyActive ? Colors.black : Colors.white)
                              : null,
                          ),
                        ),
                        selected: showOnlyActive,
                        onSelected: onActiveFilterChanged,
                        selectedColor: Colors.green.withOpacity(0.2),
                        checkmarkColor: Colors.green,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : null,
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
        return Colors.green;
      case SuggestionType.budgetWarning:
        return Colors.orange;
      case SuggestionType.goalRecommendation:
        return Colors.blue;
      case SuggestionType.spendingPattern:
        return Colors.purple;
      case SuggestionType.roundUpOptimization:
        return Colors.teal;
      case SuggestionType.allocationImprovement:
        return Colors.indigo;
      case SuggestionType.goalMilestone:
        return Colors.amber;
      case SuggestionType.unusualActivity:
        return Colors.red;
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

  Color _getPriorityColor(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return Colors.grey;
      case SuggestionPriority.medium:
        return Colors.blue;
      case SuggestionPriority.high:
        return Colors.orange;
      case SuggestionPriority.urgent:
        return Colors.red;
    }
  }
}