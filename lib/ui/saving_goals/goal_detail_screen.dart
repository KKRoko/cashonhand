import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/freezed/saving_goal.dart';
import '../../state/saving_goal_notifier.dart';
import '../../theme/design_tokens.dart';
import '../../utils/formatters.dart';
import 'widgets/goal_allocation_history_widget.dart';
import 'widgets/add_edit_goal_dialog.dart';

class GoalDetailScreen extends StatefulWidget {
  static const routeName = '/goalDetail';
  final SavingGoal goal;

  const GoalDetailScreen({
    super.key,
    required this.goal,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late SavingGoal _currentGoal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentGoal = widget.goal;
    // Defer the refresh until after the initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshGoal();
    });
  }

  Future<void> _refreshGoal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = Provider.of<SavingGoalNotifier>(context, listen: false);
      
      // Refresh goals to get real-time progress  
      await notifier.refreshGoalsWithRealTimeProgress();
      
      // Find the updated goal from the notifier's goals list
      final updatedGoal = notifier.goals.firstWhere(
        (g) => g.id == _currentGoal.id,
        orElse: () => _currentGoal,
      );
      
      setState(() {
        _currentGoal = updatedGoal;
      });
    } catch (e) {
      print('Error refreshing goal: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddEditGoalDialog(goal: _currentGoal),
    );
    // Refresh goal after editing
    await _refreshGoal();
  }

  Future<void> _syncProgress() async {
    setState(() {
      _isLoading = true;
    });

    final notifier = Provider.of<SavingGoalNotifier>(context, listen: false);
    await notifier.syncGoalProgress(_currentGoal.id);
    await _refreshGoal();
  }

  Future<void> _showDeleteConfirmation() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete Goal'),
        content: Text(
          'Are you sure you want to delete "${_currentGoal.title}"?\n\n'
          'This action cannot be undone and will remove all progress data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: DesignTokens.color('error')),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteGoal();
    }
  }

  Future<void> _deleteGoal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = Provider.of<SavingGoalNotifier>(context, listen: false);
      await notifier.deleteGoal(_currentGoal.id);
      
      if (mounted) {
        // Show success message and go back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goal "${_currentGoal.title}" deleted successfully'),
            backgroundColor: DesignTokens.color('success'),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete goal: $e'),
            backgroundColor: DesignTokens.color('error'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = _currentGoal.progressPercentage;
    final isCompleted = _currentGoal.isCompleted;
    final daysRemaining = _currentGoal.deadlineDate?.difference(DateTime.now()).inDays;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentGoal.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: 'Edit Goal',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: DesignTokens.color('error')),
                    const SizedBox(width: 8),
                    Text('Delete Goal', style: TextStyle(color: DesignTokens.color('error'))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGoal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Goal Header Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DesignTokens.color('success').withOpacity(0.8),
                      DesignTokens.color('success'),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: DesignTokens.borderRadius['lg']!,
                  boxShadow: [
                    BoxShadow(
                      color: DesignTokens.color('success').withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentGoal.title,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                              borderRadius: DesignTokens.borderRadius['full']!,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.onPrimary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    if (_currentGoal.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        _currentGoal.description,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Progress Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          FormatUtils.formatCurrency(_currentGoal.currentAmount),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'of ${FormatUtils.formatCurrency(_currentGoal.targetAmount)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Progress Bar
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${progressPercentage.toInt()}% Complete',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (daysRemaining != null && daysRemaining >= 0 && !isCompleted)
                              Text(
                                '$daysRemaining days left',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: DesignTokens.borderRadius['sm']!,
                          child: LinearProgressIndicator(
                            value: (progressPercentage / 100).clamp(0.0, 1.0),
                            backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Stats Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: DesignTokens.borderRadius['md']!,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Remaining',
                        FormatUtils.formatCurrency(
                          (_currentGoal.targetAmount - _currentGoal.currentAmount).clamp(0.0, double.infinity)
                        ),
                        Icons.flag,
                        DesignTokens.color('warning'),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Created',
                        '${_currentGoal.createdAt.month}/${_currentGoal.createdAt.day}/${_currentGoal.createdAt.year}',
                        Icons.calendar_today,
                        DesignTokens.color('info'),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Goal Type',
                        _currentGoal.goalType.toString().split('.').last,
                        Icons.category,
                        DesignTokens.color('primary'),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Allocation History
              GoalAllocationHistoryWidget(
                goalId: _currentGoal.id,
                goalTitle: _currentGoal.title,
              ),
              
              // Bottom padding for safe area
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}