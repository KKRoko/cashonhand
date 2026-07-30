import 'package:flutter/material.dart';
import '../../../theme/design_tokens.dart';
import 'package:lottie/lottie.dart';

class StreakCelebrationWidget extends StatefulWidget {
  final int streakCount;
  final String streakType; // 'daily', 'weekly', 'monthly'
  final VoidCallback onDismiss;

  const StreakCelebrationWidget({
    super.key,
    required this.streakCount,
    required this.streakType,
    required this.onDismiss,
  });

  @override
  State<StreakCelebrationWidget> createState() =>
      _StreakCelebrationWidgetState();
}

class _StreakCelebrationWidgetState extends State<StreakCelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fireController;
  late AnimationController _pulseController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fireController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    _bounceController.forward();
    _fireController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat(reverse: true);

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fireController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getStreakColor() {
    if (widget.streakCount >= 100) return DesignTokens.color('primary');
    if (widget.streakCount >= 30) return DesignTokens.color('warning');
    if (widget.streakCount >= 7) return DesignTokens.color('success');
    return DesignTokens.color('info');
  }

  String _getStreakMessage() {
    if (widget.streakCount >= 100) {
      return 'Legendary ${widget.streakType} streak!';
    } else if (widget.streakCount >= 30) {
      return 'Amazing ${widget.streakType} streak!';
    } else if (widget.streakCount >= 7) {
      return 'Great ${widget.streakType} streak!';
    } else {
      return 'Keep the ${widget.streakType} streak going!';
    }
  }

  String _getStreakEmoji() {
    if (widget.streakCount >= 100) return '💎';
    if (widget.streakCount >= 30) return '🏆';
    if (widget.streakCount >= 7) return '⚡';
    return '🔥';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streakColor = _getStreakColor();

    return Material(
      color: Colors.black.withOpacity(0.6),
      child: Semantics(
        button: true,
        label: 'Dismiss',
        child: GestureDetector(
          onTap: widget.onDismiss,
          child: Center(
            child: AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          margin: const EdgeInsets.all(32),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: streakColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header with fire background
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      streakColor.withOpacity(0.8),
                                      streakColor
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                child: Column(
                                  children: [
                                    // Fire animation
                                    SizedBox(
                                      height: 60,
                                      width: 60,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Background circle
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          // Emoji
                                          Text(
                                            _getStreakEmoji(),
                                            style:
                                                const TextStyle(fontSize: 30),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      'Streak Active!',
                                      style:
                                          theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Content
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    // Streak count
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '${widget.streakCount}',
                                          style: theme.textTheme.displayMedium
                                              ?.copyWith(
                                            color: streakColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${widget.streakType}${widget.streakCount == 1 ? '' : 's'}',
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: streakColor,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Message
                                    Text(
                                      _getStreakMessage(),
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      'You\'re building an amazing savings habit!',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    const SizedBox(height: 20),

                                    // Progress indicator
                                    _buildStreakProgress(streakColor),

                                    const SizedBox(height: 20),

                                    // Dismiss button
                                    ElevatedButton(
                                      onPressed: widget.onDismiss,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: streakColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text(
                                        'Keep Going!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakProgress(Color streakColor) {
    // Show progress towards next milestone
    int nextMilestone;
    double progress;

    if (widget.streakCount < 7) {
      nextMilestone = 7;
      progress = widget.streakCount / 7;
    } else if (widget.streakCount < 30) {
      nextMilestone = 30;
      progress = widget.streakCount / 30;
    } else if (widget.streakCount < 100) {
      nextMilestone = 100;
      progress = widget.streakCount / 100;
    } else {
      return Container(); // No next milestone to show
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress to $nextMilestone ${widget.streakType}s',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            Text(
              '${widget.streakCount}/$nextMilestone',
              style: TextStyle(
                color: streakColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          valueColor: AlwaysStoppedAnimation(streakColor),
          minHeight: 6,
        ),
      ],
    );
  }
}

/// Helper class to show streak celebrations
class StreakCelebration {
  static void show(
    BuildContext context, {
    required int streakCount,
    required String streakType,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => StreakCelebrationWidget(
        streakCount: streakCount,
        streakType: streakType,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}
