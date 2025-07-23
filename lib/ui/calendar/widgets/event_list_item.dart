import 'package:flutter/material.dart';
import '../../../data/models/freezed/event.dart';
import '../../../data/models/freezed/saving_goal.dart';
import '../../../data/database/database.dart';
import '../../../data/repositories/saving_goal_repository.dart';
import '../../../data/models/enums/repeat_option.dart';
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
  
  // Category information
  CategoryTableData? _category;
  bool _isLoadingCategory = false;

  @override
  void initState() {
    super.initState();
    _loadEventAllocations();
    _loadCategoryInfo();
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

  Future<void> _loadCategoryInfo() async {
    setState(() => _isLoadingCategory = true);
    
    try {
      final database = getIt<Database>();
      final category = await database.getCategoryById(widget.event.categoryId);
      
      if (mounted) {
        setState(() {
          _category = category;
          _isLoadingCategory = false;
        });
      }
    } catch (e) {
      print('Error loading category: $e');
      if (mounted) {
        setState(() => _isLoadingCategory = false);
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
                          const SizedBox(height: 4),
                          _buildCategoryInfo(theme),
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

                          // Category Information (Detailed)
                          _buildDetailedCategoryInfo(theme),
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
                                _getOccurrenceInfo(),
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

  Widget _buildCategoryInfo(ThemeData theme) {
    if (_isLoadingCategory) {
      return Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading category...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    if (_category == null) {
      return Row(
        children: [
          Icon(
            Icons.help_outline,
            size: 14,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 4),
          Text(
            'Unknown category',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Category icon
        if (_category!.icon?.isNotEmpty == true) ...[
          Text(
            _category!.icon!,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
        ] else ...[
          Icon(
            widget.event.isPositiveCashflow ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: widget.event.isPositiveCashflow ? Colors.green : Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
        ],
        
        // Category name
        Flexible(
          child: Text(
            _category!.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        // Parent category hint for subcategories
        if (_category!.parentCategoryId != null) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Sub',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getOccurrenceInfo() {
    final now = DateTime.now();
    final eventDate = widget.event.dateTime;
    
    // Check if it's a one-time transaction
    if (widget.event.repeatOption == RepeatOption.today || !widget.event.isRecurring) {
      // Check if it's today
      if (eventDate.year == now.year && 
          eventDate.month == now.month && 
          eventDate.day == now.day) {
        return 'Today only';
      } else if (eventDate.isBefore(now)) {
        return 'Past transaction';
      } else {
        return 'Scheduled: ${_formatDate(eventDate)}';
      }
    }
    
    // For recurring transactions
    final daysDifference = eventDate.difference(now).inDays;
    
    if (daysDifference == 0) {
      return 'Next: Today';
    } else if (daysDifference == 1) {
      return 'Next: Tomorrow';
    } else if (daysDifference == -1) {
      return 'Last occurred: Yesterday';
    } else if (daysDifference < 0) {
      return 'Last occurred: ${_formatDate(eventDate)}';
    } else if (daysDifference <= 7) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final weekdayName = weekdays[eventDate.weekday - 1];
      return 'Next: $weekdayName';
    } else {
      return 'Next: ${_formatDate(eventDate)}';
    }
  }

  Widget _buildDetailedCategoryInfo(ThemeData theme) {
    if (_category == null) {
      return Row(
        children: [
          Icon(
            Icons.category_outlined,
            size: 16,
            color: theme.textTheme.bodyMedium?.color,
          ),
          const SizedBox(width: 8),
          Text(
            'Category: Unknown',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.event.isPositiveCashflow 
          ? Colors.green.shade50 
          : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.event.isPositiveCashflow 
            ? Colors.green.shade200 
            : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category,
            size: 16,
            color: widget.event.isPositiveCashflow 
              ? Colors.green.shade700 
              : Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_category!.icon?.isNotEmpty == true) ...[
                      Text(
                        _category!.icon!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        _category!.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.event.isPositiveCashflow 
                            ? Colors.green.shade800 
                            : Colors.orange.shade800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_category!.parentCategoryId != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.event.isPositiveCashflow 
                            ? Colors.green.shade100 
                            : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Subcategory',
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.event.isPositiveCashflow 
                              ? Colors.green.shade700 
                              : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_category!.parentCategoryId != null) ...[
                  const SizedBox(height: 4),
                  FutureBuilder<CategoryTableData?>(
                    future: _loadParentCategory(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Text(
                          'Part of: ${snapshot.data!.icon ?? '📁'} ${snapshot.data!.name}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<CategoryTableData?> _loadParentCategory() async {
    if (_category?.parentCategoryId == null) return null;
    
    try {
      final database = getIt<Database>();
      return await database.getCategoryById(_category!.parentCategoryId!);
    } catch (e) {
      return null;
    }
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
