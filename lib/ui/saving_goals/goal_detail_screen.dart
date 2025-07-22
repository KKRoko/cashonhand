import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/freezed/saving_goal.dart';
import '../../state/saving_goal_notifier.dart';
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
    await notifier.syncGoalProgress(_currentGoal.id!);
    await _refreshGoal();
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
            icon: const Icon(Icons.sync),
            onPressed: _syncProgress,
            tooltip: 'Sync Progress',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog,
            tooltip: 'Edit Goal',
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
                    colors: isCompleted
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isCompleted ? Colors.green : Colors.blue).withOpacity(0.3),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.white,
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
                          color: Colors.white.withOpacity(0.9),
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'of ${FormatUtils.formatCurrency(_currentGoal.targetAmount)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
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
                              '${(progressPercentage * 100).toInt()}% Complete',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (daysRemaining != null && daysRemaining >= 0 && !isCompleted)
                              Text(
                                '$daysRemaining days left',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressPercentage.clamp(0.0, 1.0),
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
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
                        Colors.orange,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Created',
                        '${_currentGoal.createdAt.month}/${_currentGoal.createdAt.day}/${_currentGoal.createdAt.year}',
                        Icons.calendar_today,
                        Colors.blue,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Goal Type',
                        _currentGoal.goalType.toString().split('.').last,
                        Icons.category,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Allocation History
              GoalAllocationHistoryWidget(
                goalId: _currentGoal.id!,
                goalTitle: _currentGoal.title,
              ),
              
              // Bottom padding for safe area
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: _isLoading
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: _syncProgress,
              icon: const Icon(Icons.sync),
              label: const Text('Sync Progress'),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
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
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}