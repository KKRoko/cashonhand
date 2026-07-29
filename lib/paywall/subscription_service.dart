// Real StoreKit/Play Billing integration for Cash on Hand Premium.
//
// Verification is client-side only (no backend exists in this app): we trust
// the plugin's purchaseStream (StoreKit/Play Billing already verify the
// transaction before it reaches Dart) and persist entitlement locally so it
// survives restarts. restorePurchases() reconciles with the platform on every
// launch. There is no server-side receipt validation.
//
// Product IDs below must match products created inside the "Cash on Hand
// Premium" subscription group in App Store Connect exactly.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/subscription_plan.dart';

enum PurchaseResult { success, canceled, error, pending }

class PurchaseResultInfo {
  const PurchaseResultInfo(this.result, {this.message});

  final PurchaseResult result;
  final String? message;
}

class SubscriptionService extends ChangeNotifier {
  SubscriptionService._();

  static final SubscriptionService instance = SubscriptionService._();

  static const _productIds = <String>{
    SubscriptionPlan.monthlyProductId,
    SubscriptionPlan.annualProductId,
  };

  static const _prefsIsPremiumKey = 'subscription_is_premium';
  static const _prefsProductIdKey = 'subscription_product_id';
  static const _prefsPurchaseDateKey = 'subscription_purchase_date_millis';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Completer<PurchaseResultInfo>? _pendingPurchase;

  bool isAvailable = false;
  bool isLoadingProducts = true;
  List<ProductDetails> products = [];

  bool isPremium = false;
  String? activeProductId;
  DateTime? purchaseDate;

  /// Subscribes to the purchase stream. Must run before the app's first
  /// frame so no purchase update from a prior session is missed — call from
  /// `main()` before `runApp()`, not from post-frame init.
  Future<void> startListening() async {
    await _restoreLocalEntitlement();
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (Object _) {},
    );
  }

  /// Loads product details from the store and reconciles with any existing
  /// purchases. Safe to run after the first frame — does network I/O.
  Future<void> initialize() async {
    isAvailable = await _iap.isAvailable();
    if (!isAvailable) {
      isLoadingProducts = false;
      notifyListeners();
      return;
    }

    final response = await _iap.queryProductDetails(_productIds);
    products = response.productDetails;
    isLoadingProducts = false;
    notifyListeners();

    unawaited(_iap.restorePurchases());
  }

  ProductDetails? productFor(String productId) {
    for (final product in products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  /// Starts a real purchase. Resolves once the store responds — success,
  /// cancellation, or error. The paywall UI awaits this to move from its
  /// loading state to success/error.
  Future<PurchaseResultInfo> buy(String productId) {
    final product = productFor(productId);
    if (product == null) {
      return Future.value(
        const PurchaseResultInfo(
          PurchaseResult.error,
          message: 'This plan is not available right now.',
        ),
      );
    }

    _pendingPurchase = Completer<PurchaseResultInfo>();
    _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
    return _pendingPurchase!.future;
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantEntitlement(purchase);
          await _completeIfNeeded(purchase);
          _resolvePending(const PurchaseResultInfo(PurchaseResult.success));
          break;
        case PurchaseStatus.error:
          await _completeIfNeeded(purchase);
          _resolvePending(
            PurchaseResultInfo(
              PurchaseResult.error,
              message: purchase.error?.message,
            ),
          );
          break;
        case PurchaseStatus.canceled:
          await _completeIfNeeded(purchase);
          _resolvePending(const PurchaseResultInfo(PurchaseResult.canceled));
          break;
      }
    }
  }

  Future<void> _completeIfNeeded(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void _resolvePending(PurchaseResultInfo info) {
    _pendingPurchase?.complete(info);
    _pendingPurchase = null;
  }

  Future<void> _grantEntitlement(PurchaseDetails purchase) async {
    isPremium = true;
    activeProductId = purchase.productID;
    purchaseDate = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsIsPremiumKey, true);
    await prefs.setString(_prefsProductIdKey, purchase.productID);
    await prefs.setInt(
      _prefsPurchaseDateKey,
      purchaseDate!.millisecondsSinceEpoch,
    );

    notifyListeners();
  }

  Future<void> _restoreLocalEntitlement() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium = prefs.getBool(_prefsIsPremiumKey) ?? false;
    activeProductId = prefs.getString(_prefsProductIdKey);
    final millis = prefs.getInt(_prefsPurchaseDateKey);
    purchaseDate =
        millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  /// Best-effort renewal estimate for display only. Without a backend we
  /// can't query Apple's authoritative renewal date — "Manage in App Store"
  /// links out to the real subscription management page for exact billing.
  DateTime? get estimatedRenewalDate {
    final date = purchaseDate;
    final productId = activeProductId;
    if (date == null || productId == null) return null;
    return productId == SubscriptionPlan.monthlyProductId
        ? DateTime(date.year, date.month + 1, date.day)
        : DateTime(date.year + 1, date.month, date.day);
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
