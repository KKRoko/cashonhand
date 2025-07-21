import 'package:json_annotation/json_annotation.dart';

enum TriggerType {
  @JsonValue('income')
  income,
  @JsonValue('expense')
  expense,
  @JsonValue('category')
  category,
  @JsonValue('any_transaction')
  anyTransaction,
}

extension TriggerTypeExtension on TriggerType {
  String get displayName {
    switch (this) {
      case TriggerType.income:
        return 'Income';
      case TriggerType.expense:
        return 'Expense';
      case TriggerType.category:
        return 'Specific Category';
      case TriggerType.anyTransaction:
        return 'Any Transaction';
    }
  }
  
  String get description {
    switch (this) {
      case TriggerType.income:
        return 'Triggered by income transactions';
      case TriggerType.expense:
        return 'Triggered by expense transactions';
      case TriggerType.category:
        return 'Triggered by specific category transactions';
      case TriggerType.anyTransaction:
        return 'Triggered by any transaction';
    }
  }
}