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

/// Service that analyzes user financial data and generates intelligent suggestions
@injectable
class FinancialSuggestionsEngine {
  final Database _database;
  final ISavingGoalRepository _goalRepository;
  final CategoryService _categoryService;

  FinancialSuggestionsEngine(
    this._database,
    this._goalRepository,
    this._categoryService,
  );

  /// Generate all types of financial suggestions for the user
  Future<Either<Failure, List<FinancialSuggestion>>> generateAllSuggestions() async {
    try {
      print('🧠 Suggestions Engine: Starting comprehensive analysis...');
      
      List<FinancialSuggestion> allSuggestions = [];

      // 1. Analyze spending patterns
      final spendingPatterns = await _analyzeSpendingPatterns();
      final spendingSuggestions = await _generateSpendingPatternSuggestions(spendingPatterns);
      allSuggestions.addAll(spendingSuggestions);

      // 2. Detect savings opportunities
      final savingsOpportunities = await _detectSavingsOpportunities(spendingPatterns);
      final savingsSuggestions = _convertOpportunitiesToSuggestions(savingsOpportunities);
      allSuggestions.addAll(savingsSuggestions);

      // 3. Analyze goal progress and generate insights
      final goalInsights = await _analyzeGoalProgress();
      final goalSuggestions = _generateGoalSuggestions(goalInsights);
      allSuggestions.addAll(goalSuggestions);

      // 4. Check for unusual activity
      final unusualActivitySuggestions = await _detectUnusualActivity(spendingPatterns);
      allSuggestions.addAll(unusualActivitySuggestions);

      // 5. Optimize round-up and allocation rules
      final optimizationSuggestions = await _generateOptimizationSuggestions();
      allSuggestions.addAll(optimizationSuggestions);

      // Sort by priority and limit to most relevant
      allSuggestions.sort((a, b) => _getSuggestionWeight(b).compareTo(_getSuggestionWeight(a)));
      final topSuggestions = allSuggestions.take(10).toList();

      print('🧠 Suggestions Engine: Generated ${topSuggestions.length} suggestions');
      return Right(topSuggestions);
    } catch (e) {
      return Left(DatabaseFailure('Failed to generate suggestions: $e'));
    }
  }

  /// Analyze user spending patterns over the last 6 months
  Future<List<SpendingPattern>> _analyzeSpendingPatterns() async {
    print('🔍 Analyzing spending patterns...');
    
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final eventsResult = await _database.getEventsForRange(sixMonthsAgo, DateTime.now());
    
    final events = await _convertToEvents(eventsResult);
    final expenseEvents = events.where((e) => e.amount < 0).toList();

    // Group by category
    final categoryMap = <int, List<Event>>{};
    for (final event in expenseEvents) {
      categoryMap.putIfAbsent(event.categoryId, () => []).add(event);
    }

    final patterns = <SpendingPattern>[];
    final categoriesResult = await _categoryService.getCategories();
    
    categoriesResult.fold(
      (failure) => print('Error loading categories: ${failure.message}'),
      (categories) async {
        for (final category in categories) {
          final categoryEvents = categoryMap[category.id] ?? [];
          if (categoryEvents.isNotEmpty) {
            final pattern = await _calculateSpendingPattern(category, categoryEvents);
            patterns.add(pattern);
          }
        }
      },
    );

    return patterns;
  }

  Future<SpendingPattern> _calculateSpendingPattern(
    dynamic category, 
    List<Event> events,
  ) async {
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = currentMonthStart.subtract(const Duration(days: 1));

    final currentMonthEvents = events.where((e) => 
        e.dateTime.isAfter(currentMonthStart) || e.dateTime.isAtSameMomentAs(currentMonthStart)
    ).toList();
    
    final lastMonthEvents = events.where((e) => 
        e.dateTime.isAfter(lastMonthStart) && e.dateTime.isBefore(currentMonthStart)
    ).toList();

    final currentMonth = currentMonthEvents.fold<double>(0, (sum, e) => sum + e.amount.abs());
    final lastMonth = lastMonthEvents.fold<double>(0, (sum, e) => sum + e.amount.abs());
    
    // Calculate monthly trends (last 6 months)
    final monthlyTrends = <double>[];
    for (int i = 5; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 1).subtract(const Duration(days: 1));
      
      final monthEvents = events.where((e) => 
          !e.dateTime.isBefore(monthStart) && !e.dateTime.isAfter(monthEnd)
      ).toList();
      
      final monthTotal = monthEvents.fold<double>(0, (sum, e) => sum + e.amount.abs());
      monthlyTrends.add(monthTotal);
    }

    final averageMonthly = monthlyTrends.isNotEmpty 
        ? monthlyTrends.reduce((a, b) => a + b) / monthlyTrends.length 
        : 0.0;

    // Find peak spending
    final sortedEvents = List<Event>.from(events)..sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    final peakEvent = sortedEvents.isNotEmpty ? sortedEvents.first : null;

    return SpendingPattern(
      categoryId: category.id,
      categoryName: category.name,
      averageMonthly: averageMonthly,
      currentMonth: currentMonth,
      lastMonth: lastMonth,
      transactionCount: events.length,
      firstTransaction: events.map((e) => e.dateTime).reduce((a, b) => a.isBefore(b) ? a : b),
      lastTransaction: events.map((e) => e.dateTime).reduce((a, b) => a.isAfter(b) ? a : b),
      monthlyTrends: monthlyTrends,
      peakAmount: peakEvent?.amount.abs(),
      peakDate: peakEvent?.dateTime,
    );
  }

  /// Generate suggestions based on spending patterns
  Future<List<FinancialSuggestion>> _generateSpendingPatternSuggestions(
    List<SpendingPattern> patterns,
  ) async {
    final suggestions = <FinancialSuggestion>[];

    for (final pattern in patterns) {
      // High spending increase warning
      if (pattern.isIncreasingTrend && pattern.currentMonth > 100) {
        suggestions.add(FinancialSuggestion(
          id: 'spending_increase_${pattern.categoryId}',
          type: SuggestionType.budgetWarning,
          priority: SuggestionPriority.high,
          title: 'Increased ${pattern.categoryName} Spending',
          description: 'Your ${pattern.categoryName} spending increased by ${pattern.trendPercentage.toStringAsFixed(1)}% this month (\$${pattern.currentMonth.toStringAsFixed(2)} vs \$${pattern.lastMonth.toStringAsFixed(2)} last month).',
          actionText: 'Review Transactions',
          actionRoute: '/calendar',
          relatedCategoryId: pattern.categoryId,
          createdAt: DateTime.now(),
        ));
      }

      // Unusual spending alert
      if (pattern.isUnusuallyHigh && pattern.currentMonth > 50) {
        suggestions.add(FinancialSuggestion(
          id: 'unusual_spending_${pattern.categoryId}',
          type: SuggestionType.unusualActivity,
          priority: SuggestionPriority.medium,
          title: 'Unusual ${pattern.categoryName} Activity',
          description: 'You\'ve spent ${pattern.varianceFromAverage.toStringAsFixed(1)}% more than usual on ${pattern.categoryName} this month (\$${pattern.currentMonth.toStringAsFixed(2)} vs \$${pattern.averageMonthly.toStringAsFixed(2)} average).',
          actionText: 'View Details',
          actionRoute: '/calendar',
          relatedCategoryId: pattern.categoryId,
          createdAt: DateTime.now(),
        ));
      }

      // Positive trend recognition
      if (pattern.isDecreasingTrend && pattern.currentMonth < pattern.lastMonth) {
        suggestions.add(FinancialSuggestion(
          id: 'good_spending_${pattern.categoryId}',
          type: SuggestionType.spendingPattern,
          priority: SuggestionPriority.low,
          title: 'Great Job on ${pattern.categoryName}!',
          description: 'You\'ve reduced your ${pattern.categoryName} spending by ${pattern.trendPercentage.abs().toStringAsFixed(1)}% this month. Keep it up!',
          potentialSavings: pattern.lastMonth - pattern.currentMonth,
          relatedCategoryId: pattern.categoryId,
          createdAt: DateTime.now(),
        ));
      }
    }

    return suggestions;
  }

  /// Detect savings opportunities in user spending
  Future<List<SavingsOpportunity>> _detectSavingsOpportunities(
    List<SpendingPattern> patterns,
  ) async {
    final opportunities = <SavingsOpportunity>[];

    for (final pattern in patterns) {
      // High-frequency spending opportunity
      if (pattern.transactionCount > 10 && pattern.averageMonthly > 100) {
        final reductionPotential = pattern.averageMonthly * 0.1; // 10% reduction
        opportunities.add(SavingsOpportunity(
          id: 'reduce_${pattern.categoryId}',
          title: 'Reduce ${pattern.categoryName} Spending',
          description: 'You spend an average of \$${pattern.averageMonthly.toStringAsFixed(2)} monthly on ${pattern.categoryName}. Consider reducing by 10%.',
          potentialMonthlySavings: reductionPotential,
          confidence: 0.7,
          suggestionType: SuggestionType.savingsOpportunity,
          categoryId: pattern.categoryId,
          detectedAt: DateTime.now(),
        ));
      }

      // Round-up opportunity for high-frequency categories
      if (pattern.transactionCount > 15) {
        final roundUpPotential = pattern.transactionCount * 0.5; // Avg 50 cents per transaction
        opportunities.add(SavingsOpportunity(
          id: 'roundup_${pattern.categoryId}',
          title: 'Round-Up Opportunity in ${pattern.categoryName}',
          description: 'With ${pattern.transactionCount} ${pattern.categoryName} transactions, round-up could save you approximately \$${roundUpPotential.toStringAsFixed(2)} monthly.',
          potentialMonthlySavings: roundUpPotential,
          confidence: 0.8,
          suggestionType: SuggestionType.roundUpOptimization,
          categoryId: pattern.categoryId,
          detectedAt: DateTime.now(),
        ));
      }
    }

    return opportunities.where((op) => op.isWorthSuggesting).toList();
  }

  /// Convert savings opportunities to suggestions
  List<FinancialSuggestion> _convertOpportunitiesToSuggestions(
    List<SavingsOpportunity> opportunities,
  ) {
    return opportunities.map((opportunity) {
      final priority = opportunity.potentialMonthlySavings > 50 
          ? SuggestionPriority.high 
          : opportunity.potentialMonthlySavings > 20 
              ? SuggestionPriority.medium 
              : SuggestionPriority.low;

      return FinancialSuggestion(
        id: 'savings_${opportunity.id}',
        type: opportunity.suggestionType,
        priority: priority,
        title: opportunity.title,
        description: '${opportunity.description} Potential annual savings: \$${opportunity.potentialAnnualSavings.toStringAsFixed(2)}',
        potentialSavings: opportunity.potentialMonthlySavings,
        relatedCategoryId: opportunity.categoryId,
        relatedGoalId: opportunity.goalId,
        createdAt: opportunity.detectedAt,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );
    }).toList();
  }

  /// Analyze goal progress and generate insights
  Future<List<GoalInsight>> _analyzeGoalProgress() async {
    print('🎯 Analyzing goal progress...');
    
    final goalsResult = await _goalRepository.getAllGoals();
    final insights = <GoalInsight>[];

    goalsResult.fold(
      (failure) => print('Error loading goals: ${failure.message}'),
      (goals) async {
        for (final goal in goals) {
          final insight = await _calculateGoalInsight(goal);
          insights.add(insight);
                }
      },
    );

    return insights;
  }

  Future<GoalInsight> _calculateGoalInsight(SavingGoal goal) async {
    final now = DateTime.now();
    final daysRemaining = goal.deadlineDate?.difference(now).inDays;
    final monthsRemaining = daysRemaining != null ? daysRemaining / 30.44 : 0; // Average days per month
    
    final remaining = goal.targetAmount - goal.currentAmount;
    final monthlyRequired = monthsRemaining > 0 ? remaining / monthsRemaining : remaining;

    // Calculate average monthly contribution (last 3 months)
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final allocationsResult = await _goalRepository.getGoalAllocationHistory(goal.id);
    
    final recentAllocations = allocationsResult.fold(
      (failure) => <GoalAllocationHistory>[],
      (allocations) => allocations.where((a) => 
          a.date.isAfter(threeMonthsAgo)
      ).toList(),
    );

    final totalContributions = recentAllocations.fold<double>(0, (sum, a) => sum + a.amount);
    final averageMonthly = totalContributions / 3; // 3 months

    final isOnTrack = averageMonthly >= monthlyRequired * 0.9; // 90% threshold
    final projectedCompletionDate = averageMonthly > 0 
        ? now.add(Duration(days: (remaining / (averageMonthly / 30.44)).round()))
        : null;

    final recommendations = <String>[];
    if (!isOnTrack) {
      final shortfall = monthlyRequired - averageMonthly;
      recommendations.add('Increase monthly contributions by \$${shortfall.toStringAsFixed(2)}');
      
      if (shortfall > 100) {
        recommendations.add('Consider extending your target date');
        recommendations.add('Look for additional savings opportunities');
      }
    }

    return GoalInsight(
      goalId: goal.id,
      goalTitle: goal.title,
      currentAmount: goal.currentAmount,
      targetAmount: goal.targetAmount,
      targetDate: goal.deadlineDate ?? DateTime.now().add(const Duration(days: 365)),
      monthlyRequired: monthlyRequired,
      averageMonthlyContribution: averageMonthly,
      daysRemaining: daysRemaining ?? 365,
      isOnTrack: isOnTrack,
      projectedShortfall: isOnTrack ? null : remaining - (averageMonthly * monthsRemaining),
      projectedCompletionDate: projectedCompletionDate,
      recommendations: recommendations,
    );
  }

  /// Generate goal-related suggestions
  List<FinancialSuggestion> _generateGoalSuggestions(List<GoalInsight> insights) {
    final suggestions = <FinancialSuggestion>[];

    for (final insight in insights) {
      // Goal at risk
      if (insight.isAtRisk) {
        suggestions.add(FinancialSuggestion(
          id: 'goal_risk_${insight.goalId}',
          type: SuggestionType.goalRecommendation,
          priority: SuggestionPriority.urgent,
          title: '${insight.goalTitle} Goal at Risk',
          description: 'You need to increase contributions by \$${insight.monthlyGap.toStringAsFixed(2)}/month to reach your ${insight.goalTitle} goal on time.',
          actionText: 'Adjust Goal',
          actionRoute: '/goals/${insight.goalId}',
          relatedGoalId: insight.goalId,
          createdAt: DateTime.now(),
        ));
      }

      // Goal milestone celebration
      if (insight.progressPercentage >= 0.25 && insight.progressPercentage < 0.30) {
        suggestions.add(FinancialSuggestion(
          id: 'goal_milestone_25_${insight.goalId}',
          type: SuggestionType.goalMilestone,
          priority: SuggestionPriority.low,
          title: '25% Progress on ${insight.goalTitle}!',
          description: 'Congratulations! You\'re 25% of the way to your ${insight.goalTitle} goal. Keep up the great work!',
          relatedGoalId: insight.goalId,
          createdAt: DateTime.now(),
        ));
      }

      // Ahead of schedule
      if (insight.isAheadOfSchedule) {
        suggestions.add(FinancialSuggestion(
          id: 'goal_ahead_${insight.goalId}',
          type: SuggestionType.goalMilestone,
          priority: SuggestionPriority.medium,
          title: '${insight.goalTitle} Ahead of Schedule!',
          description: 'Great news! You\'re on track to reach your ${insight.goalTitle} goal early. Consider setting a more ambitious target.',
          actionText: 'Update Goal',
          actionRoute: '/goals/${insight.goalId}',
          relatedGoalId: insight.goalId,
          createdAt: DateTime.now(),
        ));
      }
    }

    return suggestions;
  }

  /// Detect unusual activity patterns
  Future<List<FinancialSuggestion>> _detectUnusualActivity(
    List<SpendingPattern> patterns,
  ) async {
    final suggestions = <FinancialSuggestion>[];

    // Large single transactions in the last week
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentEvents = await _database.getEventsForRange(weekAgo, DateTime.now());
    final events = await _convertToEvents(recentEvents);
    
    final largeTransactions = events.where((e) => e.amount.abs() > 200).toList();
    
    for (final transaction in largeTransactions) {
      final pattern = patterns.where((p) => p.categoryId == transaction.categoryId).firstOrNull;
      if (pattern != null && transaction.amount.abs() > pattern.averageMonthly * 0.5) {
        suggestions.add(FinancialSuggestion(
          id: 'large_transaction_${transaction.id}',
          type: SuggestionType.unusualActivity,
          priority: SuggestionPriority.medium,
          title: 'Large ${pattern.categoryName} Transaction',
          description: 'Detected a large transaction of \$${transaction.amount.abs().toStringAsFixed(2)} for "${transaction.title}" - this is ${((transaction.amount.abs() / pattern.averageMonthly) * 100).toStringAsFixed(0)}% of your monthly ${pattern.categoryName} average.',
          actionText: 'Review Transaction',
          actionRoute: '/calendar',
          relatedCategoryId: transaction.categoryId,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 7)),
        ));
      }
    }

    return suggestions;
  }

  /// Generate optimization suggestions for rules and round-up
  Future<List<FinancialSuggestion>> _generateOptimizationSuggestions() async {
    final suggestions = <FinancialSuggestion>[];

    // TODO: Add round-up optimization suggestions
    // TODO: Add allocation rules optimization suggestions

    return suggestions;
  }

  /// Calculate suggestion weight for prioritization
  int _getSuggestionWeight(FinancialSuggestion suggestion) {
    int weight = 0;
    
    // Priority weight
    switch (suggestion.priority) {
      case SuggestionPriority.urgent:
        weight += 1000;
        break;
      case SuggestionPriority.high:
        weight += 100;
        break;
      case SuggestionPriority.medium:
        weight += 10;
        break;
      case SuggestionPriority.low:
        weight += 1;
        break;
    }

    // Potential savings weight
    if (suggestion.potentialSavings != null) {
      weight += (suggestion.potentialSavings! * 10).round();
    }

    // Type weight
    switch (suggestion.type) {
      case SuggestionType.budgetWarning:
      case SuggestionType.goalRecommendation:
        weight += 50;
        break;
      case SuggestionType.savingsOpportunity:
        weight += 30;
        break;
      case SuggestionType.unusualActivity:
        weight += 20;
        break;
      default:
        weight += 10;
        break;
    }

    return weight;
  }

  /// Helper method to convert database events to domain events
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
}