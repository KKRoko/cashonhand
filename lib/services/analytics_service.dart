import 'package:injectable/injectable.dart';
import '../data/database/database.dart';
import '../data/repositories/saving_goal_repository.dart';
import 'dart:math' as math;

/// Comprehensive analytics service for advanced savings insights
@injectable
class AnalyticsService {
  final Database _database;
  final ISavingGoalRepository _goalRepository;

  AnalyticsService(this._database, this._goalRepository);

  // STEP 11.1: SAVINGS VELOCITY TRACKING

  /// Calculate savings velocity (rate of change in savings over time)
  Future<SavingsVelocityData> getSavingsVelocity({
    Duration period = const Duration(days: 30),
    VelocityGranularity granularity = VelocityGranularity.daily,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(period);
    
    final velocityData = await _database.getVelocityData(startDate, endDate);
    
    if (velocityData.isEmpty) {
      return SavingsVelocityData.empty();
    }

    // Group data by granularity
    final groupedData = _groupVelocityData(velocityData, granularity);
    
    // Calculate velocity metrics
    final velocities = <double>[];
    final totals = groupedData.map((d) => d['total'] as double).toList();
    
    for (int i = 1; i < totals.length; i++) {
      final velocity = totals[i] - totals[i - 1];
      velocities.add(velocity);
    }

    final averageVelocity = velocities.isEmpty ? 0.0 : 
        velocities.reduce((a, b) => a + b) / velocities.length;
    
    final accelerationTrend = _calculateAcceleration(velocities);
    final consistencyScore = _calculateConsistency(velocities);
    
    return SavingsVelocityData(
      averageVelocity: averageVelocity,
      currentVelocity: velocities.isNotEmpty ? velocities.last : 0.0,
      accelerationTrend: accelerationTrend,
      consistencyScore: consistencyScore,
      dataPoints: groupedData,
      period: period,
    );
  }

  /// Calculate velocity with forecasting
  Future<VelocityForecast> getVelocityForecast(Duration lookAhead) async {
    final historical = await getSavingsVelocity(period: const Duration(days: 90));
    
    if (historical.dataPoints.length < 7) {
      return VelocityForecast.insufficient();
    }

    // Simple linear regression for forecasting
    final predictions = _forecastVelocity(historical, lookAhead);
    final confidence = _calculateForecastConfidence(historical);
    
    return VelocityForecast(
      predictions: predictions,
      confidence: confidence,
      basedOnData: historical,
    );
  }

  // STEP 11.2: GOAL COMPLETION PREDICTIVE ANALYTICS

  /// Advanced goal completion prediction with risk assessment
  Future<GoalPredictionAnalytics> getGoalCompletionPrediction(int goalId) async {
    final goalResult = await _goalRepository.getGoal(goalId);
    
    return await goalResult.fold(
      (failure) async => GoalPredictionAnalytics.error('Goal not found'),
      (goal) async {
        if (goal == null) return GoalPredictionAnalytics.error('Goal not found');
        
        // Get historical allocation data
        final allocations = await _database.getAllocationsForGoal(goalId);
        
        if (allocations.length < 3) {
          return GoalPredictionAnalytics.insufficient();
        }

        // Calculate current metrics
        final remainingAmount = goal.targetAmount - goal.currentAmount;
        final progress = goal.currentAmount / goal.targetAmount;
        
        // Historical analysis
        final historicalRate = _calculateHistoricalSavingsRate(allocations);
        final trendAnalysis = _analyzeSavingsTrend(allocations);
        
        // Risk factors
        final riskFactors = await _assessGoalRisks(goal, allocations);
        
        // Predictions with different scenarios
        final optimisticDate = _predictCompletionDate(goal, historicalRate * 1.2);
        final realisticDate = _predictCompletionDate(goal, historicalRate);
        final conservativeDate = _predictCompletionDate(goal, historicalRate * 0.8);
        
        // Probability calculation
        final completionProbability = _calculateCompletionProbability(
          goal, historicalRate, riskFactors
        );
        
        return GoalPredictionAnalytics(
          goalId: goalId,
          currentProgress: progress,
          remainingAmount: remainingAmount,
          historicalRate: historicalRate,
          trendAnalysis: trendAnalysis,
          riskFactors: riskFactors,
          predictions: GoalPredictions(
            optimistic: optimisticDate,
            realistic: realisticDate,
            conservative: conservativeDate,
          ),
          completionProbability: completionProbability,
          recommendations: _generateGoalRecommendations(goal, riskFactors),
        );
      },
    );
  }

  // STEP 11.3: SPENDING VS SAVINGS BALANCE INDICATORS

  /// Comprehensive balance analysis
  Future<SpendingSavingsBalance> getSpendingSavingsBalance({
    Duration period = const Duration(days: 30),
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(period);
    
    // Get spending data
    final spendingByCategory = await _database.getSpendingByCategory(startDate, endDate);
    final totalSpending = spendingByCategory.values.fold<double>(0, (a, b) => a + b);
    
    // Get savings data
    final allocations = await _database.getAllocationsInRange(startDate, endDate);
    final totalSavings = allocations.fold<double>(0, (sum, alloc) => sum + alloc.amount);
    
    // Calculate balance metrics
    final savingsRate = totalSpending > 0 ? totalSavings / totalSpending : 0.0;
    final balanceRatio = totalSpending > 0 ? totalSavings / (totalSpending + totalSavings) : 0.0;
    
    // Trend analysis
    final trendData = await _getBalanceTrend(startDate, endDate);
    final balanceTrend = _analyzeBalanceTrend(trendData);
    
    // Health assessment
    final healthScore = _calculateBalanceHealthScore(savingsRate, balanceRatio, balanceTrend);
    
    // Recommendations
    final recommendations = _generateBalanceRecommendations(
      savingsRate, balanceRatio, spendingByCategory
    );
    
    return SpendingSavingsBalance(
      period: period,
      totalSpending: totalSpending,
      totalSavings: totalSavings,
      savingsRate: savingsRate,
      balanceRatio: balanceRatio,
      spendingByCategory: spendingByCategory,
      balanceTrend: balanceTrend,
      healthScore: healthScore,
      recommendations: recommendations,
      trendData: trendData,
    );
  }

  // STEP 11.4: DETAILED ALLOCATION REPORTS

  /// Comprehensive allocation analysis and reporting
  Future<AllocationReport> getAllocationReport({
    Duration period = const Duration(days: 30),
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(period);
    
    final allocations = await _database.getAllocationsInRange(startDate, endDate);
    final allocationsByType = await _database.getAllocationsByType(startDate, endDate);
    
    if (allocations.isEmpty) {
      return AllocationReport.empty(period);
    }

    // Basic metrics
    final totalAmount = allocations.fold<double>(0, (sum, alloc) => sum + alloc.amount);
    final averageAmount = totalAmount / allocations.length;
    final allocationFrequency = allocations.length / period.inDays;
    
    // Goal distribution
    final goalDistribution = _calculateGoalDistribution(allocations);
    
    // Type analysis
    final typeEffectiveness = await _analyzeAllocationTypeEffectiveness();
    
    // Rule performance
    final rulePerformance = await _analyzeRulePerformance(startDate, endDate);
    
    // Time patterns
    final timePatterns = _analyzeAllocationTimePatterns(allocations);
    
    // Efficiency metrics
    final efficiencyMetrics = _calculateAllocationEfficiency(allocations, rulePerformance);
    
    return AllocationReport(
      period: period,
      totalAmount: totalAmount,
      allocationCount: allocations.length,
      averageAmount: averageAmount,
      frequency: allocationFrequency,
      allocationsByType: allocationsByType,
      goalDistribution: goalDistribution,
      typeEffectiveness: typeEffectiveness,
      rulePerformance: rulePerformance,
      timePatterns: timePatterns,
      efficiencyMetrics: efficiencyMetrics,
      recommendations: _generateAllocationRecommendations(
        efficiencyMetrics, rulePerformance, timePatterns
      ),
    );
  }

  // Helper Methods

  List<Map<String, dynamic>> _groupVelocityData(
    List<Map<String, dynamic>> data, 
    VelocityGranularity granularity
  ) {
    // Implementation for grouping data by granularity
    switch (granularity) {
      case VelocityGranularity.daily:
        return data;
      case VelocityGranularity.weekly:
        // Group by week
        final grouped = <String, Map<String, dynamic>>{};
        for (final item in data) {
          final date = DateTime.parse(item['date'] as String);
          final weekKey = '${date.year}-W${_getWeekOfYear(date)}';
          
          if (grouped.containsKey(weekKey)) {
            grouped[weekKey]!['total'] += item['daily_total'];
            grouped[weekKey]!['count'] += item['allocation_count'];
          } else {
            grouped[weekKey] = {
              'date': weekKey,
              'total': item['daily_total'],
              'count': item['allocation_count'],
            };
          }
        }
        return grouped.values.toList();
      case VelocityGranularity.monthly:
        // Group by month
        final grouped = <String, Map<String, dynamic>>{};
        for (final item in data) {
          final date = DateTime.parse(item['date'] as String);
          final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          
          if (grouped.containsKey(monthKey)) {
            grouped[monthKey]!['total'] += item['daily_total'];
            grouped[monthKey]!['count'] += item['allocation_count'];
          } else {
            grouped[monthKey] = {
              'date': monthKey,
              'total': item['daily_total'],
              'count': item['allocation_count'],
            };
          }
        }
        return grouped.values.toList();
    }
  }

  double _calculateAcceleration(List<double> velocities) {
    if (velocities.length < 2) return 0.0;
    
    final accelerations = <double>[];
    for (int i = 1; i < velocities.length; i++) {
      accelerations.add(velocities[i] - velocities[i - 1]);
    }
    
    return accelerations.isEmpty ? 0.0 : 
        accelerations.reduce((a, b) => a + b) / accelerations.length;
  }

  double _calculateConsistency(List<double> velocities) {
    if (velocities.isEmpty) return 0.0;
    
    final mean = velocities.reduce((a, b) => a + b) / velocities.length;
    final variance = velocities
        .map((v) => math.pow(v - mean, 2))
        .reduce((a, b) => a + b) / velocities.length;
    
    final standardDeviation = math.sqrt(variance);
    return mean != 0 ? (1 - (standardDeviation / mean.abs())).clamp(0.0, 1.0) : 0.0;
  }

  List<Map<String, dynamic>> _forecastVelocity(
    SavingsVelocityData historical, 
    Duration lookAhead
  ) {
    // Simple linear regression implementation
    final dataPoints = historical.dataPoints;
    if (dataPoints.length < 2) return [];
    
    // Calculate trend
    final trend = historical.accelerationTrend;
    final lastValue = dataPoints.last['total'] as double;
    
    final predictions = <Map<String, dynamic>>[];
    final daysToForecast = lookAhead.inDays;
    
    for (int i = 1; i <= daysToForecast; i++) {
      final predictedValue = lastValue + (trend * i);
      predictions.add({
        'day': i,
        'predicted_total': predictedValue.clamp(0, double.infinity),
      });
    }
    
    return predictions;
  }

  double _calculateForecastConfidence(SavingsVelocityData historical) {
    // Based on consistency and data quantity
    final dataQuality = (historical.dataPoints.length / 30.0).clamp(0.0, 1.0);
    return (historical.consistencyScore * 0.7) + (dataQuality * 0.3);
  }

  double _calculateHistoricalSavingsRate(List<GoalAllocationTableData> allocations) {
    if (allocations.length < 2) return 0.0;
    
    final sortedAllocations = [...allocations]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    final totalDays = sortedAllocations.last.createdAt
        .difference(sortedAllocations.first.createdAt).inDays;
    
    if (totalDays <= 0) return 0.0;
    
    final totalAmount = allocations.fold<double>(0, (sum, alloc) => sum + alloc.amount);
    return totalAmount / totalDays;
  }

  SavingsTrend _analyzeSavingsTrend(List<GoalAllocationTableData> allocations) {
    if (allocations.length < 3) return SavingsTrend.insufficient;
    
    final sorted = [...allocations]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    // Calculate weekly averages
    final weeklyAverages = <double>[];
    final now = DateTime.now();
    
    for (int weekOffset = 0; weekOffset < 4; weekOffset++) {
      final weekEnd = now.subtract(Duration(days: weekOffset * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 7));
      
      final weekAllocations = sorted.where(
        (alloc) => alloc.createdAt.isAfter(weekStart) && alloc.createdAt.isBefore(weekEnd)
      );
      
      final weekTotal = weekAllocations.fold<double>(0, (sum, alloc) => sum + alloc.amount);
      weeklyAverages.add(weekTotal);
    }
    
    if (weeklyAverages.length < 2) return SavingsTrend.stable;
    
    // Analyze trend
    final recentAvg = (weeklyAverages[0] + weeklyAverages[1]) / 2;
    final olderAvg = weeklyAverages.length > 2 ? 
        (weeklyAverages[2] + (weeklyAverages.length > 3 ? weeklyAverages[3] : weeklyAverages[2])) / 2 :
        weeklyAverages[1];
    
    final changePercent = olderAvg > 0 ? (recentAvg - olderAvg) / olderAvg : 0.0;
    
    if (changePercent > 0.15) return SavingsTrend.increasing;
    if (changePercent < -0.15) return SavingsTrend.decreasing;
    return SavingsTrend.stable;
  }

  Future<List<RiskFactor>> _assessGoalRisks(
    dynamic goal, 
    List<GoalAllocationTableData> allocations
  ) async {
    final risks = <RiskFactor>[];
    
    // Inconsistent allocation pattern
    if (allocations.length > 0) {
      final daysBetweenAllocations = _calculateAverageAllocationInterval(allocations);
      if (daysBetweenAllocations > 14) {
        risks.add(RiskFactor(
          type: RiskType.inconsistentPattern,
          severity: RiskSeverity.medium,
          description: 'Allocations are infrequent (avg ${daysBetweenAllocations.toStringAsFixed(1)} days apart)',
        ));
      }
    }
    
    // Declining trend
    final trend = _analyzeSavingsTrend(allocations);
    if (trend == SavingsTrend.decreasing) {
      risks.add(RiskFactor(
        type: RiskType.decliningTrend,
        severity: RiskSeverity.high,
        description: 'Recent allocation trend is declining',
      ));
    }
    
    // Time constraint
    final timeRemaining = goal.targetDate.difference(DateTime.now());
    final progress = goal.currentAmount / goal.targetAmount;
    final timeProgress = 1.0 - (timeRemaining.inDays / goal.targetDate.difference(goal.createdAt).inDays);
    
    if (timeProgress > progress + 0.2) {
      risks.add(RiskFactor(
        type: RiskType.timeConstraint,
        severity: RiskSeverity.high,
        description: 'Behind schedule - time progress exceeds savings progress',
      ));
    }
    
    return risks;
  }

  DateTime? _predictCompletionDate(dynamic goal, double dailyRate) {
    if (dailyRate <= 0) return null;
    
    final remainingAmount = goal.targetAmount - goal.currentAmount;
    final daysNeeded = (remainingAmount / dailyRate).ceil();
    
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  double _calculateCompletionProbability(
    dynamic goal, 
    double historicalRate, 
    List<RiskFactor> riskFactors
  ) {
    // Base probability from historical performance
    double baseProbability = 0.7;
    
    // Adjust for progress
    final progress = goal.currentAmount / goal.targetAmount;
    baseProbability += progress * 0.2;
    
    // Adjust for risk factors
    for (final risk in riskFactors) {
      switch (risk.severity) {
        case RiskSeverity.low:
          baseProbability -= 0.05;
          break;
        case RiskSeverity.medium:
          baseProbability -= 0.15;
          break;
        case RiskSeverity.high:
          baseProbability -= 0.25;
          break;
      }
    }
    
    return baseProbability.clamp(0.0, 1.0);
  }

  List<String> _generateGoalRecommendations(dynamic goal, List<RiskFactor> riskFactors) {
    final recommendations = <String>[];
    
    for (final risk in riskFactors) {
      switch (risk.type) {
        case RiskType.inconsistentPattern:
          recommendations.add('Set up auto-allocation rules to maintain consistency');
          break;
        case RiskType.decliningTrend:
          recommendations.add('Review your budget to increase allocation amounts');
          break;
        case RiskType.timeConstraint:
          recommendations.add('Consider extending your target date or increasing contributions');
          break;
      }
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('You\'re on track! Keep up the consistent saving habits.');
    }
    
    return recommendations;
  }

  // Additional helper methods for balance and allocation analysis
  Future<List<Map<String, dynamic>>> _getBalanceTrend(DateTime start, DateTime end) async {
    // Implementation for getting balance trend data
    final days = end.difference(start).inDays;
    final trendData = <Map<String, dynamic>>[];
    
    for (int i = 0; i < days; i += 7) { // Weekly data points
      final weekStart = start.add(Duration(days: i));
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      final weekSpending = await _database.getSpendingByCategory(weekStart, weekEnd);
      final weekAllocations = await _database.getAllocationsInRange(weekStart, weekEnd);
      
      final totalSpending = weekSpending.values.fold<double>(0, (a, b) => a + b);
      final totalSavings = weekAllocations.fold<double>(0, (sum, alloc) => sum + alloc.amount);
      
      trendData.add({
        'week_start': weekStart.toIso8601String(),
        'spending': totalSpending,
        'savings': totalSavings,
        'ratio': totalSpending > 0 ? totalSavings / totalSpending : 0.0,
      });
    }
    
    return trendData;
  }

  BalanceTrend _analyzeBalanceTrend(List<Map<String, dynamic>> trendData) {
    if (trendData.length < 2) return BalanceTrend.insufficient;
    
    final ratios = trendData.map((d) => d['ratio'] as double).toList();
    final recentRatio = ratios.take(2).reduce((a, b) => a + b) / 2;
    final olderRatio = ratios.skip(math.max(0, ratios.length - 2)).reduce((a, b) => a + b) / 2;
    
    final change = recentRatio - olderRatio;
    
    if (change > 0.05) return BalanceTrend.improving;
    if (change < -0.05) return BalanceTrend.worsening;
    return BalanceTrend.stable;
  }

  double _calculateBalanceHealthScore(double savingsRate, double balanceRatio, BalanceTrend trend) {
    double score = 0.0;
    
    // Savings rate contribution (40%)
    score += (savingsRate.clamp(0.0, 0.5) / 0.5) * 0.4;
    
    // Balance ratio contribution (40%)
    score += (balanceRatio.clamp(0.0, 0.5) / 0.5) * 0.4;
    
    // Trend contribution (20%)
    switch (trend) {
      case BalanceTrend.improving:
        score += 0.2;
        break;
      case BalanceTrend.stable:
        score += 0.1;
        break;
      case BalanceTrend.worsening:
        score += 0.0;
        break;
      case BalanceTrend.insufficient:
        score += 0.05;
        break;
    }
    
    return score.clamp(0.0, 1.0);
  }

  List<String> _generateBalanceRecommendations(
    double savingsRate, 
    double balanceRatio, 
    Map<String, double> spendingByCategory
  ) {
    final recommendations = <String>[];
    
    if (savingsRate < 0.1) {
      recommendations.add('Try to save at least 10% of your spending for better financial health');
    }
    
    if (balanceRatio < 0.2) {
      recommendations.add('Consider increasing your savings allocation percentage');
    }
    
    // Analyze top spending categories
    final sortedSpending = spendingByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    if (sortedSpending.isNotEmpty && sortedSpending.first.value > spendingByCategory.values.reduce((a, b) => a + b) * 0.4) {
      recommendations.add('Your top spending category (${sortedSpending.first.key}) accounts for a large portion of expenses');
    }
    
    return recommendations;
  }

  Map<String, double> _calculateGoalDistribution(List<GoalAllocationTableData> allocations) {
    final distribution = <int, double>{};
    
    for (final allocation in allocations) {
      distribution[allocation.goalId] = (distribution[allocation.goalId] ?? 0) + allocation.amount;
    }
    
    // Convert to percentage
    final total = distribution.values.fold<double>(0, (a, b) => a + b);
    return distribution.map((goalId, amount) => 
        MapEntry('Goal $goalId', total > 0 ? amount / total : 0.0));
  }

  Future<Map<String, double>> _analyzeAllocationTypeEffectiveness() async {
    // Analyze effectiveness of different allocation types
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final allocationsByType = await _database.getAllocationsByType(thirtyDaysAgo, DateTime.now());
    
    // Calculate effectiveness metrics
    final effectiveness = <String, double>{};
    final total = allocationsByType.values.fold<double>(0, (a, b) => a + b);
    
    for (final entry in allocationsByType.entries) {
      effectiveness[entry.key] = total > 0 ? entry.value / total : 0.0;
    }
    
    return effectiveness;
  }

  Future<Map<String, dynamic>> _analyzeRulePerformance(DateTime start, DateTime end) async {
    final rules = await _database.getAllAllocationRules();
    final allocations = await _database.getAllocationsInRange(start, end);
    
    // Analyze rule-based vs manual allocations
    final ruleBasedCount = allocations.where((a) => a.ruleId != null).length;
    final manualCount = allocations.length - ruleBasedCount;
    
    final ruleBasedAmount = allocations
        .where((a) => a.ruleId != null)
        .fold<double>(0, (sum, alloc) => sum + alloc.amount);
    
    final manualAmount = allocations
        .where((a) => a.ruleId == null)
        .fold<double>(0, (sum, alloc) => sum + alloc.amount);
    
    return {
      'total_rules': rules.length,
      'active_rules': rules.where((r) => r.isActive).length,
      'rule_based_allocations': ruleBasedCount,
      'manual_allocations': manualCount,
      'rule_based_amount': ruleBasedAmount,
      'manual_amount': manualAmount,
      'automation_rate': allocations.isNotEmpty ? ruleBasedCount / allocations.length : 0.0,
    };
  }

  Map<String, dynamic> _analyzeAllocationTimePatterns(List<GoalAllocationTableData> allocations) {
    final hourDistribution = <int, int>{};
    final dayOfWeekDistribution = <int, int>{};
    
    for (final allocation in allocations) {
      final hour = allocation.createdAt.hour;
      final dayOfWeek = allocation.createdAt.weekday;
      
      hourDistribution[hour] = (hourDistribution[hour] ?? 0) + 1;
      dayOfWeekDistribution[dayOfWeek] = (dayOfWeekDistribution[dayOfWeek] ?? 0) + 1;
    }
    
    // Find peak times
    final peakHour = hourDistribution.entries.isEmpty ? 0 :
        hourDistribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    final peakDay = dayOfWeekDistribution.entries.isEmpty ? 1 :
        dayOfWeekDistribution.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    return {
      'peak_hour': peakHour,
      'peak_day': peakDay,
      'hour_distribution': hourDistribution,
      'day_distribution': dayOfWeekDistribution,
    };
  }

  Map<String, double> _calculateAllocationEfficiency(
    List<GoalAllocationTableData> allocations,
    Map<String, dynamic> rulePerformance
  ) {
    return {
      'average_amount': allocations.isEmpty ? 0.0 : 
          allocations.fold<double>(0, (sum, alloc) => sum + alloc.amount) / allocations.length,
      'automation_efficiency': rulePerformance['automation_rate'] as double,
      'frequency_score': allocations.length / 30.0, // allocations per day
      'consistency_score': _calculateAllocationConsistency(allocations),
    };
  }

  double _calculateAllocationConsistency(List<GoalAllocationTableData> allocations) {
    if (allocations.length < 2) return 0.0;
    
    final sorted = [...allocations]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final intervals = <int>[];
    
    for (int i = 1; i < sorted.length; i++) {
      final interval = sorted[i].createdAt.difference(sorted[i - 1].createdAt).inDays;
      intervals.add(interval);
    }
    
    if (intervals.isEmpty) return 0.0;
    
    final averageInterval = intervals.reduce((a, b) => a + b) / intervals.length;
    final variance = intervals
        .map((i) => math.pow(i - averageInterval, 2))
        .reduce((a, b) => a + b) / intervals.length;
    
    final standardDeviation = math.sqrt(variance);
    return averageInterval > 0 ? (1 - (standardDeviation / averageInterval)).clamp(0.0, 1.0) : 0.0;
  }

  List<String> _generateAllocationRecommendations(
    Map<String, double> efficiency,
    Map<String, dynamic> rulePerformance,
    Map<String, dynamic> timePatterns
  ) {
    final recommendations = <String>[];
    
    if ((efficiency['automation_efficiency'] ?? 0) < 0.3) {
      recommendations.add('Consider setting up more auto-allocation rules to improve consistency');
    }
    
    if ((efficiency['frequency_score'] ?? 0) < 0.5) {
      recommendations.add('Try to allocate more frequently for better habit formation');
    }
    
    if ((efficiency['consistency_score'] ?? 0) < 0.6) {
      recommendations.add('Focus on maintaining regular allocation intervals');
    }
    
    return recommendations;
  }

  double _calculateAverageAllocationInterval(List<GoalAllocationTableData> allocations) {
    if (allocations.length < 2) return 0.0;
    
    final sorted = [...allocations]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final intervals = <double>[];
    
    for (int i = 1; i < sorted.length; i++) {
      final interval = sorted[i].createdAt.difference(sorted[i - 1].createdAt).inDays.toDouble();
      intervals.add(interval);
    }
    
    return intervals.isEmpty ? 0.0 : intervals.reduce((a, b) => a + b) / intervals.length;
  }

  int _getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));
    
    if (date.isBefore(firstMonday)) {
      return 1;
    }
    
    final daysDifference = date.difference(firstMonday).inDays;
    return (daysDifference / 7).floor() + 2;
  }
}

// Data Models

class SavingsVelocityData {
  final double averageVelocity;
  final double currentVelocity;
  final double accelerationTrend;
  final double consistencyScore;
  final List<Map<String, dynamic>> dataPoints;
  final Duration period;

  const SavingsVelocityData({
    required this.averageVelocity,
    required this.currentVelocity,
    required this.accelerationTrend,
    required this.consistencyScore,
    required this.dataPoints,
    required this.period,
  });

  factory SavingsVelocityData.empty() => const SavingsVelocityData(
    averageVelocity: 0.0,
    currentVelocity: 0.0,
    accelerationTrend: 0.0,
    consistencyScore: 0.0,
    dataPoints: [],
    period: Duration(days: 30),
  );
}

class VelocityForecast {
  final List<Map<String, dynamic>> predictions;
  final double confidence;
  final SavingsVelocityData basedOnData;

  const VelocityForecast({
    required this.predictions,
    required this.confidence,
    required this.basedOnData,
  });

  factory VelocityForecast.insufficient() => VelocityForecast(
    predictions: const [],
    confidence: 0.0,
    basedOnData: SavingsVelocityData.empty(),
  );
}

class GoalPredictionAnalytics {
  final int goalId;
  final double currentProgress;
  final double remainingAmount;
  final double historicalRate;
  final SavingsTrend trendAnalysis;
  final List<RiskFactor> riskFactors;
  final GoalPredictions predictions;
  final double completionProbability;
  final List<String> recommendations;

  const GoalPredictionAnalytics({
    required this.goalId,
    required this.currentProgress,
    required this.remainingAmount,
    required this.historicalRate,
    required this.trendAnalysis,
    required this.riskFactors,
    required this.predictions,
    required this.completionProbability,
    required this.recommendations,
  });

  factory GoalPredictionAnalytics.error(String message) => GoalPredictionAnalytics(
    goalId: -1,
    currentProgress: 0.0,
    remainingAmount: 0.0,
    historicalRate: 0.0,
    trendAnalysis: SavingsTrend.insufficient,
    riskFactors: [],
    predictions: GoalPredictions.empty(),
    completionProbability: 0.0,
    recommendations: [message],
  );

  factory GoalPredictionAnalytics.insufficient() => GoalPredictionAnalytics(
    goalId: -1,
    currentProgress: 0.0,
    remainingAmount: 0.0,
    historicalRate: 0.0,
    trendAnalysis: SavingsTrend.insufficient,
    riskFactors: [],
    predictions: GoalPredictions.empty(),
    completionProbability: 0.0,
    recommendations: ['Insufficient data for prediction'],
  );
}

class GoalPredictions {
  final DateTime? optimistic;
  final DateTime? realistic;
  final DateTime? conservative;

  const GoalPredictions({
    this.optimistic,
    this.realistic,
    this.conservative,
  });

  factory GoalPredictions.empty() => const GoalPredictions();
}

class RiskFactor {
  final RiskType type;
  final RiskSeverity severity;
  final String description;

  const RiskFactor({
    required this.type,
    required this.severity,
    required this.description,
  });
}

class SpendingSavingsBalance {
  final Duration period;
  final double totalSpending;
  final double totalSavings;
  final double savingsRate;
  final double balanceRatio;
  final Map<String, double> spendingByCategory;
  final BalanceTrend balanceTrend;
  final double healthScore;
  final List<String> recommendations;
  final List<Map<String, dynamic>> trendData;

  const SpendingSavingsBalance({
    required this.period,
    required this.totalSpending,
    required this.totalSavings,
    required this.savingsRate,
    required this.balanceRatio,
    required this.spendingByCategory,
    required this.balanceTrend,
    required this.healthScore,
    required this.recommendations,
    required this.trendData,
  });
}

class AllocationReport {
  final Duration period;
  final double totalAmount;
  final int allocationCount;
  final double averageAmount;
  final double frequency;
  final Map<String, double> allocationsByType;
  final Map<String, double> goalDistribution;
  final Map<String, double> typeEffectiveness;
  final Map<String, dynamic> rulePerformance;
  final Map<String, dynamic> timePatterns;
  final Map<String, double> efficiencyMetrics;
  final List<String> recommendations;

  const AllocationReport({
    required this.period,
    required this.totalAmount,
    required this.allocationCount,
    required this.averageAmount,
    required this.frequency,
    required this.allocationsByType,
    required this.goalDistribution,
    required this.typeEffectiveness,
    required this.rulePerformance,
    required this.timePatterns,
    required this.efficiencyMetrics,
    required this.recommendations,
  });

  factory AllocationReport.empty(Duration period) => AllocationReport(
    period: period,
    totalAmount: 0.0,
    allocationCount: 0,
    averageAmount: 0.0,
    frequency: 0.0,
    allocationsByType: const {},
    goalDistribution: const {},
    typeEffectiveness: const {},
    rulePerformance: const {},
    timePatterns: const {},
    efficiencyMetrics: const {},
    recommendations: const ['No allocations found in this period'],
  );
}

// Enums

enum VelocityGranularity { daily, weekly, monthly }

enum SavingsTrend { increasing, stable, decreasing, insufficient }

enum RiskType { inconsistentPattern, decliningTrend, timeConstraint }

enum RiskSeverity { low, medium, high }

enum BalanceTrend { improving, stable, worsening, insufficient }