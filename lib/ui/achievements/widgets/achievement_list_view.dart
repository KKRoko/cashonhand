import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../state/achievement_state.dart';
import 'achievement_card.dart';

enum AchievementFilter { all, unlocked, inProgress }

class AchievementListView extends StatelessWidget {
  final AchievementFilter filter;

  const AchievementListView({
    super.key,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementNotifier>(
      builder: (context, notifier, child) {
        final achievements = switch (filter) {
          AchievementFilter.unlocked => notifier.unlockedAchievements,
          AchievementFilter.inProgress => notifier.inProgressAchievements,
          _ => notifier.achievements,
        };

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            return AchievementCard(
              achievement: achievements[index],
            );
          },
        );
      },
    );
  }
}
