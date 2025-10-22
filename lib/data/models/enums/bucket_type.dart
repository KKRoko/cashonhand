import 'package:json_annotation/json_annotation.dart';

enum BucketType {
  @JsonValue('needs')
  needs,
  @JsonValue('wants')
  wants,
  @JsonValue('savings')
  savings,
}

extension BucketTypeExtension on BucketType {
  String get displayName {
    switch (this) {
      case BucketType.needs:
        return 'Needs';
      case BucketType.wants:
        return 'Wants';
      case BucketType.savings:
        return 'Savings';
    }
  }

  String get description {
    switch (this) {
      case BucketType.needs:
        return 'Essential expenses (housing, food, utilities, healthcare)';
      case BucketType.wants:
        return 'Non-essential spending (entertainment, dining out, hobbies)';
      case BucketType.savings:
        return 'Savings and financial goals';
    }
  }

  double get defaultPercentage {
    switch (this) {
      case BucketType.needs:
        return 0.50; // 50%
      case BucketType.wants:
        return 0.30; // 30%
      case BucketType.savings:
        return 0.20; // 20%
    }
  }
}
