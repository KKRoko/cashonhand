import 'package:flutter/material.dart';

import '../../../data/models/freezed/achievement_base_implementation.dart';
import 'achievement_progress_indicator.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  achievement.isUnlocked
                      ? Icons.emoji_events
                      : Icons.emoji_events_outlined,
                  color: achievement.isUnlocked
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    achievement.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (achievement.isUnlocked)
                  Text(
                    achievement.unlockedAt!
                        .toString()
                        .split(' ')[0], // Show only date
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!achievement.isUnlocked) ...[
              const SizedBox(height: 16),
              AchievementProgressIndicator(achievement: achievement),
            ],
          ],
        ),
      ),
    );
  }
}

