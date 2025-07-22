import 'package:flutter/material.dart';
import '../../../data/models/freezed/event.dart';
import '../../../data/models/freezed/saving_goal.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/saving_goal_repository.dart';
import '../../../core/di/injection.dart';
import '../../../theme/app_theme.dart';

class EventListItem extends StatefulWidget {
  final Event event;
  final Function(Event) onDeleteEvent;
  final Function(Event) onEditEvent;

  const EventListItem({
    super.key,
    required this.event,
    required this.onDeleteEvent,
    required this.onEditEvent,
  });

  @override
  State<EventListItem> createState() => _EventListItemState();
}

class _EventListItemState extends State<EventListItem> {
  bool _isExpanded = false;
  List<GoalAllocationHistory> _allocations = [];
  Map<int, String> _goalTitles = {};
  bool _isLoadingAllocations = false;

  @override
  void initState() {
    super.initState();
    _loadEventAllocations();
  }

  Future<void> _loadEventAllocations() async {
    if (widget.event.id == null) return;
    
    setState(() => _isLoadingAllocations = true);
    
    try {
      final database = getIt<Database>();
      final goalRepository = getIt<ISavingGoalRepository>();
      
      // Load allocations for this event
      final allocations = await database.getAllocationsForEvent(widget.event.id!);
      
      // Load goal titles
      final goalTitles = <int, String>{};
      for (final allocation in allocations) {
        if (!goalTitles.containsKey(allocation.goalId)) {
          final goalResult = await goalRepository.getGoalById(allocation.goalId);
          goalResult.fold(
            (failure) => null,
            (goal) => goalTitles[allocation.goalId] = goal?.title ?? 'Unknown Goal',
          );
        }
      }
      
      // Convert GoalAllocationTableData to GoalAllocationHistory
      final allocationHistories = allocations.map((alloc) => GoalAllocationHistory(
        allocationId: alloc.id,
        eventId: alloc.eventId,
        goalId: alloc.goalId,
        amount: alloc.allocationAmount,
        date: alloc.createdAt,
        eventTitle: widget.event.title,
        allocationType: alloc.allocationType.toString().split('.').last,
      )).toList();
      
      if (mounted) {
        setState(() {
          _allocations = allocationHistories;
          _goalTitles = goalTitles;
          _isLoadingAllocations = false;
        });
      }
    } catch (e) {
      print('Error loading event allocations: $e');
      if (mounted) {
        setState(() => _isLoadingAllocations = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine amount color based on cashflow type
    final amountColor = widget.event.isPositiveCashflow
        ? colorScheme.tertiary
        : colorScheme.error;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.defaultPadding,
        vertical: AppTheme.defaultPadding / 2,
      ),
      child: Card(
        elevation: AppTheme.cardElevation,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
          child: Column(
            children: [
              // Main Tile Content
              Padding(
                padding: const EdgeInsets.all(AppTheme.defaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.event.title,
                            style: theme.textTheme.titleMedium,
                          ),
                          if (_allocations.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            _buildAllocationSummary(theme),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.event.formattedAmount,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_allocations.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Allocated: \$${_getTotalAllocatedAmount().toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Expanded Content
              AppTheme.expandTransition(
                expand: _isExpanded,
                child: Column(
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Repeat Information
                          Row(
                            children: [
                              Icon(
                                Icons.repeat,
                                size: 16,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.event.repeatDescription,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Date Information
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Next: ${_formatDate(widget.event.dateTime)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          
                          // Allocation Details
                          if (_allocations.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _buildAllocationDetails(theme),
                            const SizedBox(height: 16),
                          ] else
                            const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    widget.onEditEvent(widget.event),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () =>
                                    widget.onDeleteEvent(widget.event),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Delete'),
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildAllocationSummary(ThemeData theme) {
    final totalCount = _allocations.length;
    final totalAmount = _getTotalAllocatedAmount();
    
    return Row(
      children: [
        Icon(
          Icons.savings,
          size: 14,
          color: Colors.green.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          '$totalCount goal${totalCount == 1 ? '' : 's'} • \$${totalAmount.toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.savings,
              size: 16,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              'Goal Allocations',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: _allocations.map((allocation) {
              final goalTitle = _goalTitles[allocation.goalId] ?? 'Unknown Goal';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 14,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goalTitle,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '\$${allocation.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
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

  double _getTotalAllocatedAmount() {
    return _allocations.fold<double>(0, (sum, allocation) => sum + allocation.amount);
  }
}
