import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendar_page.dart';
import 'event_model.dart';
import 'package:intl/intl.dart'; // Add this import


class CashOnHandPage extends StatefulWidget {
  static const routeName = '/cashOnHand';

  const CashOnHandPage({super.key});

  @override
  _CashOnHandPageState createState() => _CashOnHandPageState();
}

class _CashOnHandPageState extends State<CashOnHandPage> {
  late DateTime _now;
  late Map<String, double> _totals;
    final currencyFormatter = NumberFormat("#,##0.00", "en_US"); // Add this line


  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _calculateTotals();
  }

  void _calculateTotals() {
    _totals = {
      'day': 0,
      'week': 0,
      'month': 0,
      'halfYear': 0,
      'year': 0,
    };

    final startOfYear = DateTime(_now.year, 1, 1);
    final endOfYear = DateTime(_now.year, 12, 31);

    kEvents.forEach((date, events) {
      if (date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfYear.add(const Duration(days: 1)))) {
        for (var event in events) {
          final amount = (event.amount ?? 0) * (event.isPositiveCashflow ? 1 : -1);

          // Day total
          if (isSameDay(date, _now)) {
            _totals['day'] = (_totals['day'] ?? 0) + amount;
          }

          // Week total
          if (isInSameWeek(date, _now)) {
            _totals['week'] = (_totals['week'] ?? 0) + amount;
          }

          // Month total
          if (date.year == _now.year && date.month == _now.month) {
            _totals['month'] = (_totals['month'] ?? 0) + amount;
          }

          // Half-year total
          if (date.year == _now.year &&
              ((date.month <= 6 && _now.month <= 6) ||
                  (date.month > 6 && _now.month > 6))) {
            _totals['halfYear'] = (_totals['halfYear'] ?? 0) + amount;
          }

          // Year total
          _totals['year'] = (_totals['year'] ?? 0) + amount;
        }
      }
    });
  }

  bool isInSameWeek(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2).inDays;
    return difference >= 0 && difference < 7 && date1.weekday >= date2.weekday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash On Hand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTile('End of Day', _totals['day'] ?? 0),
            _buildTile('End of Week', _totals['week'] ?? 0),
            _buildTile('End of Month', _totals['month'] ?? 0),
            _buildTile('End of Half Year', _totals['halfYear'] ?? 0),
            _buildTile('End of Year', _totals['year'] ?? 0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarPage()),
                  ).then((_) => setState(() => _calculateTotals()));
                },
        child: const Icon(Icons.calendar_today),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTile(String title, double amount) {
       final formattedAmount = amount < 0
        ? '-\$${currencyFormatter.format(amount.abs())}'
        : '\$${currencyFormatter.format(amount)}';    
        final color = amount >= 0 ? Colors.green : Colors.red;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: color.withOpacity(0.2),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          formattedAmount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

// Dummy Add Entry Page (Replace with your actual page)
class AddEntryPage extends StatelessWidget {
  const AddEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entry'),
      ),
      body: const Center(
        child: Text('Add Entry Page'),
      ),
    );
  }
}

// TODO: Implement filtering options for totals in the future
// This could include filtering by event category or type
