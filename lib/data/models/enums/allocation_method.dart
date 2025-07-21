import 'package:json_annotation/json_annotation.dart';

enum AllocationMethod {
  @JsonValue('percentage')
  percentage,
  @JsonValue('fixed_amount')
  fixedAmount,
  @JsonValue('round_up')
  roundUp,
}

extension AllocationMethodExtension on AllocationMethod {
  String get displayName {
    switch (this) {
      case AllocationMethod.percentage:
        return 'Percentage';
      case AllocationMethod.fixedAmount:
        return 'Fixed Amount';
      case AllocationMethod.roundUp:
        return 'Round Up';
    }
  }
  
  String get description {
    switch (this) {
      case AllocationMethod.percentage:
        return 'Allocate a percentage of the transaction amount';
      case AllocationMethod.fixedAmount:
        return 'Allocate a fixed dollar amount';
      case AllocationMethod.roundUp:
        return 'Round up to nearest dollar and allocate difference';
    }
  }
  
  String get symbol {
    switch (this) {
      case AllocationMethod.percentage:
        return '%';
      case AllocationMethod.fixedAmount:
        return '\$';
      case AllocationMethod.roundUp:
        return '↗️';
    }
  }
}