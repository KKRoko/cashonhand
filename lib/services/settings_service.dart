import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/error/failures.dart';
import '../data/models/freezed/round_up_preferences.dart';

@singleton
class SettingsService {
  static const String _settingsKey = 'app_settings';
  static const String _roundUpPrefsKey = 'round_up_preferences';
  static const String _monthlyProgressThresholdKey = 'monthly_progress_threshold';
  
  SharedPreferences? _prefs;
  RoundUpPreferences _roundUpPreferences = const RoundUpPreferences();
  double _monthlyProgressThreshold = 10000.0; // Default $10K

  RoundUpPreferences get roundUpPreferences => _roundUpPreferences;
  double get monthlyProgressThreshold => _monthlyProgressThreshold;

  /// Initialize the settings service
  Future<Either<Failure, void>> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
      return const Right(null);
    } catch (e) {
      return Left(SettingsFailure('Failed to initialize settings: $e'));
    }
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final roundUpJson = _prefs?.getString(_roundUpPrefsKey);
      if (roundUpJson != null) {
        final roundUpMap = jsonDecode(roundUpJson) as Map<String, dynamic>;
        _roundUpPreferences = RoundUpPreferences.fromJson(roundUpMap);
      } else {
        // First time - use defaults
        _roundUpPreferences = const RoundUpPreferences();
        await _saveSettings();
      }
      
      // Load monthly progress threshold
      _monthlyProgressThreshold = _prefs?.getDouble(_monthlyProgressThresholdKey) ?? 10000.0;
    } catch (e) {
      print('Error loading settings, using defaults: $e');
      _roundUpPreferences = const RoundUpPreferences();
      _monthlyProgressThreshold = 10000.0;
    }
  }

  /// Save settings to storage
  Future<Either<Failure, void>> _saveSettings() async {
    try {
      final roundUpJson = jsonEncode(_roundUpPreferences.toJson());
      final success = await _prefs?.setString(_roundUpPrefsKey, roundUpJson) ?? false;
      
      if (!success) {
        return const Left(SettingsFailure('Failed to save settings to storage'));
      }
      
      return const Right(null);
    } catch (e) {
      return Left(SettingsFailure('Failed to save settings: $e'));
    }
  }

  /// Update round-up preferences
  Future<Either<Failure, void>> updateRoundUpPreferences(RoundUpPreferences newPrefs) async {
    try {
      _roundUpPreferences = newPrefs;
      return await _saveSettings();
    } catch (e) {
      return Left(SettingsFailure('Failed to update round-up preferences: $e'));
    }
  }

  /// Toggle round-up enabled/disabled
  Future<Either<Failure, void>> toggleRoundUp(bool enabled) async {
    final updatedPrefs = _roundUpPreferences.copyWith(isEnabled: enabled);
    return await updateRoundUpPreferences(updatedPrefs);
  }

  /// Update round-up strategy
  Future<Either<Failure, void>> updateRoundUpStrategy(RoundUpStrategy strategy) async {
    final updatedPrefs = _roundUpPreferences.copyWith(strategy: strategy);
    return await updateRoundUpPreferences(updatedPrefs);
  }

  /// Set default goal for round-ups
  Future<Either<Failure, void>> setRoundUpDefaultGoal(int? goalId) async {
    final updatedPrefs = _roundUpPreferences.copyWith(defaultGoalId: goalId);
    return await updateRoundUpPreferences(updatedPrefs);
  }

  /// Update round-up limits
  Future<Either<Failure, void>> updateRoundUpLimits({
    double? minimumRoundUp,
    double? maximumRoundUp,
  }) async {
    final updatedPrefs = _roundUpPreferences.copyWith(
      minimumRoundUp: minimumRoundUp ?? _roundUpPreferences.minimumRoundUp,
      maximumRoundUp: maximumRoundUp ?? _roundUpPreferences.maximumRoundUp,
    );
    return await updateRoundUpPreferences(updatedPrefs);
  }

  /// Add/remove category from round-up exclusions
  Future<Either<Failure, void>> toggleRoundUpCategoryExclusion(int categoryId, bool exclude) async {
    final currentExclusions = List<int>.from(_roundUpPreferences.excludedCategoryIds);
    
    if (exclude && !currentExclusions.contains(categoryId)) {
      currentExclusions.add(categoryId);
    } else if (!exclude) {
      currentExclusions.remove(categoryId);
    }

    final updatedPrefs = _roundUpPreferences.copyWith(
      excludedCategoryIds: currentExclusions,
    );
    return await updateRoundUpPreferences(updatedPrefs);
  }

  /// Reset round-up settings to defaults
  Future<Either<Failure, void>> resetRoundUpToDefaults() async {
    _roundUpPreferences = const RoundUpPreferences();
    return await _saveSettings();
  }

  /// Update monthly progress threshold
  Future<Either<Failure, void>> updateMonthlyProgressThreshold(double threshold) async {
    try {
      if (threshold <= 0) {
        return const Left(SettingsFailure('Monthly progress threshold must be greater than 0'));
      }
      
      _monthlyProgressThreshold = threshold;
      final success = await _prefs?.setDouble(_monthlyProgressThresholdKey, threshold) ?? false;
      
      if (!success) {
        return const Left(SettingsFailure('Failed to save monthly progress threshold'));
      }
      
      return const Right(null);
    } catch (e) {
      return Left(SettingsFailure('Failed to update monthly progress threshold: $e'));
    }
  }
}

/// Settings-related failure
class SettingsFailure extends Failure {
  const SettingsFailure(super.message);
}