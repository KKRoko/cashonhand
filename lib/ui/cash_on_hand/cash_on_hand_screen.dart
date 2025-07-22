import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/settings_view.dart';
import '../../state/event_notifier.dart';
import '../../state/saving_goal_notifier.dart';
import '../../core/di/injection.dart';
import '../../data/database/database.dart';
import '../achievements/achievement_screen.dart';
import '../../utils/formatters.dart';

class CashOnHandScreen extends StatefulWidget {
  static const routeName = '/cashOnHand';
  const CashOnHandScreen({super.key});

  @override
  State<CashOnHandScreen> createState() => _CashOnHandScreenState();
}

class _CashOnHandScreenState extends State<CashOnHandScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _now;
  late DateTime _endOfWeek;
  late DateTime _endOfMonth;
  late DateTime _endOfYear;
  late Map<String, Map<String, double>> _totals;
  String? _expandedTileId;
  bool _isLoading = false;

  // Animation controller for progress bars
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Initialize dates
    _now = DateTime.now();
    _endOfWeek = _getEndOfWeek(_now);
    _endOfMonth = _getEndOfMonth(_now);

    // Initialize totals with goal-aware metrics
    _totals = {
      'day': {'positive': 0, 'negative': 0, 'goalAllocations': 0, 'availableAfterGoals': 0},
      'week': {'positive': 0, 'negative': 0, 'goalAllocations': 0, 'availableAfterGoals': 0},
      'month': {'positive': 0, 'negative': 0, 'goalAllocations': 0, 'availableAfterGoals': 0},
      'year': {'positive': 0, 'negative': 0, 'goalAllocations': 0, 'availableAfterGoals': 0},
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventNotifier = Provider.of<EventNotifier>(context, listen: false);
      eventNotifier.loadInitialEvents();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the EventNotifier and initialize dates that depend on it
    final eventNotifier = Provider.of<EventNotifier>(context);
    final year = eventNotifier.currentYear;
    _endOfYear = DateTime(year, 12, 31);

    // Get EventService from EventNotifier

    // Initial load of totals
    _calculateTotals();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  DateTime _getEndOfWeek(DateTime date) {
    return date.add(Duration(
        days: DateTime.saturday -
            date.weekday +
            (date.weekday == DateTime.sunday ? 7 : 0)));
  }

  DateTime _getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  Future<void> _calculateTotals() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final eventNotifier = Provider.of<EventNotifier>(context, listen: false);
      final events = eventNotifier.getEventsForDateRange(
        DateTime(_now.year, 1, 1),
        _endOfYear,
      );

      // Get database instance to fetch goal allocations
      final database = getIt<Database>();

      // Reset totals with goal-aware metrics
      _totals = {
        'day': {'positive': 0, 'negative': 0, 'goalAllocations': 0, 'availableAfterGoals': 0},
        'week': {'positive': 0, 'negative': 0, 'goalAllocations': 0, 'availableAfterGoals': 0},
        'month': {'positive': 0, 'negative': 0, 'goalAllocations': 0, 'availableAfterGoals': 0},
        'year': {'positive': 0, 'negative': 0, 'goalAllocations': 0, 'availableAfterGoals': 0},
      };

      final nowDate = DateTime(_now.year, _now.month, _now.day);

      // Calculate traditional cash flows
      for (var event in events) {
        final amount = event.amount;
        final eventDate = DateTime(
            event.dateTime.year, event.dateTime.month, event.dateTime.day);

        if (!eventDate.isAfter(nowDate)) {
          _updateTotals('day', amount.abs(), amount >= 0);
        }
        if (!eventDate.isAfter(_endOfWeek)) {
          _updateTotals('week', amount.abs(), amount >= 0);
        }
        if (!eventDate.isAfter(_endOfMonth)) {
          _updateTotals('month', amount.abs(), amount >= 0);
        }
        if (!eventDate.isAfter(_endOfYear)) {
          _updateTotals('year', amount.abs(), amount >= 0);
        }
      }

      // Calculate goal allocations for each period
      await _calculateGoalAllocations(database, nowDate);

      // Calculate "Available After Goals" metrics
      _calculateAvailableAfterGoals();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating totals: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateTotals(String period, double amount, bool isPositive) {
    if (isPositive) {
      _totals[period]!['positive'] =
          (_totals[period]!['positive'] ?? 0) + amount;
    } else {
      _totals[period]!['negative'] =
          (_totals[period]!['negative'] ?? 0) + amount;
    }
  }

  Future<void> _calculateGoalAllocations(Database database, DateTime nowDate) async {
    try {
      // Get all goal allocations from database
      final allocations = await database.select(database.goalAllocations).get();
      
      for (var allocation in allocations) {
        // Get the event associated with this allocation to check its date
        final event = await (database.select(database.events)
          ..where((t) => t.id.equals(allocation.eventId))).getSingleOrNull();
        
        if (event != null) {
          final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
          final allocationAmount = allocation.allocationAmount;
          
          // Add to goal allocations for appropriate periods
          if (!eventDate.isAfter(nowDate)) {
            _totals['day']!['goalAllocations'] = (_totals['day']!['goalAllocations'] ?? 0) + allocationAmount;
          }
          if (!eventDate.isAfter(_endOfWeek)) {
            _totals['week']!['goalAllocations'] = (_totals['week']!['goalAllocations'] ?? 0) + allocationAmount;
          }
          if (!eventDate.isAfter(_endOfMonth)) {
            _totals['month']!['goalAllocations'] = (_totals['month']!['goalAllocations'] ?? 0) + allocationAmount;
          }
          if (!eventDate.isAfter(_endOfYear)) {
            _totals['year']!['goalAllocations'] = (_totals['year']!['goalAllocations'] ?? 0) + allocationAmount;
          }
        }
      }
    } catch (e) {
      print('Debug: Error calculating goal allocations: $e');
    }
  }

  void _calculateAvailableAfterGoals() {
    for (String period in ['day', 'week', 'month', 'year']) {
      final positive = _totals[period]!['positive'] ?? 0;
      final negative = _totals[period]!['negative'] ?? 0;
      final goalAllocations = _totals[period]!['goalAllocations'] ?? 0;
      
      // Available after goals = (Income - Expenses) - Goal Allocations
      final netCashFlow = positive - negative;
      final availableAfterGoals = netCashFlow - goalAllocations;
      
      _totals[period]!['availableAfterGoals'] = availableAfterGoals;
    }
  }

  Widget _buildAchievementBadge({
    required String title,
    required String description,
    required bool obtained,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: obtained ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: obtained ? Colors.green : Colors.grey,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashFlowTile({
    required String period,
    required Map<String, double> amounts,
    required DateTime date,
    required double progress,
    required bool isYearEnd,
  }) {
    final positiveAmount = amounts['positive'] ?? 0;
    final negativeAmount = amounts['negative'] ?? 0;
    final goalAllocations = amounts['goalAllocations'] ?? 0;
    final availableAfterGoals = amounts['availableAfterGoals'] ?? 0;
    final totalAmount = positiveAmount - negativeAmount;
    final isExpanded = _expandedTileId == period;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: totalAmount >= 0 ? Colors.green : Colors.red,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isExpanded ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            _expandedTileId = isExpanded ? null : period;
          }),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            period,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (isYearEnd) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.amber.shade700,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          FormatUtils.formatCurrency(totalAmount),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: totalAmount >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (goalAllocations > 0)
                          Text(
                            'After goals: ${FormatUtils.formatCurrency(availableAfterGoals)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: availableAfterGoals >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Income'),
                      Text(
                        FormatUtils.formatCurrency(positiveAmount),
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Expenses'),
                      Text(
                        FormatUtils.formatCurrency(negativeAmount),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  if (goalAllocations > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.savings, size: 16, color: Colors.blue.shade600),
                            const SizedBox(width: 4),
                            const Text('Goal Allocations'),
                          ],
                        ),
                        Text(
                          FormatUtils.formatCurrency(goalAllocations),
                          style: TextStyle(color: Colors.blue.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 4),
                            const Text('Available After Goals'),
                          ],
                        ),
                        Text(
                          FormatUtils.formatCurrency(availableAfterGoals),
                          style: TextStyle(
                            color: availableAfterGoals >= 0 ? Colors.green.shade700 : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (goalAllocations > 0 && totalAmount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Goal Impact',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text('${((goalAllocations / totalAmount.abs()) * 100).toInt()}% of cash flow'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.shade200,
                          ),
                          child: Row(
                            children: [
                              Flexible(
                                flex: ((goalAllocations / totalAmount.abs()) * 100).toInt(),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.blue.shade500,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 100 - ((goalAllocations / totalAmount.abs()) * 100).toInt(),
                                child: Container(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Savings Goal Progress'),
                          Text('${(progress * 100).toInt()}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade500,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash on Hand'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              AchievementsScreen.routeName,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(
              context,
              SettingsView.routeName,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<EventNotifier>(
          builder: (context, eventNotifier, child) {
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Progress Alert
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "You're on track to save 15% more than last month!",
                              style: TextStyle(
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cash Flow Tiles
                    _buildCashFlowTile(
                      period: 'End of Day',
                      amounts: _totals['day']!,
                      date: _now,
                      progress: 0.85,
                      isYearEnd: false,
                    ),
                    _buildCashFlowTile(
                      period: 'End of Week',
                      amounts: _totals['week']!,
                      date: _endOfWeek,
                      progress: 0.87,
                      isYearEnd: false,
                    ),
                    _buildCashFlowTile(
                      period: 'End of Month',
                      amounts: _totals['month']!,
                      date: _endOfMonth,
                      progress: 0.84,
                      isYearEnd: false,
                    ),
                    _buildCashFlowTile(
                      period: 'End of Year',
                      amounts: _totals['year']!,
                      date: _endOfYear,
                      progress: 0.75,
                      isYearEnd: true,
                    ),

                    const SizedBox(height: 24),

                    // Achievements Section
                    Text(
                      'Achievements',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildAchievementBadge(
                      title: 'Saving Starter',
                      description: 'Save your first \$1,000',
                      obtained: true,
                    ),
                    const SizedBox(height: 8),
                    _buildAchievementBadge(
                      title: 'Consistent Saver',
                      description: 'Save money 3 months in a row',
                      obtained: false,
                    ),
                  ],
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
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
