// cash_on_hand_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/event_service.dart';
import '../../state/event_notifier.dart';
import '../calendar/calendar_screen.dart';
import '../../utils/formatters.dart';

class CashOnHandScreen extends StatefulWidget {
  static const routeName = '/cashOnHand';
  const CashOnHandScreen({super.key});

  @override
  _CashOnHandScreenState createState() => _CashOnHandScreenState();
}

class _CashOnHandScreenState extends State<CashOnHandScreen> with SingleTickerProviderStateMixin {
  late EventService _eventService;
  late DateTime _now;
  late DateTime _endOfWeek;
  late DateTime _endOfMonth;
  late DateTime _endOfYear;
  late Map<String, Map<String, double>> _totals;
  String? _expandedTileId;
  
  // Animation controller for progress bars
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Initialize dates
    final year = Provider.of<EventNotifier>(context, listen: false).currentYear;
    _now = DateTime.now();
    _endOfWeek = _getEndOfWeek(_now);
    _endOfMonth = _getEndOfMonth(_now);
    _endOfYear = DateTime(year, 12, 31);

    // Initialize totals
    _totals = {
      'day': {'positive': 0, 'negative': 0},
      'week': {'positive': 0, 'negative': 0},
      'month': {'positive': 0, 'negative': 0},
      'year': {'positive': 0, 'negative': 0},
    };
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _eventService = EventService(Provider.of<EventNotifier>(context));
    _calculateTotals();
  }

  DateTime _getEndOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.saturday - date.weekday + 
      (date.weekday == DateTime.sunday ? 7 : 0)));
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

    DateTime _stripTime(DateTime dt) {
      return DateTime(dt.year, dt.month, dt.day);
    }

    final nowDate = _stripTime(_now);
    final events = _eventService.getEventsForRange(
      DateTime(_now.year, 1, 1),
      _endOfYear
    );

    for (var event in events) {
      final amount = event.amount ?? 0;
      final eventDate = _stripTime(event.dateTime);

      if (!eventDate.isAfter(nowDate)) {
        _updateTotals('day', amount, event.isPositiveCashflow);
      }
      if (!_stripTime(eventDate).isAfter(_stripTime(_endOfWeek))) {
        _updateTotals('week', amount, event.isPositiveCashflow);
      }
      if (!_stripTime(eventDate).isAfter(_stripTime(_endOfMonth))) {
        _updateTotals('month', amount, event.isPositiveCashflow);
      }
      if (!_stripTime(eventDate).isAfter(_stripTime(_endOfYear))) {
        _updateTotals('year', amount, event.isPositiveCashflow);
      }
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

  // Achievement badge widget
  Widget _buildAchievementBadge({
    required String title,
    required String description,
    required bool obtained,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: obtained ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: obtained ? Colors.green : Colors.grey,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Cash flow tile widget
  Widget _buildCashFlowTile({
    required String period,
    required Map<String, double> amounts,
    required DateTime date,
    required double progress,
    required bool isYearEnd,
  }) {
    final positiveAmount = amounts['positive'] ?? 0;
    final negativeAmount = amounts['negative'] ?? 0;
    final totalAmount = positiveAmount - negativeAmount;
    final isExpanded = _expandedTileId == period;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: totalAmount >= 0 ? Colors.green : Colors.red,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isExpanded ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() {
            _expandedTileId = isExpanded ? null : period;
          }),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            period,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (isYearEnd) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.auto_awesome,
                              color: Colors.amber.shade700,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      FormatUtils.formatCurrency(totalAmount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: totalAmount >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: isExpanded ? 0.5 : 0,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Income'),
                      Text(
                        FormatUtils.formatCurrency(positiveAmount),
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Expenses'),
                      Text(
                        FormatUtils.formatCurrency(negativeAmount),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Savings Goal Progress'),
                          Text('${(progress * 100).toInt()}%'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade500,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash on Hand'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer<EventNotifier>(
          builder: (context, eventNotifier, child) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Progress Alert
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "You're on track to save 15% more than last month!",
                          style: TextStyle(
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Cash Flow Tiles
                _buildCashFlowTile(
                  period: 'End of Day',
                  amounts: _totals['day']!,
                  date: _now,
                  progress: 0.85,
                  isYearEnd: false,
                ),
                _buildCashFlowTile(
                  period: 'End of Week',
                  amounts: _totals['week']!,
                  date: _endOfWeek,
                  progress: 0.87,
                  isYearEnd: false,
                ),
                _buildCashFlowTile(
                  period: 'End of Month',
                  amounts: _totals['month']!,
                  date: _endOfMonth,
                  progress: 0.84,
                  isYearEnd: false,
                ),
                _buildCashFlowTile(
                  period: 'End of Year',
                  amounts: _totals['year']!,
                  date: _endOfYear,
                  progress: 0.75,
                  isYearEnd: true,
                ),

                const SizedBox(height: 24),
                
                // Achievements Section
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _buildAchievementBadge(
                  title: 'Saving Starter',
                  description: 'Save your first \$1,000',
                  obtained: true,
                ),
                const SizedBox(height: 8),
                _buildAchievementBadge(
                  title: 'Consistent Saver',
                  description: 'Save money 3 months in a row',
                  obtained: false,
                ),
              ],
            );
          },
        ),
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
    );
  }
}
