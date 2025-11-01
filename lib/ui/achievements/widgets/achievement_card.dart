import 'package:flutter/material.dart';
import '../../../data/models/freezed/achievement_base_implementation.dart';
import '../../../services/achievement_sharing_service.dart';
import '../../../core/di/injection.dart';
import '../../../theme/design_tokens.dart';
import 'achievement_progress_indicator.dart';
import 'achievement_celebration_overlay.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    super.key,
    required this.achievement,
  });

  Color _getTierColor(BuildContext context) {
    switch (achievement.tier) {
      case 1: return const Color(0xFFCD7F32); // Bronze
      case 2: return const Color(0xFFC0C0C0); // Silver
      case 3: return const Color(0xFFFFD700); // Gold
      case 4: return const Color(0xFFE5E4E2); // Platinum
      default: return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierColor = _getTierColor(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: achievement.isUnlocked ? 4 : 2,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: achievement.isUnlocked ? () => _showCelebration(context) : null,
        borderRadius: DesignTokens.borderRadius['md']!,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: DesignTokens.borderRadius['md']!,
            border: achievement.isUnlocked 
                ? Border.all(color: tierColor.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon, title, and actions
                Row(
                  children: [
                    // Achievement emoji and tier
                    Stack(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: achievement.isUnlocked
                                ? tierColor.withOpacity(0.1)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: DesignTokens.borderRadius['full']!,
                            border: Border.all(
                              color: achievement.isUnlocked
                                  ? tierColor.withOpacity(0.3)
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              achievement.emoji,
                              style: TextStyle(
                                fontSize: 24,
                                color: achievement.isUnlocked
                                    ? null
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                        if (achievement.isUnlocked)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: tierColor,
                                borderRadius: DesignTokens.borderRadius['sm']!,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.surface,
                                size: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Title and tier info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  achievement.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: achievement.isUnlocked
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (achievement.isUnlocked) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: tierColor.withOpacity(0.1),
                                    borderRadius: DesignTokens.borderRadius['sm']!,
                                    border: Border.all(color: tierColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    achievement.tierName,
                                    style: TextStyle(
                                      color: tierColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (achievement.isUnlocked) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.stars, size: 14, color: tierColor),
                                const SizedBox(width: 4),
                                Text(
                                  '+${achievement.points} points',
                                  style: TextStyle(
                                    color: tierColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                if (achievement.unlockedAt != null)
                                  Text(
                                    '${achievement.unlockedAt!.month}/${achievement.unlockedAt!.day}/${achievement.unlockedAt!.year}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Action button
                    if (achievement.isUnlocked)
                      PopupMenuButton<String>(
                        onSelected: (action) => _handleAction(context, action),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'celebrate',
                            child: Row(
                              children: [
                                Icon(Icons.celebration, size: 20),
                                SizedBox(width: 8),
                                Text('Celebrate'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share, size: 20),
                                SizedBox(width: 8),
                                Text('Share'),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  achievement.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: achievement.isUnlocked
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                // Progress indicator for unlockedachievements
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 16),
                  AchievementProgressIndicator(achievement: achievement),
                ],
                
                // Celebration message for unlocked achievements
                if (achievement.isUnlocked && achievement.celebrationMessages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tierColor.withOpacity(0.05),
                      borderRadius: DesignTokens.borderRadius['sm']!,
                      border: Border.all(color: tierColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_quote,
                          color: tierColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            achievement.celebrationMessage,
                            style: TextStyle(
                              color: tierColor.withAlpha(200),
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'celebrate':
        _showCelebration(context);
        break;
      case 'share':
        _shareAchievement(context);
        break;
    }
  }

  void _showCelebration(BuildContext context) {
    AchievementCelebration.show(context, achievement);
  }

  void _shareAchievement(BuildContext context) async {
    final sharingService = getIt<AchievementSharingService>();
    await sharingService.shareAchievement(achievement);
  }
}

