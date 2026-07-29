// Manage subscription — reflects the real SubscriptionService entitlement.
//
// Neither "change plan" nor "cancel" can be done unilaterally by the app:
// changing plans re-purchases the other product (StoreKit/Play Billing swap
// automatically within the same subscription group with proration), and
// canceling can only happen in the platform's own subscription management
// page, which we deep-link to.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/design_tokens.dart';
import '../ui/components/cash_components.dart';
import 'models/subscription_plan.dart';
import 'purchase_confirmation_screen.dart';
import 'subscription_service.dart';
import 'paywall_screen.dart';
import 'widgets/plan_option_card.dart';

class ManageSubscriptionScreen extends StatefulWidget {
  static const routeName = '/manageSubscription';

  const ManageSubscriptionScreen({super.key});

  @override
  State<ManageSubscriptionScreen> createState() =>
      _ManageSubscriptionScreenState();
}

class _ManageSubscriptionScreenState extends State<ManageSubscriptionScreen> {
  static final _renewalFormat = DateFormat('MMM d, y');

  void _changePlan(SubscriptionPlan plan) {
    final service = SubscriptionService.instance;
    final currentType =
        service.activeProductId == SubscriptionPlan.monthlyProductId
            ? SubscriptionPlanType.monthly
            : SubscriptionPlanType.annual;
    if (plan.type == currentType) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PurchaseConfirmationScreen(plan: plan)),
    );
  }

  Future<void> _openManageInStore() async {
    final url = Uri.parse(
      Platform.isIOS
          ? 'https://apps.apple.com/account/subscriptions'
          : 'https://play.google.com/store/account/subscriptions',
    );
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open subscription settings.')),
      );
    }
  }

  Future<void> _confirmCancel() async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Premium?'),
        content: const Text(
          "Subscriptions are managed by the App Store. We'll take you to "
          'your Apple ID subscription settings, where you can turn off '
          'auto-renewal.',
        ),
        actions: [
          SecondaryButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not now'),
          ),
          FinancialButton(
            financialType: FinancialButtonType.expense,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Manage in App Store'),
          ),
        ],
      ),
    );

    if (proceed == true) {
      await _openManageInStore();
    }
  }

  void _openPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Subscription')),
      body: AnimatedBuilder(
        animation: SubscriptionService.instance,
        builder: (context, _) {
          final service = SubscriptionService.instance;
          return SingleChildScrollView(
            padding: EdgeInsets.all(DesignTokens.space('lg')),
            child: service.isPremium
                ? _buildActiveSubscription(context, service)
                : _buildUpsell(context),
          );
        },
      ),
    );
  }

  Widget _buildUpsell(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CashCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: theme.colorScheme.onSurfaceVariant,
                size: 32,
              ),
              SizedBox(height: DesignTokens.space('sm')),
              Text(
                "You're on the Free plan",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: DesignTokens.space('xs')),
              Text(
                'Upgrade to Cash on Hand Premium for unlimited budgets, savings challenges, and advanced insights.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: DesignTokens.space('lg')),
        PrimaryButton(
          onPressed: _openPaywall,
          size: ButtonSize.large,
          fullWidth: true,
          child: const Text('Upgrade to Premium'),
        ),
      ],
    );
  }

  Widget _buildActiveSubscription(
    BuildContext context,
    SubscriptionService service,
  ) {
    final theme = Theme.of(context);
    final isMonthly =
        service.activeProductId == SubscriptionPlan.monthlyProductId;
    final plan = isMonthly ? SubscriptionPlan.monthly : SubscriptionPlan.annual;
    final liveProduct = service.productFor(plan.productId);
    final priceText = liveProduct?.price ?? plan.priceLabel;
    final renewal = service.estimatedRenewalDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CashCard(
          financialContext: FinancialContext.income,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current plan',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: DesignTokens.space('xs')),
              Text(
                plan.displayName,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: DesignTokens.space('xs')),
              Text(
                '$priceText${plan.periodLabel}'
                '${renewal != null ? ' — est. renewal ${_renewalFormat.format(renewal)}' : ''}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: DesignTokens.space('xs')),
              Text(
                'Exact billing dates are managed by the App Store.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: DesignTokens.space('md')),
        SecondaryButton(
          onPressed: _openManageInStore,
          size: ButtonSize.medium,
          fullWidth: true,
          child: const Text('Manage in App Store'),
        ),
        SizedBox(height: DesignTokens.space('xl')),
        Text(
          'Change plan',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: DesignTokens.space('sm')),
        PlanOptionCard(
          plan: SubscriptionPlan.monthly,
          liveProduct: service.productFor(SubscriptionPlan.monthlyProductId),
          selected: isMonthly,
          onTap: () => _changePlan(SubscriptionPlan.monthly),
        ),
        SizedBox(height: DesignTokens.space('md')),
        PlanOptionCard(
          plan: SubscriptionPlan.annual,
          liveProduct: service.productFor(SubscriptionPlan.annualProductId),
          selected: !isMonthly,
          onTap: () => _changePlan(SubscriptionPlan.annual),
        ),
        SizedBox(height: DesignTokens.space('xl')),
        Center(
          child: TextButton(
            onPressed: _confirmCancel,
            style: TextButton.styleFrom(
              foregroundColor: DesignTokens.color('error'),
            ),
            child: const Text('Cancel subscription'),
          ),
        ),
      ],
    );
  }
}
