import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../data/models/freezed/achievement_base_implementation.dart';
import 'package:share_plus/share_plus.dart';

class AchievementCelebrationOverlay extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;
  final bool showShareButton;

  const AchievementCelebrationOverlay({
    super.key,
    required this.achievement,
    required this.onDismiss,
    this.showShareButton = true,
  });

  @override
  State<AchievementCelebrationOverlay> createState() => _AchievementCelebrationOverlayState();
}

class _AchievementCelebrationOverlayState extends State<AchievementCelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _sparkleController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _sparkleAnimation;
  
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Setup animations
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize confetti
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    // Start animations
    _startCelebration();
  }
  
  void _startCelebration() async {
    // Start all animations with slight delays for better effect
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 100));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _slideController.forward();
    _confettiController.play();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _sparkleController.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _sparkleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
  
  Color _getTierColor() {
    switch (widget.achievement.tier) {
      case 1: return const Color(0xFFCD7F32); // Bronze
      case 2: return const Color(0xFFC0C0C0); // Silver
      case 3: return const Color(0xFFFFD700); // Gold
      case 4: return const Color(0xFFE5E4E2); // Platinum
      default: return const Color(0xFFCD7F32);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          // Background tap to dismiss
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(color: Colors.transparent),
          ),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57, // Downward
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: [
                _getTierColor(),
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
              ],
            ),
          ),
          
          // Main celebration content
          Center(
            child: AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildCelebrationCard(),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Floating sparkles
          ..._buildSparkles(),
        ],
      ),
    );
  }
  
  Widget _buildCelebrationCard() {
    final theme = Theme.of(context);
    final tierColor = _getTierColor();
    
    return Container(
      margin: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: tierColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with tier ribbon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tierColor.withOpacity(0.8), tierColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Tier badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${widget.achievement.tierName} Tier',
                    style: TextStyle(
                      color: tierColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Achievement emoji with sparkle effect
                AnimatedBuilder(
                  animation: _sparkleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_sparkleAnimation.value * 0.1),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(_sparkleAnimation.value * 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.achievement.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // "Achievement Unlocked!" text
                Text(
                  'Achievement Unlocked!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Achievement details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Achievement title
                Text(
                  widget.achievement.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tierColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Achievement description
                Text(
                  widget.achievement.description,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Points earned
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: tierColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: tierColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars,
                        color: tierColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.achievement.points} Points',
                        style: TextStyle(
                          color: tierColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Celebration message
                Text(
                  widget.achievement.celebrationMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onDismiss,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: tierColor),
                        ),
                        child: Text(
                          'Continue',
                          style: TextStyle(color: tierColor),
                        ),
                      ),
                    ),
                    if (widget.showShareButton) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _shareAchievement,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tierColor,
                          ),
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text(
                            'Share',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildSparkles() {
    final sparkles = <Widget>[];
    
    for (int i = 0; i < 6; i++) {
      sparkles.add(
        AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, child) {
            final offset = _sparkleAnimation.value * 2 * 3.14159; // Full rotation
            final x = 0.5 + 0.3 * (i / 6) * MediaQuery.of(context).size.width / MediaQuery.of(context).size.width;
            final y = 0.3 + 0.4 * (i % 3) / 3;
            
            return Positioned(
              left: x * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Transform.rotate(
                angle: offset + (i * 0.5),
                child: Opacity(
                  opacity: 0.7 + 0.3 * _sparkleAnimation.value,
                  child: Icon(
                    Icons.auto_awesome,
                    color: _getTierColor(),
                    size: 20 + 10 * _sparkleAnimation.value,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return sparkles;
  }
  
  void _shareAchievement() {
    Share.share(
      widget.achievement.defaultShareText,
      subject: 'Achievement Unlocked: ${widget.achievement.title}',
    );
  }
}

/// Helper widget to show achievement celebration
class AchievementCelebration {
  static void show(
    BuildContext context,
    Achievement achievement, {
    bool showShareButton = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => AchievementCelebrationOverlay(
        achievement: achievement,
        onDismiss: () => Navigator.of(context).pop(),
        showShareButton: showShareButton,
      ),
    );
  }
}