import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/allocation_type.dart';

part 'goal_allocation.freezed.dart';
part 'goal_allocation.g.dart';

@freezed
class GoalAllocation with _$GoalAllocation {
  const factory GoalAllocation({
    required int? id,
    required int eventId,
    required int goalId,
    required double allocationAmount,
    required AllocationType allocationType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    
    // Additional fields for UI/display purposes
    @Default('') String goalTitle,
    @Default('') String eventTitle,
  }) = _GoalAllocation;

  factory GoalAllocation.fromJson(Map<String, dynamic> json) =>
      _$GoalAllocationFromJson(json);
}

// Extension for business logic
extension GoalAllocationExtension on GoalAllocation {
  bool get isManualAllocation => allocationType == AllocationType.manual;
  bool get isAutoAllocation => allocationType == AllocationType.auto;
  bool get isRoundUpAllocation => allocationType == AllocationType.roundUp;
  
  String get displayAmount => '\$${allocationAmount.toStringAsFixed(2)}';
  
  String get allocationDescription {
    switch (allocationType) {
      case AllocationType.manual:
        return 'Manually allocated to $goalTitle';
      case AllocationType.auto:
        return 'Auto-allocated to $goalTitle';
      case AllocationType.roundUp:
        return 'Round-up saved to $goalTitle';
    }
  }
}