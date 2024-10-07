import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendar_page.dart';
import 'event_model.dart';


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
  late DateTime _endOfYear;
  late Map<String, Map<String, double>> _totals;
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");
    final dateFormatter = DateFormat("EEEE, MMM d, yyyy");

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _endOfWeek = _getEndOfWeek(_now);
    _endOfMonth = _getEndOfMonth(_now);
    _endOfYear = DateTime(_now.year, 12, 31);
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

    final startOfYear = DateTime(_now.year, 1, 1);
    final endOfYear = DateTime(_now.year, 12, 31);
    final endOfToday = DateTime(_now.year, _now.month, _now.day, 23, 59, 59);


    kEvents.forEach((date, events) {
      if (date.isAfter(startOfYear.subtract(const Duration(days: 1))) &&
          date.isBefore(endOfYear.add(const Duration(days: 1)))) {
        for (var event in events) {
          final amount = event.amount ?? 0;

          // Day totals
        if (!date.isAfter(endOfToday)) {
            _updateTotals('day', amount, event.isPositiveCashflow);
          }

          // Week totals
          if (!date.isAfter(_endOfWeek)) {
            _updateTotals('week', amount, event.isPositiveCashflow);
          }

          // Month totals
          if (!date.isAfter(_endOfMonth)) {
            _updateTotals('month', amount, event.isPositiveCashflow);
          }

          // Year totals
          _updateTotals('year', amount, event.isPositiveCashflow);
        }
      }
    });
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
        title: const Text('Cash On Hand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTile('End of Day', _totals['day']!, _now),
            _buildTile('End of Week', _totals['week']!, _endOfWeek),
            _buildTile('End of Month', _totals['month']!, _endOfMonth),
            _buildTile('End of Year', _totals['year']!, _endOfYear),
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



  Widget _buildTile(String title, Map<String, double> amounts, DateTime date) {
    final positiveAmount = amounts['positive'] ?? 0;
    final negativeAmount = amounts['negative'] ?? 0;
    final totalAmount = positiveAmount - negativeAmount;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Text(dateFormatter.format(date), style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            _buildAmountRow('Total Positive Cashflow', positiveAmount, Colors.green),
            _buildAmountRow('Total Negative Cashflow', negativeAmount, Colors.red),
            const Divider(),
            _buildAmountRow('Total Cashflow', totalAmount, totalAmount >= 0 ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          amount < 0 ? '-\$${currencyFormatter.format(amount.abs())}' : '\$${currencyFormatter.format(amount)}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}


// TODO: Implement filtering options for totals in the future
// This could include filtering by event category or type