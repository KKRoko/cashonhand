// Purchase confirmation — awaits a real StoreKit/Play Billing purchase.
//
// Cancellation (user backs out of the native payment sheet) quietly returns
// to the paywall. Errors get a retry. Success shows the celebration screen.

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../ui/components/cash_components.dart';
import 'models/subscription_plan.dart';
import 'subscription_service.dart';

class PurchaseConfirmationScreen extends StatefulWidget {
  const PurchaseConfirmationScreen({super.key, required this.plan});

  final SubscriptionPlan plan;

  @override
  State<PurchaseConfirmationScreen> createState() =>
      _PurchaseConfirmationScreenState();
}

class _PurchaseConfirmationScreenState
    extends State<PurchaseConfirmationScreen> {
  late Future<PurchaseResultInfo> _purchaseFuture;

  @override
  void initState() {
    super.initState();
    _purchaseFuture = _startPurchase();
  }

  Future<PurchaseResultInfo> _startPurchase() {
    final future = SubscriptionService.instance.buy(widget.plan.productId);
    future.then((result) {
      if (!mounted) return;
      // A user-initiated cancel isn't an error — just return to the paywall
      // so they can pick a different plan or try again.
      if (result.result == PurchaseResult.canceled) {
        Navigator.of(context).pop();
      }
    });
    return future;
  }

  void _retry() {
    setState(() => _purchaseFuture = _startPurchase());
  }

  void _finish() {
    final navigator = Navigator.of(context);
    navigator.pop();
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PurchaseResultInfo>(
      future: _purchaseFuture,
      builder: (context, snapshot) {
        final isProcessing = snapshot.connectionState != ConnectionState.done;
        return PopScope(
          canPop: !isProcessing,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(DesignTokens.space('xl')),
                  child: _buildContent(context, isProcessing, snapshot.data),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isProcessing,
    PurchaseResultInfo? result,
  ) {
    if (isProcessing || result?.result == PurchaseResult.canceled) {
      return _buildLoading(context);
    }
    if (result?.result == PurchaseResult.success) {
      return _buildSuccess(context);
    }
    return _buildError(context, result);
  }

  Widget _buildLoading(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: DesignTokens.color('primary')),
        SizedBox(height: DesignTokens.space('lg')),
        Semantics(
          liveRegion: true,
          child: Text(
            'Setting up your subscription…',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        SizedBox(height: DesignTokens.space('xs')),
        Text(
          'This will only take a moment.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: reduceMotion ? 1.0 : 0.0, end: 1.0),
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: DesignTokens.color('success').withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: DesignTokens.color('success'),
              size: 64,
            ),
          ),
        ),
        SizedBox(height: DesignTokens.space('lg')),
        Semantics(
          liveRegion: true,
          header: true,
          child: Text(
            "You're on Premium!",
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: DesignTokens.space('xs')),
        Text(
          'You now have full access to every Cash on Hand Premium feature.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: DesignTokens.space('xl')),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: _finish,
            size: ButtonSize.large,
            fullWidth: true,
            child: const Text('Get started'),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, PurchaseResultInfo? result) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: DesignTokens.color('error').withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error_outline,
            color: DesignTokens.color('error'),
            size: 64,
          ),
        ),
        SizedBox(height: DesignTokens.space('lg')),
        Semantics(
          liveRegion: true,
          header: true,
          child: Text(
            'Purchase failed',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: DesignTokens.space('xs')),
        Text(
          result?.message ?? 'Something went wrong. Please try again.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: DesignTokens.space('xl')),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: _retry,
            size: ButtonSize.large,
            fullWidth: true,
            child: const Text('Try again'),
          ),
        ),
        SizedBox(height: DesignTokens.space('sm')),
        SizedBox(
          width: double.infinity,
          child: SecondaryButton(
            onPressed: () => Navigator.of(context).pop(),
            size: ButtonSize.large,
            fullWidth: true,
            child: const Text('Close'),
          ),
        ),
      ],
    );
  }
}
