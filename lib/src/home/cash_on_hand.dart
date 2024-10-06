import 'package:flutter/material.dart';
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
  late DateTime _endOfWeek;
  late DateTime _endOfMonth;
  late Map<String, double> _totals;
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
        _endOfWeek = _getEndOfWeek(_now);
            _endOfMonth = _getEndOfMonth(_now);
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
      'day': 0,
      'week': 0,
      'month': 0,
      'year': 0,
    };

    final startOfYear = DateTime(_now.year, 1, 1);
    final endOfYear = DateTime(_now.year, 12, 31);

    kEvents.forEach((date, events) {
      if (date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfYear.add(const Duration(days: 1)))) {
        for (var event in events) {
          final amount = (event.amount ?? 0) * (event.isPositiveCashflow ? 1 : -1);

          // Day total (cumulative from start of year to current day)
          if (!date.isAfter(_now)) {
            _totals['day'] = (_totals['day'] ?? 0) + amount;
          }

          // Week total (cumulative from start of year to end of current week)
          if (!date.isAfter(_endOfWeek)) {
            _totals['week'] = (_totals['week'] ?? 0) + amount;
          }

          // Month total (cumulative from start of year to end of current month)
          if (!date.isAfter(_endOfMonth)) {
            _totals['month'] = (_totals['month'] ?? 0) + amount;
          }

          // // Half-year total
          // if (date.year == _now.year &&
          //     ((date.month <= 6 && _now.month <= 6) ||
          //         (date.month > 6 && _now.month > 6))) {
          //   _totals['halfYear'] = (_totals['halfYear'] ?? 0) + amount;
          // }

          // Year total
          _totals['year'] = (_totals['year'] ?? 0) + amount;
        }
      }
    });
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
            // _buildTile('End of Half Year', _totals['halfYear'] ?? 0),
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



// TODO: Implement filtering options for totals in the future
// This could include filtering by event category or type
