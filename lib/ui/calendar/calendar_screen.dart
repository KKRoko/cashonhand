import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/di/injection.dart';
import '../../data/database/database.dart';
import '../../data/models/enums/category_type.dart';
import '../../data/models/freezed/event.dart';
import '../../services/event_service.dart';
import '../dialogs/add_edit_event_dialog.dart';
import '../dialogs/delete_event_dialog.dart' show showDeleteEventDialog;
import '../../state/event_notifier.dart';
import 'widgets/index.dart';

class CalendarScreen extends StatefulWidget {
  static const routeName = '/calendar';
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late EventService _eventService;
  late Database _database;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = false;
  bool _isDatabaseInitialized = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _eventService = getIt<EventService>();
    _database = getIt<Database>();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Test a simple query to ensure database is working
      final categoryCount = await _database
          .getCategoryCount()
          .timeout(const Duration(seconds: 5));

      // Add this part to ensure default categories exist
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
  }

  void _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  Future<void> _showAddEventDialog({required bool isPositiveCashflow}) async {
    if (!_isDatabaseInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Database not initialized. Please wait or restart the app.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print("Starting _showAddEventDialog");
      final categoryType =
          isPositiveCashflow ? CategoryType.income : CategoryType.expense;

      if (!context.mounted) return;

      setState(() {
        _isLoading = true;
      });

      print("Fetching categories for type: $categoryType");
      final categories =
          await _database.getCategories(type: categoryType).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print("Category fetch timed out");
          throw TimeoutException(
              'Database query took too long. Please try again.');
        },
      );

      print("Categories fetched: ${categories.length}");

      if (!context.mounted) return;
      setState(() {
        _isLoading = false;
      });

      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No categories found. Please add categories first.'),
          ),
        );
        return;
      }

      print("About to show AddEditEventDialog");
      final newEvent = await showDialog<Event>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AddEditEventDialog(
            selectedDay: _selectedDay!,
            isPositiveCashflow: isPositiveCashflow,
            categories: categories,
          );
        },
      );

      print(
          "Dialog result: ${newEvent != null ? 'event created' : 'cancelled'}");
      if (newEvent != null && context.mounted) {
        final eventNotifier = context.read<EventNotifier>();
        await eventNotifier.addEvent(_selectedDay!, newEvent);
        print("Event added successfully");
      }
    } catch (e, stackTrace) {
      print("Error in _showAddEventDialog: $e");
      print("Stack trace: $stackTrace");

      if (!context.mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEditEventDialog(Event event) async {
    try {
      final categoryType =
          event.isPositiveCashflow ? CategoryType.income : CategoryType.expense;

      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final categories = await _database.getCategories(type: categoryType);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No categories found. Please add categories first.'),
          ),
        );
        return;
      }

      final editedEvent = await showDialog<Event>(
        context: context,
        builder: (BuildContext context) {
          return AddEditEventDialog(
            selectedDay: _selectedDay!,
            event: event,
            isPositiveCashflow: event.isPositiveCashflow,
            categories: categories,
          );
        },
      );

      if (editedEvent != null) {
        _eventService.updateEvent(_selectedDay!, event, editedEvent);
      }
    } catch (e) {
      if (!context.mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> _showDeleteEventDialog(Event event) async {
    final deleteOption = await showDeleteEventDialog(context, event);
    if (deleteOption != null) {
      _eventService.deleteEvent(_selectedDay!, event, deleteOption);
    }
  }

  double _getDayAmount(DateTime day) {
    final eventNotifier = context.read<EventNotifier>();
    final events = eventNotifier.getEventsForDay(day);
    return events.fold(0.0, (sum, event) => sum + (event.amount));
  }

  Map<DateTime, double> _getMonthSummary() {
    final summary = <DateTime, double>{};
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    for (var day = firstDayOfMonth;
        day.isBefore(lastDayOfMonth);
        day = day.add(const Duration(days: 1))) {
      summary[day] = _getDayAmount(day);
    }

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
  child: Column(
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
          eventLoader: (day) => context.watch<EventNotifier>().getEventsForDay(day),
          getDayAmount: _getDayAmount,
          calendarFormat: _calendarFormat,
          monthSummary: _getMonthSummary(),
        ),
      ),
      Expanded(
        child: Consumer<EventNotifier>(
          builder: (context, eventNotifier, _) {
            final events = eventNotifier.getEventsForDay(_selectedDay!);
            return events.isEmpty
              ? const Center(
                  child: Text('No events for selected day'),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: EventListWidget(
                    events: events,
                    onDeleteEvent: _showDeleteEventDialog,
                    onEditEvent: _showEditEventDialog,
                  ),
                );
          },
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
  ),
),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
