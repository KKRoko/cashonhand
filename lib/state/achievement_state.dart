import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';
import '../data/models/freezed/achievement_base_implementation.dart';
import '../data/repositories/base_achievement_repository.dart';

class AchievementEvent {
  final Achievement? achievement;
  final String? achievementId;
  final AchievementEventType type;

  AchievementEvent({
    this.achievement,
    this.achievementId,
    required this.type,
  });
}

enum AchievementEventType {
  updated,
  unlocked,
}

@injectable
class AchievementNotifier extends ChangeNotifier {
  final BaseAchievementRepository _repository;
  final _achievementController = StreamController<AchievementEvent>.broadcast();
  List<Achievement> _achievements = [];
  bool _isLoading = true;

  Stream<AchievementEvent> get achievementStream => _achievementController.stream;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;

  AchievementNotifier(
    this._repository,
  ) {
    _achievementController.stream.listen(_handleAchievementEvent);
        _initialize();
  }

   Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _achievements = await _repository.getAllAchievements();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _achievements = [];
      notifyListeners();
    }
  }

  void _handleAchievementEvent(AchievementEvent event) {
    switch (event.type) {
      case AchievementEventType.updated:
        if (event.achievement != null) {
          _achievements = [
            for (final existing in _achievements)
              if (existing.id == event.achievement!.id) 
                event.achievement! 
              else 
                existing
          ];
          notifyListeners();
        }
        break;
      case AchievementEventType.unlocked:
        if (event.achievementId != null) {
          final achievement = _achievements.firstWhere((a) => a.id == event.achievementId);
          final updated = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            progress: 100,
          );
          _achievements = [
            for (final existing in _achievements)
              if (existing.id == event.achievementId) 
                updated 
              else 
                existing
          ];
          notifyListeners();
        }
        break;
    }
  }

  List<Achievement> get unlockedAchievements => 
    _achievements.where((achievement) => achievement.isUnlocked).toList();

  /// Reload achievements from database
  Future<void> reload() async {
    await _initialize();
  }

  List<Achievement> get inProgressAchievements =>
    _achievements.where((achievement) =>
      !achievement.isUnlocked && achievement.progress > 0
    ).toList();

  void onAchievementUpdated(Achievement achievement) {
    _achievementController.add(AchievementEvent(
      achievement: achievement,
      type: AchievementEventType.updated,
    ));
  }

  void onAchievementUnlocked(String id) {
    _achievementController.add(AchievementEvent(
      achievementId: id,
      type: AchievementEventType.unlocked,
    ));
  }

  @override
  void dispose() {
    _achievementController.close();
    super.dispose();
  }
}
