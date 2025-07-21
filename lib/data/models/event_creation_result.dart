import 'freezed/event.dart';
import 'freezed/goal_allocation.dart';

class EventCreationResult {
  final Event event;
  final List<GoalAllocation> allocations;

  const EventCreationResult({
    required this.event,
    required this.allocations,
  });
}