// Subscription paywall — real StoreKit/Play Billing purchase flow.
//
// "Start Premium" pushes PurchaseConfirmationScreen, which calls
// SubscriptionService.buy() and awaits the real result from the store.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../theme/design_tokens.dart';
import '../ui/components/cash_components.dart';
import 'models/subscription_plan.dart';
import 'purchase_confirmation_screen.dart';
import 'subscription_service.dart';
import 'widgets/plan_option_card.dart';

class PaywallScreen extends StatefulWidget {
  static const routeName = '/paywall';

  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.annual;

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  static const _benefits = [
    (Icons.all_inclusive, 'Unlimited budgets and savings goals'),
    (Icons.emoji_events_outlined, 'Savings challenges and streak tools'),
    (Icons.insights_outlined, 'Advanced spending insights'),
    (Icons.block_outlined, 'No ads, ever'),
  ];

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showDemoLinkNotice('Terms of Use');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showDemoLinkNotice('Privacy Policy');
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _showDemoLinkNotice(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label (demo link)')),
    );
  }

  Future<void> _restorePurchases() async {
    final service = SubscriptionService.instance;
    final wasPremium = service.isPremium;
    await service.restorePurchases();
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final isPremiumNow = service.isPremium;
    final message = isPremiumNow && !wasPremium
        ? 'Your Premium subscription has been restored.'
        : isPremiumNow
            ? 'You already have an active Premium subscription.'
            : 'No previous purchases found to restore.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PurchaseConfirmationScreen(plan: _selectedPlan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SubscriptionService.instance,
      builder: (context, _) {
        final service = SubscriptionService.instance;
        if (service.isLoadingProducts) {
          return _buildStatusScaffold(
            context,
            child: const CircularProgressIndicator(),
          );
        }
        if (!service.isAvailable || service.products.isEmpty) {
          return _buildStatusScaffold(
            context,
            child: Text(
              "In-app purchases aren't available on this device right now. "
              'Please try again later.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        return _buildPaywall(context, service);
      },
    );
  }

  Widget _buildStatusScaffold(BuildContext context, {required Widget child}) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.all(DesignTokens.space('xl')),
                child: child,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaywall(BuildContext context, SubscriptionService service) {
    final theme = Theme.of(context);
    final monthlyProduct =
        service.productFor(SubscriptionPlan.monthlyProductId);
    final annualProduct = service.productFor(SubscriptionPlan.annualProductId);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                DesignTokens.space('lg'),
                DesignTokens.space('xl'),
                DesignTokens.space('lg'),
                DesignTokens.space('lg'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _buildHeroIcon(context)),
                  SizedBox(height: DesignTokens.space('lg')),
                  Text(
                    'Unlock Cash on Hand Premium',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: DesignTokens.space('xs')),
                  Text(
                    'Get the full toolkit for building better saving habits.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: DesignTokens.space('xl')),
                  ..._benefits
                      .map((b) => _buildBenefitRow(context, b.$1, b.$2)),
                  SizedBox(height: DesignTokens.space('lg')),
                  PlanOptionCard(
                    plan: SubscriptionPlan.monthly,
                    liveProduct: monthlyProduct,
                    selected:
                        _selectedPlan.type == SubscriptionPlanType.monthly,
                    onTap: () => setState(
                        () => _selectedPlan = SubscriptionPlan.monthly),
                  ),
                  SizedBox(height: DesignTokens.space('md')),
                  PlanOptionCard(
                    plan: SubscriptionPlan.annual,
                    liveProduct: annualProduct,
                    selected: _selectedPlan.type == SubscriptionPlanType.annual,
                    onTap: () =>
                        setState(() => _selectedPlan = SubscriptionPlan.annual),
                  ),
                  SizedBox(height: DesignTokens.space('lg')),
                  PrimaryButton(
                    onPressed: _continue,
                    size: ButtonSize.large,
                    fullWidth: true,
                    child: const Text('Start Premium'),
                  ),
                  SizedBox(height: DesignTokens.space('md')),
                  _buildComplianceText(context, monthlyProduct, annualProduct),
                  SizedBox(height: DesignTokens.space('sm')),
                  Center(
                    child: TextButton(
                      onPressed: _restorePurchases,
                      child: const Text('Restore Purchases'),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroIcon(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: DesignTokens.color('primary').withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.workspace_premium,
        color: DesignTokens.color('primary'),
        size: 48,
      ),
    );
  }

  Widget _buildBenefitRow(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.space('md')),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DesignTokens.color('primary').withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: DesignTokens.color('primary'),
              size: 20,
            ),
          ),
          SizedBox(width: DesignTokens.space('md')),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceText(
    BuildContext context,
    ProductDetails? monthlyProduct,
    ProductDetails? annualProduct,
  ) {
    final theme = Theme.of(context);
    final monthlyPrice =
        monthlyProduct?.price ?? SubscriptionPlan.monthly.priceLabel;
    final annualPrice =
        annualProduct?.price ?? SubscriptionPlan.annual.priceLabel;
    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.5,
    );
    final linkStyle = baseStyle?.copyWith(
      color: DesignTokens.color('primary'),
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: 'Premium Monthly is $monthlyPrice/month and Premium Annual '
                'is $annualPrice/year. Payment is charged to your Apple ID '
                'account at confirmation of purchase. Your subscription '
                'automatically renews unless auto-renew is turned off at '
                'least 24 hours before the end of the current period. Manage '
                'or cancel anytime in your Apple ID account settings. By '
                'continuing, you agree to our ',
          ),
          TextSpan(
            text: 'Terms of Use',
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
