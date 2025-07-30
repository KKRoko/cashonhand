import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cash_on_hand/core/di/injection.dart';
import 'package:cash_on_hand/services/round_up_service.dart';
import 'package:cash_on_hand/services/settings_service.dart';
import 'package:cash_on_hand/data/models/freezed/round_up_preferences.dart';
import 'package:cash_on_hand/data/models/freezed/round_up_calculation.dart';
import 'package:cash_on_hand/data/models/enums/allocation_type.dart';
import 'package:cash_on_hand/data/repositories/event_repository.dart';
import 'package:cash_on_hand/data/repositories/saving_goal_repository.dart';
import 'package:cash_on_hand/data/database/database.dart';

class RoundUpHistoryScreen extends StatefulWidget {
  static const routeName = '/round-up-history';
  
  const RoundUpHistoryScreen({super.key});

  @override
  State<RoundUpHistoryScreen> createState() => _RoundUpHistoryScreenState();
}

class _RoundUpHistoryScreenState extends State<RoundUpHistoryScreen> {
  final RoundUpService _roundUpService = getIt<RoundUpService>();
  final SettingsService _settingsService = getIt<SettingsService>();
  final Database _database = getIt<Database>();
  
  List<RoundUpHistoryItem> _historyItems = [];
  RoundUpStatistics? _statistics;
  bool _isLoading = true;
  String _selectedPeriod = 'This Month';
  
  final List<String> _periods = [
    'This Month',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _loadRoundUpHistory();
  }

  Future<void> _loadRoundUpHistory() async {
    setState(() => _isLoading = true);
    
    try {
      final dateRange = _getDateRangeForPeriod(_selectedPeriod);
      
      // Get round-up allocations from database
      final allocations = await _database.getRoundUpAllocations(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
      
      // Convert to history items
      final historyItems = <RoundUpHistoryItem>[];
      double totalRoundUp = 0;
      int totalTransactions = 0;
      final goalBreakdown = <String, double>{};
      
      for (final allocation in allocations) {
        final event = await _database.getEventById(allocation.eventId);
        final goal = await _database.getSavingGoalById(allocation.goalId);
        
        if (event != null && goal != null) {
          final originalAmount = event.amount;
          final roundUpAmount = allocation.allocationAmount;
          
          historyItems.add(RoundUpHistoryItem(
            id: allocation.id,
            eventTitle: event.title,
            originalAmount: originalAmount,
            roundUpAmount: roundUpAmount,
            goalTitle: goal.title,
            goalId: goal.id,
            date: event.date,
          ));
          
          totalRoundUp += roundUpAmount;
          totalTransactions++;
          goalBreakdown[goal.title] = (goalBreakdown[goal.title] ?? 0) + roundUpAmount;
        }
      }
      
      // Sort by date (most recent first)
      historyItems.sort((a, b) => b.date.compareTo(a.date));
      
      // Calculate statistics
      final averageRoundUp = totalTransactions > 0 ? totalRoundUp / totalTransactions : 0.0;
      
      setState(() {
        _historyItems = historyItems;
        _statistics = RoundUpStatistics(
          totalRoundUpAmount: totalRoundUp,
          totalTransactions: totalTransactions,
          averageRoundUp: averageRoundUp,
          goalBreakdown: goalBreakdown,
          period: _selectedPeriod,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading round-up history: $e')),
        );
      }
    }
  }

  DateRange _getDateRangeForPeriod(String period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (period) {
      case 'This Month':
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: today,
        );
      case 'Last 3 Months':
        return DateRange(
          start: DateTime(now.year, now.month - 2, 1),
          end: today,
        );
      case 'Last 6 Months':
        return DateRange(
          start: DateTime(now.year, now.month - 5, 1),
          end: today,
        );
      case 'This Year':
        return DateRange(
          start: DateTime(now.year, 1, 1),
          end: today,
        );
      case 'All Time':
        return DateRange(
          start: DateTime(2020, 1, 1),
          end: today,
        );
      default:
        return DateRange(start: today, end: today);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Round-Up History'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String period) {
              setState(() => _selectedPeriod = period);
              _loadRoundUpHistory();
            },
            itemBuilder: (BuildContext context) {
              return _periods.map((String period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Row(
                    children: [
                      if (period == _selectedPeriod) ...[
                        const Icon(Icons.check, size: 18),
                        const SizedBox(width: 8),
                      ] else
                        const SizedBox(width: 26),
                      Text(period),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRoundUpHistory,
              child: CustomScrollView(
                slivers: [
                  if (_statistics != null) ...[
                    SliverToBoxAdapter(
                      child: _buildStatisticsCard(_statistics!),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                  
                  if (_historyItems.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No Round-Up History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Round-up transactions will appear here',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = _historyItems[index];
                          return _buildHistoryItem(item);
                        },
                        childCount: _historyItems.length,
                      ),
                    ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsCard(RoundUpStatistics stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${stats.period} Summary',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Round-Up',
                  '\$${stats.totalRoundUpAmount.toStringAsFixed(2)}',
                  Icons.savings,
                  Theme.of(context).primaryColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Transactions',
                  stats.totalTransactions.toString(),
                  Icons.receipt,
                  Colors.blue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Average',
                  '\$${stats.averageRoundUp.toStringAsFixed(2)}',
                  Icons.analytics,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Goals Funded',
                  stats.goalBreakdown.length.toString(),
                  Icons.flag,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          if (stats.goalBreakdown.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Goal Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...stats.goalBreakdown.entries.map((entry) => 
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryItem(RoundUpHistoryItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_upward,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          title: Text(
            item.eventTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Rounded up to ${item.goalTitle}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(item.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+\$${item.roundUpAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'from \$${item.originalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class RoundUpHistoryItem {
  final int id;
  final String eventTitle;
  final double originalAmount;
  final double roundUpAmount;
  final String goalTitle;
  final int goalId;
  final DateTime date;

  RoundUpHistoryItem({
    required this.id,
    required this.eventTitle,
    required this.originalAmount,
    required this.roundUpAmount,
    required this.goalTitle,
    required this.goalId,
    required this.date,
  });
}

class RoundUpStatistics {
  final double totalRoundUpAmount;
  final int totalTransactions;
  final double averageRoundUp;
  final Map<String, double> goalBreakdown;
  final String period;

  RoundUpStatistics({
    required this.totalRoundUpAmount,
    required this.totalTransactions,
    required this.averageRoundUp,
    required this.goalBreakdown,
    required this.period,
  });
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}