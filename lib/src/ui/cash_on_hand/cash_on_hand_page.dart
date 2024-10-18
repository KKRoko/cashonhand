import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cash_on_hand/src/providers/event_provider.dart';
import 'package:cash_on_hand/src/ui/calendar/calendar_page.dart';
import 'dart:developer' as developer;

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
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");
  final dateFormatter = DateFormat("EEEE, MMM d, yyyy");

 @override
  void initState() {
    super.initState();
    _updateDates();
  }

  void _updateDates() {
    _now = DateTime.now();
    _endOfWeek = _getEndOfWeek(_now);
    _endOfMonth = _getEndOfMonth(_now);
    _endOfYear = DateTime(_now.year, 12, 31);
  }

  DateTime _getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.saturday - date.weekday + (date.weekday == DateTime.sunday ? 7 : 0)));
  }

  DateTime _getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final totals = eventProvider.calculateTotals();
        developer.log('Totals in CashOnHandPage: $totals', name: 'CashOnHandPage');
        return Scaffold(
          appBar: AppBar(
              title: const Text(''),
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _updateDates();
              });
            },
            child: ListView(
            padding: const EdgeInsets.all(16.0),
              children: [
                _buildTile('End of Day', totals['day']!, _now),
                _buildTile('End of Week', totals['week']!, _endOfWeek),
                _buildTile('End of Month', totals['month']!, _endOfMonth),
                _buildTile('End of Year', totals['year']!, _endOfYear),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalendarPage()),
              ).then((_) => setState(() {}));
            },
            child: const Icon(Icons.calendar_today),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
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
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(dateFormatter.format(date), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            _buildAmountRow('Total Positive Cashflow', positiveAmount, Colors.green),
            _buildAmountRow('Total Negative Cashflow', negativeAmount, Colors.red),
            const Divider(),
               _buildAmountRow('Cash on Hand', totalAmount, totalAmount >= 0 ? Colors.green : Colors.red),
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
          '${amount < 0 ? '-' : ''}\$${currencyFormatter.format(amount.abs())}',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
