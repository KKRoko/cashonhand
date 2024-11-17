import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/repeat_option.dart';

part 'custom_recurrence.freezed.dart';
part 'custom_recurrence.g.dart';

@freezed
class CustomRecurrence with _$CustomRecurrence {
  const factory CustomRecurrence({
    required RepeatOption interval,
    required int frequency,
    @Default([]) List<bool> selectedDays,
    int? dayOfMonth,
    @Default(false) bool repeatAtEndOfMonth,
    @Default(false) bool useLastDayOfMonth,
    DateTime? originalDate,
  }) = _CustomRecurrence;

  const CustomRecurrence._();

  factory CustomRecurrence.fromJson(Map<String, dynamic> json) =>
      _$CustomRecurrenceFromJson(json);

  bool get hasSelectedDays => selectedDays.any((day) => day);

  List<int> get selectedDayIndices {
    List<int> indices = [];
    for (int i = 0; i < selectedDays.length; i++) {
      if (selectedDays[i]) indices.add(i);
    }
    return indices;
  }

  String getDescription() {
    switch (interval) {
      case RepeatOption.daily:
        return frequency == 1 ? 'Daily' : 'Every $frequency days';
      case RepeatOption.weekly:
        return frequency == 1 ? 'Weekly' : 'Every $frequency weeks';
      case RepeatOption.monthly:
        if (repeatAtEndOfMonth) {
          return frequency == 1
              ? 'Monthly (End of month)'
              : 'Every $frequency months (End of month)';
        }
        return frequency == 1 ? 'Monthly' : 'Every $frequency months';
      default:
        return 'Custom';
    }
  }
}
