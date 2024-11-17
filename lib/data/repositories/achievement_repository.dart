import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import '../models/freezed/achievement_base_implementation.dart';
import '../database/database.dart';
import 'base_achievement_repository.dart';

@Injectable(as: BaseAchievementRepository)
class AchievementRepository implements BaseAchievementRepository {
  final Database _db;

  AchievementRepository(this._db);

  Achievement _mapToModel(AchievementTableData data) {
    return Achievement(
      id: data.id,
      title: data.title,
      description: data.description,
      type: data.type,
      targetAmount: data.targetAmount,
      isUnlocked: data.isUnlocked,
      progress: data.progress,
      unlockedAt: data.unlockedAt,
    );
  }

  AchievementsCompanion _mapToCompanion(Achievement achievement) {
    return AchievementsCompanion.insert(
      id: achievement.id,
      title: achievement.title,
      description: achievement.description,
      type: achievement.type,
      targetAmount: achievement.targetAmount,
      isUnlocked: Value(achievement.isUnlocked),
      progress: Value(achievement.progress),
      unlockedAt: Value(achievement.unlockedAt),
    );
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final achievements = await _db.getAllAchievements();
      return achievements.map(_mapToModel).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Achievement?> getAchievementById(String id) async {
    try {
      final result = await _db.getAchievementById(id);
      return result != null ? _mapToModel(result) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAchievement(Achievement achievement) async {
    try {
      final existing = await _db.getAchievementById(achievement.id);
      if (existing != null) {
        await _db.updateAchievement(
          AchievementTableData(
            id: achievement.id,
            title: achievement.title,
            description: achievement.description,
            type: achievement.type,
            targetAmount: achievement.targetAmount,
            isUnlocked: achievement.isUnlocked,
            progress: achievement.progress,
            unlockedAt: achievement.unlockedAt,
            createdAt: existing.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await _db.createAchievement(_mapToCompanion(achievement));
      }
    } catch (e) {
      // Log error or handle accordingly
    }
  }

  @override
  Future<bool> unlockAchievement(String id) async {
    try {
      final achievement = await _db.getAchievementById(id);
      if (achievement != null && !achievement.isUnlocked) {
        final updated = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: Value(DateTime.now()),  // Use Value here
          updatedAt: DateTime.now()           // Don't use Value here
        );
        return await _db.updateAchievement(updated);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateProgress(String id, double progress) async {
    try {
      final achievement = await _db.getAchievementById(id);
      if (achievement != null) {
        final updated = achievement.copyWith(
          progress: progress,
          updatedAt: DateTime.now()  // Don't use Value here
        );
        await _db.updateAchievement(updated);
      }
    } catch (e) {
      // Log error or handle accordingly
    }
  }

  @override
  Future<void> deleteAchievement(String id) async {
    try {
      await _db.deleteAchievement(id);
    } catch (e) {
      // Log error or handle accordingly
    }
  }
}
