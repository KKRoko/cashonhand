import 'package:flutter/material.dart';

import '../../../data/models/freezed/achievement_base_implementation.dart';

class AchievementProgressIndicator extends StatelessWidget {
  final Achievement achievement;

  const AchievementProgressIndicator({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: achievement.progress / 100,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${achievement.progress.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
