import 'package:injectable/injectable.dart';
import '../data/models/freezed/achievement_base_implementation.dart';
import '../data/repositories/base_achievement_repository.dart';
import '../state/achievement_state.dart';
import 'event_service.dart';

@injectable
class AchievementService {
  final BaseAchievementRepository _repository;
  final EventService _eventService;
  final AchievementNotifier _notifier;

  AchievementService(
    this._repository,
    this._eventService,
    this._notifier,
  );
    Future<List<Achievement>> checkSavingGoalsAchievements() async {
    return await checkAchievements(); // This will check all achievements including saving-related ones
  }

  // Core achievement checking logic
  Future<List<Achievement>> checkAchievements() async {
    final unlockedAchievements = <Achievement>[];
    
    unlockedAchievements.addAll(await checkSavingMilestones());
    unlockedAchievements.addAll(await checkStreaks());
    unlockedAchievements.addAll(await checkYearEndTarget());
    
    return unlockedAchievements;
  }

  Future<List<Achievement>> checkSavingMilestones() async {
    final unlockedAchievements = <Achievement>[];
    final eventsResult = await _eventService.getEventsForRange(
      DateTime(DateTime.now().year),
      DateTime.now(),
    );
    
    return eventsResult.fold(
      (failure) => [], // Return empty list on failure
      (events) async {
        final currentBalance = events.fold<double>(
          0.0,
          (sum, event) => sum + (event.amount),
        );

        final milestones = [1000, 5000, 10000];
        for (final milestone in milestones) {
          final id = 'saving_milestone_$milestone';
          if (currentBalance >= milestone) {
            final achievement = await _repository.getAchievementById(id);
            if (achievement != null && !achievement.isUnlocked) {
              await _repository.unlockAchievement(id);
              _notifier.achievementStream.listen((event) {
                if (event.type == AchievementEventType.unlocked && 
                    event.achievementId == id) {
                  unlockedAchievements.add(achievement);
                }
              });
              _notifier.onAchievementUnlocked(id);
            }
          }
        }
        return unlockedAchievements;
      },
    );
  }

  Future<List<Achievement>> checkStreaks() async {
    final unlockedAchievements = <Achievement>[];
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final eventsResult = await _eventService.getEventsForRange(
      threeMonthsAgo,
      DateTime.now(),
    );

    return eventsResult.fold(
      (failure) => [],
      (events) async {
        final monthlySavings = <int, double>{};
        for (final event in events) {
          final month = event.dateTime.month;
          monthlySavings[month] = (monthlySavings[month] ?? 0) + (event.amount);
        }

        var consecutiveMonths = 0;
        for (var i = 0; i < 3; i++) {
          final month = DateTime.now().subtract(Duration(days: 30 * i)).month;
          if ((monthlySavings[month] ?? 0) > 0) {
            consecutiveMonths++;
          } else {
            break;
          }
        }

        if (consecutiveMonths >= 3) {
          final wasUnlocked = await _repository.unlockAchievement('streak_3_months');
          if (wasUnlocked) {
            final achievement = await _repository.getAchievementById('streak_3_months');
            if (achievement != null) {
              _notifier.achievementStream.listen((event) {
                if (event.type == AchievementEventType.unlocked && 
                    event.achievementId == 'streak_3_months') {
                  unlockedAchievements.add(achievement);
                }
              });
              _notifier.onAchievementUnlocked('streak_3_months');
            }
          }
        }
        return unlockedAchievements;
      },
    );
  }

  Future<List<Achievement>> checkYearEndTarget() async {
    final unlockedAchievements = <Achievement>[];
    final yearStart = DateTime(DateTime.now().year);
    final eventsResult = await _eventService.getEventsForRange(
      yearStart,
      DateTime.now(),
    );

    return eventsResult.fold(
      (failure) => [],
      (events) async {
        final currentSavings = events.fold<double>(
          0,
          (sum, event) => sum + (event.amount),
        );

        const yearEndTarget = 12000.0;
        final progress = (currentSavings / yearEndTarget) * 100;

        final achievement = await _repository.getAchievementById('year_end_target');
        if (achievement != null) {
          _notifier.onAchievementUpdated(achievement.copyWith(progress: progress));
        }
        
        if (currentSavings >= yearEndTarget) {
          final wasUnlocked = await _repository.unlockAchievement('year_end_target');
          if (wasUnlocked) {
            final achievement = await _repository.getAchievementById('year_end_target');
            if (achievement != null) {
              _notifier.achievementStream.listen((event) {
                if (event.type == AchievementEventType.unlocked && 
                    event.achievementId == 'year_end_target') {
                  unlockedAchievements.add(achievement);
                }
              });
              _notifier.onAchievementUnlocked('year_end_target');
            }
          }
        }
        return unlockedAchievements;
      },
    );
  }

  Future<void> initializeAchievements() async {
    final defaults = [
      const Achievement(
        id: 'saving_milestone_1000',
        title: 'First Grand',
        description: 'Save your first \$1,000',
        type: AchievementType.savingMilestone,
        targetAmount: 1000,
        isUnlocked: false,
      ),
      const Achievement(
        id: 'streak_3_months',
        title: 'Consistent Saver',
        description: 'Save money for 3 consecutive months',
        type: AchievementType.streak,
        targetAmount: 3,
        isUnlocked: false,
      ),
      const Achievement(
        id: 'year_end_target',
        title: 'Yearly Master',
        description: 'Reach your yearly savings goal',
        type: AchievementType.yearEndTarget,
        targetAmount: 12000,
        isUnlocked: false,
      ),
    ];

    for (final achievement in defaults) {
      final existing = await _repository.getAchievementById(achievement.id);
      if (existing == null) {
        await _repository.saveAchievement(achievement);
      }
    }
  }
}
