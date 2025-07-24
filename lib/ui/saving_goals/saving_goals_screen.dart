import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/freezed/saving_goal.dart';
import '../../state/saving_goal_notifier.dart';
import '../../services/goal_update_notifier.dart';
import '../../theme/design_tokens.dart';
import '../components/cash_components.dart';
import 'widgets/goal_list_item.dart';
import 'widgets/goal_statistics_widget.dart';
import 'widgets/add_edit_goal_dialog.dart';
import 'goal_detail_screen.dart';

class SavingGoalsScreen extends StatefulWidget {
  static const routeName = '/savingGoals';
  const SavingGoalsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SavingGoalsScreenState createState() => _SavingGoalsScreenState();
}

class _SavingGoalsScreenState extends State<SavingGoalsScreen> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  int? _expandedGoalId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {  
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen for goal updates from other screens
    GoalUpdateNotifier().addListener(_onGoalUpdated);
    
    _loadGoals();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GoalUpdateNotifier().removeListener(_onGoalUpdated);
    super.dispose();
  }

  void _onGoalUpdated() {
    if (mounted) {
      // Received goal update notification, refreshing goals automatically
      context.read<SavingGoalNotifier>().loadGoals();
    }
  }

  void _loadGoals() {
    // Loading goals for Goals screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SavingGoalNotifier>().loadGoals();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      // App resumed, refreshing goals
      _loadGoals();
    }
  }

  // Track if this is the first build
  bool _isFirstBuild = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh on subsequent builds (when returning to screen)
    if (!_isFirstBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Goals screen became visible (returning), refreshing goals
          context.read<SavingGoalNotifier>().loadGoals();
        }
      });
    }
    _isFirstBuild = false;
  }


  Future<void> _showAddEditGoalDialog([SavingGoal? goal]) async {
    await showDialog(
      context: context,
      builder: (context) => AddEditGoalDialog(goal: goal),
    );
  }

  void _navigateToGoalDetail(SavingGoal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GoalDetailScreen(goal: goal),
      ),
    ).then((_) {
      // Refresh goals when returning from detail screen
      _loadGoals();
    });
  }

  Widget _buildOverallProgress() {
    return CashCard(
      financialContext: FinancialContext.income,
      padding: EdgeInsets.all(DesignTokens.space('lg')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.savings, 
                color: DesignTokens.color('income'),
              ),
              HSpace('md'),
              Expanded(
                child: Text(
                  'Overall Savings Progress',
                  style: DesignTokens.textStyle('titleMedium').copyWith(
                    color: DesignTokens.color('income'),
                  ),
                ),
              ),
            ],
          ),
          VSpace('lg'),
          const GoalStatisticsWidget(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saving Goals'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Manual refresh triggered
              context.read<SavingGoalNotifier>().loadGoals();
            },
          ),
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
            
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<SavingGoalNotifier>().loadGoals();
              },
              child: ListView(
                padding: EdgeInsets.all(DesignTokens.space('lg')),
              children: [
                _buildOverallProgress(),
                VSpace('xl'),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Goals',
                      style: DesignTokens.textStyle('titleLarge'),
                    ),
                    PrimaryButton(
                      onPressed: () => _showAddEditGoalDialog(),
                      icon: Icons.add,
                      size: ButtonSize.medium,
                      child: const Text('Add Goal'),
                    ),
                  ],
                ),
                VSpace('lg'),
                
                ...goals.map((goal) => Padding(
                  padding: EdgeInsets.only(bottom: DesignTokens.space('sm')),
                  child: GoalListItem(
                    goal: goal,
                    isExpanded: _expandedGoalId == goal.id,
                    onTap: () => setState(() {
                      _expandedGoalId = _expandedGoalId == goal.id ? null : goal.id;
                    }),
                    onEdit: () => _showAddEditGoalDialog(goal),
                    onViewDetails: () => _navigateToGoalDetail(goal),
                  ),
                )),
                
                if (goals.isEmpty)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(DesignTokens.space('2xl')),
                      child: Column(
                        children: [
                          Icon(
                            Icons.savings_outlined,
                            size: 48,
                            color: DesignTokens.color('textTertiary'),
                          ),
                          VSpace('lg'),
                          Text(
                            'No saving goals yet',
                            style: DesignTokens.textStyle('bodyLarge').copyWith(
                              color: DesignTokens.color('textSecondary'),
                            ),
                          ),
                          VSpace('sm'),
                          PrimaryButton(
                            onPressed: () => _showAddEditGoalDialog(),
                            child: const Text('Create Your First Goal'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              ),
            );
          },
        ),
      ),
    );
  }
}
