import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'dart:math' as math;
import '../core/error/failures.dart';
import '../data/database/database.dart';
import '../data/models/freezed/financial_suggestion.dart';
import '../data/models/freezed/event.dart';
import '../data/models/freezed/saving_goal.dart';
import '../data/repositories/saving_goal_repository.dart';
import '../services/category_service.dart';

/// Advanced savings opportunity detection patterns
enum OpportunityPattern {
  subscriptionOptimization,
  categoryReduction,
  roundUpMaximization,
  seasonalSavings,
  frequencyReduction,
  merchantSwitch,
  goalReallocation,
  unusedBudget,
}

/// Detailed savings opportunity analysis
class SavingsOpportunityAnalysis {
  final String id;
  final OpportunityPattern pattern;
  final String title;
  final String description;
  final double potentialMonthlySavings;
  final double potentialAnnualSavings;
  final double confidence;
  final Map<String, dynamic> analysisData;
  final List<String> actionSteps;
  final int? categoryId;
  final int? goalId;
  final DateTime detectedAt;

  const SavingsOpportunityAnalysis({
    required this.id,
    required this.pattern,
    required this.title,
    required this.description,
    required this.potentialMonthlySavings,
    required this.potentialAnnualSavings,
    required this.confidence,
    required this.analysisData,
    required this.actionSteps,
    this.categoryId,
    this.goalId,
    required this.detectedAt,
  });

  /// Check if opportunity is worth acting on
  bool get isWorthActingOn => 
      potentialMonthlySavings >= 10.0 && confidence >= 0.5;

  /// Get priority based on savings potential
  SuggestionPriority get priority {
    if (potentialMonthlySavings >= 100) return SuggestionPriority.urgent;
    if (potentialMonthlySavings >= 50) return SuggestionPriority.high;
    if (potentialMonthlySavings >= 20) return SuggestionPriority.medium;
    return SuggestionPriority.low;
  }

  /// Convert to financial suggestion
  FinancialSuggestion toSuggestion() {
    return FinancialSuggestion(
      id: 'savings_opportunity_$id',
      type: SuggestionType.savingsOpportunity,
      priority: priority,
      title: title,
      description: '$description\n\nPotential annual savings: \$${potentialAnnualSavings.toStringAsFixed(2)}',
      potentialSavings: potentialMonthlySavings,
      relatedCategoryId: categoryId,
      relatedGoalId: goalId,
      createdAt: detectedAt,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      actionData: {
        'pattern': pattern.toString(),
        'confidence': confidence,
        'actionSteps': actionSteps,
        'analysisData': analysisData,
      },
    );
  }
}

/// Service for detecting advanced savings opportunities
@injectable
class SavingsOpportunityDetector {
  final Database _database;
  final ISavingGoalRepository _goalRepository;
  final CategoryService _categoryService;

  SavingsOpportunityDetector(
    this._database,
    this._goalRepository,
    this._categoryService,
  );

  /// Detect all types of savings opportunities
  Future<Either<Failure, List<SavingsOpportunityAnalysis>>> detectAllOpportunities() async {
    try {
      print('💰 Savings Detector: Starting comprehensive opportunity analysis...');
      
      final opportunities = <SavingsOpportunityAnalysis>[];

      // 1. Subscription optimization
      final subscriptionOpportunities = await _detectSubscriptionOptimization();
      opportunities.addAll(subscriptionOpportunities);

      // 2. Category spending reduction
      final categoryOpportunities = await _detectCategoryReduction();
      opportunities.addAll(categoryOpportunities);

      // 3. Round-up maximization
      final roundUpOpportunities = await _detectRoundUpMaximization();
      opportunities.addAll(roundUpOpportunities);

      // 4. Seasonal savings patterns
      final seasonalOpportunities = await _detectSeasonalSavings();
      opportunities.addAll(seasonalOpportunities);

      // 5. Frequency reduction opportunities
      final frequencyOpportunities = await _detectFrequencyReduction();
      opportunities.addAll(frequencyOpportunities);

      // 6. Merchant switching opportunities
      final merchantOpportunities = await _detectMerchantSwitching();
      opportunities.addAll(merchantOpportunities);

      // 7. Goal reallocation opportunities
      final goalOpportunities = await _detectGoalReallocation();
      opportunities.addAll(goalOpportunities);

      // 8. Unused budget opportunities
      final budgetOpportunities = await _detectUnusedBudget();
      opportunities.addAll(budgetOpportunities);

      // Sort by potential savings and filter low-confidence opportunities
      final filteredOpportunities = opportunities
          .where((op) => op.isWorthActingOn)
          .toList()
        ..sort((a, b) => b.potentialMonthlySavings.compareTo(a.potentialMonthlySavings));

      print('💰 Savings Detector: Found ${filteredOpportunities.length} actionable opportunities');
      return Right(filteredOpportunities.take(15).toList());
    } catch (e) {
      return Left(DatabaseFailure('Failed to detect savings opportunities: $e'));
    }
  }

  /// Detect subscription optimization opportunities
  Future<List<SavingsOpportunityAnalysis>> _detectSubscriptionOptimization() async {
    print('💰 Detecting subscription optimization opportunities...');
    
    final opportunities = <SavingsOpportunityAnalysis>[];
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final eventsResult = await _database.getEventsForRange(sixMonthsAgo, DateTime.now());
    final events = await _convertToEvents(eventsResult);

    // Look for recurring patterns that might be subscriptions
    final recurringPatterns = _findRecurringPatterns(events);
    
    for (final pattern in recurringPatterns) {
      if (pattern['frequency'] >= 3 && pattern['averageAmount'] > 5.0) {
        final monthlyAmount = pattern['averageAmount'] as double;
        final title = pattern['title'] as String;
        
        // Estimate potential savings (5-15% reduction through optimization)
        final potentialSavings = monthlyAmount * 0.1; // 10% average
        
        if (potentialSavings >= 2.0) {
          opportunities.add(SavingsOpportunityAnalysis(
            id: 'subscription_${pattern['id']}',
            pattern: OpportunityPattern.subscriptionOptimization,
            title: 'Optimize $title Subscription',
            description: 'Review your $title subscription (\$${monthlyAmount.toStringAsFixed(2)}/month). Consider canceling, downgrading, or finding alternatives.',
            potentialMonthlySavings: potentialSavings,
            potentialAnnualSavings: potentialSavings * 12,
            confidence: 0.7,
            analysisData: {
              'originalAmount': monthlyAmount,
              'frequency': pattern['frequency'],
              'categoryId': pattern['categoryId'],
            },
            actionSteps: [
              'Review subscription features you actually use',
              'Check for annual plans with better rates',
              'Look for similar services at lower cost',
              'Consider canceling if not essential',
            ],
            categoryId: pattern['categoryId'] as int?,
            detectedAt: DateTime.now(),
          ));
        }
      }
    }

    return opportunities;
  }

  /// Detect category spending reduction opportunities
  Future<List<SavingsOpportunityAnalysis>> _detectCategoryReduction() async {
    print('💰 Detecting category reduction opportunities...');
    
    final opportunities = <SavingsOpportunityAnalysis>[];
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final eventsResult = await _database.getEventsForRange(threeMonthsAgo, DateTime.now());
    final events = await _convertToEvents(eventsResult);
    
    // Group spending by category
    final categorySpending = <int, List<Event>>{};
    for (final event in events.where((e) => e.amount < 0)) {
      categorySpending.putIfAbsent(event.categoryId, () => []).add(event);
    }

    final categoriesResult = await _categoryService.getCategories();
    await categoriesResult.fold(
      (failure) => print('Error loading categories: ${failure.message}'),
      (categories) async {
        for (final category in categories) {
          final categoryEvents = categorySpending[category.id] ?? [];
          if (categoryEvents.isNotEmpty) {
            final monthlyAverage = categoryEvents.fold<double>(0, (sum, e) => sum + e.amount.abs()) / 3;
            
            // Focus on categories with significant spending (>$100/month)
            if (monthlyAverage > 100) {
              final transactionCount = categoryEvents.length;
              final averageTransaction = monthlyAverage / transactionCount;
              
              // Suggest 15% reduction for high-spending categories
              final potentialSavings = monthlyAverage * 0.15;
              
              opportunities.add(SavingsOpportunityAnalysis(
                id: 'category_reduction_${category.id}',
                pattern: OpportunityPattern.categoryReduction,
                title: 'Reduce ${category.name} Spending',
                description: 'You spend an average of \$${monthlyAverage.toStringAsFixed(2)} monthly on ${category.name}. Consider reducing by 15% through mindful spending.',
                potentialMonthlySavings: potentialSavings,
                potentialAnnualSavings: potentialSavings * 12,
                confidence: 0.6,
                analysisData: {
                  'monthlyAverage': monthlyAverage,
                  'transactionCount': transactionCount,
                  'averageTransaction': averageTransaction,
                },
                actionSteps: [
                  'Set a monthly budget for ${category.name}',
                  'Track spending in this category more carefully',
                  'Look for cheaper alternatives',
                  'Reduce frequency of purchases',
                ],
                categoryId: category.id,
                detectedAt: DateTime.now(),
              ));
            }
          }
        }
      },
    );

    return opportunities;
  }

  /// Detect round-up maximization opportunities
  Future<List<SavingsOpportunityAnalysis>> _detectRoundUpMaximization() async {
    print('💰 Detecting round-up maximization opportunities...');
    
    final opportunities = <SavingsOpportunityAnalysis>[];
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final eventsResult = await _database.getEventsForRange(threeMonthsAgo, DateTime.now());
    final events = await _convertToEvents(eventsResult);
    
    final transactions = events.where((e) => e.amount < 0).toList();
    
    if (transactions.length > 50) { // Need significant transaction volume
      // Calculate potential round-up savings
      double totalRoundUpPotential = 0;
      for (final transaction in transactions) {
        final amount = transaction.amount.abs();
        final roundUp = math.ceil(amount) - amount;
        totalRoundUpPotential += roundUp;
      }
      
      final monthlyRoundUpPotential = totalRoundUpPotential / 3; // 3 months
      
      if (monthlyRoundUpPotential >= 10.0) {
        opportunities.add(SavingsOpportunityAnalysis(
          id: 'roundup_maximization',
          pattern: OpportunityPattern.roundUpMaximization,
          title: 'Maximize Round-Up Savings',
          description: 'Based on your transaction patterns, you could save an additional \$${monthlyRoundUpPotential.toStringAsFixed(2)} monthly through round-up rules.',
          potentialMonthlySavings: monthlyRoundUpPotential,
          potentialAnnualSavings: monthlyRoundUpPotential * 12,
          confidence: 0.8,
          analysisData: {
            'transactionCount': transactions.length,
            'averageRoundUp': totalRoundUpPotential / transactions.length,
          },
          actionSteps: [
            'Enable round-up on all transactions',
            'Set up automatic transfer of round-up amounts',
            'Choose a high-yield savings account for round-ups',
            'Review and adjust round-up settings monthly',
          ],
          detectedAt: DateTime.now(),
        ));
      }
    }

    return opportunities;
  }

  /// Detect seasonal savings patterns
  Future<List<SavingsOpportunityAnalysis>> _detectSeasonalSavings() async {
    print('💰 Detecting seasonal savings opportunities...');
    
    final opportunities = <SavingsOpportunityAnalysis>[];
    final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));
    final eventsResult = await _database.getEventsForRange(oneYearAgo, DateTime.now());
    final events = await _convertToEvents(eventsResult);
    
    // Analyze spending by month to find seasonal patterns
    final monthlySpending = <int, double>{};
    for (final event in events.where((e) => e.amount < 0)) {
      final month = event.dateTime.month;
      monthlySpending[month] = (monthlySpending[month] ?? 0) + event.amount.abs();
    }
    
    if (monthlySpending.length >= 8) { // Need at least 8 months of data
      final averageMonthly = monthlySpending.values.reduce((a, b) => a + b) / monthlySpending.length;
      
      // Find months with significantly higher spending
      for (final entry in monthlySpending.entries) {
        if (entry.value > averageMonthly * 1.5) { // 50% above average
          final month = entry.key;
          final monthName = _getMonthName(month);
          final excessSpending = entry.value - averageMonthly;
          
          // Potential to reduce seasonal excess by 25%
          final potentialSavings = (excessSpending * 0.25) / 12; // Spread over year
          
          if (potentialSavings >= 5.0) {
            opportunities.add(SavingsOpportunityAnalysis(
              id: 'seasonal_$month',
              pattern: OpportunityPattern.seasonalSavings,
              title: 'Plan for $monthName Spending',
              description: 'You typically spend \$${entry.value.toStringAsFixed(2)} in $monthName, which is ${((entry.value / averageMonthly - 1) * 100).toStringAsFixed(0)}% above your monthly average. Plan ahead to reduce seasonal overspending.',
              potentialMonthlySavings: potentialSavings,
              potentialAnnualSavings: excessSpending * 0.25,
              confidence: 0.6,
              analysisData: {
                'month': month,
                'monthlyAmount': entry.value,
                'averageMonthly': averageMonthly,
                'excessAmount': excessSpending,
              },
              actionSteps: [
                'Set a specific budget for $monthName',
                'Start saving for $monthName expenses in advance',
                'Look for deals and discounts before the month',
                'Consider spreading purchases across multiple months',
              ],
              detectedAt: DateTime.now(),
            ));
          }
        }
      }
    }

    return opportunities;
  }

  /// Detect frequency reduction opportunities
  Future<List<SavingsOpportunityAnalysis>> _detectFrequencyReduction() async {
    print('💰 Detecting frequency reduction opportunities...');
    
    final opportunities = <SavingsOpportunityAnalysis>[];
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final eventsResult = await _database.getEventsForRange(threeMonthsAgo, DateTime.now());
    final events = await _convertToEvents(eventsResult);
    
    // Group by category and analyze frequency
    final categoryAnalysis = <int, Map<String, dynamic>>{};
    for (final event in events.where((e) => e.amount < 0)) {
      if (!categoryAnalysis.containsKey(event.categoryId)) {
        categoryAnalysis[event.categoryId] = {
          'events': <Event>[],
          'totalAmount': 0.0,
        };
      }
      categoryAnalysis[event.categoryId]!['events'].add(event);
      categoryAnalysis[event.categoryId]!['totalAmount'] += event.amount.abs();
    }

    final categoriesResult = await _categoryService.getCategories();
    await categoriesResult.fold(
      (failure) => print('Error loading categories: ${failure.message}'),
      (categories) async {
        for (final category in categories) {
          final analysis = categoryAnalysis[category.id];
          if (analysis != null) {
            final events = analysis['events'] as List<Event>;
            final totalAmount = analysis['totalAmount'] as double;
            
            // Look for high-frequency, small-amount categories
            if (events.length > 20 && totalAmount / events.length < 15) { // >20 transactions, <$15 average
              final monthlyFrequency = events.length / 3; // 3 months
              final monthlyAmount = totalAmount / 3;
              
              // Suggest reducing frequency by 20%
              final potentialSavings = monthlyAmount * 0.2;
              
              if (potentialSavings >= 5.0) {
                opportunities.add(SavingsOpportunityAnalysis(
                  id: 'frequency_${category.id}',
                  pattern: OpportunityPattern.frequencyReduction,
                  title: 'Reduce ${category.name} Frequency',
                  description: 'You make ${monthlyFrequency.toStringAsFixed(0)} ${category.name} purchases monthly. Reducing frequency by 20% could save money while maintaining satisfaction.',
                  potentialMonthlySavings: potentialSavings,
                  potentialAnnualSavings: potentialSavings * 12,
                  confidence: 0.7,
                  analysisData: {
                    'monthlyFrequency': monthlyFrequency,
                    'monthlyAmount': monthlyAmount,
                    'averageTransaction': totalAmount / events.length,
                  },
                  actionSteps: [
                    'Set a weekly limit for ${category.name} purchases',
                    'Plan purchases in advance',
                    'Try bulk buying when appropriate',
                    'Find alternative ways to satisfy the same need',
                  ],
                  categoryId: category.id,
                  detectedAt: DateTime.now(),
                ));
              }
            }
          }
        }
      },
    );

    return opportunities;
  }

  /// Detect merchant switching opportunities
  Future<List<SavingsOpportunityAnalysis>> _detectMerchantSwitching() async {
    print('💰 Detecting merchant switching opportunities...');
    
    // This would require merchant data analysis
    // For now, return empty list as merchant data might not be available
    return <SavingsOpportunityAnalysis>[];
  }

  /// Detect goal reallocation opportunities
  Future<List<SavingsOpportunityAnalysis>> _detectGoalReallocation() async {
    print('💰 Detecting goal reallocation opportunities...');
    
    final opportunities = <SavingsOpportunityAnalysis>[];
    final goalsResult = await _goalRepository.getAllGoals();
    
    await goalsResult.fold(
      (failure) => print('Error loading goals: ${failure.message}'),
      (goals) async {
        // Look for overfunded goals that could redirect to underfunded ones
        final overfundedGoals = <SavingGoal>[];
        final underfundedGoals = <SavingGoal>[];
        
        for (final goal in goals) {
          final progress = goal.currentAmount / goal.targetAmount;
          final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;
          
          if (progress > 0.8 && daysRemaining > 90) {
            overfundedGoals.add(goal);
          } else if (progress < 0.3 && daysRemaining < 180) {
            underfundedGoals.add(goal);
          }
        }
        
        if (overfundedGoals.isNotEmpty && underfundedGoals.isNotEmpty) {
          // Suggest reallocating from overfunded to underfunded goals
          final potentialReallocation = overfundedGoals.first.currentAmount * 0.1; // 10% reallocation
          
          opportunities.add(SavingsOpportunityAnalysis(
            id: 'goal_reallocation',
            pattern: OpportunityPattern.goalReallocation,
            title: 'Rebalance Goal Allocations',
            description: 'Consider reallocating some funds from ahead-of-schedule goals to goals that need more attention.',
            potentialMonthlySavings: 0, // This is more about optimization than savings
            potentialAnnualSavings: 0,
            confidence: 0.8,
            analysisData: {
              'overfundedGoals': overfundedGoals.map((g) => g.id).toList(),
              'underfundedGoals': underfundedGoals.map((g) => g.id).toList(),
              'potentialReallocation': potentialReallocation,
            },
            actionSteps: [
              'Review progress on all savings goals',
              'Identify goals that are ahead of schedule',
              'Redirect some allocations to urgent goals',
              'Update auto-allocation rules accordingly',
            ],
            detectedAt: DateTime.now(),
          ));
        }
      },
    );

    return opportunities;
  }

  /// Detect unused budget opportunities
  Future<List<SavingsOpportunityAnalysis>> _detectUnusedBudget() async {
    print('💰 Detecting unused budget opportunities...');
    
    // This would require budget vs actual spending comparison
    // For now, return empty list as budget data structure is not defined
    return <SavingsOpportunityAnalysis>[];
  }

  /// Find recurring payment patterns
  List<Map<String, dynamic>> _findRecurringPatterns(List<Event> events) {
    final patterns = <String, Map<String, dynamic>>{};
    
    for (final event in events.where((e) => e.amount < 0)) {
      final title = event.title.toLowerCase();
      
      if (!patterns.containsKey(title)) {
        patterns[title] = {
          'id': event.id,
          'title': event.title,
          'categoryId': event.categoryId,
          'amounts': <double>[],
          'dates': <DateTime>[],
        };
      }
      
      patterns[title]!['amounts'].add(event.amount.abs());
      patterns[title]!['dates'].add(event.dateTime);
    }
    
    // Filter for recurring patterns (at least 3 occurrences)
    final recurringPatterns = <Map<String, dynamic>>[];
    
    for (final pattern in patterns.values) {
      final amounts = pattern['amounts'] as List<double>;
      final dates = pattern['dates'] as List<DateTime>;
      
      if (amounts.length >= 3) {
        // Check if amounts are similar (within 20% variance)
        final averageAmount = amounts.reduce((a, b) => a + b) / amounts.length;
        final variance = amounts.map((a) => (a - averageAmount).abs() / averageAmount).reduce(math.max);
        
        if (variance <= 0.2) { // Similar amounts
          // Check if dates are somewhat regular
          dates.sort();
          final intervals = <int>[];
          for (int i = 1; i < dates.length; i++) {
            intervals.add(dates[i].difference(dates[i - 1]).inDays);
          }
          
          if (intervals.isNotEmpty) {
            final averageInterval = intervals.reduce((a, b) => a + b) / intervals.length;
            
            // If average interval is 25-35 days, it's likely monthly
            if (averageInterval >= 25 && averageInterval <= 35) {
              recurringPatterns.add({
                ...pattern,
                'frequency': amounts.length,
                'averageAmount': averageAmount,
                'averageInterval': averageInterval,
              });
            }
          }
        }
      }
    }
    
    return recurringPatterns;
  }

  /// Convert database events to domain events
  Future<List<Event>> _convertToEvents(List<EventTableData> eventData) async {
    return eventData.map((e) => Event(
      id: e.id,
      originalEventId: e.originalEventId,
      title: e.title,
      categoryId: e.categoryId,
      amount: e.amount,
      dateTime: e.date,
      repeatOption: e.repeatOption,
      isRecurring: e.isRecurring,
      notes: e.notes,
      customRecurrence: e.customRecurrence,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      isYearEndSummary: false,
    )).toList();
  }

  /// Get month name from number
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}