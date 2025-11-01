import 'package:flutter/material.dart';
import '../data/models/enums/bucket_type.dart';

class CategoryHelpers {
  /// Color scheme for parent categories
  static const Map<String, Color> parentCategoryColors = {
    // Income
    'Income': Color(0xFF4CAF50), // Green

    // Needs (generally blue/teal tones)
    'Living Expenses': Color(0xFF2196F3), // Blue
    'Transportation': Color(0xFF00BCD4), // Cyan
    'Health and Wellness': Color(0xFF009688), // Teal

    // Wants (generally purple/pink/orange tones)
    'Entertainment': Color(0xFF9C27B0), // Purple
    'Travel Expenses': Color(0xFFFF9800), // Orange
    'Gifts and Donations': Color(0xFFE91E63), // Pink
    'Clothes': Color(0xFF673AB7), // Deep Purple

    // Mixed (can be either)
    'Pet Care': Color(0xFF8D6E63), // Brown
    'Education': Color(0xFF3F51B5), // Indigo

    // Savings
    'Financial Goals': Color(0xFF4CAF50), // Green
  };

  /// Default bucket type mapping for parent categories
  static const Map<String, BucketType> parentCategoryDefaultBucket = {
    // Income doesn't have a bucket
    'Income': BucketType.needs, // Placeholder, income categories won't show bucket

    // Needs
    'Living Expenses': BucketType.needs,
    'Transportation': BucketType.needs,
    'Health and Wellness': BucketType.needs,

    // Wants
    'Entertainment': BucketType.wants,
    'Travel Expenses': BucketType.wants,
    'Gifts and Donations': BucketType.wants,
    'Clothes': BucketType.wants, // Can argue basic clothing is needs, but treating as wants

    // Mixed - defaulting to needs but users can change
    'Pet Care': BucketType.needs,
    'Education': BucketType.needs,

    // Savings
    'Financial Goals': BucketType.savings,
  };

  /// Get color for a parent category name
  static Color getParentCategoryColor(String parentName) {
    return parentCategoryColors[parentName] ?? Colors.grey;
  }

  /// Get default bucket type for a parent category
  static BucketType getDefaultBucketType(String parentName) {
    return parentCategoryDefaultBucket[parentName] ?? BucketType.needs;
  }

  /// Get bucket type label
  static String getBucketLabel(BucketType bucketType) {
    switch (bucketType) {
      case BucketType.needs:
        return 'Needs';
      case BucketType.wants:
        return 'Wants';
      case BucketType.savings:
        return 'Savings';
    }
  }

  /// Get bucket type color (for badges)
  static Color getBucketColor(BucketType bucketType) {
    switch (bucketType) {
      case BucketType.needs:
        return const Color(0xFF2196F3); // Blue
      case BucketType.wants:
        return const Color(0xFFFF9800); // Orange
      case BucketType.savings:
        return const Color(0xFF4CAF50); // Green
    }
  }
}
