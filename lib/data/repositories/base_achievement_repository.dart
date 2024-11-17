import '../models/freezed/achievement_base_implementation.dart';

abstract class BaseAchievementRepository {
  // Get achievement by ID
  Future<Achievement?> getAchievementById(String id);

  // Get all achievements
  Future<List<Achievement>> getAllAchievements();  

  // Save achievement
  Future<void> saveAchievement(Achievement achievement);

  // Unlock achievement
  Future<bool> unlockAchievement(String id);

  // Update achievement progress
  Future<void> updateProgress(String id, double progress);

  // Optional: Delete achievement
  Future<void> deleteAchievement(String id);
}
