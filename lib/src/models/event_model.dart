import 'package:uuid/uuid.dart';

enum RepeatOption { today, daily, weekly, monthly, yearly, custom }

class Event {
  final String id;
  final String title;
  final double? amount;
  final bool isPositiveCashflow;
  final bool isNegativeCashflow;
  final RepeatOption repeatOption;
  final CustomRecurrence? customRecurrence;
  final DateTime createdAt;
  final bool isYearEndSummary;

  Event({
    String? id,
    required this.title,
    this.amount,
    required this.isPositiveCashflow,
    required this.isNegativeCashflow,
    required this.repeatOption,
    this.customRecurrence,
    DateTime? createdAt,
    this.isYearEndSummary = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Event copyWith({
    String? title,
    double? amount,
    bool? isPositiveCashflow,
    bool? isNegativeCashflow,
    RepeatOption? repeatOption,
    CustomRecurrence? customRecurrence,
    bool? isYearEndSummary,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isPositiveCashflow: isPositiveCashflow ?? this.isPositiveCashflow,
      isNegativeCashflow: isNegativeCashflow ?? this.isNegativeCashflow,
      repeatOption: repeatOption ?? this.repeatOption,
      customRecurrence: customRecurrence ?? this.customRecurrence,
      createdAt: createdAt,
      isYearEndSummary: isYearEndSummary ?? this.isYearEndSummary,
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isPositiveCashflow': isPositiveCashflow,
      'isNegativeCashflow': isNegativeCashflow,
      'repeatOption': repeatOption.index,
      'customRecurrence': customRecurrence?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'isYearEndSummary': isYearEndSummary,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      isPositiveCashflow: json['isPositiveCashflow'],
      isNegativeCashflow: json['isNegativeCashflow'],
      repeatOption: RepeatOption.values[json['repeatOption']],
      customRecurrence: json['customRecurrence'] != null
          ? CustomRecurrence.fromJson(json['customRecurrence'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      isYearEndSummary: json['isYearEndSummary'],
    );
  }
}

class CustomRecurrence {
  final RepeatOption interval;
  final int frequency;
  final List<bool> selectedDays;
  final int? dayOfMonth;
  final int? weekOfMonth;
  final int? month;

  CustomRecurrence({
    required this.interval,
    required this.frequency,
    this.selectedDays = const [],
    this.dayOfMonth,
    this.weekOfMonth,
    this.month,
  });

  Map<String, dynamic> toJson() {
    return {
      'interval': interval.index,
      'frequency': frequency,
      'selectedDays': selectedDays,
      'dayOfMonth': dayOfMonth,
      'weekOfMonth': weekOfMonth,
      'month': month,
    };
  }

  factory CustomRecurrence.fromJson(Map<String, dynamic> json) {
    return CustomRecurrence(
      interval: RepeatOption.values[json['interval']],
      frequency: json['frequency'],
      selectedDays: List<bool>.from(json['selectedDays']),
      dayOfMonth: json['dayOfMonth'],
      weekOfMonth: json['weekOfMonth'],
      month: json['month'],
    );
  }
}
