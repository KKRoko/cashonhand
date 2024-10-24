import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../services/event_service.dart';
import '../../state/event_notifier.dart'; 
import 'widgets/cash_on_hand_tile.dart';
import '../calendar/calendar_screen.dart';

class CashOnHandScreen extends StatefulWidget {
  static const routeName = '/cashOnHand';

  const CashOnHandScreen({super.key});

  @override
  _CashOnHandScreenState createState() => _CashOnHandScreenState();
}

class _CashOnHandScreenState extends State<CashOnHandScreen> {
  late EventService _eventService;
  late DateTime _now;
  late DateTime _endOfWeek;
  late DateTime _endOfMonth;
  late DateTime _endOfYear;
  late Map<String, Map<String, double>> _totals;

@override
void initState() {
    super.initState();
    // Get year from EventNotifier
    final year = Provider.of<EventNotifier>(context, listen: false).currentYear;
    print('\nInitializing dates:');
    print('Current DateTime.now(): ${DateTime.now()}');
    print('Using year: $year');

    _now = DateTime.now(); 
    print('Initialized _now: $_now');

    _endOfWeek = _getEndOfWeek(_now);
    print('End of week: $_endOfWeek');

    _endOfMonth = _getEndOfMonth(_now);
       print('End of month: $_endOfMonth');
    _endOfYear = DateTime(year, 12, 31);
       print('End of year: $_endOfYear');
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventService = EventService(Provider.of<EventNotifier>(context));
    _calculateTotals();
  }

  DateTime _getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.saturday - date.weekday + (date.weekday == DateTime.sunday ? 7 : 0)));
  }

  DateTime _getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

void _calculateTotals() {
   print('\n=== Starting _calculateTotals ===');
   print('Reference dates:');
   print('_now: $_now');
   print('_endOfWeek: $_endOfWeek');
   print('_endOfMonth: $_endOfMonth');
   print('_endOfYear: $_endOfYear');
   
   Provider.of<EventNotifier>(context, listen: false).debugPrintEvents();
   _totals = {
       'day': {'positive': 0, 'negative': 0},
       'week': {'positive': 0, 'negative': 0},
       'month': {'positive': 0, 'negative': 0},
       'year': {'positive': 0, 'negative': 0},
   };

   DateTime _stripTime(DateTime dt) {
       return DateTime(dt.year, dt.month, dt.day);
   }

   final nowDate = _stripTime(_now);
   print('\nCurrent date for comparison: $nowDate');
   final events = _eventService.getEventsForRange(DateTime(_now.year, 1, 1), _endOfYear);

   print('Number of unique event IDs: ${events.map((e) => e.id).toSet().length}');
   
   final processedDayEventIds = <String>{};
   
   for (var event in events) {
       final amount = event.amount ?? 0;
       final eventDate = _stripTime(event.dateTime);
       
       print('\nProcessing event:');
       print('  ID: ${event.id}');
       print('  Date: $eventDate');
       print('  Amount: $amount');
       print('  Event date components: y${eventDate.year} m${eventDate.month} d${eventDate.day}');
       print('  Now date components: y${nowDate.year} m${nowDate.month} d${nowDate.day}');
       print('  Is after now: ${eventDate.isAfter(nowDate)}');
       print('  Is before now: ${eventDate.isBefore(nowDate)}');
       print('  Is same day: ${eventDate.year == nowDate.year && eventDate.month == nowDate.month && eventDate.day == nowDate.day}');
       print('  Already processed: ${processedDayEventIds.contains(event.id)}');



       if (!eventDate.isAfter(nowDate)) {
    print('  >>> Adding to day total: $amount');
    _updateTotals('day', amount, event.isPositiveCashflow);
}       

       if (!_stripTime(eventDate).isAfter(_stripTime(_endOfWeek))) {
           print('  Adding to week total: $amount');
           _updateTotals('week', amount, event.isPositiveCashflow);
       }
       if (!_stripTime(eventDate).isAfter(_stripTime(_endOfMonth))) {
           print('  Adding to month total: $amount');
           _updateTotals('month', amount, event.isPositiveCashflow);
       }
       if (!_stripTime(eventDate).isAfter(_stripTime(_endOfYear))) {
           _updateTotals('year', amount, event.isPositiveCashflow);
       }
   }

   print('\nProcessed event IDs for day: $processedDayEventIds');
   print('\nFinal Totals:');
   print('Day total: ${_totals['day']}');
   print('Week total: ${_totals['week']}');
   print('Month total: ${_totals['month']}');
   print('Year total: ${_totals['year']}');
   print('=== End _calculateTotals ===\n');
   setState(() {});
}

  void _updateTotals(String period, double amount, bool isPositive) {
    if (isPositive) {
      _totals[period]!['positive'] = (_totals[period]!['positive'] ?? 0) + amount;
    } else {
      _totals[period]!['negative'] = (_totals[period]!['negative'] ?? 0) + amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash on Hand'),
        elevation: 0,
      ),
      body: Consumer<EventNotifier>( 
        builder: (context, eventNotifier, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CashOnHandTile(title: 'End of Day', amounts: _totals['day']!, date: _now),
                CashOnHandTile(title: 'End of Week', amounts: _totals['week']!, date: _endOfWeek),
                CashOnHandTile(title: 'End of Month', amounts: _totals['month']!, date: _endOfMonth),
                CashOnHandTile(title: 'End of Year', amounts: _totals['year']!, date: _endOfYear),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          ).then((_) => _calculateTotals());
        },
        child: const Icon(Icons.calendar_today),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}