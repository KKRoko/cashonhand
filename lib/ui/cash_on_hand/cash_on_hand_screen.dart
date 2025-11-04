import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../settings/settings_view.dart';
import '../../state/event_notifier.dart';
import '../../state/category_notifier.dart';
import '../../state/achievement_state.dart';
import '../../core/di/injection.dart';
import '../../data/database/database.dart';
import '../../data/models/enums/category_type.dart';
import '../../data/models/event_creation_result.dart';
import '../../data/models/freezed/event.dart';
import '../achievements/achievement_screen.dart';
import '../dialogs/add_edit_event_dialog.dart';
import '../calendar/calendar_screen.dart';
import '../transactions/transactions_screen.dart';
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
  List<Event> _recentTransactions = [];
  double? _yearEndGoal;
  bool _isYearEndGoalLoading = true;

  // Animation controller for progress bars
  late AnimationController _progressController;
  
  // 🎯 FLICKER FIX: Manual EventNotifier listener instead of Consumer
  EventNotifier? _eventNotifier;
  
  // 🎯 FLICKER FIX: UI update suppression for Cash page
  bool _suppressCashPageUpdates = false;
  
  // 🎯 FLICKER FIX: Debounced calculation to prevent rapid rebuilds
  Timer? _calculationDebounceTimer;

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
      _eventNotifier = Provider.of<EventNotifier>(context, listen: false);
      // 🎯 FLICKER FIX: Add manual listener with suppression check
      _eventNotifier!.addListener(_onEventNotifierChanged);
      _eventNotifier!.loadInitialEvents();
      _loadYearEndGoal();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🎯 FLICKER FIX: Only get EventNotifier without listening for changes
    // We handle changes manually in _onEventNotifierChanged
    final eventNotifier = Provider.of<EventNotifier>(context, listen: false);
    final year = eventNotifier.currentYear;
    _endOfYear = DateTime(year, 12, 31);

    // 🎯 FLICKER FIX: Use debounced calculation to prevent rapid rebuilds
    // This will batch multiple rapid EventNotifier changes into a single calculation
    _debouncedCalculateTotals();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _calculationDebounceTimer?.cancel();
    // 🎯 FLICKER FIX: Remove manual listener
    _eventNotifier?.removeListener(_onEventNotifierChanged);
    super.dispose();
  }
  
  // 🎯 FLICKER FIX: Manual EventNotifier change handler with suppression
  void _onEventNotifierChanged() {
    if (_suppressCashPageUpdates) {
      print("🚫 CashPage: EventNotifier change suppressed (flag = $_suppressCashPageUpdates)");
      return;
    }
    
    print("✅ CashPage: EventNotifier change allowed - triggering debounced calculation");
    _debouncedCalculateTotals();
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

  // 🎯 FLICKER FIX: setState wrapper that respects suppression
  void _setStateIfAllowed(VoidCallback fn) {
    if (_suppressCashPageUpdates) {
      print("🚫 CashPage: setState suppressed (flag = $_suppressCashPageUpdates)");
      fn(); // Execute the function but don't trigger setState
      return;
    }
    
    print("✅ CashPage: setState allowed (flag = $_suppressCashPageUpdates)");
    setState(fn);
  }

  // 🎯 FLICKER FIX: Debounced calculation to prevent rapid successive calls
  void _debouncedCalculateTotals() {
    _calculationDebounceTimer?.cancel();
    _calculationDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      _calculateTotals();
    });
  }

  Future<void> _calculateTotals() async {
    if (_isLoading || _eventNotifier == null) return;

    _setStateIfAllowed(() {
      _isLoading = true;
    });

    try {
      final events = _eventNotifier!.getEventsForDateRange(
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
        _setStateIfAllowed(() {});
        // Load recent transactions after calculating totals
        _loadRecentTransactions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error calculating totals: $e')),
        );
      }
    } finally {
      if (mounted) {
        _setStateIfAllowed(() {
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
  
  Future<void> _loadYearEndGoal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalAmount = prefs.getDouble('year_end_goal');
      if (mounted) {
        setState(() {
          _yearEndGoal = goalAmount;
          _isYearEndGoalLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isYearEndGoalLoading = false;
        });
      }
    }
  }
  
  Future<void> _showYearEndGoalDialog() async {
    final controller = TextEditingController(
      text: _yearEndGoal?.toStringAsFixed(0) ?? '',
    );
    
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Year-End Goal',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How much cash do you want to have on hand by the end of 2025?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Goal amount',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
                prefixText: '\$',
                prefixStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (_yearEndGoal != null)
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('year_end_goal');
                Navigator.pop(context, -1.0); // Special value to indicate removal
              },
              child: Text(
                'Remove Goal',
                style: TextStyle(
                  color: DesignTokens.color('error'),
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      if (result == -1.0) {
        // Remove goal
        await prefs.remove('year_end_goal');
        setState(() {
          _yearEndGoal = null;
        });
      } else {
        // Save new goal
        await prefs.setDouble('year_end_goal', result);
        setState(() {
          _yearEndGoal = result;
        });
      }
    }
  }

  Future<void> _loadRecentTransactions() async {
    if (_eventNotifier == null) return;
    
    try {
      // Define recent days range (today and past few days, but exclude future)
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final pastWeek = today.subtract(const Duration(days: 7));
      
      print("🔍 DEBUG: Recent transactions debug info:");
      print("🔍 Now: ${now.toIso8601String()}");
      print("🔍 Today boundary: ${today.toIso8601String()}");
      print("🔍 Past week boundary: ${pastWeek.toIso8601String()}");
      
      // Get events from the past week to today (no future dates)
      final allEvents = _eventNotifier!.getEventsForDateRange(
        pastWeek,
        today.add(const Duration(hours: 23, minutes: 59, seconds: 59)), // End of today
      );
      
      print("🔍 Total events in range: ${allEvents.length}");
      
      // Filter to only include past transactions (no future dates from recurring events)
      final recentEvents = allEvents.where((event) {
        final eventDate = DateTime(event.dateTime.year, event.dateTime.month, event.dateTime.day);
        final isPastOrToday = eventDate.isBefore(today) || eventDate.isAtSameMomentAs(today);
        final isNotFuture = !eventDate.isAfter(today);
        
        print("🔍 Checking ${event.title}: eventDate=${eventDate.toIso8601String()}, isPastOrToday=$isPastOrToday, isNotFuture=$isNotFuture");
        
        return isPastOrToday && isNotFuture;
      }).toList();
      
      print("🔍 Filtered recent events (past transactions only): ${recentEvents.length}");
      
      // Sort by date (most recent first), then by creation time for same-day events
      recentEvents.sort((a, b) {
        // First compare by event date (most recent first)
        final dateComparison = b.dateTime.compareTo(a.dateTime);
        if (dateComparison != 0) {
          return dateComparison;
        }
        // If same date, sort by creation time (most recently created first)
        return b.createdAt.compareTo(a.createdAt);
      });
      
      // Debug: Print final recent transactions
      print("📅 Final recent transactions (past week, no future):");
      for (int i = 0; i < recentEvents.take(5).length; i++) {
        final event = recentEvents[i];
        print("  ${i + 1}. ${event.title} - Event: ${event.dateTime.toIso8601String()}");
      }
      
      // Take only the most recent 5 transactions from the past week
      final finalRecentEvents = recentEvents.take(5).toList();
      
      if (mounted) {
        _setStateIfAllowed(() {
          _recentTransactions = finalRecentEvents;
        });
      }
    } catch (e) {
      print('Error loading recent transactions: $e');
      if (mounted) {
        _setStateIfAllowed(() {
          _recentTransactions = [];
        });
      }
    }
  }

  Future<void> _showAddEventDialog({required bool isPositiveCashflow}) async {
    try {
      print("Starting _showAddEventDialog from Cash page");
      final categoryNotifier = context.read<CategoryNotifier>();
      if (_eventNotifier == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EventNotifier not initialized. Please wait.')),
        );
        return;
      }
      
      final categoryType = isPositiveCashflow ? CategoryType.income : CategoryType.expense;

      // Load categories directly from database to get isSystem field
      final database = getIt<Database>();
      final allCategories = await database.getCategories(type: categoryType);

      // Filter out system categories (like "Budget Surplus") but keep both parents and children
      final categories = allCategories
          .where((category) => category.isActive && !category.isSystem)
          .toList();

      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No categories found. Please add categories first.')),
        );
        return;
      }

      // Get available goals for allocation
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
        print("🚨 CashPage: Event result received, checking if recurring...");
        DateTime? firstEventDate;
        
        // 🎯 FLICKER FIX: Suppress Cash page updates during recurring event creation
        final isRecurring = result.event.isRecurring;
        print("🔍 CashPage DEBUG: isRecurring = $isRecurring, repeatOption = ${result.event.repeatOption}");
        if (isRecurring) {
          print("🚫 CashPage: Suppressing Cash page updates for recurring event");
          // Cache current body before suppression starts
          _suppressCashPageUpdates = true;
        } else {
          print("ℹ️ CashPage: Single event detected, no suppression needed");
        }
        
        try {
          if (result.allocations.isNotEmpty) {
            // Use the new method that handles allocations
            firstEventDate = await _eventNotifier!.addEventWithAllocations(result.event.dateTime, result.event, result.allocations);
            print("Event and allocations saved: ${result.allocations.length} allocations");
          } else {
            // Use the regular method for events without allocations
            firstEventDate = await _eventNotifier!.addEvent(result.event.dateTime, result.event);
          }
        } finally {
          // Note: Don't resume suppression here - wait until after calculations
        }
        print("Event added successfully from Cash page");
        
        // 🎯 FLICKER FIX: Use debounced calculation to prevent multiple rapid calculations
        _debouncedCalculateTotals();
        
        // 🎯 FLICKER FIX: Resume suppression and single final UI update for recurring events
        if (isRecurring && mounted) {
          print("✅ CashPage: Resuming Cash page updates after all calculations");
          _suppressCashPageUpdates = false;
          
          print("🎯 CashPage: Final UI update after recurring event completion");
          setState(() {}); // Single final update to show all changes
        }
        
        // Show success feedback
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.event.isRecurring
                ? 'Recurring events created! Your balance has been updated.'
                : 'Event created successfully! Your balance has been updated.'
            ),
            backgroundColor: DesignTokens.color('success'),
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
          backgroundColor: DesignTokens.color('error'),
        ),
      );
    }
  }

  // Hero Balance Section with year-end goal tracking and motivation
  Widget _buildHeroBalanceSection() {
    final currentBalance = _totals['year']!['positive']! - _totals['year']!['negative']!;
    
    // Use dynamic goal from state
    final yearEndGoal = _yearEndGoal ?? 0.0;
    final goalProgress = yearEndGoal > 0 ? currentBalance / yearEndGoal : 0.0;
    final goalDifference = currentBalance - yearEndGoal;
    
    return CashCard(
      financialContext: currentBalance >= 0 ? FinancialContext.income : FinancialContext.expense,
      elevation: 'lg',
      onTap: () => _showYearEndGoalDialog(),
      child: Container(
        padding: EdgeInsets.all(DesignTokens.space('lg')),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Cash on Hand display
            Column(
              children: [
                ResponsiveText(
                  'Cash on Hand by End of Year',
                  styleToken: 'titleMedium',
                  style: DesignTokens.textStyle('titleMedium').copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  adaptive: true,
                ),
                VSpace('md'),
                FinancialAmount(
                  amount: currentBalance,
                  size: FinancialAmountSize.large,
                  style: DesignTokens.responsiveTextStyle('displayLarge', context).copyWith(
                    fontSize: DesignTokens.responsiveTextStyle('displayLarge', context).fontSize! * 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                  adaptive: true,
                ),
              ],
            ),
            
            if (yearEndGoal > 0) ...[
              VSpace('lg'),
              // Goal progress section
              Container(
                padding: EdgeInsets.all(DesignTokens.space('md')),
                decoration: BoxDecoration(
                  color: DesignTokens.color('income').withOpacity(0.1),
                  borderRadius: DesignTokens.borderRadius['md']!,
                  border: Border.all(
                    color: DesignTokens.color('income').withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Goal info header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              color: DesignTokens.color('income'),
                              size: 18,
                            ),
                            HSpace('xs'),
                            ResponsiveText(
                              'Year-End Goal',
                              styleToken: 'labelMedium',
                              style: DesignTokens.textStyle('labelMedium').copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        FinancialAmount(
                          amount: yearEndGoal,
                          size: FinancialAmountSize.medium,
                          showSign: false,
                          adaptive: true,
                        ),
                      ],
                    ),
                    VSpace('md'),
                    
                    // Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ResponsiveText(
                              goalProgress >= 1.0 ? 'Goal Achieved! 🎉' : 'Progress',
                              styleToken: 'labelSmall',
                              style: DesignTokens.textStyle('labelSmall').copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ResponsiveText(
                              '${(goalProgress * 100).toStringAsFixed(0)}%',
                              styleToken: 'labelSmall',
                              style: DesignTokens.textStyle('labelSmall').copyWith(
                                color: currentBalance >= 0 
                                    ? DesignTokens.color('income') 
                                    : DesignTokens.color('expense'),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        VSpace('xs'),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: DesignTokens.borderRadius['xs']!,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (goalProgress > 1.0 ? 1.0 : goalProgress.abs()).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: DesignTokens.borderRadius['xs']!,
                                gradient: LinearGradient(
                                  colors: currentBalance < 0
                                      ? [DesignTokens.color('expense'), DesignTokens.color('expense').withOpacity(0.8)]
                                      : goalProgress >= 1.0
                                          ? [DesignTokens.color('income'), DesignTokens.color('income').withOpacity(0.8)]
                                          : goalProgress >= 0.75
                                              ? [DesignTokens.color('info'), DesignTokens.color('info').withOpacity(0.8)]
                                              : goalProgress >= 0.50
                                                  ? [DesignTokens.color('warning'), DesignTokens.color('warning').withOpacity(0.8)]
                                                  : [DesignTokens.color('error'), DesignTokens.color('error').withOpacity(0.8)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            VSpace('md'),
            // Tap hint
            Center(
              child: ResponsiveText(
                yearEndGoal > 0 ? 'Tap to change your goal' : 'Tap to set year-end goal',
                styleToken: 'labelSmall',
                style: DesignTokens.textStyle('labelSmall').copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Quick Action Buttons"}]
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: FinancialButton(
            onPressed: () => _showAddEventDialog(isPositiveCashflow: true),
            financialType: FinancialButtonType.income,
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
      {'key': 'day', 'title': 'End of Day', 'subtitle': 'Daily'},
      {'key': 'week', 'title': 'End of Week', 'subtitle': 'Weekly'},
      {'key': 'month', 'title': 'End of Month', 'subtitle': 'Monthly'},
      {'key': 'year', 'title': 'End of Year', 'subtitle': 'Yearly'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Projected from Jan 1',
          styleToken: 'titleLarge',
        ),
        VSpace('md'),
        SizedBox(
          height: 140, // Increased height to prevent overflow
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
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: DesignTokens.space('sm'),
                      horizontal: DesignTokens.space('xs'),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ResponsiveText(
                          period['title'] as String,
                          styleToken: 'titleSmall',
                          textAlign: TextAlign.center,
                          maxWidth: 120,
                          maxLines: 1,
                          minFontSize: 12,
                          maxFontSize: 16,
                        ),
                        SizedBox(height: DesignTokens.space('xs') / 2), // Reduced spacing
                        Flexible(
                          child: FinancialAmount(
                            amount: total,
                            size: FinancialAmountSize.medium,
                            maxWidth: 120,
                            adaptive: true,
                          ),
                        ),
                        SizedBox(height: DesignTokens.space('xs') / 2), // Reduced spacing
                        ResponsiveText(
                          period['subtitle'] as String,
                          styleToken: 'bodySmall',
                          style: DesignTokens.textStyle('bodySmall').copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          maxWidth: 120,
                          maxLines: 1,
                          minFontSize: 10,
                          maxFontSize: 12,
                        ),
                      ],
                    ),
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
                // Navigate to Transactions page to view full transaction history
                Navigator.pushNamed(context, TransactionsScreen.routeName);
              },
              child: ResponsiveText(
                'View All',
                styleToken: 'labelMedium',
                style: DesignTokens.textStyle('labelMedium').copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                maxWidth: 60,
              ),
            ),
          ],
        ),
        VSpace('md'),
        CashCard(
          child: _recentTransactions.isEmpty
              ? Padding(
                  padding: EdgeInsets.all(DesignTokens.space('lg')),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      VSpace('md'),
                      ResponsiveText(
                        'No recent transactions',
                        styleToken: 'bodyMedium',
                        style: DesignTokens.textStyle('bodyMedium').copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      VSpace('xs'),
                      ResponsiveText(
                        'Add your first transaction using the buttons above',
                        styleToken: 'bodySmall',
                        style: DesignTokens.textStyle('bodySmall').copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: _recentTransactions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final transaction = entry.value;
                    return Column(
                      children: [
                        _buildTransactionItem(transaction: transaction),
                        if (index < _recentTransactions.length - 1)
                          Divider(
                            color: Theme.of(context).colorScheme.outline,
                            height: 1,
                          ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
  
  Widget _buildTransactionItem({
    required Event transaction,
  }) {
    // Format the date relative to today
    String formatRelativeDate(DateTime transactionDate) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final transactionDay = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
      
      final difference = today.difference(transactionDay).inDays;
      
      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Yesterday';
      } else if (difference < 7) {
        return '$difference days ago';
      } else {
        return '${transactionDate.month}/${transactionDate.day}/${transactionDate.year}';
      }
    }

    // Get appropriate icon based on transaction type and amount
    IconData getTransactionIcon() {
      if (transaction.isPositiveCashflow) {
        // For income, use a general income icon or try to determine from category
        return Icons.trending_up;
      } else {
        // For expenses, try to guess icon from category name or use general expense icon
        final categoryName = 'Unknown'; // We'll get this from the category lookup
        return Icons.trending_down;
      }
    }

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
              color: (transaction.isPositiveCashflow 
                  ? DesignTokens.color('incomeLight') 
                  : DesignTokens.color('expenseLight')
              ).withOpacity(0.2),
              borderRadius: DesignTokens.radius('sm'),
            ),
            child: Icon(
              getTransactionIcon(),
              color: transaction.isPositiveCashflow 
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
                  transaction.title,
                  styleToken: 'bodyMedium',
                  style: DesignTokens.textStyle('bodyMedium').copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
                FutureBuilder<String>(
                  future: _getCategoryName(transaction.categoryId),
                  builder: (context, snapshot) {
                    final categoryName = snapshot.data ?? 'Unknown';
                    return ResponsiveText(
                      '$categoryName • ${formatRelativeDate(transaction.dateTime)}',
                      styleToken: 'bodySmall',
                      style: DesignTokens.textStyle('bodySmall').copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                    );
                  },
                ),
              ],
            ),
          ),
          FinancialAmount(
            amount: transaction.amount,
            size: FinancialAmountSize.medium,
            adaptive: true,
            maxWidth: 80, // Constrain width to prevent overflow
          ),
        ],
      ),
    );
  }

  Future<String> _getCategoryName(int categoryId) async {
    try {
      final database = getIt<Database>();
      final category = await database.getCategoryById(categoryId);
      return category?.name ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }
  
  // Achievement Highlights (Horizontal Chips)
  Widget _buildAchievementHighlights() {
    final achievementNotifier = getIt<AchievementNotifier>();
    
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
                  color: Theme.of(context).colorScheme.primary,
                ),
                maxWidth: 60,
              ),
            ),
          ],
        ),
        VSpace('md'),
        SizedBox(
          height: 50,
          child: ListenableBuilder(
            listenable: achievementNotifier,
            builder: (context, _) {
              if (achievementNotifier.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              // Get the most recent achievements (mix of unlocked and in-progress)
              final recentAchievements = [
                ...achievementNotifier.unlockedAchievements.take(2),
                ...achievementNotifier.inProgressAchievements.take(2),
              ].take(4).toList();
              
              if (recentAchievements.isEmpty) {
                return Center(
                  child: Text(
                    'No achievements yet',
                    style: DesignTokens.textStyle('bodyMedium').copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = recentAchievements[index];
                  
                  return Container(
                    margin: EdgeInsets.only(
                      right: index < recentAchievements.length - 1 ? DesignTokens.space('sm') : 0,
                    ),
                    child: CategoryChip(
                      name: achievement.title,
                      icon: _getAchievementIcon(achievement.title),
                      financialContext: achievement.isUnlocked 
                          ? FinancialContext.income 
                          : FinancialContext.neutral,
                      selected: achievement.isUnlocked,
                      size: ChipSize.medium,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  String _getAchievementIcon(String achievementTitle) {
    // Map achievement titles to appropriate emoji icons
    final title = achievementTitle.toLowerCase();
    
    if (title.contains('saving') || title.contains('saver')) return '💰';
    if (title.contains('goal') || title.contains('target')) return '🎯';
    if (title.contains('streak') || title.contains('consistent')) return '🔥';
    if (title.contains('budget') || title.contains('pro')) return '📈';
    if (title.contains('first') || title.contains('starter')) return '🌟';
    if (title.contains('monthly') || title.contains('month')) return '📅';
    if (title.contains('milestone') || title.contains('achievement')) return '🏆';
    if (title.contains('discipline') || title.contains('master')) return '💪';
    if (title.contains('income') || title.contains('earn')) return '💵';
    if (title.contains('expense') || title.contains('spend')) return '💳';
    
    return '⭐'; // Default icon
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => Container(
        padding: EdgeInsets.all(DesignTokens.space('lg')),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: (DesignTokens.borderRadius['lg']!).topLeft,
          ),
        ),
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
                    ResponsiveText(
                      'Income',
                      styleToken: 'labelMedium',
                      textAlign: TextAlign.center,
                    ),
                    VSpace('xs'),
                    FinancialAmount(amount: amounts['positive']!, showSign: false),
                  ],
                ),
                Column(
                  children: [
                    ResponsiveText(
                      'Expenses',
                      styleToken: 'labelMedium',
                      textAlign: TextAlign.center,
                    ),
                    VSpace('xs'),
                    FinancialAmount(
                      amount: -amounts['negative']!,
                      showSign: false,
                    ),
                  ],
                ),
                Column(
                  children: [
                    ResponsiveText(
                      'Net',
                      styleToken: 'labelMedium',
                      textAlign: TextAlign.center,
                    ),
                    VSpace('xs'),
                    FinancialAmount(
                      amount: amounts['positive']! - amounts['negative']!,
                    ),
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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(DesignTokens.space('lg')),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Balance Section with Year-End Goal
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
        ),
      ),
    );
  }
}
