import 'package:json_annotation/json_annotation.dart';

enum EditOption {
  @JsonValue('thisInstance')
  thisInstance,
  @JsonValue('allInstances')
  allInstances,
  @JsonValue('futureInstances')
  futureInstances,
  @JsonValue('pastInstances')
  pastInstances,
}

extension EditOptionExtension on EditOption {
  String get displayName {
    switch (this) {
      case EditOption.thisInstance:
        return 'This event only';
      case EditOption.allInstances:
        return 'All events in series';
      case EditOption.futureInstances:
        return 'This and future events';
      case EditOption.pastInstances:
        return 'Past events only';
    }
  }
  
  String get description {
    switch (this) {
      case EditOption.thisInstance:
        return 'Only this specific occurrence';
      case EditOption.allInstances:
        return 'All events in the recurring series';
      case EditOption.futureInstances:
        return 'This event and all future occurrences';
      case EditOption.pastInstances:
        return 'All past events including today';
    }
  }
}