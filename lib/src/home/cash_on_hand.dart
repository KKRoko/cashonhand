import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'cash_flow_calculator.dart';
import 'event_model.dart';

class CashOnHandPage extends StatefulWidget {
  static const routeName = '/cashOnHand';

  const CashOnHandPage({Key? key}) : super(key: key);

  @override
  _CashOnHandPageState createState() => _CashOnHandPageState();
}

class _CashOnHandPageState extends State<CashOnHandPage> with WidgetsBindingObserver {

  late FocusNode _focusNode;
  double _endOfDayTotal = 0;
  double _endOfWeekTotal = 0;
  double _endOfMonthTotal = 0;
  double _endOfHalfYearTotal = 0;
  double _endOfYearTotal = 0;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateTotals());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _calculateTotals();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _calculateTotals();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _calculateTotals();
    }
  }

   Future<void> _calculateTotals() async {
    if (_isCalculating) return;
    _isCalculating = true;

    setState(() {
      _endOfDayTotal = 0;
      _endOfWeekTotal = 0;
      _endOfMonthTotal = 0;
      _endOfHalfYearTotal = 0;
      _endOfYearTotal = 0;
    });

    try {
      final DateTime now = DateTime.now();
      final List<Event> allEvents = kEvents.values.expand((events) => events).toList();

      print('Total events found: ${allEvents.length}');

      final results = await Future.wait([
        CashFlowCalculator.calculateNetCashFlow(
          allEvents,
          DateTime(now.year, now.month, now.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        ),
        CashFlowCalculator.calculateNetCashFlow(
          allEvents,
          now,
          now.add(Duration(days: 7 - now.weekday)),
        ),
        CashFlowCalculator.calculateNetCashFlow(
          allEvents,
          now,
          DateTime(now.year, now.month + 1, 0),
        ),
        CashFlowCalculator.calculateNetCashFlow(
          allEvents,
          now,
          DateTime(now.year + (now.month > 6 ? 1 : 0), (now.month > 6 ? 1 : 7), 0),
        ),
        CashFlowCalculator.calculateNetCashFlow(
          allEvents,
          now,
          DateTime(now.year + 1, 1, 0),
        ),
      ]);

      setState(() {
        _endOfDayTotal = results[0];
        _endOfWeekTotal = results[1];
        _endOfMonthTotal = results[2];
        _endOfHalfYearTotal = results[3];
        _endOfYearTotal = results[4];
      });

      print('Calculations completed');
    } catch (e) {
      print('Error calculating totals: $e');
    } finally {
      _isCalculating = false;
    }
  }


  Widget _buildTile(String title, double amount) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: amount >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cash On Hand'),
        ),
        body: RefreshIndicator(
          onRefresh: _calculateTotals,
          child: ListView(
          padding: const EdgeInsets.all(16.0),
            children: [
              _buildTile('End of Day', _endOfDayTotal),
              _buildTile('End of Week', _endOfWeekTotal),
              _buildTile('End of Month', _endOfMonthTotal),
              _buildTile('End of Half Year', _endOfHalfYearTotal),
              _buildTile('End of Year', _endOfYearTotal),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                 onTap: () {
                    print("Calendar icon pressed");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CalendarPage()),
                    ).then((_) {
                      print("Returned from CalendarPage");
                      _calculateTotals();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.calendar_today),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}