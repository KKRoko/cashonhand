import 'package:json_annotation/json_annotation.dart';

enum AllocationType {
  @JsonValue('manual')
  manual,
  @JsonValue('auto')
  auto,
  @JsonValue('round_up')
  roundUp,
}

extension AllocationTypeExtension on AllocationType {
  String get displayName {
    switch (this) {
      case AllocationType.manual:
        return 'Manual Allocation';
      case AllocationType.auto:
        return 'Auto Allocation';
      case AllocationType.roundUp:
        return 'Round-up';
    }
  }
  
  String get description {
    switch (this) {
      case AllocationType.manual:
        return 'Manually allocated by user';
      case AllocationType.auto:
        return 'Automatically allocated by rule';
      case AllocationType.roundUp:
        return 'Round-up to nearest dollar';
    }
  }
}