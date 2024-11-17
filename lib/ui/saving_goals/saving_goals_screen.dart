import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/freezed/saving_goal.dart';
import '../../state/saving_goal_notifier.dart';
import 'widgets/goal_list_item.dart';
import 'widgets/goal_statistics_widget.dart';
import 'widgets/add_edit_goal_dialog.dart';

class SavingGoalsScreen extends StatefulWidget {
  static const routeName = '/savingGoals';
  const SavingGoalsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SavingGoalsScreenState createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> {
  String? _expandedGoalId;

  @override
  void initState() {  
    super.initState();
  }

  Future<void> _showAddEditGoalDialog([SavingGoal? goal]) async {
    await showDialog(
      context: context,
      builder: (context) => AddEditGoalDialog(goal: goal),
    );
  }

  Widget _buildOverallProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings, color: Colors.green.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Overall Savings Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const GoalStatisticsWidget(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saving Goals'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // TODO: Show savings history
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<SavingGoalNotifier>(
          builder: (context, goalNotifier, child) {
            final goals = goalNotifier.goals;
            
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOverallProgress(),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Goals',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Goal'),
                      onPressed: () => _showAddEditGoalDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                ...goals.map((goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GoalListItem(
                    goal: goal,
                    isExpanded: _expandedGoalId == goal.id,
                    onTap: () => setState(() {
                      _expandedGoalId = _expandedGoalId == goal.id ? null : goal.id;
                    }),
                    onEdit: () => _showAddEditGoalDialog(goal),
                  ),
                )).toList(),
                
                if (goals.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.savings_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saving goals yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddEditGoalDialog(),
                            child: const Text('Create Your First Goal'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
