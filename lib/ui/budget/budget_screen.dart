import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../app.dart';
import '../../core/di/injection.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../data/models/freezed/budget.dart';
import '../../data/models/freezed/budget_template.dart';
import '../../data/models/freezed/allocation_template.dart';
import '../../state/budget_notifier.dart';
import '../../services/budget_template_service.dart';
import '../../theme/design_tokens.dart';
import 'budget_setup_screen.dart';
import 'budget_settings_screen.dart';
import 'category_allocation_screen.dart';
import 'alert_settings_screen.dart';
import 'surplus_allocation_screen.dart';
import 'budget_month_summary_screen.dart';
import 'budget_analytics_screen.dart';
import 'budget_template_library_screen.dart';
import 'allocation_template_library_screen.dart';
import 'widgets/budget_pie_chart.dart';

enum BudgetViewMode {
  plan,
  actual,
}

class BudgetScreen extends StatefulWidget {
  static const routeName = '/budget';
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> with AutomaticKeepAliveClientMixin {
  late final BudgetNotifier _budgetNotifier;
  BudgetViewMode _viewMode = BudgetViewMode.plan;
  BucketType? _expandedBucket; // Track which bucket is expanded to show transactions (Actual view)
  BucketType? _expandedPlanBucket; // Track which bucket is expanded in Plan view

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _budgetNotifier = getIt<BudgetNotifier>();
    _budgetNotifier.loadActiveBudget();

    // Listen to tab changes and reload when navigating back from calendar
    globalTabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    globalTabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    // Reload budget data when navigating to budget tab from another tab
    // This ensures spending data is fresh if user added transactions in calendar
    if (globalTabNotifier.currentTabIndex == 3) { // Budget tab is index 3
      // Reset to current month when navigating back to budget tab
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      _budgetNotifier.setSelectedMonth(currentMonth);
    }
  }

  void _changeMonth(int monthOffset) {
    final currentMonth = _budgetNotifier.selectedMonth;
    final newMonth = DateTime(currentMonth.year, currentMonth.month + monthOffset, 1);

    // Validate navigation limits
    if (!_canNavigateToMonth(newMonth)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            monthOffset < 0
                ? 'Cannot navigate more than 2 years into the past'
                : 'Cannot navigate more than 1 year into the future',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    _budgetNotifier.setSelectedMonth(newMonth);
  }

  bool _canNavigateToMonth(DateTime month) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    // Allow 2 years back, 1 year forward
    final twoYearsAgo = DateTime(currentMonth.year - 2, currentMonth.month, 1);
    final oneYearForward = DateTime(currentMonth.year + 1, currentMonth.month, 1);

    return month.isAfter(twoYearsAgo.subtract(const Duration(days: 1))) &&
           month.isBefore(oneYearForward.add(const Duration(days: 1)));
  }

  void _navigateToSetup() async {
    // Capture the current selected month BEFORE navigating
    final targetMonth = _budgetNotifier.selectedMonth;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetSetupScreen(
          targetMonth: targetMonth,
          onCreateBudget: ({
            required double monthlyIncome,
            required int cycleStartDay,
            required double needsPercentage,
            required double wantsPercentage,
            required double savingsPercentage,
          }) async {
            // This callback is no longer used since BudgetSetupScreen handles
            // budget creation and navigation internally
            // Keeping it for interface compatibility
          },
        ),
      ),
    );

    if (result == true) {
      _budgetNotifier.loadActiveBudget();
    }
  }

  void _navigateToAlertSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AlertSettingsScreen(),
      ),
    );

    // Reload alert preferences after returning
    _budgetNotifier.reloadAlertPreferences();
  }

  void _navigateToMonthSummary(BudgetNotifier notifier) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetMonthSummaryScreen(
          budgetNotifier: notifier,
          month: notifier.selectedMonth,
        ),
      ),
    );

    // Reload budget data after returning
    notifier.loadActiveBudget();
  }

  void _navigateToAnalytics() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BudgetAnalyticsScreen(),
      ),
    );
  }

  void _navigateToSettings(BudgetNotifier notifier) async {
    final budget = notifier.activeBudget;
    if (budget == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BudgetSettingsScreen(
          budget: budget,
          onUpdateBudget: ({
            required double monthlyIncome,
            required int cycleStartDay,
            required double needsPercentage,
            required double wantsPercentage,
            required double savingsPercentage,
          }) async {
            final updated = budget.copyWith(
              monthlyIncome: monthlyIncome,
              cycleStartDay: cycleStartDay,
              needsPercentage: needsPercentage,
              wantsPercentage: wantsPercentage,
              savingsPercentage: savingsPercentage,
            );
            await _budgetNotifier.updateBudget(updated);
          },
          onDeleteBudget: () async {
            await _budgetNotifier.deleteBudget(budget.id);
          },
        ),
      ),
    );

    if (result == true) {
      _budgetNotifier.loadActiveBudget();
    }
  }

  void _navigateToTemplateLibrary(BudgetNotifier notifier) async {
    final template = await Navigator.of(context).push<BudgetTemplate>(
      MaterialPageRoute(
        builder: (context) => const BudgetTemplateLibraryScreen(),
      ),
    );

    if (template != null && mounted) {
      _showApplyTemplateDialog(notifier, template);
    }
  }

  void _navigateToAllocationTemplateLibrary() async {
    final templateId = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (context) => const AllocationTemplateLibraryScreen(),
      ),
    );

    if (templateId != null && mounted) {
      final success = await _budgetNotifier.applyTemplate(templateId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Allocation template applied successfully'),
              backgroundColor: DesignTokens.color('success'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_budgetNotifier.error ?? 'Failed to apply template'),
              backgroundColor: DesignTokens.color('error'),
            ),
          );
        }
      }
    }
  }

  void _showSaveTemplateDialog(BudgetNotifier notifier) async {
    final budget = notifier.activeBudget;
    if (budget == null) return;

    String templateName = '';
    String templateDescription = '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Save Budget Template',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Template Name',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
                hintText: 'My Budget Template',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  fontSize: 18,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) => templateName = value,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
                hintText: 'Describe this budget template',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: DesignTokens.borderRadius['sm']!,
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) => templateDescription = value,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && templateName.isNotEmpty) {
      final templateService = getIt<BudgetTemplateService>();
      final result = await templateService.createTemplateFromBudget(
        budget: budget,
        name: templateName,
        description: templateDescription.isEmpty ? 'Custom budget template' : templateDescription,
      );

      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save template: ${failure.message}'),
                backgroundColor: DesignTokens.color('error'),
              ),
            );
          },
          (templateId) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Template saved successfully!'),
                backgroundColor: DesignTokens.color('success'),
              ),
            );
          },
        );
      }
    }
  }

  void _showApplyTemplateDialog(BudgetNotifier notifier, BudgetTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Template'),
        content: Text(
          'Apply "${template.name}" to your current budget?\n\nThis will update your bucket percentages to:\n'
          '• Needs: ${(template.needsPercentage * 100).toInt()}%\n'
          '• Wants: ${(template.wantsPercentage * 100).toInt()}%\n'
          '• Savings: ${(template.savingsPercentage * 100).toInt()}%',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _applyTemplate(notifier, template);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTemplate(BudgetNotifier notifier, BudgetTemplate template) async {
    final budget = notifier.activeBudget;
    if (budget == null) return;

    final templateService = getIt<BudgetTemplateService>();
    final updatedBudget = templateService.applyTemplateToBudget(
      budget: budget,
      template: template,
    );

    final success = await notifier.updateBudget(updatedBudget);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Template applied successfully!'),
            backgroundColor: DesignTokens.color('success'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply template: ${notifier.error}'),
            backgroundColor: DesignTokens.color('error'),
          ),
        );
      }
    }
  }

  /// Show dialog to load and apply a category allocation template
  Future<void> _showLoadAllocationTemplateDialog() async {
    // Load templates if not already loaded
    if (!_budgetNotifier.templatesLoaded) {
      await _budgetNotifier.loadTemplates();
    }

    if (!mounted) return;

    final templates = _budgetNotifier.templates;

    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No saved allocation templates found'),
        ),
      );
      return;
    }

    final selectedTemplate = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _LoadAllocationTemplateDialog(
        templates: templates,
        budgetNotifier: _budgetNotifier,
      ),
    );

    if (selectedTemplate != null && mounted) {
      final success = await _budgetNotifier.applyTemplate(selectedTemplate);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Budget template applied successfully'),
              backgroundColor: DesignTokens.color('success'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_budgetNotifier.error ?? 'Failed to apply template'),
              backgroundColor: DesignTokens.color('error'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ChangeNotifierProvider.value(
      value: _budgetNotifier,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budget'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          actions: [
            Consumer<BudgetNotifier>(
              builder: (context, notifier, _) {
                if (notifier.hasBudget) {
                  return PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'budget_settings') {
                        _navigateToSettings(notifier);
                      } else if (value == 'alert_settings') {
                        _navigateToAlertSettings();
                      } else if (value == 'month_summary') {
                        _navigateToMonthSummary(notifier);
                      } else if (value == 'analytics') {
                        _navigateToAnalytics();
                      } else if (value == 'template_library') {
                        _navigateToTemplateLibrary(notifier);
                      } else if (value == 'save_template') {
                        _showSaveTemplateDialog(notifier);
                      } else if (value == 'load_allocation_template') {
                        _showLoadAllocationTemplateDialog();
                      } else if (value == 'allocation_template_library') {
                        _navigateToAllocationTemplateLibrary();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'month_summary',
                        child: Row(
                          children: [
                            Icon(Icons.summarize_outlined),
                            SizedBox(width: 12),
                            Text('Month Summary'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'analytics',
                        child: Row(
                          children: [
                            Icon(Icons.analytics_outlined),
                            SizedBox(width: 12),
                            Text('Analytics'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'budget_settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings_outlined),
                            SizedBox(width: 12),
                            Text('Budget Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'alert_settings',
                        child: Row(
                          children: [
                            Icon(Icons.notifications_outlined),
                            SizedBox(width: 12),
                            Text('Alert Settings'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'template_library',
                        child: Row(
                          children: [
                            Icon(Icons.library_books_outlined),
                            SizedBox(width: 12),
                            Text('Budget Template Library'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'save_template',
                        child: Row(
                          children: [
                            Icon(Icons.save_alt_outlined),
                            SizedBox(width: 12),
                            Text('Save Budget Template'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'allocation_template_library',
                        child: Row(
                          children: [
                            Icon(Icons.folder_outlined),
                            SizedBox(width: 12),
                            Text('Allocation Template Library'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'load_allocation_template',
                        child: Row(
                          children: [
                            Icon(Icons.file_download_outlined),
                            SizedBox(width: 12),
                            Text('Load Budget Template'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<BudgetNotifier>(
          builder: (context, notifier, _) {
            if (notifier.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notifier.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: DesignTokens.color('error'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading budget',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        notifier.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => notifier.loadActiveBudget(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!notifier.hasBudget) {
              return _buildEmptyState();
            }

            return _buildBudgetView(notifier);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final selectedMonth = _budgetNotifier.selectedMonth;
    final monthName = DateFormat('MMMM yyyy').format(selectedMonth);
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.year == now.year && selectedMonth.month == now.month;

    // Check navigation limits
    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    final canGoPrev = _canNavigateToMonth(prevMonth);
    final canGoNext = _canNavigateToMonth(nextMonth);

    return Column(
      children: [
        // Month Navigation (always visible)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: DesignTokens.borderRadius['md']!,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: canGoPrev ? () => _changeMonth(-1) : null,
                  color: canGoPrev ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                Column(
                  children: [
                    Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (!isCurrentMonth)
                      Text(
                        isCurrentMonth ? '' : (selectedMonth.isBefore(DateTime(now.year, now.month, 1)) ? 'Past Month' : 'Future Month'),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: canGoNext ? () => _changeMonth(1) : null,
                  color: canGoNext ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        // Empty state message
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Budget for $monthName',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create a budget for this month to track your spending and save more effectively',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _navigateToSetup,
                    icon: const Icon(Icons.add),
                    label: Text('Create Budget for $monthName'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getTimePeriodMultiplier() {
    // Always monthly now
    return 1.0;
  }

  String _getTimePeriodLabel() {
    // Always monthly now
    return 'Monthly';
  }

  Widget _buildBudgetView(BudgetNotifier notifier) {
    final budget = notifier.activeBudget!;

    // Calculate amounts based on time period
    final multiplier = _getTimePeriodMultiplier();
    final planData = {
      BucketType.needs: budget.needsAmount * multiplier,
      BucketType.wants: budget.wantsAmount * multiplier,
      BucketType.savings: budget.savingsAmount * multiplier,
    };

    // Adjust actual spending based on time period
    final actualData = {
      BucketType.needs: (notifier.actualSpending[BucketType.needs] ?? 0.0) * multiplier,
      BucketType.wants: (notifier.actualSpending[BucketType.wants] ?? 0.0) * multiplier,
      BucketType.savings: (notifier.actualSpending[BucketType.savings] ?? 0.0) * multiplier,
    };

    // Check navigation limits
    final selectedMonth = notifier.selectedMonth;
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.year == now.year && selectedMonth.month == now.month;
    final prevMonth = DateTime(selectedMonth.year, selectedMonth.month - 1, 1);
    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);
    final canGoPrev = _canNavigateToMonth(prevMonth);
    final canGoNext = _canNavigateToMonth(nextMonth);

    return CustomScrollView(
      slivers: [
        // Sticky Month Navigation Header
        SliverPersistentHeader(
          pinned: true,
          delegate: _MonthNavigationHeaderDelegate(
            selectedMonth: selectedMonth,
            isCurrentMonth: isCurrentMonth,
            canGoPrev: canGoPrev,
            canGoNext: canGoNext,
            onPrevMonth: () => _changeMonth(-1),
            onNextMonth: () => _changeMonth(1),
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            onSurfaceColor: Theme.of(context).colorScheme.onSurface,
            onSurfaceVariantColor: Theme.of(context).colorScheme.onSurfaceVariant,
            primaryColor: Theme.of(context).colorScheme.primary,
          ),
        ),

        // Rest of content
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 24),

          // Legend
          _buildLegend(_viewMode == BudgetViewMode.plan ? planData : actualData),
          const SizedBox(height: 32),

          // Pie Chart
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Builder(
              builder: (context) {
                // Calculate totals based on view mode
                final isActual = _viewMode == BudgetViewMode.actual;
                final currentData = isActual ? actualData : planData;
                final totalAmount = currentData.values.fold<double>(0.0, (sum, amount) => sum + amount);

                return BudgetPieChart(
                  bucketAmounts: currentData,
                  centerText: '\$${totalAmount.toStringAsFixed(0)}',
                  subtitle: isActual
                      ? 'Current Spending'
                      : '${_getTimePeriodLabel()} Plan',
                  showLegend: false,
                  isActualView: isActual,
                );
              }
            ),
          ),
          const SizedBox(height: 32),

          // View Mode Toggle
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: DesignTokens.borderRadius['md']!,
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton('Budget Plan', BudgetViewMode.plan),
                  const SizedBox(width: 4),
                  _buildToggleButton('Actual', BudgetViewMode.actual),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Budget vs Actual Comparison (Actual view only - show first)
          if (_viewMode == BudgetViewMode.actual) ...[
            Text(
              'Budget vs Actual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildIncomeComparisonCard(budget, notifier),
            const SizedBox(height: 12),
            _buildComparisonCard(BucketType.needs, budget, notifier),
            const SizedBox(height: 12),
            _buildComparisonCard(BucketType.wants, budget, notifier),
            const SizedBox(height: 12),
            _buildComparisonCard(BucketType.savings, budget, notifier),
            const SizedBox(height: 32),
          ],

          // Budget Details
          Text(
            'Budget Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Category Allocations (Plan view only)
          if (_viewMode == BudgetViewMode.plan) ...[
            _buildAllocationBucket(BucketType.needs, notifier),
            const SizedBox(height: 12),
            _buildAllocationBucket(BucketType.wants, notifier),
            const SizedBox(height: 12),
            _buildAllocationBucket(BucketType.savings, notifier),
            const SizedBox(height: 16),
          ],

          // Alert Banner
          if (notifier.hasAlerts)
            _buildAlertBanner(notifier),
          if (notifier.hasAlerts)
            const SizedBox(height: 16),

          _buildBudgetDetailCard(
            'Allocated',
            notifier.isFullyAllocated ? 'Fully allocated' : 'Needs allocation',
            notifier.isFullyAllocated ? Icons.check_circle_outline : Icons.warning_outlined,
            color: notifier.isFullyAllocated
                ? DesignTokens.color('success')
                : DesignTokens.color('warning'),
          ),
          const SizedBox(height: 12),

          // Overspending Alert
          if (notifier.hasAnyOverspending)
            _buildBudgetDetailCard(
              'Alert',
              'Overspending detected in ${_getOverspendingBuckets(notifier)}',
              Icons.warning_rounded,
              color: DesignTokens.color('error'),
            ),
          if (notifier.hasAnyOverspending)
            const SizedBox(height: 12),

          // Surplus Allocation
          if (notifier.hasSurplus)
            _buildSurplusCard(notifier),
          const SizedBox(height: 32),

          // Allocate Categories Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryAllocationScreen(
                      budget: budget,
                      budgetNotifier: _budgetNotifier,
                    ),
                  ),
                );
                // Reload budget after returning
                _budgetNotifier.loadActiveBudget();
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Allocate to Categories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: DesignTokens.borderRadius['md']!,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
            ]), // Close SliverChildListDelegate
          ), // Close SliverList
        ), // Close SliverPadding
      ], // Close slivers list
    ); // Close CustomScrollView
  }

  Widget _buildToggleButton(String label, BudgetViewMode mode) {
    final isSelected = _viewMode == mode;

    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: DesignTokens.borderRadius['sm']!,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }


  Widget _buildBudgetDetailCard(String title, String subtitle, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['md']!,
      ),
      child: Row(
        children: [
          Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurplusCard(BudgetNotifier notifier) {
    return GestureDetector(
      onTap: () => _navigateToSurplusAllocation(notifier),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: DesignTokens.borderRadius['md']!,
          border: Border.all(
            color: DesignTokens.color('success').withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignTokens.color('success').withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.savings_outlined,
                color: DesignTokens.color('success'),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Surplus Available',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Allocate \$${notifier.totalSurplus.toStringAsFixed(2)} to savings goals',
                    style: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.color('success'),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToSurplusAllocation(BudgetNotifier notifier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurplusAllocationScreen(budgetNotifier: notifier),
      ),
    );

    // Reload budget data if allocation was successful
    if (result == true && mounted) {
      notifier.loadActiveBudget();
    }
  }

  String _getOverspendingBuckets(BudgetNotifier notifier) {
    final buckets = <String>[];
    if (notifier.overspendingStatus[BucketType.needs] == true) buckets.add('Needs');
    if (notifier.overspendingStatus[BucketType.wants] == true) buckets.add('Wants');
    if (notifier.overspendingStatus[BucketType.savings] == true) buckets.add('Savings');
    return buckets.join(', ');
  }

  Color _getBucketColor(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return Theme.of(context).colorScheme.primary;
      case BucketType.wants:
        return DesignTokens.color('info');
      case BucketType.savings:
        return DesignTokens.color('warning');
    }
  }

  String _getBucketLabel(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return 'Needs';
      case BucketType.wants:
        return 'Wants';
      case BucketType.savings:
        return 'Savings';
    }
  }

  Widget _buildLegend(Map<BucketType, double> bucketAmounts) {
    final total = bucketAmounts.values.fold<double>(0.0, (sum, amount) => sum + amount);

    return Wrap(
      spacing: 24,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: bucketAmounts.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total) * 100 : 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getBucketColor(entry.key),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_getBucketLabel(entry.key)}: \$${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(0)}%)',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAlertBanner(BudgetNotifier notifier) {
    final mostCritical = notifier.mostCriticalAlert;
    if (mostCritical == null) return const SizedBox.shrink();

    final isCritical = mostCritical.isCritical;
    final backgroundColor = isCritical
        ? DesignTokens.color('error').withOpacity(0.1)
        : DesignTokens.color('warning').withOpacity(0.1);
    final iconColor = isCritical
        ? DesignTokens.color('error')
        : DesignTokens.color('warning');
    final textColor = isCritical
        ? DesignTokens.color('error')
        : DesignTokens.color('warning');

    // If the main alert is a bucket alert, find related category alerts
    List<BudgetAlert> relatedCategoryAlerts = [];
    if (mostCritical.bucketType != null && mostCritical.categoryBudgetId == null) {
      // This is a bucket-level alert, find category alerts in the same bucket
      relatedCategoryAlerts = notifier.alerts
          .where((alert) =>
              alert.bucketType == mostCritical.bucketType &&
              alert.categoryBudgetId != null &&
              alert.level != AlertLevel.none)
          .toList();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: DesignTokens.borderRadius['md']!,
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical ? Icons.error : Icons.warning,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main alert
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        mostCritical.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (notifier.alerts.length > 1) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.2),
                          borderRadius: DesignTokens.borderRadius['sm']!,
                        ),
                        child: Text(
                          '+${notifier.alerts.length - 1} more',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  mostCritical.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                  ),
                ),

                // Category breakdown (if bucket alert with related categories)
                if (relatedCategoryAlerts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: DesignTokens.borderRadius['sm']!,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categories with alerts:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...relatedCategoryAlerts.map((alert) {
                          // Find the category name from categoryBudgets
                          String categoryName = 'Unknown';
                          if (alert.bucketType != null) {
                            final categories = notifier.categoryBudgets[alert.bucketType!] ?? [];
                            final category = categories.firstWhere(
                              (c) => c.id == alert.categoryBudgetId,
                              orElse: () => categories.first,
                            );
                            categoryName = category.categoryName ?? 'Unknown';
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  alert.isCritical ? Icons.error : Icons.warning,
                                  size: 14,
                                  color: textColor.withOpacity(0.7),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '$categoryName: \$${alert.spentAmount.toStringAsFixed(0)}/\$${alert.budgetAmount.toStringAsFixed(0)} (${alert.percentage.toStringAsFixed(0)}%)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: textColor.withOpacity(0.9),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(BucketType bucket, Budget budget, BudgetNotifier notifier) {
    final multiplier = _getTimePeriodMultiplier();
    final budgetAmount = budget.getBucketAmount(bucket.toString().split('.').last) * multiplier;
    final actualAmount = (notifier.actualSpending[bucket] ?? 0.0) * multiplier;
    final remaining = budgetAmount - actualAmount;
    final percentage = budgetAmount > 0 ? (actualAmount / budgetAmount * 100).clamp(0, 100) : 0.0;
    final isOverspending = remaining < 0;

    // Get alert level for this bucket
    final alertLevel = notifier.bucketAlertLevels[bucket] ?? AlertLevel.none;
    final hasWarning = alertLevel == AlertLevel.warning;
    final hasCritical = alertLevel == AlertLevel.critical;

    // Determine border and badge colors based on alert level
    Color? borderColor;
    String? badgeText;
    Color? badgeColor;

    if (hasCritical) {
      borderColor = DesignTokens.color('error');
      badgeText = 'OVER';
      badgeColor = DesignTokens.color('error');
    } else if (hasWarning) {
      borderColor = DesignTokens.color('warning');
      badgeText = 'WARNING';
      badgeColor = DesignTokens.color('warning');
    }

    final isExpanded = _expandedBucket == bucket;

    return InkWell(
      onTap: () {
        setState(() {
          _expandedBucket = isExpanded ? null : bucket;
        });
      },
      borderRadius: DesignTokens.borderRadius['md']!,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: DesignTokens.borderRadius['md']!,
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getBucketColor(bucket),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.category, color: Theme.of(context).colorScheme.onPrimary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getBucketLabel(bucket),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if (badgeText != null && badgeColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.1),
                      borderRadius: DesignTokens.borderRadius['sm']!,
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${budgetAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${actualAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOverspending
                          ? DesignTokens.color('error')
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Remaining',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    isOverspending
                        ? '-\$${(-remaining).toStringAsFixed(0)}'
                        : '\$${remaining.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOverspending
                          ? DesignTokens.color('error')
                          : DesignTokens.color('success'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(
              hasCritical
                  ? DesignTokens.color('error')
                  : hasWarning
                      ? DesignTokens.color('warning')
                      : _getBucketColor(bucket),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}% of budget used',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          // Show transactions when expanded
          if (isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildBucketTransactions(bucket, notifier),
          ],
        ],
      ),
    ),
    );
  }

  Widget _buildBucketTransactions(BucketType bucket, BudgetNotifier notifier) {
    // Get categories for this bucket
    final categories = notifier.categoryBudgets[bucket] ?? [];

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No categories allocated to this bucket',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Filter categories that have spending
    final categoriesWithSpending = categories.where((cat) {
      final spending = notifier.categorySpending[cat.id] ?? 0.0;
      return spending > 0;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spending by Category',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (categoriesWithSpending.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'No spending in this bucket yet',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...categoriesWithSpending.map((category) {
            final spending = notifier.categorySpending[category.id] ?? 0.0;
            final allocated = category.allocatedAmount;
            final percentage = allocated > 0 ? (spending / allocated * 100).clamp(0, 100) : 0.0;
            final isOver = spending > allocated;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                category.categoryName ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${spending.toStringAsFixed(0)} / \$${allocated.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isOver
                                    ? DesignTokens.color('error')
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (percentage / 100).clamp(0.0, 1.0),
                          backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(
                            isOver
                                ? DesignTokens.color('error')
                                : _getBucketColor(bucket),
                          ),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildIncomeComparisonCard(Budget budget, BudgetNotifier notifier) {
    final multiplier = _getTimePeriodMultiplier();
    final budgetedIncome = budget.monthlyIncome * multiplier;
    final actualIncome = notifier.actualIncome * multiplier;
    final variance = actualIncome - budgetedIncome;
    final percentage = budgetedIncome > 0 ? (actualIncome / budgetedIncome * 100).clamp(0, 200) : 0.0;
    final isSignificantlyUnder = variance < 0 && (variance.abs() / budgetedIncome) >= 0.15; // 15% or more under

    // Determine colors and badges
    Color? borderColor;
    String? badgeText;
    Color? badgeColor;

    if (isSignificantlyUnder) {
      borderColor = DesignTokens.color('warning');
      badgeText = 'LOW INCOME';
      badgeColor = DesignTokens.color('warning');
    } else if (variance < 0) {
      // Slightly under but not significant
      badgeText = 'UNDER';
      badgeColor = DesignTokens.color('warning').withOpacity(0.7);
    } else if (variance > 0) {
      badgeText = 'OVER';
      badgeColor = DesignTokens.color('success');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['md']!,
        border: borderColor != null
            ? Border.all(color: borderColor, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: DesignTokens.color('success'),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.onPrimary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Income',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (badgeText != null && badgeColor != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: DesignTokens.borderRadius['sm']!,
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budgeted',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${budgetedIncome.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actual',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${actualIncome.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSignificantlyUnder
                          ? DesignTokens.color('warning')
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Variance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    variance >= 0
                        ? '+\$${variance.toStringAsFixed(0)}'
                        : '-\$${(-variance).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: variance >= 0
                          ? DesignTokens.color('success')
                          : (isSignificantlyUnder ? DesignTokens.color('warning') : Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(
              isSignificantlyUnder
                  ? DesignTokens.color('warning')
                  : DesignTokens.color('success'),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}% of budgeted income received',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (isSignificantlyUnder) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: DesignTokens.color('warning').withOpacity(0.1),
                borderRadius: DesignTokens.borderRadius['sm']!,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: DesignTokens.color('warning'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your actual income is significantly below budget. Consider reviewing your spending.',
                      style: TextStyle(
                        fontSize: 11,
                        color: DesignTokens.color('warning'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllocationBucket(BucketType bucket, BudgetNotifier notifier) {
    final categories = notifier.categoryBudgets[bucket] ?? [];
    final categoriesWithAllocation = categories.where((cat) => cat.allocatedAmount > 0).toList();

    // Don't show bucket if no categories have allocations
    if (categoriesWithAllocation.isEmpty) {
      return const SizedBox.shrink();
    }

    final isExpanded = _expandedPlanBucket == bucket;
    final totalAllocated = categoriesWithAllocation.fold<double>(
      0.0,
      (sum, cat) => sum + cat.allocatedAmount,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: DesignTokens.borderRadius['md']!,
        border: Border.all(
          color: _getBucketColor(bucket).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bucket header (tappable)
          InkWell(
            onTap: () {
              setState(() {
                _expandedPlanBucket = isExpanded ? null : bucket;
              });
            },
            borderRadius: DesignTokens.borderRadius['md']!,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getBucketColor(bucket),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.category,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          _getBucketLabel(bucket),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${totalAllocated.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getBucketColor(bucket),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // Category list (when expanded)
          if (isExpanded)
            Column(
              children: categoriesWithAllocation.map((category) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            category.categoryName ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          '\$${category.allocatedAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getBucketColor(bucket),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/// Sticky header delegate for month navigation
class _MonthNavigationHeaderDelegate extends SliverPersistentHeaderDelegate {
  final DateTime selectedMonth;
  final bool isCurrentMonth;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Color onSurfaceVariantColor;
  final Color primaryColor;

  _MonthNavigationHeaderDelegate({
    required this.selectedMonth,
    required this.isCurrentMonth,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.onSurfaceVariantColor,
    required this.primaryColor,
  });

  @override
  double get minExtent => 88.0;

  @override
  double get maxExtent => 88.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final now = DateTime.now();

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: DesignTokens.borderRadius['md']!,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: canGoPrev ? onPrevMonth : null,
              color: canGoPrev ? primaryColor : onSurfaceVariantColor,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(selectedMonth),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: onSurfaceColor,
                  ),
                ),
                if (!isCurrentMonth)
                  Text(
                    selectedMonth.isBefore(DateTime(now.year, now.month, 1)) ? 'Past Month' : 'Future Month',
                    style: TextStyle(
                      fontSize: 10,
                      color: onSurfaceVariantColor,
                      height: 1.0,
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoNext ? onNextMonth : null,
              color: canGoNext ? primaryColor : onSurfaceVariantColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_MonthNavigationHeaderDelegate oldDelegate) {
    return selectedMonth != oldDelegate.selectedMonth ||
        isCurrentMonth != oldDelegate.isCurrentMonth ||
        canGoPrev != oldDelegate.canGoPrev ||
        canGoNext != oldDelegate.canGoNext ||
        backgroundColor != oldDelegate.backgroundColor ||
        surfaceColor != oldDelegate.surfaceColor ||
        onSurfaceColor != oldDelegate.onSurfaceColor ||
        onSurfaceVariantColor != oldDelegate.onSurfaceVariantColor ||
        primaryColor != oldDelegate.primaryColor;
  }
}

/// Dialog for loading and applying category allocation templates
class _LoadAllocationTemplateDialog extends StatefulWidget {
  final List<AllocationTemplate> templates;
  final BudgetNotifier budgetNotifier;

  const _LoadAllocationTemplateDialog({
    required this.templates,
    required this.budgetNotifier,
  });

  @override
  State<_LoadAllocationTemplateDialog> createState() => _LoadAllocationTemplateDialogState();
}

class _LoadAllocationTemplateDialogState extends State<_LoadAllocationTemplateDialog> {
  late List<AllocationTemplate> _localTemplates;

  @override
  void initState() {
    super.initState();
    // Create a local copy of templates so we can update UI immediately on delete
    _localTemplates = List.from(widget.templates);
  }

  Future<void> _deleteTemplate(AllocationTemplate template) async {
    final success = await widget.budgetNotifier.deleteTemplate(template.id);

    if (success && mounted) {
      setState(() {
        _localTemplates.removeWhere((t) => t.id == template.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted template "${template.name}"'),
          backgroundColor: DesignTokens.color('success'),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete template: ${widget.budgetNotifier.error ?? "Unknown error"}'),
          backgroundColor: DesignTokens.color('error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Load Budget Template',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: _localTemplates.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No templates available',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _localTemplates.length,
                itemBuilder: (context, index) {
                  final template = _localTemplates[index];
                  return Dismissible(
                    key: Key('template_${template.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: DesignTokens.color('error'),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          title: Text(
                            'Delete Template',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to delete "${template.name}"?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ) ?? false;
                    },
                    onDismissed: (direction) {
                      _deleteTemplate(template);
                    },
                    child: ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Text(
                        template.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: template.description != null
                          ? Text(
                              template.description!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => Navigator.pop(context, template.id),
                    ),
                  );
                },
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
