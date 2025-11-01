import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/saving_goal_repository.dart';
import '../../../state/saving_goal_notifier.dart';
import '../../../utils/formatters.dart';

class GoalAllocationHistoryWidget extends StatefulWidget {
  final int goalId;
  final String goalTitle;

  const GoalAllocationHistoryWidget({
    super.key,
    required this.goalId,
    required this.goalTitle,
  });

  @override
  State<GoalAllocationHistoryWidget> createState() => _GoalAllocationHistoryWidgetState();
}

class _GoalAllocationHistoryWidgetState extends State<GoalAllocationHistoryWidget> {
  List<GoalAllocationHistory> _allocations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer loading until after the initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllocationHistory();
    });
  }

  Future<void> _loadAllocationHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifier = Provider.of<SavingGoalNotifier>(context, listen: false);
      final history = await notifier.getGoalAllocationHistory(widget.goalId);
      
      setState(() {
        _allocations = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: DesignTokens.color('info'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Allocation History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadAllocationHistory,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error, color: DesignTokens.color('error'), size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load allocation history',
                      style: TextStyle(color: DesignTokens.color('error')),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (_allocations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.savings,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No allocations yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start allocating money to this goal from your transactions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                // Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: DesignTokens.color('info').withOpacity(0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Allocations: ${_allocations.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        FormatUtils.formatCurrency(
                          _allocations.fold(0.0, (sum, allocation) => sum + allocation.amount)
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.color('info'),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Allocation List
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _allocations.length,
                    itemBuilder: (context, index) {
                      final allocation = _allocations[index];
                      return _buildAllocationItem(allocation);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAllocationItem(GoalAllocationHistory allocation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          // Date
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${allocation.date.month}/${allocation.date.day}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${allocation.date.year}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allocation.eventTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      _getAllocationTypeIcon(allocation.allocationType),
                      size: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getAllocationTypeLabel(allocation.allocationType),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Amount
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DesignTokens.color('success').withOpacity(0.1),
              borderRadius: DesignTokens.borderRadius['md']!,
              border: Border.all(color: DesignTokens.color('success').withOpacity(0.3)),
            ),
            child: Text(
              FormatUtils.formatCurrency(allocation.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: DesignTokens.color('success'),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAllocationTypeIcon(String allocationType) {
    switch (allocationType.toLowerCase()) {
      case 'manual':
        return Icons.edit;
      case 'automatic':
        return Icons.autorenew;
      case 'roundup':
        return Icons.arrow_circle_up;
      default:
        return Icons.savings;
    }
  }

  String _getAllocationTypeLabel(String allocationType) {
    switch (allocationType.toLowerCase()) {
      case 'manual':
        return 'Manual';
      case 'automatic':
        return 'Auto';
      case 'roundup':
        return 'Round-up';
      default:
        return 'Allocation';
    }
  }
}