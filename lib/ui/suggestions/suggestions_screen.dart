import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/di/injection.dart';
import '../../data/models/freezed/financial_suggestion.dart';
import '../../services/financial_suggestions_engine.dart';
import '../../services/notification_service.dart';
import '../../state/saving_goal_notifier.dart';
import '../dialogs/suggestion_detail_dialog.dart';
import 'widgets/suggestion_card.dart';
import 'widgets/suggestions_filter_bar.dart';

class SuggestionsScreen extends StatefulWidget {
  static const routeName = '/suggestions';
  
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> with TickerProviderStateMixin {
  final FinancialSuggestionsEngine _suggestionsEngine = getIt<FinancialSuggestionsEngine>();
  final NotificationService _notificationService = getIt<NotificationService>();
  
  List<FinancialSuggestion> _allSuggestions = [];
  List<FinancialSuggestion> _filteredSuggestions = [];
  List<AppNotification> _notifications = [];
  
  bool _isLoading = true;
  String? _error;
  
  // Filter state
  Set<SuggestionType> _selectedTypes = {};
  Set<SuggestionPriority> _selectedPriorities = {};
  bool _showOnlyActive = true;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _listenToNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _listenToNotifications() {
    _notificationService.notificationsStream.listen((notifications) {
      if (mounted) {
        setState(() {
          _notifications = notifications;
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Generate fresh suggestions
      final suggestionsResult = await _suggestionsEngine.generateAllSuggestions();
      
      suggestionsResult.fold(
        (failure) {
          setState(() {
            _error = failure.message;
            _isLoading = false;
          });
        },
        (suggestions) {
          setState(() {
            _allSuggestions = suggestions;
            _filteredSuggestions = suggestions;
            _isLoading = false;
          });
        },
      );

      // Trigger notification update
      await _notificationService.runComprehensiveCheck();
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredSuggestions = _allSuggestions.where((suggestion) {
        // Type filter
        if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(suggestion.type)) {
          return false;
        }
        
        // Priority filter
        if (_selectedPriorities.isNotEmpty && !_selectedPriorities.contains(suggestion.priority)) {
          return false;
        }
        
        // Active filter
        if (_showOnlyActive && !suggestion.isActive) {
          return false;
        }
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Suggestions'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.lightbulb_outline),
              text: 'Suggestions (${_filteredSuggestions.length})',
            ),
            Tab(
              icon: const Icon(Icons.notifications_outlined),
              text: 'Notifications (${_notifications.where((n) => n.isActive).length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSuggestionsTab(),
          _buildNotificationsTab(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing your financial data...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error Loading Suggestions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Filter bar
        SuggestionsFilterBar(
          selectedTypes: _selectedTypes,
          selectedPriorities: _selectedPriorities,
          showOnlyActive: _showOnlyActive,
          onTypesChanged: (types) {
            setState(() => _selectedTypes = types);
            _applyFilters();
          },
          onPrioritiesChanged: (priorities) {
            setState(() => _selectedPriorities = priorities);
            _applyFilters();
          },
          onActiveFilterChanged: (active) {
            setState(() => _showOnlyActive = active);
            _applyFilters();
          },
        ),
        
        // Suggestions list
        Expanded(
          child: _filteredSuggestions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _filteredSuggestions[index];
                      return SuggestionCard(
                        suggestion: suggestion,
                        onTap: () => _showSuggestionDetail(suggestion),
                        onDismiss: () => _dismissSuggestion(suggestion),
                        onAction: () => _takeSuggestionAction(suggestion),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    final activeNotifications = _notifications.where((n) => n.isActive).toList();
    
    if (activeNotifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'No Active Notifications',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ll notify you about important financial insights and goal updates.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeNotifications.length,
      itemBuilder: (context, index) {
        final notification = activeNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getNotificationColor(notification.priority),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body),
            const SizedBox(height: 8),
            Text(
              _formatNotificationTime(notification.createdAt),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleNotificationAction(action, notification),
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(value: 'read', child: Text('Mark as Read')),
            if (notification.actionRoute != null)
              const PopupMenuItem(value: 'action', child: Text('Take Action')),
            const PopupMenuItem(value: 'dismiss', child: Text('Dismiss')),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            _notificationService.markAsRead(notification.id);
          }
          if (notification.actionRoute != null) {
            Navigator.pushNamed(context, notification.actionRoute!);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Suggestions Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Keep using the app and we\'ll provide personalized financial insights based on your spending patterns.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Check Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuggestionDetail(FinancialSuggestion suggestion) {
    showDialog(
      context: context,
      builder: (context) => SuggestionDetailDialog(suggestion: suggestion),
    );
  }

  void _dismissSuggestion(FinancialSuggestion suggestion) {
    // TODO: Implement suggestion dismissal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dismissed suggestion: ${suggestion.title}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  void _takeSuggestionAction(FinancialSuggestion suggestion) {
    if (suggestion.actionRoute != null) {
      Navigator.pushNamed(context, suggestion.actionRoute!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No specific action available for this suggestion')),
      );
    }
  }

  void _handleNotificationAction(String action, AppNotification notification) {
    switch (action) {
      case 'read':
        _notificationService.markAsRead(notification.id);
        break;
      case 'action':
        if (notification.actionRoute != null) {
          Navigator.pushNamed(context, notification.actionRoute!);
        }
        break;
      case 'dismiss':
        _notificationService.removeNotification(notification.id);
        break;
    }
  }

  Color _getNotificationColor(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Colors.grey;
      case NotificationPriority.normal:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.urgent:
        return Colors.red;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.goalAlert:
        return Icons.flag;
      case NotificationType.savingsOpportunity:
        return Icons.savings;
      case NotificationType.budgetWarning:
        return Icons.warning;
      case NotificationType.goalMilestone:
        return Icons.celebration;
      case NotificationType.unusualActivity:
        return Icons.notification_important;
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Smart Suggestions'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Smart Suggestions analyze your financial data to provide personalized insights and recommendations.\\n',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Types of suggestions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Savings opportunities'),
              Text('• Budget warnings'),
              Text('• Goal recommendations'),
              Text('• Spending pattern insights'),
              Text('• Round-up optimizations'),
              Text('• Goal milestones'),
              Text('• Unusual activity alerts'),
              Text('\\nSuggestions are updated automatically based on your latest financial activity.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}