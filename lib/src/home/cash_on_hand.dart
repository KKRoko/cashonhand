import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendar_page.dart';
import 'event_model.dart';

class CashOnHandPage extends StatefulWidget {
  static const routeName = '/cashOnHand';

  const CashOnHandPage({Key? key}) : super(key: key);

  @override
  CashOnHandPageState createState() => CashOnHandPageState();
}

class CashOnHandPageState extends State<CashOnHandPage> {
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
    calculateTotals();
    _addYearEndCashFlow();
  }

    DateTime _getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.saturday - date.weekday + (date.weekday == DateTime.sunday ? 7 : 0)));
  }

  DateTime _getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  void calculateTotals() {
    _totals = {
      'day': {'positive': 0, 'negative': 0},
      'week': {'positive': 0, 'negative': 0},
      'month': {'positive': 0, 'negative': 0},
      'year': {'positive': 0, 'negative': 0},
    };

    final startOfYear = DateTime(_now.year, 1, 1);
    final endOfYear = DateTime(_now.year, 12, 31);
    final endOfToday = DateTime(_now.year, _now.month, _now.day, 23, 59, 59);

   double yearTotal = 0;

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
          
           // Calculate total for year-end cash flow
          yearTotal += event.isPositiveCashflow ? amount : -amount;
        }
      }
    });
        // Create the next year's starting event
    DateTime nextYearStart = DateTime(_now.year + 1, 1, 1);
    Event yearEndCashFlow = Event(
      title: "Cash Flow at end of ${_now.year}",
      amount: yearTotal.abs(),
      isPositiveCashflow: yearTotal >= 0,
      isNegativeCashflow: yearTotal < 0,
      repeatOption: RepeatOption.today,
    );

    // Add the event to kEvents
    if (kEvents[nextYearStart] != null) {
      kEvents[nextYearStart]!.add(yearEndCashFlow);
    } else {
      kEvents[nextYearStart] = [yearEndCashFlow];
    }
  }
  
  void _updateTotals(String period, double amount, bool isPositive) {
    if (isPositive) {
      _totals[period]!['positive'] = (_totals[period]!['positive'] ?? 0) + amount;
    } else {
      _totals[period]!['negative'] = (_totals[period]!['negative'] ?? 0) + amount;
    }
  }

void _addYearEndCashFlow() {
  calculateTotals();
  double yearTotal = _totals['year']!['positive']! - _totals['year']!['negative']!;
  
  DateTime nextYearStart = DateTime(_now.year + 1, 1, 1);
  Event yearEndCashFlow = Event(
    title: "Cash Flow at end of ${_now.year}",
    amount: yearTotal.abs(),
    isPositiveCashflow: yearTotal >= 0,
    isNegativeCashflow: yearTotal < 0,
    repeatOption: RepeatOption.today,
  );

  if (kEvents[nextYearStart] != null) {
    kEvents[nextYearStart]!.add(yearEndCashFlow);
  } else {
    kEvents[nextYearStart] = [yearEndCashFlow];
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: PreferredSize(
      preferredSize: Size.fromHeight(5.0), 
      child: AppBar(
        title: const Text(''),
        elevation: 0, // Removes the shadow
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Makes it blend with the background
      ),
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
                  ).then((_) => setState(() => calculateTotals()));
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(dateFormatter.format(date), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          _buildAmountRow('Total Positive Cashflow', positiveAmount, Colors.green),
          _buildAmountRow('Total Negative Cashflow', negativeAmount, Colors.red),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cash on hand', style: Theme.of(context).textTheme.titleMedium),
              Text(
                totalAmount < 0 ? '-\$${currencyFormatter.format(totalAmount.abs())}' : '\$${currencyFormatter.format(totalAmount)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: totalAmount >= 0 ? Colors.green : Colors.red),
              ),
            ],
          ),
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