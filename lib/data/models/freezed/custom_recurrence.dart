import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/repeat_option.dart';

part 'custom_recurrence.freezed.dart';
part 'custom_recurrence.g.dart';

@freezed
class CustomRecurrence with _$CustomRecurrence {
  // Keep the private constructor for methods
  const CustomRecurrence._();

  const factory CustomRecurrence({
    required RepeatOption interval,
    required int frequency,
    @Default([false, false, false, false, false, false, false]) 
    List<bool> selectedDays,
    int? dayOfMonth,
    int? weekOfMonth,
    int? month,
  }) = _CustomRecurrence;  // Note: using _CustomRecurrence here

  factory CustomRecurrence.fromJson(Map<String, dynamic> json) =>
      _$CustomRecurrenceFromJson(json);

  // Keep your methods here
  bool get hasSelectedDays => selectedDays.contains(true);

  List<int> get selectedDayIndices => 
    List.generate(selectedDays.length, (i) => i)
        .where((i) => selectedDays[i])
        .toList();

  String getDescription() {
    switch (interval) {
      case RepeatOption.weekly:
        return _getWeeklyDescription();
      case RepeatOption.monthly:
        return _getMonthlyDescription();
      default:
        return 'Every ${frequency > 1 ? '$frequency ' : ''}${interval.toString().split('.').last}';
    }
  }

  String _getWeeklyDescription() {
    if (!hasSelectedDays) return 'Weekly';
    
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDays = days
        .asMap()
        .entries
        .where((e) => this.selectedDays[e.key])
        .map((e) => e.value)
        .join(', ');
    
    return 'Weekly on $selectedDays';
  }

  String _getMonthlyDescription() {
    if (dayOfMonth != null) {
      return 'Monthly on day $dayOfMonth';
    }
    if (weekOfMonth != null) {
      final ordinal = ['first', 'second', 'third', 'fourth', 'fifth', 'last']
          [weekOfMonth!.abs() - 1];
      return 'Monthly on the $ordinal week';
    }
    return 'Monthly';
  }
}