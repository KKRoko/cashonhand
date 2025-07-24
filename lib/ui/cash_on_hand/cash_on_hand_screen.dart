import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../settings/settings_view.dart';
import '../../state/event_notifier.dart';
import '../../state/category_notifier.dart';
import '../../core/di/injection.dart';
import '../../data/database/database.dart';
import '../../data/models/enums/category_type.dart';
import '../../data/models/event_creation_result.dart';
import '../achievements/achievement_screen.dart';
import '../dialogs/add_edit_event_dialog.dart';
import '../calendar/calendar_screen.dart';
import '../../theme/design_tokens.dart';
import '../components/cash_components.dart';

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
      // Error calculating goal allocations: $e
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

  Future<void> _showAddEventDialog({required bool isPositiveCashflow}) async {
    try {
      print("Starting _showAddEventDialog from Cash page");
      final categoryNotifier = context.read<CategoryNotifier>();
      final eventNotifier = context.read<EventNotifier>();
      
      final categoryType = isPositiveCashflow ? CategoryType.income : CategoryType.expense;
      final categories = categoryNotifier.getCategoriesByType(categoryType)
          .map((category) => CategoryTableData(
                id: category.id,
                name: category.name,
                type: category.type,
                parentCategoryId: null,
                icon: null,
                sortOrder: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .toList();

      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No categories found. Please add categories first.')),
        );
        return;
      }

      // Get available goals for allocation
      final database = getIt<Database>();
      final availableGoals = await database.getActiveGoals();
      print("Debug: Found ${availableGoals.length} active goals for allocation");
      
      // Use current date as the selected day
      final selectedDay = DateTime.now();
      
      print("About to show AddEditEventDialog from Cash page");
      final result = await showDialog<EventCreationResult>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AddEditEventDialog(
            selectedDay: selectedDay,
            isPositiveCashflow: isPositiveCashflow,
            categories: categories,
            availableGoals: availableGoals,
          );
        },
      );

      print("Dialog result: ${result != null ? 'event created with ${result.allocations.length} allocations' : 'cancelled'}");
      if (result != null) {
        DateTime? firstEventDate;
        
        if (result.allocations.isNotEmpty) {
          // Use the new method that handles allocations
          firstEventDate = await eventNotifier.addEventWithAllocations(selectedDay, result.event, result.allocations);
          print("Event and allocations saved: ${result.allocations.length} allocations");
        } else {
          // Use the regular method for events without allocations
          firstEventDate = await eventNotifier.addEvent(selectedDay, result.event);
        }
        print("Event added successfully from Cash page");
        
        // Refresh the cash totals after adding the event
        _calculateTotals();
        
        // Show success feedback
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.event.isRecurring 
                ? 'Recurring events created! Your balance has been updated.'
                : 'Event created successfully! Your balance has been updated.'
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      print("Error in _showAddEventDialog from Cash page: $e");
      print("Stack trace: $stackTrace");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Hero Balance Section with large current balance and trend
  Widget _buildHeroBalanceSection() {
    final currentBalance = _totals['month']!['positive']! - _totals['month']!['negative']!;
    final previousBalance = currentBalance * 0.85; // Mock previous month data
    final trend = currentBalance - previousBalance;
    final trendPercentage = previousBalance != 0 ? ((trend / previousBalance) * 100) : 0;
    
    return CashCard(
      financialContext: currentBalance >= 0 ? FinancialContext.income : FinancialContext.expense,
      elevation: 'lg',
      child: Column(
        children: [
          // Current Balance
          ResponsiveText(
            'Current Balance',
            styleToken: 'titleMedium',
            style: DesignTokens.textStyle('titleMedium').copyWith(
              color: DesignTokens.color('textSecondary'),
            ),
            textAlign: TextAlign.center,
          ),
          VSpace('sm'),
          FinancialAmount(
            amount: currentBalance,
            size: FinancialAmountSize.large,
            style: DesignTokens.responsiveTextStyle('displayMedium', context),
            adaptive: true,
          ),
          VSpace('md'),
          
          // Trend Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                trend >= 0 ? Icons.trending_up : Icons.trending_down,
                color: trend >= 0 ? DesignTokens.color('income') : DesignTokens.color('expense'),
                size: 20,
              ),
              HSpace('xs'),
              FinancialAmount(
                amount: trend,
                size: FinancialAmountSize.small,
              ),
              HSpace('xs'),
              ResponsiveText(
                '(${trendPercentage.toStringAsFixed(1)}%)',
                styleToken: 'bodySmall',
                style: DesignTokens.textStyle('bodySmall').copyWith(
                  color: trend >= 0 ? DesignTokens.color('income') : DesignTokens.color('expense'),
                ),
                maxWidth: 80,
              ),
            ],
          ),
          VSpace('sm'),
          ResponsiveText(
            'vs last month',
            styleToken: 'bodySmall',
            style: DesignTokens.textStyle('bodySmall').copyWith(
              color: DesignTokens.color('textTertiary'),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // Quick Action Buttons
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: FinancialButton(
            onPressed: () => _showAddEventDialog(isPositiveCashflow: true),
            financialType: FinancialButtonType.income,
            icon: Icons.add,
            size: ButtonSize.large,
            child: ResponsiveText(
              'Add Income',
              styleToken: 'labelLarge',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        HSpace('md'),
        Expanded(
          child: FinancialButton(
            onPressed: () => _showAddEventDialog(isPositiveCashflow: false),
            financialType: FinancialButtonType.expense,
            icon: Icons.remove,
            size: ButtonSize.large,
            child: ResponsiveText(
              'Add Expense',
              styleToken: 'labelLarge',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
  
  // Time Period Mini Cards (Horizontal Scroll)
  Widget _buildTimePeriodSection() {
    final periods = [
      {'key': 'day', 'title': 'Today', 'subtitle': 'Daily'},
      {'key': 'week', 'title': 'This Week', 'subtitle': 'Weekly'},
      {'key': 'month', 'title': 'This Month', 'subtitle': 'Monthly'},
      {'key': 'year', 'title': 'This Year', 'subtitle': 'Yearly'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Time Periods',
          styleToken: 'titleLarge',
        ),
        VSpace('md'),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: periods.length,
            itemBuilder: (context, index) {
              final period = periods[index];
              final amounts = _totals[period['key']]!;
              final total = amounts['positive']! - amounts['negative']!;
              
              return Container(
                width: 140,
                margin: EdgeInsets.only(
                  right: index < periods.length - 1 ? DesignTokens.space('md') : 0,
                ),
                child: CashCard(
                  financialContext: total >= 0 
                      ? FinancialContext.income 
                      : total < 0 
                          ? FinancialContext.expense 
                          : FinancialContext.neutral,
                  onTap: () => _toggleExpanded(period['key'] as String),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveText(
                        period['title'] as String,
                        styleToken: 'titleSmall',
                        textAlign: TextAlign.center,
                        maxWidth: 120, // Constrain width to prevent overflow
                      ),
                      VSpace('xs'),
                      FinancialAmount(
                        amount: total,
                        size: FinancialAmountSize.medium,
                        maxWidth: 120, // Prevent amount from overflowing card
                        adaptive: true,
                      ),
                      VSpace('xs'),
                      ResponsiveText(
                        period['subtitle'] as String,
                        styleToken: 'bodySmall',
                        style: DesignTokens.textStyle('bodySmall').copyWith(
                          color: DesignTokens.color('textSecondary'),
                        ),
                        textAlign: TextAlign.center,
                        maxWidth: 120,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Recent Transactions Preview
  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveText(
              'Recent Activity',
              styleToken: 'titleLarge',
            ),
            TextButton(
              onPressed: () {
                // Navigate to Calendar page to view full transaction history
                Navigator.pushNamed(context, CalendarScreen.routeName);
              },
              child: ResponsiveText(
                'View All',
                styleToken: 'labelMedium',
                style: DesignTokens.textStyle('labelMedium').copyWith(
                  color: DesignTokens.color('primary'),
                ),
                maxWidth: 60,
              ),
            ),
          ],
        ),
        VSpace('md'),
        CashCard(
          child: Column(
            children: [
              _buildTransactionItem(
                title: 'Salary Payment',
                category: 'Income',
                amount: 3500.00,
                date: 'Today',
                icon: Icons.attach_money,
              ),
              Divider(
                color: DesignTokens.color('border'),
                height: 1,
              ),
              _buildTransactionItem(
                title: 'Grocery Shopping',
                category: 'Food',
                amount: -87.50,
                date: 'Yesterday',
                icon: Icons.shopping_cart,
              ),
              Divider(
                color: DesignTokens.color('border'),
                height: 1,
              ),
              _buildTransactionItem(
                title: 'Coffee',
                category: 'Food',
                amount: -4.25,
                date: '2 days ago',
                icon: Icons.local_cafe,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransactionItem({
    required String title,
    required String category,
    required double amount,
    required String date,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: DesignTokens.space('sm'),
        horizontal: DesignTokens.space('xs'),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(DesignTokens.space('sm')),
            decoration: BoxDecoration(
              color: (amount >= 0 
                  ? DesignTokens.color('incomeLight') 
                  : DesignTokens.color('expenseLight')
              ).withOpacity(0.2),
              borderRadius: DesignTokens.radius('sm'),
            ),
            child: Icon(
              icon,
              color: amount >= 0 
                  ? DesignTokens.color('income') 
                  : DesignTokens.color('expense'),
              size: 20,
            ),
          ),
          HSpace('md'),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  title,
                  styleToken: 'bodyMedium',
                  style: DesignTokens.textStyle('bodyMedium').copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
                ResponsiveText(
                  '$category • $date',
                  styleToken: 'bodySmall',
                  style: DesignTokens.textStyle('bodySmall').copyWith(
                    color: DesignTokens.color('textSecondary'),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          FinancialAmount(
            amount: amount,
            size: FinancialAmountSize.medium,
            adaptive: true,
            maxWidth: 80, // Constrain width to prevent overflow
          ),
        ],
      ),
    );
  }
  
  // Achievement Highlights (Horizontal Chips)
  Widget _buildAchievementHighlights() {
    final achievements = [
      {'title': 'Saving Starter', 'icon': Icons.savings, 'obtained': true},
      {'title': 'Goal Achiever', 'icon': Icons.flag, 'obtained': true},
      {'title': 'Streak Master', 'icon': Icons.local_fire_department, 'obtained': false},
      {'title': 'Budget Pro', 'icon': Icons.timeline, 'obtained': false},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveText(
              'Achievements',
              styleToken: 'titleLarge',
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(
                context,
                AchievementsScreen.routeName,
              ),
              child: ResponsiveText(
                'View All',
                styleToken: 'labelMedium',
                style: DesignTokens.textStyle('labelMedium').copyWith(
                  color: DesignTokens.color('primary'),
                ),
                maxWidth: 60,
              ),
            ),
          ],
        ),
        VSpace('md'),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              final obtained = achievement['obtained'] as bool;
              
              return Container(
                margin: EdgeInsets.only(
                  right: index < achievements.length - 1 ? DesignTokens.space('sm') : 0,
                ),
                child: CategoryChip(
                  name: achievement['title'] as String,
                  icon: _getIconString(achievement['icon'] as IconData),
                  financialContext: obtained 
                      ? FinancialContext.income 
                      : FinancialContext.neutral,
                  selected: obtained,
                  size: ChipSize.medium,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  String _getIconString(IconData icon) {
    if (icon == Icons.savings) return '💰';
    if (icon == Icons.flag) return '🏁';
    if (icon == Icons.local_fire_department) return '🔥';
    if (icon == Icons.timeline) return '📈';
    return '⭐';
  }
  
  void _toggleExpanded(String periodKey) {
    setState(() {
      _expandedTileId = _expandedTileId == periodKey ? null : periodKey;
    });
    
    // Show detailed breakdown in a bottom sheet or dialog
    _showPeriodDetails(periodKey);
  }
  
  void _showPeriodDetails(String periodKey) {
    final amounts = _totals[periodKey]!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(DesignTokens.space('lg')),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ResponsiveText(
              '${periodKey.toUpperCase()} BREAKDOWN',
              styleToken: 'titleLarge',
              textAlign: TextAlign.center,
            ),
            VSpace('lg'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    ResponsiveText('Income', styleToken: 'labelMedium', textAlign: TextAlign.center),
                    VSpace('xs'),
                    FinancialAmount(amount: amounts['positive']!, showSign: false),
                  ],
                ),
                Column(
                  children: [
                    ResponsiveText('Expenses', styleToken: 'labelMedium', textAlign: TextAlign.center),
                    VSpace('xs'),
                    FinancialAmount(amount: amounts['negative']!, showSign: false),
                  ],
                ),
                Column(
                  children: [
                    ResponsiveText('Net', styleToken: 'labelMedium', textAlign: TextAlign.center),
                    VSpace('xs'),
                    FinancialAmount(amount: amounts['positive']! - amounts['negative']!),
                  ],
                ),
              ],
            ),
            VSpace('xl'),
            SecondaryButton(
              onPressed: () => Navigator.pop(context),
              child: ResponsiveText('Close', styleToken: 'labelLarge', textAlign: TextAlign.center),
            ),
          ],
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
                SingleChildScrollView(
                  padding: EdgeInsets.all(DesignTokens.space('lg')),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Balance Section with Trend
                      _buildHeroBalanceSection(),
                      VSpace('xl'),
                      
                      // Quick Action Buttons
                      _buildQuickActions(),
                      VSpace('xl'),
                      
                      // Time Period Mini Cards (Horizontal Scroll)
                      _buildTimePeriodSection(),
                      VSpace('xl'),
                      
                      // Recent Transactions Preview
                      _buildRecentTransactionsSection(),
                      VSpace('xl'),
                      
                      // Achievement Highlights (Horizontal Chips)
                      _buildAchievementHighlights(),
                      
                      // Add bottom padding for safe area
                      VSpace('2xl'),
                    ],
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: DesignTokens.color('overlay'),
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
