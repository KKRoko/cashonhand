import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/di/injection.dart';
import '../../data/database/database.dart';
import '../../data/models/enums/category_type.dart';
import '../../data/models/enums/edit_option.dart';
import '../../data/models/freezed/event.dart';
import '../../data/models/event_creation_result.dart';
import '../dialogs/add_edit_event_dialog.dart';
import '../dialogs/delete_event_dialog.dart' show showDeleteEventDialog;
import '../dialogs/edit_scope_dialog.dart';
import '../../state/event_notifier.dart';
import '../../state/category_notifier.dart';
import 'widgets/index.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar';
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  bool _isDatabaseInitialized = false;
  late Database _database;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _database = getIt<Database>();
    _initializeDatabase();
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
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  void _onPageChanged(DateTime focusedDay) {
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
        print('Selected day updated to: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}');
        
        // Load events for the new selected day
        context.read<EventNotifier>().loadEventsForDay(_selectedDay!);
      }
    });
    print('Calendar page changed to: ${focusedDay.month}/${focusedDay.year}');
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
        
        if (result.allocations.isNotEmpty) {
          // Use the new method that handles allocations
          firstEventDate = await eventNotifier.addEventWithAllocations(_selectedDay!, result.event, result.allocations);
          print("Event and allocations saved: ${result.allocations.length} allocations");
        } else {
          // Use the regular method for events without allocations
          firstEventDate = await eventNotifier.addEvent(_selectedDay!, result.event);
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
      
      // TODO: Handle allocation updates in edit scenario
      // Always show scope dialog for all events (both single and recurring)
      await _handleEventEdit(event, editedEvent);
    }
  }

  Future<void> _handleEventEdit(Event originalEvent, Event editedEvent) async {
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
    final editOption = await showEditScopeDialog(
      context: context,
      event: originalEvent,
      selectedDate: _selectedDay!,
      totalEventsInSeries: impactCounts['total'] ?? 1,
      futureEventsCount: impactCounts['future'] ?? 0,
      pastEventsCount: impactCounts['past'] ?? 0,
    );

    if (editOption != null) {
      if (originalEvent.isRecurring || impactCounts['total']! > 1) {
        // Use scoped update for recurring events
        await eventNotifier.updateEventWithScope(_selectedDay!, originalEvent, editedEvent, editOption);
      } else {
        // For single events, use regular update regardless of scope selection
        await eventNotifier.updateEvent(_selectedDay!, originalEvent, editedEvent);
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
  Widget build(BuildContext context) {
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

                return Column(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: EnhancedCalendarWidget(
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: EventListWidget(
                          events: eventNotifier.getEventsForDay(_selectedDay!),
                          onDeleteEvent: _showDeleteEventDialog,
                          onEditEvent: _showEditEventDialog,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _showAddEventDialog(isPositiveCashflow: true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              ),
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Add Income',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _showAddEventDialog(isPositiveCashflow: false),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              ),
                              icon: const Icon(Icons.remove, color: Colors.white),
                              label: const Text(
                                'Add Expense',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
}