// lib/core/architecture/architecture_screen.dart
//
// Dev-only in-app architecture viewer. Mirrors docs/architecture.md in visual
// card format. Never linked from the main nav — navigate to it directly in dev.
// Route: /architecture
//
// Keep this in sync with docs/architecture.md whenever the system changes.

import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// In-app visual representation of the system architecture.
/// Dev-only — not accessible from main navigation.
class ArchitectureScreen extends StatelessWidget {
  static const routeName = '/architecture';

  const ArchitectureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Architecture'),
        backgroundColor: DesignTokens.color('primary'),
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      body: ListView(
        padding: EdgeInsets.all(DesignTokens.space('md')),
        children: [
          _buildHeader(context),
          SizedBox(height: DesignTokens.space('lg')),
          _buildSection(context, '📱 Overview', _overviewContent),
          _buildSection(context, '🛠 Tech Stack', null,
              child: _buildTechStackTable(context)),
          _buildSection(context, '🗂 Project Structure', _structureContent),
          _buildSection(context, '⚙️ Key Systems', null,
              child: _buildSystemsGrid(context)),
          _buildSection(context, '🔄 Data Flow', null,
              child: _buildDataFlow(context)),
          _buildSection(context, '🗄 Database Schema', null,
              child: _buildDatabaseTable(context)),
          _buildSection(context, '📍 Routes', null,
              child: _buildRoutesTable(context)),
          _buildSection(
              context, '🚫 External Services', _externalServicesContent),
          SizedBox(height: DesignTokens.space('xl')),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.space('lg')),
      decoration: BoxDecoration(
        color: DesignTokens.color('primary').withValues(alpha: 0.1),
        borderRadius: DesignTokens.radius('lg'),
        border: Border.all(
            color: DesignTokens.color('primary').withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: DesignTokens.color('primary'), size: 28),
              SizedBox(width: DesignTokens.space('sm')),
              Text(
                'Cash on Hand',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.color('primary'),
                    ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.space('xs')),
          Text(
            'Architecture Reference — v1.1.2+16',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: DesignTokens.space('sm')),
          const Text(
            'Personal finance app. Fully local — no backend, no accounts. '
            'Track cash flow, build saving goals, manage budgets, earn achievements.',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section wrapper
  // ---------------------------------------------------------------------------

  Widget _buildSection(
    BuildContext context,
    String title,
    String? body, {
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: DesignTokens.space('sm')),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(DesignTokens.space('md')),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: DesignTokens.radius('md'),
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: child ??
              Text(
                body ?? '',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.6),
              ),
        ),
        SizedBox(height: DesignTokens.space('lg')),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Static content strings
  // ---------------------------------------------------------------------------

  static const String _overviewContent =
      'Personal finance Flutter app for iOS and Android. Helps users track cash flow, '
      'build saving goals, manage budgets, and develop saving habits through automatic '
      'allocations, round-ups, and gamified achievements. Runs fully offline — all data '
      'in a local SQLite database.';

  static const String _structureContent = 'lib/\n'
      '├── app.dart              Root widget, theme, nav shell, route map\n'
      '├── main.dart             Entry point — DI init, settings, launch\n'
      '├── core/\n'
      '│   ├── di/               GetIt + Injectable DI setup\n'
      '│   ├── error/            Failure types and exceptions\n'
      '│   └── architecture/     This screen\n'
      '├── data/\n'
      '│   ├── database/         Drift database + tables + type converters\n'
      '│   ├── models/           Freezed models + enums\n'
      '│   └── repositories/     Data access (interfaces + implementations)\n'
      '├── services/             Business logic layer (22 services)\n'
      '├── state/                ChangeNotifier classes (Provider)\n'
      '├── ui/                   All screens and widgets by feature\n'
      '├── paywall/              Real subscription paywall (in_app_purchase)\n'
      '├── theme/                Design tokens, app theme, enhanced theme\n'
      '├── localization/         ARB files (English only)\n'
      '└── utils/                Formatters, money math, date utils';

  static const String _externalServicesContent =
      'App Store / Play Store — subscriptions only, via StoreKit / Play '
      'Billing (in_app_purchase). No server-side receipt validation.\n\n'
      'Everything else is fully local: no analytics, no crash reporting, no '
      "backend API, no user accounts. All other data lives in the device's "
      'SQLite database via Drift.';

  // ---------------------------------------------------------------------------
  // Tech stack table
  // ---------------------------------------------------------------------------

  Widget _buildTechStackTable(BuildContext context) {
    final rows = [
      ['Framework', 'Flutter (iOS + Android)'],
      ['Language', 'Dart 3.5+'],
      ['State management', 'Provider (ChangeNotifier)'],
      ['Local database', 'Drift / SQLite — schema v17'],
      ['Dependency injection', 'GetIt + Injectable'],
      ['Models', 'Freezed + json_serializable'],
      ['Error handling', 'dartz (Either<Failure, T>)'],
      ['Charts', 'fl_chart'],
      ['Calendar', 'table_calendar'],
      ['Sharing', 'share_plus'],
      ['Animations', 'lottie, confetti'],
      ['Preferences', 'shared_preferences'],
      ['In-app purchases', 'in_app_purchase (StoreKit / Play Billing)'],
      ['Deep links', 'url_launcher'],
      ['Localization', 'Flutter ARB (English)'],
    ];

    return _buildTable(context, const ['Layer', 'Technology'], rows);
  }

  // ---------------------------------------------------------------------------
  // Systems grid
  // ---------------------------------------------------------------------------

  Widget _buildSystemsGrid(BuildContext context) {
    const systems = [
      _SystemCard('💵 Cash Dashboard',
          'Current balance + week/month/year projections. Quick-add transactions. Debounced rebuilds to prevent flicker.'),
      _SystemCard('📅 Events',
          'Core data primitive. Title, category, amount, date, optional recurrence. Recurring events expanded virtually on read.'),
      _SystemCard('🎯 Saving Goals',
          'Target amount, deadline, recurring contribution target, checkpoints. Three allocation types: manual, auto, round_up.'),
      _SystemCard('📊 Budget',
          'Monthly 50/30/20 buckets (Needs/Wants/Savings). Category-to-bucket mapping. Analytics, alerts, templates.'),
      _SystemCard('⚡ Auto-Allocation Rules',
          'Rules allocate % or fixed amount from income/expense events to goals automatically. Min/max caps supported.'),
      _SystemCard('🪙 Round-Up',
          'Rounds up expense amounts to nearest dollar → allocates difference to a goal. Configurable strategy + exclusions.'),
      _SystemCard('💡 Suggestions Engine',
          'Rule-based analysis of spending patterns, savings opportunities, goal progress, unusual activity. Top 10 per run.'),
      _SystemCard('🏆 Achievements',
          '12 achievement types (milestones, streaks, habits). Lottie + confetti celebrations on unlock. Shareable cards.'),
      _SystemCard('📈 Year-End Goals',
          'Annual % targets per bucket. Compared to YTD actuals. Per-year — stored in its own table.'),
      _SystemCard('🗂 Categories',
          'Hierarchical (parent/child). System presets protected. Custom categories supported. Bucket mapping configurable.'),
      _SystemCard('🤖 Smart Categorization',
          'Keyword matching against category names + past transactions to auto-suggest category on new event entry.'),
      _SystemCard('🚀 Onboarding',
          'Single flow on first launch. SharedPreferences flag tracks completion. Introduces goals + allocation concept.'),
      _SystemCard('💎 Subscription Paywall',
          'Real StoreKit/Play Billing flow via in_app_purchase — Premium Monthly/Annual. Client-side verification only, no backend. Cancel deep-links to platform subscription settings.'),
    ];

    return Wrap(
      spacing: DesignTokens.space('sm'),
      runSpacing: DesignTokens.space('sm'),
      children: systems.map((s) => _buildSystemCard(context, s)).toList(),
    );
  }

  Widget _buildSystemCard(BuildContext context, _SystemCard system) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignTokens.space('sm')),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: DesignTokens.radius('sm'),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            system.title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: DesignTokens.space('xs')),
          Text(
            system.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Data flow diagram
  // ---------------------------------------------------------------------------

  Widget _buildDataFlow(BuildContext context) {
    const steps = [
      ('👆 User Action (UI)', 'Tap, form submit, swipe'),
      ('📡 State Notifier', 'ChangeNotifier — holds UI-visible state'),
      ('⚙️ Service Layer', 'Business logic, validation, coordination'),
      ('🗃 Repository', 'Data access interface (Either<Failure, T>)'),
      ('💾 Drift / SQLite', 'Local database — no sync, no backend'),
    ];

    return Column(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: DesignTokens.space('xs')),
            child: Icon(
              Icons.arrow_downward,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
          );
        }
        final step = steps[i ~/ 2];
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space('md'),
            vertical: DesignTokens.space('sm'),
          ),
          decoration: BoxDecoration(
            color: DesignTokens.color('primary').withValues(alpha: 0.08),
            borderRadius: DesignTokens.radius('sm'),
            border: Border.all(
                color: DesignTokens.color('primary').withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.$1,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      step.$2,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Database table
  // ---------------------------------------------------------------------------

  Widget _buildDatabaseTable(BuildContext context) {
    final rows = [
      ['categories', 'Income/expense categories — hierarchical, system + user'],
      ['events', 'All transactions with optional recurrence'],
      ['saving_goals', 'Goals with targets, deadlines, recurring targets'],
      [
        'goal_allocations',
        'Links events to goals — tracks funding per transaction'
      ],
      [
        'auto_allocation_rules',
        'Automated rules that trigger goal contributions'
      ],
      ['budgets', 'Monthly budget (income + bucket % + cycle start day)'],
      [
        'category_budgets',
        'Per-category dollar allocations within a budget month'
      ],
      ['budget_templates', 'Saved budget configurations (preset + custom)'],
      ['year_end_goals', 'Annual bucket % targets, one row per year'],
      [
        'allocation_templates',
        'Saved category allocation split configurations'
      ],
      ['allocation_template_items', 'Line items within an allocation template'],
      ['achievements', 'Gamification achievements — progress + unlock state'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space('sm'),
            vertical: DesignTokens.space('xs'),
          ),
          decoration: BoxDecoration(
            color: DesignTokens.color('primary').withValues(alpha: 0.12),
            borderRadius: DesignTokens.radius('xs'),
          ),
          child: Text(
            'Schema v17 — migrations use _addColumnIfNotExists() to guard against non-linear upgrades',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        SizedBox(height: DesignTokens.space('sm')),
        _buildTable(context, const ['Table', 'Purpose'], rows),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Routes table
  // ---------------------------------------------------------------------------

  Widget _buildRoutesTable(BuildContext context) {
    const tabRows = [
      ['/cashOnHand', 'CashOnHandScreen', 'Tab 1 — Cash dashboard'],
      ['/savingGoals', 'SavingGoalsScreen', 'Tab 2 — Goals list'],
      ['/calendar', 'CalendarScreen', 'Tab 3 — Calendar'],
      ['/budget', 'BudgetScreen', 'Tab 4 — Budget'],
      ['/suggestions', 'SuggestionsScreen', 'Tab 5 — Insights'],
    ];

    const navRows = [
      ['/transactions', 'TransactionsScreen', 'Full transaction log'],
      ['/achievements', 'AchievementsScreen', 'Achievements + progress'],
      ['/allocationRules', 'AllocationRulesScreen', 'Auto-allocation rules'],
      ['/roundUpSettings', 'RoundUpSettingsScreen', 'Round-up configuration'],
      ['/roundUpHistory', 'RoundUpHistoryScreen', 'Round-up history'],
      ['/settings', 'SettingsView', 'Theme + preferences'],
      ['(push)', 'GoalDetailScreen', 'Individual goal detail'],
      ['(push)', 'BudgetSetupScreen', 'Create/edit monthly budget'],
      ['(push)', 'BudgetAnalyticsScreen', 'Spending analytics'],
      ['(push)', 'BudgetMonthSummaryScreen', 'Monthly summary'],
      ['(push)', 'AlertSettingsScreen', 'Budget alert thresholds'],
      ['(push)', 'SurplusAllocationScreen', 'Allocate budget surplus'],
      ['(push)', 'ManageCategoriesScreen', 'Add/edit/deactivate categories'],
      ['/paywall', 'PaywallScreen', 'Subscription paywall (real StoreKit)'],
      [
        '(push)',
        'PurchaseConfirmationScreen',
        'Purchase loading/success/error'
      ],
      [
        '/manageSubscription',
        'ManageSubscriptionScreen',
        'Manage subscription — real entitlement'
      ],
      ['(launch)', 'GoalIntegrationOnboarding', 'First-run onboarding'],
      ['/architecture', 'ArchitectureScreen', 'This screen — dev only'],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bottom nav tabs',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: DesignTokens.space('xs')),
        _buildTable(context, const ['Route', 'Screen', 'Purpose'], tabRows),
        SizedBox(height: DesignTokens.space('md')),
        Text(
          'Navigated screens',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: DesignTokens.space('xs')),
        _buildTable(context, const ['Route', 'Screen', 'Purpose'], navRows),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared table builder
  // ---------------------------------------------------------------------------

  Widget _buildTable(
    BuildContext context,
    List<String> headers,
    List<List<String>> rows,
  ) {
    final headerStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final cellStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5);

    return Table(
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(),
      },
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: DesignTokens.radius('xs'),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          children: headers
              .map((h) => Padding(
                    padding: EdgeInsets.all(DesignTokens.space('xs')),
                    child: Text(h, style: headerStyle),
                  ))
              .toList(),
        ),
        ...rows.map(
          (row) => TableRow(
            children: row
                .map((cell) => Padding(
                      padding: EdgeInsets.all(DesignTokens.space('xs')),
                      child: Text(cell, style: cellStyle),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data class for system cards
// ---------------------------------------------------------------------------

/// Holds title and description for a system overview card.
class _SystemCard {
  final String title;
  final String description;
  const _SystemCard(this.title, this.description);
}
