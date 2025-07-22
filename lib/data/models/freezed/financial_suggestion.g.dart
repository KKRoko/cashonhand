// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FinancialSuggestionImpl _$$FinancialSuggestionImplFromJson(
        Map<String, dynamic> json) =>
    _$FinancialSuggestionImpl(
      id: json['id'] as String,
      type: $enumDecode(_$SuggestionTypeEnumMap, json['type']),
      priority: $enumDecode(_$SuggestionPriorityEnumMap, json['priority']),
      title: json['title'] as String,
      description: json['description'] as String,
      actionText: json['actionText'] as String?,
      actionRoute: json['actionRoute'] as String?,
      actionData: json['actionData'] as Map<String, dynamic>?,
      potentialSavings: (json['potentialSavings'] as num?)?.toDouble(),
      relatedGoalId: (json['relatedGoalId'] as num?)?.toInt(),
      relatedCategoryId: (json['relatedCategoryId'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isDismissed: json['isDismissed'] as bool? ?? false,
      isActionTaken: json['isActionTaken'] as bool? ?? false,
      dismissedAt: json['dismissedAt'] == null
          ? null
          : DateTime.parse(json['dismissedAt'] as String),
      actionTakenAt: json['actionTakenAt'] == null
          ? null
          : DateTime.parse(json['actionTakenAt'] as String),
    );

Map<String, dynamic> _$$FinancialSuggestionImplToJson(
        _$FinancialSuggestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SuggestionTypeEnumMap[instance.type]!,
      'priority': _$SuggestionPriorityEnumMap[instance.priority]!,
      'title': instance.title,
      'description': instance.description,
      'actionText': instance.actionText,
      'actionRoute': instance.actionRoute,
      'actionData': instance.actionData,
      'potentialSavings': instance.potentialSavings,
      'relatedGoalId': instance.relatedGoalId,
      'relatedCategoryId': instance.relatedCategoryId,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'isDismissed': instance.isDismissed,
      'isActionTaken': instance.isActionTaken,
      'dismissedAt': instance.dismissedAt?.toIso8601String(),
      'actionTakenAt': instance.actionTakenAt?.toIso8601String(),
    };

const _$SuggestionTypeEnumMap = {
  SuggestionType.savingsOpportunity: 'savingsOpportunity',
  SuggestionType.budgetWarning: 'budgetWarning',
  SuggestionType.goalRecommendation: 'goalRecommendation',
  SuggestionType.spendingPattern: 'spendingPattern',
  SuggestionType.roundUpOptimization: 'roundUpOptimization',
  SuggestionType.allocationImprovement: 'allocationImprovement',
  SuggestionType.goalMilestone: 'goalMilestone',
  SuggestionType.unusualActivity: 'unusualActivity',
};

const _$SuggestionPriorityEnumMap = {
  SuggestionPriority.low: 'low',
  SuggestionPriority.medium: 'medium',
  SuggestionPriority.high: 'high',
  SuggestionPriority.urgent: 'urgent',
};

_$SpendingPatternImpl _$$SpendingPatternImplFromJson(
        Map<String, dynamic> json) =>
    _$SpendingPatternImpl(
      categoryId: (json['categoryId'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      averageMonthly: (json['averageMonthly'] as num).toDouble(),
      currentMonth: (json['currentMonth'] as num).toDouble(),
      lastMonth: (json['lastMonth'] as num).toDouble(),
      transactionCount: (json['transactionCount'] as num).toInt(),
      firstTransaction: DateTime.parse(json['firstTransaction'] as String),
      lastTransaction: DateTime.parse(json['lastTransaction'] as String),
      monthlyTrends: (json['monthlyTrends'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
      peakAmount: (json['peakAmount'] as num?)?.toDouble(),
      peakDate: json['peakDate'] == null
          ? null
          : DateTime.parse(json['peakDate'] as String),
      frequentMerchants: (json['frequentMerchants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SpendingPatternImplToJson(
        _$SpendingPatternImpl instance) =>
    <String, dynamic>{
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'averageMonthly': instance.averageMonthly,
      'currentMonth': instance.currentMonth,
      'lastMonth': instance.lastMonth,
      'transactionCount': instance.transactionCount,
      'firstTransaction': instance.firstTransaction.toIso8601String(),
      'lastTransaction': instance.lastTransaction.toIso8601String(),
      'monthlyTrends': instance.monthlyTrends,
      'peakAmount': instance.peakAmount,
      'peakDate': instance.peakDate?.toIso8601String(),
      'frequentMerchants': instance.frequentMerchants,
    };

_$SavingsOpportunityImpl _$$SavingsOpportunityImplFromJson(
        Map<String, dynamic> json) =>
    _$SavingsOpportunityImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      potentialMonthlySavings:
          (json['potentialMonthlySavings'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      suggestionType:
          $enumDecode(_$SuggestionTypeEnumMap, json['suggestionType']),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      goalId: (json['goalId'] as num?)?.toInt(),
      analysisData: json['analysisData'] as Map<String, dynamic>?,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
    );

Map<String, dynamic> _$$SavingsOpportunityImplToJson(
        _$SavingsOpportunityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'potentialMonthlySavings': instance.potentialMonthlySavings,
      'confidence': instance.confidence,
      'suggestionType': _$SuggestionTypeEnumMap[instance.suggestionType]!,
      'categoryId': instance.categoryId,
      'goalId': instance.goalId,
      'analysisData': instance.analysisData,
      'detectedAt': instance.detectedAt.toIso8601String(),
    };

_$GoalInsightImpl _$$GoalInsightImplFromJson(Map<String, dynamic> json) =>
    _$GoalInsightImpl(
      goalId: (json['goalId'] as num).toInt(),
      goalTitle: json['goalTitle'] as String,
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate'] as String),
      monthlyRequired: (json['monthlyRequired'] as num).toDouble(),
      averageMonthlyContribution:
          (json['averageMonthlyContribution'] as num).toDouble(),
      daysRemaining: (json['daysRemaining'] as num).toInt(),
      isOnTrack: json['isOnTrack'] as bool,
      projectedShortfall: (json['projectedShortfall'] as num?)?.toDouble(),
      projectedCompletionDate: json['projectedCompletionDate'] == null
          ? null
          : DateTime.parse(json['projectedCompletionDate'] as String),
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GoalInsightImplToJson(_$GoalInsightImpl instance) =>
    <String, dynamic>{
      'goalId': instance.goalId,
      'goalTitle': instance.goalTitle,
      'currentAmount': instance.currentAmount,
      'targetAmount': instance.targetAmount,
      'targetDate': instance.targetDate.toIso8601String(),
      'monthlyRequired': instance.monthlyRequired,
      'averageMonthlyContribution': instance.averageMonthlyContribution,
      'daysRemaining': instance.daysRemaining,
      'isOnTrack': instance.isOnTrack,
      'projectedShortfall': instance.projectedShortfall,
      'projectedCompletionDate':
          instance.projectedCompletionDate?.toIso8601String(),
      'recommendations': instance.recommendations,
    };
