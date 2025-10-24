import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/di/injection.dart';
import '../../app.dart'; // Import for TabChangeNotifier
import '../../data/database/database.dart';
import '../../data/models/enums/category_type.dart';
import '../../data/models/enums/edit_option.dart';
import '../../data/models/freezed/event.dart';
import '../../data/models/freezed/goal_allocation.dart';
import '../../data/models/event_creation_result.dart';
import '../../theme/design_tokens.dart';
import '../components/cash_components.dart';
import '../dialogs/add_edit_event_dialog.dart';
import '../dialogs/delete_event_dialog.dart' show showDeleteEventDialog;
import '../dialogs/edit_scope_dialog.dart';
import '../../state/event_notifier.dart';
import '../../state/category_notifier.dart';
import '../../state/saving_goal_notifier.dart';
import 'widgets/index.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar';
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with WidgetsBindingObserver {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  bool _isDatabaseInitialized = false;
  late Database _database;
  bool _hasBeenInitialized = false;
  DateTime _lastResetCheck = DateTime.now();
  bool _isUserScrolling = false;
  
  // 🎯 FLICKER FIX: Key to access CalendarWidget state
  final GlobalKey<EnhancedCalendarWidgetState> _calendarWidgetKey = GlobalKey<EnhancedCalendarWidgetState>();

  @override
  void initState() {
    super.initState();
    print('🏁 CALENDAR INIT: CalendarScreen initState called');
    
    // Always reset to current date when initializing calendar
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
    _database = getIt<Database>();
    _hasBeenInitialized = true;
    
    print('🏁 CALENDAR INIT: Initialized to ${now.day}/${now.month}/${now.year}');
    
    // Add this screen as observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    
    // Listen to tab changes for proper navigation detection
    globalTabNotifier.addListener(_onTabChanged);
    
    _initializeDatabase();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    print('🔄 APP LIFECYCLE DEBUG: State changed to $state');
    print('  - Has been initialized: $_hasBeenInitialized');
    print('  - Current focused day: ${_focusedDay.day}/${_focusedDay.month}/${_focusedDay.year}');
    print('  - Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}');
    
    // Reset calendar when app becomes active (covers navigation between pages)
    if (state == AppLifecycleState.resumed && _hasBeenInitialized) {
      print('  - ✅ App resumed and initialized - triggering calendar reset');
      _resetCalendarToCurrentDate();
    } else {
      print('  - ❌ No reset needed for this lifecycle change');
    }
  }
  
  
  // Handle tab change notifications from the global tab notifier
  void _onTabChanged() {
    if (!mounted) return;
    
    final now = DateTime.now();
    final isCalendarNowVisible = globalTabNotifier.isCalendarVisible;
    final didNavigateToCalendar = globalTabNotifier.didNavigateToCalendar;
    
    print('🔄 TAB CHANGE CALLBACK: Tab change detected');
    print('  - Is calendar now visible: $isCalendarNowVisible');
    print('  - Did navigate TO calendar: $didNavigateToCalendar');
    print('  - Current tab: ${globalTabNotifier.currentTabIndex}');
    print('  - Previous tab: ${globalTabNotifier.previousTabIndex}');
    print('  - Current focused day: ${_focusedDay.day}/${_focusedDay.month}/${_focusedDay.year}');
    print('  - Today: ${now.day}/${now.month}/${now.year}');
    
    // Only reset when navigating TO the calendar (not away from it)
    if (didNavigateToCalendar && _hasBeenInitialized) {
      final needsReset = (_focusedDay.day != now.day || _focusedDay.month != now.month || _focusedDay.year != now.year);
      
      print('  - Needs reset: $needsReset');
      print('  - Is user scrolling: $_isUserScrolling');
      
      if (needsReset && !_isUserScrolling) {
        print('  - ✅ TAB NAVIGATION TO CALENDAR - Resetting to current date');
        _resetCalendarToCurrentDate();
      } else {
        print('  - ❌ No reset needed (already current date or user scrolling)');
      }
    } else {
      print('  - ❌ Not navigating to calendar or not initialized, no action needed');
    }
  }

  void _resetCalendarToCurrentDate() {
    if (!mounted) {
      print('🔄 CALENDAR RESET: Widget not mounted, skipping reset');
      return;
    }
    
    final now = DateTime.now();
    final needsReset = _focusedDay.day != now.day || _focusedDay.month != now.month || _focusedDay.year != now.year;
    
    print('🔄 CALENDAR RESET: Executing reset');
    print('  - Current focused: ${_focusedDay.day}/${_focusedDay.month}/${_focusedDay.year}');
    print('  - Resetting to: ${now.day}/${now.month}/${now.year}');
    print('  - Needs reset: $needsReset');
    
    if (needsReset) {
      print('  - ✅ RESETTING calendar to current date');
      setState(() {
        _focusedDay = now;
        _selectedDay = now;
      });
      
      // Load events for today when resetting
      if (_isDatabaseInitialized) {
        print('  - 📅 Loading events for today');
        context.read<EventNotifier>().loadEventsForDay(now);
      } else {
        print('  - ⏳ Database not initialized, skipping event loading');
      }
    } else {
      print('  - ℹ️ Calendar already on current date, no reset needed');
    }
  }

  Future<void> _initializeDatabase() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final categoryCount = await _database
          .getCategoryCount()
          .timeout(const Duration(seconds: 5));

      if (categoryCount == 0) {
        print("No categories found, adding defaults");
        await _database.ensureDefaultCategories();
      } else {
        print("Categories already exist: $categoryCount");
      }

      if (mounted) {
        setState(() {
          _isDatabaseInitialized = true;
          _isLoading = false;
        });

        // Initialize data through notifiers
        context.read<EventNotifier>().loadInitialEvents();
        context.read<CategoryNotifier>().loadCategories();
        
        // Load events for the currently selected day
        if (_selectedDay != null) {
          context.read<EventNotifier>().loadEventsForDay(_selectedDay!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database initialization failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _initializeDatabase,
            ),
          ),
        );
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    
    // Load events for the selected day
    context.read<EventNotifier>().loadEventsForDay(selectedDay);
  }

  void _onFormatChanged(CalendarFormat format) {
    // Calendar is locked to month view only - no format changes allowed
  }

  void _onPageChanged(DateTime focusedDay) {
    print('🔄 MONTH SCROLL DEBUG: Calendar page changed');
    print('  - From: ${_focusedDay.month}/${_focusedDay.year}');
    print('  - To: ${focusedDay.month}/${focusedDay.year}');
    print('  - Setting user scrolling flag to prevent reset');
    
    _isUserScrolling = true;
    _lastResetCheck = DateTime.now(); // Update last check to prevent reset during scrolling
    
    setState(() {
      _focusedDay = focusedDay;
      
      // Update selected day to be in the new month to keep event list relevant
      if (_selectedDay != null) {
        final currentSelectedDay = _selectedDay!.day;
        final newMonth = focusedDay.month;
        final newYear = focusedDay.year;
        
        // Try to keep the same day of month, but ensure it's valid for the new month
        final daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
        final validDay = currentSelectedDay <= daysInNewMonth ? currentSelectedDay : daysInNewMonth;
        
        _selectedDay = DateTime(newYear, newMonth, validDay);
        
        print('  - Updated selected day to: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}');
        print('  - Loading events for new selected day');
        
        // Load events for the new selected day
        context.read<EventNotifier>().loadEventsForDay(_selectedDay!);
      }
    });
    
    // Clear the scrolling flag after a delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      print('  - 🔄 Clearing user scrolling flag - resets now allowed again');
      _isUserScrolling = false;
    });
  }

  Future<void> _showAddEventDialog({required bool isPositiveCashflow}) async {
    if (!_isDatabaseInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database not initialized. Please wait or restart the app.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print("Starting _showAddEventDialog");
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
          isActive: true,
          isSystem: false,
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
      
      print("About to show AddEditEventDialog");
      final result = await showDialog<EventCreationResult>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AddEditEventDialog(
            selectedDay: _selectedDay!,
            isPositiveCashflow: isPositiveCashflow,
            categories: categories,
            availableGoals: availableGoals,
          );
        },
      );

      print("Dialog result: ${result != null ? 'event created with ${result.allocations.length} allocations' : 'cancelled'}");
      if (result != null) {
        DateTime? firstEventDate;
        
        // 🎯 FLICKER FIX: Suppress CalendarWidget updates during recurring event creation
        final isRecurring = result.event.isRecurring;
        if (isRecurring) {
          print("🚫 CalendarScreen: Suppressing CalendarWidget updates for recurring event");
          _calendarWidgetKey.currentState?.suppressUpdates();
        }
        
        try {
          if (result.allocations.isNotEmpty) {
            // Use the new method that handles allocations
            firstEventDate = await eventNotifier.addEventWithAllocations(result.event.dateTime, result.event, result.allocations);
            print("Event and allocations saved: ${result.allocations.length} allocations");
          } else {
            // Use the regular method for events without allocations
            firstEventDate = await eventNotifier.addEvent(result.event.dateTime, result.event);
          }
        } finally {
          // 🎯 FLICKER FIX: Resume CalendarWidget updates
          if (isRecurring) {
            print("✅ CalendarScreen: Resuming CalendarWidget updates after recurring event");
            _calendarWidgetKey.currentState?.resumeUpdates();
          }
        }
        print("Event added successfully");
        
        // Navigate to the month where the first event was created
        if (firstEventDate != null && mounted) {
          setState(() {
            _focusedDay = firstEventDate!;
            _selectedDay = firstEventDate;
          });
          
          // Show feedback about where events were created
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.event.isRecurring 
                  ? 'Recurring events created! First event on ${firstEventDate.day}/${firstEventDate.month}/${firstEventDate.year}'
                  : 'Event created successfully!'
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print("Error in _showAddEventDialog: $e");
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

  Future<void> _showEditEventDialog(Event event) async {
    final categoryNotifier = context.read<CategoryNotifier>();
    final eventNotifier = context.read<EventNotifier>();
    
    final categoryType = event.isPositiveCashflow ? CategoryType.income : CategoryType.expense;
    final categories = categoryNotifier.getCategoriesByType(categoryType)
        .map((category) => CategoryTableData(
              id: category.id,
              name: category.name,
              type: category.type,
              parentCategoryId: null,
              icon: null,
              sortOrder: 0,
              isActive: true,
              isSystem: false,
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
    print("Debug: Found ${availableGoals.length} active goals for edit dialog");
    
    final result = await showDialog<EventCreationResult>(
      context: context,
      builder: (BuildContext context) {
        return AddEditEventDialog(
          selectedDay: _selectedDay!,
          event: event,
          isPositiveCashflow: event.isPositiveCashflow,
          categories: categories,
          availableGoals: availableGoals,
        );
      },
    );

    if (result != null) {
      final editedEvent = result.event;
      final allocations = result.allocations;
      
      // Handle allocation updates in edit scenario
      // Always show scope dialog for all events (both single and recurring)
      await _handleEventEdit(event, editedEvent, allocations);
    }
  }

  Future<void> _handleEventEdit(Event originalEvent, Event editedEvent, List<GoalAllocation> allocations) async {
    final eventNotifier = context.read<EventNotifier>();
    
    // Get edit impact counts for the dialog (works for both single and recurring events)
    final impactResult = await eventNotifier.getEditImpactCounts(originalEvent, _selectedDay!);
    
    Map<String, int> impactCounts = {'total': 0, 'future': 0, 'past': 0};
    impactResult.fold(
      (failure) {
        print('Failed to get impact counts: ${failure.message}');
        // For single events or on failure, set counts to indicate single event
        impactCounts = {'total': 1, 'future': 0, 'past': 0};
      },
      (counts) {
        impactCounts = counts;
      },
    );

    // Show edit scope dialog for all events (single and recurring)
    final hasAllocationChanges = allocations.isNotEmpty;
    final editOption = await showEditScopeDialog(
      context: context,
      event: originalEvent,
      selectedDate: _selectedDay!,
      totalEventsInSeries: impactCounts['total'] ?? 1,
      futureEventsCount: impactCounts['future'] ?? 0,
      pastEventsCount: impactCounts['past'] ?? 0,
      hasAllocationChanges: hasAllocationChanges,
    );

    if (editOption != null) {
      if (originalEvent.isRecurring || impactCounts['total']! > 1) {
        // Use scoped update for recurring events
        if (allocations.isNotEmpty) {
          // Use the new method that handles allocations
          await eventNotifier.updateEventWithScopeAndAllocations(_selectedDay!, originalEvent, editedEvent, editOption, allocations);
        } else {
          // Use existing method for events without allocations
          await eventNotifier.updateEventWithScope(_selectedDay!, originalEvent, editedEvent, editOption);
        }
      } else {
        // For single events, check if we have allocations to handle
        if (allocations.isNotEmpty) {
          print('🔍 DEBUG: Single event with allocations - using scoped update with thisInstance');
          // Use the scoped method with thisInstance to handle allocations properly
          await eventNotifier.updateEventWithScopeAndAllocations(_selectedDay!, originalEvent, editedEvent, EditOption.thisInstance, allocations);
        } else {
          print('🔍 DEBUG: Single event without allocations - using regular update');
          // For single events without allocations, use regular update
          await eventNotifier.updateEvent(_selectedDay!, originalEvent, editedEvent);
        }
      }
    }
  }

  Future<void> _showDeleteEventDialog(Event event) async {
    final deleteOption = await showDeleteEventDialog(context, event);
    if (deleteOption != null) {
      await context.read<EventNotifier>().deleteEvent(_selectedDay!, event, deleteOption);
    }
  }

  double _getDayAmount(DateTime day) {
    final events = context.read<EventNotifier>().getEventsForDay(day);
    return events.fold(0.0, (sum, event) => sum + (event.amount));
  }

  Map<DateTime, double> _getMonthSummary() {
    final summary = <DateTime, double>{};
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    // Calculate total for the entire month
    double monthTotal = 0.0;
    for (var day = firstDayOfMonth;
        !day.isAfter(lastDayOfMonth);
        day = day.add(const Duration(days: 1))) {
      monthTotal += _getDayAmount(day);
    }

    // Store the monthly total using the first day of the month as key
    summary[firstDayOfMonth] = monthTotal;
    print('Monthly summary for ${firstDayOfMonth.month}/${firstDayOfMonth.year}: \$${monthTotal.toStringAsFixed(2)}');
    return summary;
  }

  @override
  void dispose() {
    print('🏁 CALENDAR DISPOSE: CalendarScreen dispose called');
    // Remove the observer to prevent memory leaks
    WidgetsBinding.instance.removeObserver(this);
    // Remove tab change listener
    globalTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final needsReset = (_focusedDay.day != now.day || _focusedDay.month != now.month || _focusedDay.year != now.year);
    
    print('🏗️ BUILD: Calendar build() - focused: ${_focusedDay.day}/${_focusedDay.month}/${_focusedDay.year}, today: ${now.day}/${now.month}/${now.year}, needs reset: $needsReset');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Consumer2<EventNotifier, CategoryNotifier>(
              builder: (context, eventNotifier, categoryNotifier, _) {
                if (eventNotifier.error != null) {
                  return Center(child: Text(eventNotifier.error!));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // Calendar wrapped in gesture interceptor
                      _CalendarScrollWrapper(
                        child: EnhancedCalendarWidget(
                          key: _calendarWidgetKey,
                          focusedDay: _focusedDay,
                          selectedDay: _selectedDay,
                          onDaySelected: _onDaySelected,
                          onFormatChanged: _onFormatChanged,
                          onPageChanged: _onPageChanged,
                          eventLoader: (day) => eventNotifier.getEventsForDay(day),
                          getDayAmount: _getDayAmount,
                          calendarFormat: _calendarFormat,
                          monthSummary: _getMonthSummary(),
                        ),
                      ),
                      // Event list - now part of unified scroll
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: EventListWidget(
                          events: eventNotifier.getEventsForDay(_selectedDay!),
                          onDeleteEvent: _showDeleteEventDialog,
                          onEditEvent: _showEditEventDialog,
                        ),
                      ),
                      // Goals Summary Section - moved below calendar
                      Consumer<SavingGoalNotifier>(
                        builder: (context, goalNotifier, child) {
                          final goals = goalNotifier.goals;
                          if (goals.isEmpty) return const SizedBox.shrink();
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            child: _buildGoalsSummaryCard(goalNotifier),
                          );
                        },
                      ),
                      // Add some bottom padding for the action buttons
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
          ),
          // Floating action buttons at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(DesignTokens.space('lg')),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.black 
                  : DesignTokens.color('surface'),
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white30 
                      : DesignTokens.color('border'),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: FinancialButton(
                      onPressed: () => _showAddEventDialog(isPositiveCashflow: true),
                      financialType: FinancialButtonType.income,
                      fullWidth: true,
                      child: const Text('Add Income'),
                    ),
                  ),
                  HSpace('lg'),
                  Expanded(
                    child: FinancialButton(
                      onPressed: () => _showAddEventDialog(isPositiveCashflow: false),
                      financialType: FinancialButtonType.expense,
                      fullWidth: true,
                      child: const Text('Add Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGoalsSummaryCard(SavingGoalNotifier goalNotifier) {
    final goals = goalNotifier.goals;
    final activeGoals = goals.where((g) => g.currentAmount < g.targetAmount).length;
    final totalSaved = goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);
    
    print('📅 CalendarScreen: Goals Summary (Real-time) - ${goals.length} total goals, $activeGoals active, \$${totalSaved.toStringAsFixed(2)} total saved');

    return CashCard(
      financialContext: Theme.of(context).brightness == Brightness.dark ? null : FinancialContext.income,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goals Summary',
            style: DesignTokens.textStyle('titleMedium').copyWith(
              color: Theme.of(context).brightness == Brightness.dark 
                ? DesignTokens.color('income') 
                : DesignTokens.color('income'),
            ),
          ),
          VSpace('sm'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$activeGoals Active Goals',
                style: DesignTokens.textStyle('bodyLarge').copyWith(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? DesignTokens.color('income') 
                    : DesignTokens.color('income'),
                ),
              ),
              FinancialAmount(
                amount: totalSaved,
                size: FinancialAmountSize.medium,
                showSign: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalendarScrollWrapper extends StatelessWidget {
  final Widget child;

  const _CalendarScrollWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        // Create a custom pan recognizer that beats TableCalendar's internal ones
        _VerticalPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<_VerticalPanGestureRecognizer>(
          () => _VerticalPanGestureRecognizer()
            ..team = GestureArenaTeam(), // Create our own team to win conflicts
          (_VerticalPanGestureRecognizer instance) {
            instance
              ..onStart = (DragStartDetails details) {
                // Vertical pan started
              }
              ..onUpdate = (DragUpdateDetails details) {
                // Forward vertical pan gestures to the parent ScrollView
                final scrollableState = Scrollable.of(context);
                if (scrollableState != null) {
                  final position = scrollableState.position;
                  final newOffset = position.pixels - details.delta.dy;
                  position.moveTo(newOffset);
                }
              }
              ..onEnd = (DragEndDetails details) {
                // Vertical pan ended
              };
          },
        ),
      },
      child: child,
    );
  }
}

// Smart gesture recognizer that only claims vertical drags, lets taps through
class _VerticalPanGestureRecognizer extends OneSequenceGestureRecognizer {
  Offset? _initialPosition;
  bool _hasDragged = false;
  static const double _kTouchSlop = 18.0; // Minimum movement to be considered a drag
  
  @override
  void addAllowedPointer(PointerDownEvent event) {
    startTrackingPointer(event.pointer, event.transform);
    _initialPosition = event.localPosition;
    _hasDragged = false;
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (_initialPosition != null) {
        final delta = event.localPosition - _initialPosition!;
        final distance = delta.distance;
        
        // Only claim the gesture if there's significant movement
        if (!_hasDragged && distance > _kTouchSlop) {
          final isVertical = delta.dy.abs() > delta.dx.abs();
          
          if (isVertical) {
            // This is a vertical drag - claim it!
            resolve(GestureDisposition.accepted);
            _hasDragged = true;
            
            if (onStart != null) {
              onStart!(DragStartDetails(
                sourceTimeStamp: event.timeStamp,
                localPosition: _initialPosition!,
                globalPosition: event.position - event.localDelta,
              ));
            }
          } else {
            // This is horizontal or unclear - reject it
            resolve(GestureDisposition.rejected);
            return;
          }
        }
        
        // If we've claimed the gesture, send updates
        if (_hasDragged && onUpdate != null) {
          onUpdate!(DragUpdateDetails(
            sourceTimeStamp: event.timeStamp,
            delta: event.delta,
            localPosition: event.localPosition,
            globalPosition: event.position,
          ));
        }
      }
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      if (!_hasDragged) {
        // This was a tap - reject so other widgets can handle it
        resolve(GestureDisposition.rejected);
      } else {
        if (onEnd != null) {
          onEnd!(DragEndDetails(
            velocity: Velocity.zero,
          ));
        }
      }
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _initialPosition = null;
    _hasDragged = false;
  }

  @override
  String get debugDescription => 'smart_vertical_pan';

  GestureDragStartCallback? onStart;
  GestureDragUpdateCallback? onUpdate;
  GestureDragEndCallback? onEnd;
}