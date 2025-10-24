import 'package:injectable/injectable.dart';
import '../data/models/enums/bucket_type.dart';

/// Service that automatically maps expense categories to budget buckets
/// based on common category names and patterns.
@singleton
class CategoryBucketMapper {

  /// Get suggested bucket for a category based on its name
  BucketType suggestBucket(String categoryName) {
    final lowerName = categoryName.toLowerCase().trim();

    // NEEDS: Essential expenses for living
    if (_isNeedsCategory(lowerName)) {
      return BucketType.needs;
    }

    // SAVINGS: Long-term financial goals
    if (_isSavingsCategory(lowerName)) {
      return BucketType.savings;
    }

    // WANTS: Everything else (discretionary spending)
    return BucketType.wants;
  }

  bool _isNeedsCategory(String categoryName) {
    // Housing & utilities
    if (categoryName.contains('rent') ||
        categoryName.contains('mortgage') ||
        categoryName.contains('utilities') ||
        categoryName.contains('electric') ||
        categoryName.contains('water') ||
        categoryName.contains('gas') ||
        categoryName.contains('internet') ||
        categoryName.contains('phone') ||
        categoryName.contains('housing')) {
      return true;
    }

    // Food essentials
    if (categoryName.contains('groceries') ||
        categoryName.contains('grocery')) {
      return true;
    }

    // Transportation essentials
    if (categoryName.contains('car payment') ||
        categoryName.contains('insurance') ||
        categoryName.contains('fuel') ||
        categoryName.contains('gas') ||
        categoryName.contains('transport')) {
      return true;
    }

    // Healthcare
    if (categoryName.contains('health') ||
        categoryName.contains('medical') ||
        categoryName.contains('medicine') ||
        categoryName.contains('doctor') ||
        categoryName.contains('pharmacy')) {
      return true;
    }

    // Childcare & education essentials
    if (categoryName.contains('childcare') ||
        categoryName.contains('daycare') ||
        categoryName.contains('school') && !categoryName.contains('supplies')) {
      return true;
    }

    return false;
  }

  bool _isSavingsCategory(String categoryName) {
    // Savings & investments
    if (categoryName.contains('saving') ||
        categoryName.contains('investment') ||
        categoryName.contains('retirement') ||
        categoryName.contains('401k') ||
        categoryName.contains('ira') ||
        categoryName.contains('emergency fund') ||
        categoryName.contains('debt payment') ||
        categoryName.contains('loan payment')) {
      return true;
    }

    return false;
  }

  /// Get human-readable explanation for why a category was mapped to a bucket
  String getReasonForMapping(String categoryName, BucketType bucket) {
    final lowerName = categoryName.toLowerCase().trim();

    switch (bucket) {
      case BucketType.needs:
        if (lowerName.contains('rent') || lowerName.contains('mortgage') || lowerName.contains('utilities')) {
          return 'Essential housing cost';
        }
        if (lowerName.contains('groceries')) {
          return 'Essential food expense';
        }
        if (lowerName.contains('insurance') || lowerName.contains('car payment')) {
          return 'Essential transportation cost';
        }
        if (lowerName.contains('health') || lowerName.contains('medical')) {
          return 'Essential healthcare expense';
        }
        return 'Essential living expense';

      case BucketType.savings:
        if (lowerName.contains('saving') || lowerName.contains('investment')) {
          return 'Builds financial future';
        }
        if (lowerName.contains('debt') || lowerName.contains('loan')) {
          return 'Reduces debt burden';
        }
        return 'Long-term financial goal';

      case BucketType.wants:
        return 'Discretionary spending';
    }
  }
}
