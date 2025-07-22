import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';
import '../data/models/freezed/financial_suggestion.dart';
import '../data/models/freezed/saving_goal.dart';
import '../data/repositories/saving_goal_repository.dart';
import 'financial_suggestions_engine.dart';

/// Types of notifications
enum NotificationType {
  goalAlert,
  savingsOpportunity,
  budgetWarning,
  goalMilestone,
  unusualActivity,
}

/// Notification priority levels
enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

/// A notification to be displayed to the user
class AppNotification {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? actionData;

  const AppNotification({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.body,
    this.data,
    required this.createdAt,
    this.expiresAt,
    this.isRead = false,
    this.actionRoute,
    this.actionData,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isRead,
    String? actionRoute,
    Map<String, dynamic>? actionData,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionData: actionData ?? this.actionData,
    );
  }

  /// Check if notification is still active
  bool get isActive {
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  /// Get icon for notification type
  String get iconName {
    switch (type) {
      case NotificationType.goalAlert:
        return 'flag';
      case NotificationType.savingsOpportunity:
        return 'savings';
      case NotificationType.budgetWarning:
        return 'warning';
      case NotificationType.goalMilestone:
        return 'celebration';
      case NotificationType.unusualActivity:
        return 'notification_important';
    }
  }

  /// Get color for notification priority
  String get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return 'grey';
      case NotificationPriority.normal:
        return 'blue';
      case NotificationPriority.high:
        return 'orange';
      case NotificationPriority.urgent:
        return 'red';
    }
  }
}

/// Service for managing app notifications and alerts
@injectable
class NotificationService {
  final ISavingGoalRepository _goalRepository;
  final FinancialSuggestionsEngine _suggestionsEngine;

  // In-memory storage for notifications (could be replaced with local storage)
  final List<AppNotification> _notifications = [];
  final StreamController<List<AppNotification>> _notificationsController = 
      StreamController<List<AppNotification>>.broadcast();

  NotificationService(
    this._goalRepository,
    this._suggestionsEngine,
  );

  /// Stream of all active notifications
  Stream<List<AppNotification>> get notificationsStream => _notificationsController.stream;

  /// Get all notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead && n.isActive).length;

  /// Check for and generate goal-related alerts
  Future<void> checkGoalAlerts() async {
    print('🔔 Notification Service: Checking goal alerts...');
    
    try {
      final goalsResult = await _goalRepository.getAllGoals();
      
      await goalsResult.fold(
        (failure) async => print('Error loading goals: ${failure.message}'),
        (goals) async {
          for (final goal in goals) {
            if (goal.id != null) {
              await _checkIndividualGoalAlerts(goal);
            }
          }
        },
      );

      _notifyListeners();
    } catch (e) {
      print('Error checking goal alerts: $e');
    }
  }

  /// Check alerts for a specific goal
  Future<void> _checkIndividualGoalAlerts(SavingGoal goal) async {
    final now = DateTime.now();
    final daysRemaining = goal.targetDate.difference(now).inDays;
    final progress = goal.currentAmount / goal.targetAmount;
    
    // Goal deadline approaching (7 days warning)
    if (daysRemaining <= 7 && daysRemaining > 0 && progress < 0.9) {
      final notificationId = 'goal_deadline_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalAlert,
          priority: NotificationPriority.high,
          title: '⏰ Goal Deadline Approaching',
          body: 'Your "${goal.title}" goal is due in $daysRemaining days. You\'re ${(progress * 100).toStringAsFixed(0)}% complete.',
          data: {'goalId': goal.id},
          createdAt: now,
          expiresAt: goal.targetDate,
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    // Goal overdue
    if (daysRemaining < 0 && progress < 1.0) {
      final notificationId = 'goal_overdue_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalAlert,
          priority: NotificationPriority.urgent,
          title: '🚨 Goal Overdue',
          body: 'Your "${goal.title}" goal is ${daysRemaining.abs()} days overdue. Consider updating the target date.',
          data: {'goalId': goal.id},
          createdAt: now,
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    // Goal milestone celebrations
    if (progress >= 0.25 && progress < 0.3) {
      final notificationId = 'goal_milestone_25_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.normal,
          title: '🎉 25% Progress!',
          body: 'Great job! You\'re 25% of the way to your "${goal.title}" goal.',
          data: {'goalId': goal.id, 'milestone': 0.25},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    if (progress >= 0.5 && progress < 0.55) {
      final notificationId = 'goal_milestone_50_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.normal,
          title: '🎉 Halfway There!',
          body: 'Amazing! You\'re 50% of the way to your "${goal.title}" goal.',
          data: {'goalId': goal.id, 'milestone': 0.5},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    if (progress >= 0.75 && progress < 0.8) {
      final notificationId = 'goal_milestone_75_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.normal,
          title: '🎉 Almost There!',
          body: 'You\'re 75% complete on your "${goal.title}" goal. The finish line is in sight!',
          data: {'goalId': goal.id, 'milestone': 0.75},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 7)),
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }

    // Goal completed
    if (progress >= 1.0) {
      final notificationId = 'goal_completed_${goal.id}';
      if (!_hasNotification(notificationId)) {
        _addNotification(AppNotification(
          id: notificationId,
          type: NotificationType.goalMilestone,
          priority: NotificationPriority.high,
          title: '🎉 Goal Completed!',
          body: 'Congratulations! You\'ve reached your "${goal.title}" goal of \$${goal.targetAmount.toStringAsFixed(2)}!',
          data: {'goalId': goal.id, 'milestone': 1.0},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 30)),
          actionRoute: '/goals/${goal.id}',
        ));
      }
    }
  }

  /// Convert financial suggestions to notifications
  Future<void> processFinancialSuggestions() async {
    print('🔔 Notification Service: Processing financial suggestions...');
    
    try {
      final suggestionsResult = await _suggestionsEngine.generateAllSuggestions();
      
      suggestionsResult.fold(
        (failure) => print('Error generating suggestions: ${failure.message}'),
        (suggestions) {
          for (final suggestion in suggestions) {
            _convertSuggestionToNotification(suggestion);
          }
          _notifyListeners();
        },
      );
    } catch (e) {
      print('Error processing financial suggestions: $e');
    }
  }

  /// Convert a financial suggestion to a notification
  void _convertSuggestionToNotification(FinancialSuggestion suggestion) {
    final notificationId = 'suggestion_${suggestion.id}';
    
    // Don't create duplicate notifications
    if (_hasNotification(notificationId)) return;

    final notificationType = _getNotificationTypeFromSuggestion(suggestion.type);
    final priority = _getNotificationPriority(suggestion.priority);

    _addNotification(AppNotification(
      id: notificationId,
      type: notificationType,
      priority: priority,
      title: suggestion.title,
      body: suggestion.description,
      data: {
        'suggestionId': suggestion.id,
        'suggestionType': suggestion.type.toString(),
        'potentialSavings': suggestion.potentialSavings,
        'relatedGoalId': suggestion.relatedGoalId,
        'relatedCategoryId': suggestion.relatedCategoryId,
      },
      createdAt: suggestion.createdAt,
      expiresAt: suggestion.expiresAt,
      actionRoute: suggestion.actionRoute,
      actionData: suggestion.actionData,
    ));
  }

  /// Get notification type from suggestion type
  NotificationType _getNotificationTypeFromSuggestion(SuggestionType suggestionType) {
    switch (suggestionType) {
      case SuggestionType.savingsOpportunity:
      case SuggestionType.roundUpOptimization:
      case SuggestionType.allocationImprovement:
        return NotificationType.savingsOpportunity;
      case SuggestionType.budgetWarning:
        return NotificationType.budgetWarning;
      case SuggestionType.goalRecommendation:
        return NotificationType.goalAlert;
      case SuggestionType.goalMilestone:
        return NotificationType.goalMilestone;
      case SuggestionType.unusualActivity:
        return NotificationType.unusualActivity;
      default:
        return NotificationType.savingsOpportunity;
    }
  }

  /// Get notification priority from suggestion priority
  NotificationPriority _getNotificationPriority(SuggestionPriority suggestionPriority) {
    switch (suggestionPriority) {
      case SuggestionPriority.low:
        return NotificationPriority.low;
      case SuggestionPriority.medium:
        return NotificationPriority.normal;
      case SuggestionPriority.high:
        return NotificationPriority.high;
      case SuggestionPriority.urgent:
        return NotificationPriority.urgent;
    }
  }

  /// Add a notification to the list
  void _addNotification(AppNotification notification) {
    _notifications.add(notification);
    
    // Keep only the most recent 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeAt(0);
    }
    
    if (kDebugMode) {
      print('🔔 Added notification: ${notification.title}');
    }
  }

  /// Check if a notification with the given ID already exists
  bool _hasNotification(String id) {
    return _notifications.any((n) => n.id == id);
  }

  /// Mark a notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notifyListeners();
  }

  /// Remove a notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    _notifyListeners();
  }

  /// Get active notifications (not expired)
  List<AppNotification> getActiveNotifications() {
    return _notifications.where((n) => n.isActive).toList();
  }

  /// Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type && n.isActive).toList();
  }

  /// Get high priority notifications
  List<AppNotification> getHighPriorityNotifications() {
    return _notifications.where((n) => 
      (n.priority == NotificationPriority.high || n.priority == NotificationPriority.urgent) 
      && n.isActive
    ).toList();
  }

  /// Run comprehensive notification check
  Future<void> runComprehensiveCheck() async {
    print('🔔 Notification Service: Running comprehensive check...');
    
    // Clean up expired notifications first
    _cleanupExpiredNotifications();
    
    // Check goal alerts
    await checkGoalAlerts();
    
    // Process financial suggestions
    await processFinancialSuggestions();
    
    print('🔔 Notification Service: Comprehensive check complete. ${_notifications.length} total notifications.');
  }

  /// Clean up expired notifications
  void _cleanupExpiredNotifications() {
    final sizeBefore = _notifications.length;
    _notifications.removeWhere((n) => !n.isActive);
    final sizeAfter = _notifications.length;
    
    if (sizeBefore != sizeAfter) {
      print('🔔 Cleaned up ${sizeBefore - sizeAfter} expired notifications');
      _notifyListeners();
    }
  }

  /// Notify all listeners of notification changes
  void _notifyListeners() {
    if (!_notificationsController.isClosed) {
      _notificationsController.add(List.unmodifiable(_notifications));
    }
  }

  /// Schedule periodic notification checks
  Timer? _periodicTimer;

  void startPeriodicChecks({Duration interval = const Duration(hours: 6)}) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) {
      runComprehensiveCheck();
    });
    
    // Run initial check
    runComprehensiveCheck();
  }

  void stopPeriodicChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  /// Dispose of resources
  void dispose() {
    _periodicTimer?.cancel();
    _notificationsController.close();
  }
}