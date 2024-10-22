import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import '../../services/event_service.dart';
import '../../state/event_notifier.dart'; 
import 'widgets/cash_on_hand_tile.dart';
import '../calendar/calendar_page.dart';

class CashOnHandPage extends StatefulWidget {
  static const routeName = '/cashOnHand';

  const CashOnHandPage({super.key});

  @override
  CashOnHandPageState createState() => CashOnHandPageState();
}

class CashOnHandPageState extends State<CashOnHandPage> {
  late EventService _eventService;  // Change to late
  late DateTime _now;
  late DateTime _endOfWeek;
  late DateTime _endOfMonth;
  late DateTime _endOfYear;
  late Map<String, Map<String, double>> _totals;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _endOfWeek = _getEndOfWeek(_now);
    _endOfMonth = _getEndOfMonth(_now);
    _endOfYear = DateTime(_now.year, 12, 31);
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
    _totals = {
      'day': {'positive': 0, 'negative': 0},
      'week': {'positive': 0, 'negative': 0},
      'month': {'positive': 0, 'negative': 0},
      'year': {'positive': 0, 'negative': 0},
    };

    final events = _eventService.getEventsForRange(DateTime(_now.year, 1, 1), _endOfYear);

    for (var event in events) {
      final amount = event.amount ?? 0;
      final date = event.createdAt;

      if (!date.isAfter(_now)) {
        _updateTotals('day', amount, event.isPositiveCashflow);
      }
      if (!date.isAfter(_endOfWeek)) {
        _updateTotals('week', amount, event.isPositiveCashflow);
      }
      if (!date.isAfter(_endOfMonth)) {
        _updateTotals('month', amount, event.isPositiveCashflow);
      }
      _updateTotals('year', amount, event.isPositiveCashflow);
    }

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
      body: Consumer<EventNotifier>(  // Wrap with Consumer to update when events change
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
            MaterialPageRoute(builder: (context) => const CalendarPage()),
          ).then((_) => _calculateTotals());
        },
        child: const Icon(Icons.calendar_today),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}