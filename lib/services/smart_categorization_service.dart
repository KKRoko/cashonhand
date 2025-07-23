import 'package:injectable/injectable.dart';
import '../data/database/database.dart';
import '../data/models/enums/category_type.dart';
import '../core/di/injection.dart';

@injectable
class SmartCategorizationService {
  final Database _database;

  SmartCategorizationService(this._database);

  /// Smart categorization rules mapping keywords to category names
  static const Map<String, List<String>> _expenseKeywords = {
    // Living Expenses
    'Rent or mortgage': ['rent', 'mortgage', 'lease', 'housing payment', 'landlord'],
    'Internet': ['internet', 'wifi', 'broadband', 'comcast', 'verizon', 'att', 'spectrum'],
    'Cable': ['cable', 'directv', 'dish', 'satellite tv', 'cable tv'],
    'Water': ['water', 'water bill', 'utility water', 'municipal water'],
    'Electricity': ['electric', 'electricity', 'power', 'pge', 'edison', 'utility electric'],
    'Phone service': ['phone', 'mobile', 'cell', 'verizon', 'att', 't-mobile', 'sprint'],
    'Groceries': ['grocery', 'groceries', 'food', 'supermarket', 'walmart', 'target', 'kroger', 'safeway', 'whole foods', 'trader joe'],
    
    // Transportation  
    'Gas': ['gas', 'gasoline', 'fuel', 'chevron', 'shell', 'exxon', 'bp', 'mobil', 'arco'],
    'Car insurance': ['car insurance', 'auto insurance', 'geico', 'progressive', 'state farm', 'allstate'],
    'Car payment': ['car payment', 'auto loan', 'vehicle payment', 'car finance'],
    'Car repairs': ['mechanic', 'auto repair', 'car repair', 'maintenance', 'oil change', 'tire'],
    'Uber/Lyft': ['uber', 'lyft', 'rideshare', 'taxi', 'cab'],
    'Parking': ['parking', 'park', 'meter', 'garage'],
    
    // Food & Dining
    'Restaurants': ['restaurant', 'dining', 'mcdonald', 'burger', 'pizza', 'starbucks', 'coffee', 'cafe', 'bar', 'pub', 'takeout', 'delivery', 'doordash', 'ubereats', 'grubhub'],
    
    // Entertainment
    'Movies': ['movie', 'cinema', 'theater', 'amc', 'regal'],
    'Streaming platforms': ['netflix', 'hulu', 'disney', 'amazon prime', 'spotify', 'apple music', 'youtube premium'],
    'Gaming': ['steam', 'playstation', 'xbox', 'nintendo', 'game'],
    
    // Health & Wellness
    'Prescription medications': ['pharmacy', 'cvs', 'walgreens', 'rite aid', 'prescription', 'medication'],
    'Gym membership': ['gym', 'fitness', 'planet fitness', '24 hour fitness', 'la fitness'],
    
    // Pet Care
    'Veterinary care': ['vet', 'veterinary', 'animal hospital', 'pet clinic'],
    'Pet insurance': ['pet insurance', 'petplan', 'healthy paws'],
    'Food': ['pet food', 'dog food', 'cat food', 'petco', 'petsmart'],
    
    // Travel
    'Airfare': ['airline', 'flight', 'airport', 'american airlines', 'delta', 'united', 'southwest'],
    'Transportation': ['train', 'bus', 'amtrak', 'greyhound', 'metro'],
    'Accommodations': ['hotel', 'motel', 'airbnb', 'booking', 'marriott', 'hilton'],
    
    // Financial Goals
    'Credit card payments': ['credit card', 'visa', 'mastercard', 'amex', 'discover', 'payment'],
    'Student loan payments': ['student loan', 'sallie mae', 'navient', 'federal loan'],
    
    // Clothes
    'Work attire': ['suit', 'dress shirt', 'business', 'professional'],
    'Leisure attire': ['casual', 't-shirt', 'jeans', 'sneakers'],
    'Shoes': ['shoes', 'boots', 'sneakers', 'sandals', 'nike', 'adidas'],
    
    // Education
    'Books': ['book', 'textbook', 'amazon books', 'barnes', 'bookstore'],
    'Tuition': ['tuition', 'school', 'university', 'college', 'education'],
  };

  static const Map<String, List<String>> _incomeKeywords = {
    'Salary': ['salary', 'payroll', 'paycheck', 'wages', 'employer', 'work', 'job'],
    'Investment': ['dividend', 'stock', 'bond', 'investment', 'capital gains', 'portfolio'],
    'Freelance': ['freelance', 'consulting', 'contractor', 'gig', 'project'],
    'Side Business': ['business', 'side income', 'sales', 'revenue'],
    'Rental Income': ['rent income', 'rental', 'tenant', 'property income'],
  };

  /// Suggests a category based on transaction title
  Future<SmartCategorizationResult?> suggestCategory(String title, CategoryType type) async {
    if (title.trim().isEmpty) return null;
    
    final titleLower = title.toLowerCase();
    final keywords = type == CategoryType.expense ? _expenseKeywords : _incomeKeywords;
    
    // Find the best matching category
    String? bestMatchCategory;
    String? matchedKeyword;
    int bestScore = 0;
    
    for (final entry in keywords.entries) {
      final categoryName = entry.key;
      final categoryKeywords = entry.value;
      
      for (final keyword in categoryKeywords) {
        int score = _calculateMatchScore(titleLower, keyword.toLowerCase());
        if (score > bestScore) {
          bestScore = score;
          bestMatchCategory = categoryName;
          matchedKeyword = keyword;
        }
      }
    }
    
    // Only suggest if we have a good match (score > 50)
    if (bestScore > 50 && bestMatchCategory != null) {
      final category = await _findCategoryByName(bestMatchCategory, type);
      if (category != null) {
        return SmartCategorizationResult(
          suggestedCategory: category,
          confidence: (bestScore / 100.0).clamp(0.0, 1.0),
          matchedKeyword: matchedKeyword ?? '',
          reason: 'Matched "$matchedKeyword" in transaction title',
        );
      }
    }
    
    return null;
  }

  /// Calculate match score between title and keyword
  int _calculateMatchScore(String title, String keyword) {
    // Exact match gets highest score
    if (title == keyword) return 100;
    
    // Contains the keyword gets high score
    if (title.contains(keyword)) return 90;
    
    // Check for partial matches and word boundaries
    final titleWords = title.split(RegExp(r'\s+'));
    final keywordWords = keyword.split(RegExp(r'\s+'));
    
    int wordMatches = 0;
    for (final keywordWord in keywordWords) {
      for (final titleWord in titleWords) {
        if (titleWord.contains(keywordWord) || keywordWord.contains(titleWord)) {
          wordMatches++;
          break;
        }
      }
    }
    
    // Score based on word matches
    if (wordMatches == keywordWords.length) return 80; // All words match
    if (wordMatches > 0) return 60; // Some words match
    
    // Check for fuzzy matching (simple Levenshtein-like)
    if (_isFuzzyMatch(title, keyword)) return 55;
    
    return 0;
  }

  /// Simple fuzzy matching for typos and variations
  bool _isFuzzyMatch(String title, String keyword) {
    if (keyword.length < 4) return false; // Too short for fuzzy matching
    
    // Check if most characters are present
    int matchingChars = 0;
    for (int i = 0; i < keyword.length; i++) {
      if (title.contains(keyword[i])) {
        matchingChars++;
      }
    }
    
    return matchingChars >= (keyword.length * 0.7); // 70% character match
  }

  /// Find category by name in the database
  Future<CategoryTableData?> _findCategoryByName(String categoryName, CategoryType type) async {
    try {
      final categories = await _database.getCategories(type: type);
      
      // First try exact match
      for (final category in categories) {
        if (category.name.toLowerCase() == categoryName.toLowerCase()) {
          return category;
        }
      }
      
      // Then try partial match
      for (final category in categories) {
        if (category.name.toLowerCase().contains(categoryName.toLowerCase()) ||
            categoryName.toLowerCase().contains(category.name.toLowerCase())) {
          return category;
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error finding category by name: $e');
      return null;
    }
  }

  /// Get all categories for validation
  Future<List<CategoryTableData>> getAllCategories(CategoryType type) async {
    return await _database.getCategories(type: type);
  }
}

/// Result of smart categorization
class SmartCategorizationResult {
  final CategoryTableData suggestedCategory;
  final double confidence;
  final String matchedKeyword;
  final String reason;

  SmartCategorizationResult({
    required this.suggestedCategory,
    required this.confidence,
    required this.matchedKeyword,
    required this.reason,
  });

  /// Whether this suggestion has high confidence (>0.8)
  bool get isHighConfidence => confidence > 0.8;

  /// Whether this suggestion has medium confidence (0.6-0.8)
  bool get isMediumConfidence => confidence >= 0.6 && confidence <= 0.8;

  /// Confidence as percentage string
  String get confidencePercentage => '${(confidence * 100).round()}%';
}