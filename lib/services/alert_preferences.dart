import 'package:shared_preferences/shared_preferences.dart';

/// Manages user preferences for budget alerts
class AlertPreferences {
  static const String _keyWarningThreshold = 'alert_warning_threshold';
  static const String _keyCriticalThreshold = 'alert_critical_threshold';
  static const String _keyEnableBucketAlerts = 'alert_enable_bucket';
  static const String _keyEnableCategoryAlerts = 'alert_enable_category';
  static const String _keyShowAlertBanner = 'alert_show_banner';
  static const String _keyShowPercentage = 'alert_show_percentage';
  static const String _keyEnableIncomeVarianceAlerts = 'alert_enable_income_variance';

  // Default values
  static const double defaultWarningThreshold = 0.80; // 80%
  static const double defaultCriticalThreshold = 1.00; // 100%
  static const bool defaultEnableBucketAlerts = true;
  static const bool defaultEnableCategoryAlerts = true;
  static const bool defaultShowAlertBanner = true;
  static const bool defaultShowPercentage = true;
  static const bool defaultEnableIncomeVarianceAlerts = true;

  final double warningThreshold;
  final double criticalThreshold;
  final bool enableBucketAlerts;
  final bool enableCategoryAlerts;
  final bool showAlertBanner;
  final bool showPercentage;
  final bool enableIncomeVarianceAlerts;

  AlertPreferences({
    required this.warningThreshold,
    required this.criticalThreshold,
    required this.enableBucketAlerts,
    required this.enableCategoryAlerts,
    required this.showAlertBanner,
    required this.showPercentage,
    required this.enableIncomeVarianceAlerts,
  });

  /// Load preferences from SharedPreferences
  static Future<AlertPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();

    return AlertPreferences(
      warningThreshold: prefs.getDouble(_keyWarningThreshold) ?? defaultWarningThreshold,
      criticalThreshold: prefs.getDouble(_keyCriticalThreshold) ?? defaultCriticalThreshold,
      enableBucketAlerts: prefs.getBool(_keyEnableBucketAlerts) ?? defaultEnableBucketAlerts,
      enableCategoryAlerts: prefs.getBool(_keyEnableCategoryAlerts) ?? defaultEnableCategoryAlerts,
      showAlertBanner: prefs.getBool(_keyShowAlertBanner) ?? defaultShowAlertBanner,
      showPercentage: prefs.getBool(_keyShowPercentage) ?? defaultShowPercentage,
      enableIncomeVarianceAlerts: prefs.getBool(_keyEnableIncomeVarianceAlerts) ?? defaultEnableIncomeVarianceAlerts,
    );
  }

  /// Save preferences to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setDouble(_keyWarningThreshold, warningThreshold),
      prefs.setDouble(_keyCriticalThreshold, criticalThreshold),
      prefs.setBool(_keyEnableBucketAlerts, enableBucketAlerts),
      prefs.setBool(_keyEnableCategoryAlerts, enableCategoryAlerts),
      prefs.setBool(_keyShowAlertBanner, showAlertBanner),
      prefs.setBool(_keyShowPercentage, showPercentage),
      prefs.setBool(_keyEnableIncomeVarianceAlerts, enableIncomeVarianceAlerts),
    ]);
  }

  /// Create a copy with updated values
  AlertPreferences copyWith({
    double? warningThreshold,
    double? criticalThreshold,
    bool? enableBucketAlerts,
    bool? enableCategoryAlerts,
    bool? showAlertBanner,
    bool? showPercentage,
    bool? enableIncomeVarianceAlerts,
  }) {
    return AlertPreferences(
      warningThreshold: warningThreshold ?? this.warningThreshold,
      criticalThreshold: criticalThreshold ?? this.criticalThreshold,
      enableBucketAlerts: enableBucketAlerts ?? this.enableBucketAlerts,
      enableCategoryAlerts: enableCategoryAlerts ?? this.enableCategoryAlerts,
      showAlertBanner: showAlertBanner ?? this.showAlertBanner,
      showPercentage: showPercentage ?? this.showPercentage,
      enableIncomeVarianceAlerts: enableIncomeVarianceAlerts ?? this.enableIncomeVarianceAlerts,
    );
  }

  /// Get warning threshold as percentage (0.80 -> 80)
  int get warningPercentage => (warningThreshold * 100).round();

  /// Get critical threshold as percentage (1.00 -> 100)
  int get criticalPercentage => (criticalThreshold * 100).round();

  /// Validate thresholds are in acceptable range
  bool get isValid {
    return warningThreshold >= 0.50 &&
           warningThreshold <= 1.50 &&
           criticalThreshold >= 0.50 &&
           criticalThreshold <= 1.50 &&
           warningThreshold < criticalThreshold;
  }
}
