import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../state/event_notifier.dart';
import '../../state/category_notifier.dart';
import '../../data/models/freezed/event.dart';
import '../../theme/design_tokens.dart';
import '../components/cash_components.dart';
import '../../core/di/injection.dart';
import '../../data/database/database.dart';

class TransactionsScreen extends StatefulWidget {
  static const routeName = '/transactions';
  
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Event> _allTransactions = [];
  List<Event> _filteredTransactions = [];
  String _searchQuery = '';
  String _filterType = 'all'; // 'all', 'income', 'expense'
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllTransactions();
  }

  Future<void> _loadAllTransactions() async {
    setState(() => _isLoading = true);
    
    try {
      final eventNotifier = Provider.of<EventNotifier>(context, listen: false);
      final currentYear = DateTime.now().year;
      
      // Get all events from the current year
      final allEvents = eventNotifier.getEventsForDateRange(
        DateTime(currentYear, 1, 1),
        DateTime(currentYear, 12, 31),
      );
      
      // Sort by date (most recent first), then by creation time
      final sortedEvents = allEvents.toList()
        ..sort((a, b) {
          final dateComparison = b.dateTime.compareTo(a.dateTime);
          if (dateComparison != 0) {
            return dateComparison;
          }
          return b.createdAt.compareTo(a.createdAt);
        });
      
      setState(() {
        _allTransactions = sortedEvents;
        _filteredTransactions = sortedEvents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading transactions: $e')),
        );
      }
    }
  }

  void _filterTransactions() {
    setState(() {
      _filteredTransactions = _allTransactions.where((transaction) {
        // Filter by type
        bool matchesType = true;
        if (_filterType == 'income') {
          matchesType = transaction.isPositiveCashflow;
        } else if (_filterType == 'expense') {
          matchesType = !transaction.isPositiveCashflow;
        }
        
        // Filter by search query
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          matchesSearch = transaction.title.toLowerCase().contains(_searchQuery.toLowerCase());
        }
        
        return matchesType && matchesSearch;
      }).toList();
    });
  }

  Future<String> _getCategoryName(int categoryId) async {
    try {
      final database = getIt<Database>();
      final category = await database.getCategoryById(categoryId);
      return category?.name ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDay = DateTime(date.year, date.month, date.day);
    
    final difference = today.difference(transactionDay).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Search bar
        TextField(
          decoration: InputDecoration(
            hintText: 'Search transactions...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: DesignTokens.radius('md'),
              borderSide: BorderSide(color: DesignTokens.color('border')),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: DesignTokens.space('md'),
              vertical: DesignTokens.space('sm'),
            ),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            _filterTransactions();
          },
        ),
        VSpace('md'),
        // Filter chips
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('All'),
                selected: _filterType == 'all',
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _filterType = 'all');
                    _filterTransactions();
                  }
                },
              ),
            ),
            HSpace('sm'),
            Expanded(
              child: ChoiceChip(
                label: const Text('Income'),
                selected: _filterType == 'income',
                selectedColor: DesignTokens.color('incomeLight'),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _filterType = 'income');
                    _filterTransactions();
                  }
                },
              ),
            ),
            HSpace('sm'),
            Expanded(
              child: ChoiceChip(
                label: const Text('Expenses'),
                selected: _filterType == 'expense',
                selectedColor: DesignTokens.color('expenseLight'),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _filterType = 'expense');
                    _filterTransactions();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Event transaction) {
    return CashCard(
      financialContext: transaction.isPositiveCashflow 
          ? FinancialContext.income 
          : FinancialContext.expense,
      child: Padding(
        padding: EdgeInsets.all(DesignTokens.space('md')),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Amount
            Row(
              children: [
                Expanded(
                  child: ResponsiveText(
                    transaction.title,
                    styleToken: 'titleSmall',
                    style: DesignTokens.textStyle('titleSmall').copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                  ),
                ),
                HSpace('md'),
                FinancialAmount(
                  amount: transaction.amount,
                  size: FinancialAmountSize.large,
                  adaptive: true,
                ),
              ],
            ),
            VSpace('sm'),
            // Category and Date
            Row(
              children: [
                Icon(
                  transaction.isPositiveCashflow ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: transaction.isPositiveCashflow 
                      ? DesignTokens.color('income') 
                      : DesignTokens.color('expense'),
                ),
                HSpace('xs'),
                Expanded(
                  child: FutureBuilder<String>(
                    future: _getCategoryName(transaction.categoryId),
                    builder: (context, snapshot) {
                      return ResponsiveText(
                        snapshot.data ?? 'Loading...',
                        styleToken: 'bodyMedium',
                        style: DesignTokens.textStyle('bodyMedium').copyWith(
                          color: DesignTokens.color('textSecondary'),
                        ),
                      );
                    },
                  ),
                ),
                ResponsiveText(
                  _formatDate(transaction.dateTime),
                  styleToken: 'bodySmall',
                  style: DesignTokens.textStyle('bodySmall').copyWith(
                    color: DesignTokens.color('textSecondary'),
                  ),
                ),
              ],
            ),
            // Recurring indicator
            if (transaction.isRecurring) ...[
              VSpace('xs'),
              Row(
                children: [
                  Icon(
                    Icons.repeat,
                    size: 14,
                    color: DesignTokens.color('textTertiary'),
                  ),
                  HSpace('xs'),
                  ResponsiveText(
                    'Recurring',
                    styleToken: 'bodySmall',
                    style: DesignTokens.textStyle('bodySmall').copyWith(
                      color: DesignTokens.color('textTertiary'),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(DesignTokens.space('lg')),
                child: Column(
                  children: [
                    _buildSearchAndFilter(),
                    VSpace('lg'),
                    // Results summary
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ResponsiveText(
                          '${_filteredTransactions.length} transactions',
                          styleToken: 'titleMedium',
                        ),
                        if (_filteredTransactions.isNotEmpty)
                          ResponsiveText(
                            'Total: ',
                            styleToken: 'bodyMedium',
                            style: DesignTokens.textStyle('bodyMedium').copyWith(
                              color: DesignTokens.color('textSecondary'),
                            ),
                          ),
                      ],
                    ),
                    VSpace('md'),
                    // Transactions list
                    Expanded(
                      child: _filteredTransactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: DesignTokens.color('textTertiary'),
                                  ),
                                  VSpace('md'),
                                  ResponsiveText(
                                    'No transactions found',
                                    styleToken: 'titleMedium',
                                    style: DesignTokens.textStyle('titleMedium').copyWith(
                                      color: DesignTokens.color('textSecondary'),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  VSpace('sm'),
                                  ResponsiveText(
                                    _searchQuery.isNotEmpty || _filterType != 'all'
                                        ? 'Try adjusting your search or filters'
                                        : 'Start adding transactions to see them here',
                                    styleToken: 'bodyMedium',
                                    style: DesignTokens.textStyle('bodyMedium').copyWith(
                                      color: DesignTokens.color('textTertiary'),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredTransactions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: DesignTokens.space('md'),
                                  ),
                                  child: _buildTransactionItem(_filteredTransactions[index]),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}