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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          
          const SizedBox(height: 12),
          
          // Type filters
          const Text(
            'Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: SuggestionType.values.map((type) {
              final isSelected = selectedTypes.contains(type);
              return FilterChip(
                label: Text(_getTypeLabel(type)),
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
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Priority filters
          const Text(
            'Priority',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: SuggestionPriority.values.map((priority) {
              final isSelected = selectedPriorities.contains(priority);
              return FilterChip(
                label: Text(_getPriorityLabel(priority)),
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
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Active filter
          Row(
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Active Only'),
                selected: showOnlyActive,
                onSelected: onActiveFilterChanged,
                selectedColor: Colors.green.withOpacity(0.2),
                checkmarkColor: Colors.green,
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