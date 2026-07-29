// Selectable plan card used on the paywall and the "change plan" section of
// ManageSubscriptionScreen.

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../theme/design_tokens.dart';
import '../models/subscription_plan.dart';

class PlanOptionCard extends StatelessWidget {
  const PlanOptionCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.onTap,
    this.liveProduct,
  });

  final SubscriptionPlan plan;
  final bool selected;
  final VoidCallback onTap;

  /// Live App Store/Play pricing, when available. Falls back to [plan]'s
  /// static price while products are still loading or the store is
  /// unreachable, so the paywall never renders blank.
  final ProductDetails? liveProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = DesignTokens.color('primary');
    final outline = theme.colorScheme.outline;
    final priceText = liveProduct?.price ?? plan.priceLabel;

    return Padding(
      padding: EdgeInsets.only(
        top: plan.badgeLabel != null ? DesignTokens.space('sm') : 0,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Semantics(
            button: true,
            selected: selected,
            label: _semanticLabel,
            child: InkWell(
              onTap: onTap,
              borderRadius: DesignTokens.radius('md'),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(DesignTokens.space('md')),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.08)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: DesignTokens.radius('md'),
                  border: Border.all(
                    color: selected ? primary : outline,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selected ? primary : outline,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: DesignTokens.space('sm')),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plan.displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plan.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: DesignTokens.space('sm')),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              priceText,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              plan.periodLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        if (plan.savingsLabel != null)
                          Text(
                            plan.savingsLabel!,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: DesignTokens.color('success'),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (plan.badgeLabel != null)
            Positioned(
              top: -DesignTokens.space('sm'),
              right: DesignTokens.space('md'),
              child: ExcludeSemantics(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: DesignTokens.space('sm'),
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: DesignTokens.radius('full'),
                  ),
                  child: Text(
                    plan.badgeLabel!.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: DesignTokens.color('onPrimary'),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String get _semanticLabel {
    final priceText = liveProduct?.price ?? plan.priceLabel;
    final savings = plan.savingsLabel != null ? ', ${plan.savingsLabel}' : '';
    final badge = plan.badgeLabel != null ? ', ${plan.badgeLabel}' : '';
    return '${plan.displayName}, $priceText${plan.periodLabel}$savings$badge';
  }
}
