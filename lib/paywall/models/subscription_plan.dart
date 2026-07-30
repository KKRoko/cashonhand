// Display data for Cash on Hand Premium's two plans. Product IDs here must
// match products created in the App Store Connect subscription group exactly.

/// Distinguishes the two durations within the single "Cash on Hand Premium"
/// subscription group.
enum SubscriptionPlanType { monthly, annual }

/// Static display data for a purchasable plan, used as a fallback while real
/// App Store pricing is still loading (or if the store is unavailable).
/// [productId] is the single source of truth for the App Store Connect
/// product identifier — it must match a product created inside the
/// "Cash on Hand Premium" subscription group exactly.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.type,
    required this.productId,
    required this.displayName,
    required this.priceLabel,
    required this.periodLabel,
    required this.description,
    this.badgeLabel,
    this.savingsLabel,
  });

  final SubscriptionPlanType type;
  final String productId;
  final String displayName;
  final String priceLabel;
  final String periodLabel;
  final String description;
  final String? badgeLabel;
  final String? savingsLabel;

  static const monthlyProductId = 'com.cashonhand.premium.monthly';
  static const annualProductId = 'com.cashonhand.premium.annual';

  static const monthly = SubscriptionPlan(
    type: SubscriptionPlanType.monthly,
    productId: monthlyProductId,
    displayName: 'Premium Monthly',
    priceLabel: '\$4.99',
    periodLabel: '/mo',
    description: 'Full access to all premium features',
  );

  static const annual = SubscriptionPlan(
    type: SubscriptionPlanType.annual,
    productId: annualProductId,
    displayName: 'Premium Annual',
    priceLabel: '\$39.99',
    periodLabel: '/yr',
    description: 'Full access, billed yearly & save',
    badgeLabel: 'Best value',
    savingsLabel: 'Save ~33%',
  );

  static const all = [monthly, annual];
}
