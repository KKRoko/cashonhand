import 'package:injectable/injectable.dart';
import '../data/models/freezed/achievement_base_implementation.dart';
import '../data/repositories/base_achievement_repository.dart';
import '../data/repositories/saving_goal_repository.dart';
import '../data/database/database.dart';
import '../state/achievement_state.dart';
import 'event_service.dart';

@injectable
class AchievementService {
  final BaseAchievementRepository _repository;
  final EventService _eventService;
  final AchievementNotifier _notifier;
  final ISavingGoalRepository _goalRepository;
  final Database _database;

  AchievementService(
    this._repository,
    this._eventService,
    this._notifier,
    this._goalRepository,
    this._database,
  );
    Future<List<Achievement>> checkSavingGoalsAchievements() async {
    return await checkAchievements(); // This will check all achievements including saving-related ones
  }

  // Core achievement checking logic
  Future<List<Achievement>> checkAchievements() async {
    final unlockedAchievements = <Achievement>[];
    
    // Original achievements
    unlockedAchievements.addAll(await checkSavingMilestones());
    unlockedAchievements.addAll(await checkStreaks());
    unlockedAchievements.addAll(await checkYearEndTarget());
    
    // New allocation-focused achievements
    unlockedAchievements.addAll(await checkAllocationConsistency());
    unlockedAchievements.addAll(await checkMultiGoalSaver());
    unlockedAchievements.addAll(await checkRoundUpMaster());
    unlockedAchievements.addAll(await checkSmartAllocator());
    unlockedAchievements.addAll(await checkGoalCompleter());
    unlockedAchievements.addAll(await checkSavingsStreak());
    unlockedAchievements.addAll(await checkWeeklyHabit());
    unlockedAchievements.addAll(await checkMonthlyChampion());
    
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

  // New allocation-focused achievement checks

  /// Check for consistent allocation behavior (10+ allocations in 30 days)
  Future<List<Achievement>> checkAllocationConsistency() async {
    final unlockedAchievements = <Achievement>[];
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    try {
      final allAllocations = await _database.getAllocationsInRange(thirtyDaysAgo, DateTime.now());
      final allocationCount = allAllocations.length;
      
      if (allocationCount >= 10) {
        final achievement = await _unlockAchievementIfNew('allocation_consistency_bronze');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (allocationCount >= 25) {
        final achievement = await _unlockAchievementIfNew('allocation_consistency_silver');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (allocationCount >= 50) {
        final achievement = await _unlockAchievementIfNew('allocation_consistency_gold');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
    } catch (e) {
      print('Error checking allocation consistency: $e');
    }
    
    return unlockedAchievements;
  }

  /// Check for multi-goal saving behavior
  Future<List<Achievement>> checkMultiGoalSaver() async {
    final unlockedAchievements = <Achievement>[];
    
    try {
      final goalsResult = await _goalRepository.getAllGoals();
      await goalsResult.fold(
        (failure) => null,
        (goals) async {
          final activeGoals = goals.where((g) => g.currentAmount > 0).length;
          
          if (activeGoals >= 2) {
            final achievement = await _unlockAchievementIfNew('multi_goal_saver_bronze');
            if (achievement != null) unlockedAchievements.add(achievement);
          }
          if (activeGoals >= 3) {
            final achievement = await _unlockAchievementIfNew('multi_goal_saver_silver');
            if (achievement != null) unlockedAchievements.add(achievement);
          }
          if (activeGoals >= 5) {
            final achievement = await _unlockAchievementIfNew('multi_goal_saver_gold');
            if (achievement != null) unlockedAchievements.add(achievement);
          }
        },
      );
    } catch (e) {
      print('Error checking multi-goal saver: $e');
    }
    
    return unlockedAchievements;
  }

  /// Check for round-up mastery
  Future<List<Achievement>> checkRoundUpMaster() async {
    final unlockedAchievements = <Achievement>[];
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    try {
      // Count round-up allocations (assuming they have metadata indicating round-up)
      final roundUpAllocations = await _database.getRoundUpAllocationsInRange(thirtyDaysAgo, DateTime.now());
      final roundUpCount = roundUpAllocations.length;
      
      if (roundUpCount >= 20) {
        final achievement = await _unlockAchievementIfNew('round_up_master_bronze');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (roundUpCount >= 50) {
        final achievement = await _unlockAchievementIfNew('round_up_master_silver');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (roundUpCount >= 100) {
        final achievement = await _unlockAchievementIfNew('round_up_master_gold');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
    } catch (e) {
      print('Error checking round-up master: $e');
    }
    
    return unlockedAchievements;
  }

  /// Check for smart allocation behavior (using auto-allocation rules)
  Future<List<Achievement>> checkSmartAllocator() async {
    final unlockedAchievements = <Achievement>[];
    
    try {
      final allRules = await _database.getAllAllocationRules();
      final activeRules = allRules.where((rule) => rule.isActive).length;
      
      if (activeRules >= 1) {
        final achievement = await _unlockAchievementIfNew('smart_allocator_bronze');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (activeRules >= 3) {
        final achievement = await _unlockAchievementIfNew('smart_allocator_silver');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (activeRules >= 5) {
        final achievement = await _unlockAchievementIfNew('smart_allocator_gold');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
    } catch (e) {
      print('Error checking smart allocator: $e');
    }
    
    return unlockedAchievements;
  }

  /// Check for goal completion achievements
  Future<List<Achievement>> checkGoalCompleter() async {
    final unlockedAchievements = <Achievement>[];
    
    try {
      final goalsResult = await _goalRepository.getAllGoals();
      await goalsResult.fold(
        (failure) => null,
        (goals) async {
          final completedGoals = goals.where((g) => g.currentAmount >= g.targetAmount).length;
          
          if (completedGoals >= 1) {
            final achievement = await _unlockAchievementIfNew('goal_completer_bronze');
            if (achievement != null) unlockedAchievements.add(achievement);
          }
          if (completedGoals >= 3) {
            final achievement = await _unlockAchievementIfNew('goal_completer_silver');
            if (achievement != null) unlockedAchievements.add(achievement);
          }
          if (completedGoals >= 5) {
            final achievement = await _unlockAchievementIfNew('goal_completer_gold');
            if (achievement != null) unlockedAchievements.add(achievement);
          }
        },
      );
    } catch (e) {
      print('Error checking goal completer: $e');
    }
    
    return unlockedAchievements;
  }

  /// Enhanced savings streak tracking (daily)
  Future<List<Achievement>> checkSavingsStreak() async {
    final unlockedAchievements = <Achievement>[];
    
    try {
      final streak = await _calculateDailySavingsStreak();
      
      if (streak >= 7) {
        final achievement = await _unlockAchievementIfNew('savings_streak_week');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (streak >= 30) {
        final achievement = await _unlockAchievementIfNew('savings_streak_month');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (streak >= 100) {
        final achievement = await _unlockAchievementIfNew('savings_streak_100');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
    } catch (e) {
      print('Error checking savings streak: $e');
    }
    
    return unlockedAchievements;
  }

  /// Check for weekly saving habits
  Future<List<Achievement>> checkWeeklyHabit() async {
    final unlockedAchievements = <Achievement>[];
    
    try {
      final weeksWithSavings = await _calculateWeeksWithSavings();
      
      if (weeksWithSavings >= 4) {
        final achievement = await _unlockAchievementIfNew('weekly_habit_bronze');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (weeksWithSavings >= 12) {
        final achievement = await _unlockAchievementIfNew('weekly_habit_silver');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (weeksWithSavings >= 26) {
        final achievement = await _unlockAchievementIfNew('weekly_habit_gold');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
    } catch (e) {
      print('Error checking weekly habit: $e');
    }
    
    return unlockedAchievements;
  }

  /// Check for monthly championship (highest monthly savings)
  Future<List<Achievement>> checkMonthlyChampion() async {
    final unlockedAchievements = <Achievement>[];
    
    try {
      final monthlyTotals = await _calculateMonthlyAllocationTotals();
      final maxMonthly = monthlyTotals.isNotEmpty ? monthlyTotals.values.reduce((a, b) => a > b ? a : b) : 0.0;
      
      if (maxMonthly >= 500) {
        final achievement = await _unlockAchievementIfNew('monthly_champion_bronze');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (maxMonthly >= 1000) {
        final achievement = await _unlockAchievementIfNew('monthly_champion_silver');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
      if (maxMonthly >= 2000) {
        final achievement = await _unlockAchievementIfNew('monthly_champion_gold');
        if (achievement != null) unlockedAchievements.add(achievement);
      }
    } catch (e) {
      print('Error checking monthly champion: $e');
    }
    
    return unlockedAchievements;
  }

  // Helper methods

  Future<Achievement?> _unlockAchievementIfNew(String achievementId) async {
    final achievement = await _repository.getAchievementById(achievementId);
    if (achievement != null && !achievement.isUnlocked) {
      await _repository.unlockAchievement(achievementId);
      _notifier.onAchievementUnlocked(achievementId);
      return achievement;
    }
    return null;
  }

  Future<int> _calculateDailySavingsStreak() async {
    final today = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 365; i++) { // Check up to a year
      final day = today.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayAllocations = await _database.getAllocationsInRange(dayStart, dayEnd);
      
      if (dayAllocations.isNotEmpty) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Future<int> _calculateWeeksWithSavings() async {
    final twelveWeeksAgo = DateTime.now().subtract(const Duration(days: 84));
    int weeksWithSavings = 0;
    
    for (int week = 0; week < 12; week++) {
      final weekStart = twelveWeeksAgo.add(Duration(days: week * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      
      final weekAllocations = await _database.getAllocationsInRange(weekStart, weekEnd);
      
      if (weekAllocations.isNotEmpty) {
        weeksWithSavings++;
      }
    }
    
    return weeksWithSavings;
  }

  Future<Map<int, double>> _calculateMonthlyAllocationTotals() async {
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    final allocations = await _database.getAllocationsInRange(sixMonthsAgo, DateTime.now());
    
    final monthlyTotals = <int, double>{};
    
    for (final allocation in allocations) {
      final month = allocation.createdAt.month;
      monthlyTotals[month] = (monthlyTotals[month] ?? 0) + allocation.allocationAmount;
    }
    
    return monthlyTotals;
  }

  Future<void> initializeAchievements() async {
    final defaults = [
      // Original achievements
      const Achievement(
        id: 'saving_milestone_1000',
        title: 'First Grand',
        description: 'Save your first \$1,000',
        type: AchievementType.savingMilestone,
        targetAmount: 1000,
        isUnlocked: false,
        emoji: '💰',
        tier: 2,
        points: 150,
        celebrationMessages: ['Your first thousand is the hardest!', 'Great start to your savings journey!'],
      ),
      const Achievement(
        id: 'streak_3_months',
        title: 'Consistent Saver',
        description: 'Save money for 3 consecutive months',
        type: AchievementType.streak,
        targetAmount: 3,
        isUnlocked: false,
        emoji: '🔥',
        tier: 2,
        points: 200,
        celebrationMessages: ['Consistency is key!', 'Building great habits!'],
      ),
      const Achievement(
        id: 'year_end_target',
        title: 'Yearly Master',
        description: 'Reach your yearly savings goal',
        type: AchievementType.yearEndTarget,
        targetAmount: 12000,
        isUnlocked: false,
        emoji: '🏆',
        tier: 4,
        points: 500,
        celebrationMessages: ['Incredible yearly achievement!', 'You are a savings master!'],
      ),

      // New allocation-focused achievements
      const Achievement(
        id: 'allocation_consistency_bronze',
        title: 'Allocation Apprentice',
        description: 'Make 10 goal allocations in 30 days',
        type: AchievementType.allocationConsistency,
        targetAmount: 10,
        isUnlocked: false,
        emoji: '🥉',
        tier: 1,
        points: 50,
      ),
      const Achievement(
        id: 'allocation_consistency_silver',
        title: 'Allocation Expert',
        description: 'Make 25 goal allocations in 30 days',
        type: AchievementType.allocationConsistency,
        targetAmount: 25,
        isUnlocked: false,
        emoji: '🥈',
        tier: 2,
        points: 100,
      ),
      const Achievement(
        id: 'allocation_consistency_gold',
        title: 'Allocation Master',
        description: 'Make 50 goal allocations in 30 days',
        type: AchievementType.allocationConsistency,
        targetAmount: 50,
        isUnlocked: false,
        emoji: '🥇',
        tier: 3,
        points: 200,
      ),

      // Multi-goal achievements
      const Achievement(
        id: 'multi_goal_saver_bronze',
        title: 'Goal Juggler',
        description: 'Save towards 2 different goals',
        type: AchievementType.multiGoalSaver,
        targetAmount: 2,
        isUnlocked: false,
        emoji: '🤹',
        tier: 1,
        points: 75,
      ),
      const Achievement(
        id: 'multi_goal_saver_silver',
        title: 'Goal Balancer',
        description: 'Save towards 3 different goals',
        type: AchievementType.multiGoalSaver,
        targetAmount: 3,
        isUnlocked: false,
        emoji: '⚖️',
        tier: 2,
        points: 125,
      ),
      const Achievement(
        id: 'multi_goal_saver_gold',
        title: 'Goal Champion',
        description: 'Save towards 5 different goals',
        type: AchievementType.multiGoalSaver,
        targetAmount: 5,
        isUnlocked: false,
        emoji: '👑',
        tier: 3,
        points: 250,
      ),

      // Savings streak achievements
      const Achievement(
        id: 'savings_streak_week',
        title: 'Week Warrior',
        description: 'Save money for 7 consecutive days',
        type: AchievementType.savingsStreak,
        targetAmount: 7,
        isUnlocked: false,
        emoji: '⚡',
        tier: 1,
        points: 100,
      ),
      const Achievement(
        id: 'savings_streak_month',
        title: 'Month Master',
        description: 'Save money for 30 consecutive days',
        type: AchievementType.savingsStreak,
        targetAmount: 30,
        isUnlocked: false,
        emoji: '🌟',
        tier: 3,
        points: 300,
      ),
      const Achievement(
        id: 'savings_streak_100',
        title: 'Century Saver',
        description: 'Save money for 100 consecutive days',
        type: AchievementType.savingsStreak,
        targetAmount: 100,
        isUnlocked: false,
        emoji: '💎',
        tier: 4,
        points: 1000,
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
