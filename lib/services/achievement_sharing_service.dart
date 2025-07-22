import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/freezed/achievement_base_implementation.dart';

/// Service for creating and sharing achievement cards
@injectable
class AchievementSharingService {
  
  /// Create a shareable achievement image
  Future<String?> createAchievementImage(Achievement achievement) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(400, 600);
      
      await _drawAchievementCard(canvas, size, achievement);
      
      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/achievement_${achievement.id}.png';
        
        final file = File(imagePath);
        await file.writeAsBytes(buffer);
        
        return imagePath;
      }
    } catch (e) {
      print('Error creating achievement image: $e');
    }
    
    return null;
  }
  
  /// Draw the achievement card on canvas
  Future<void> _drawAchievementCard(Canvas canvas, Size size, Achievement achievement) async {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Background gradient
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _getTierColor(achievement.tier).withOpacity(0.1),
        _getTierColor(achievement.tier).withOpacity(0.05),
        Colors.white,
      ],
    ).createShader(rect);
    canvas.drawRect(rect, paint);
    
    // Header background
    final headerRect = Rect.fromLTWH(0, 0, size.width, 200);
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _getTierColor(achievement.tier).withOpacity(0.8),
        _getTierColor(achievement.tier),
      ],
    ).createShader(headerRect);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        headerRect,
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
      ),
      paint,
    );
    
    // App branding
    final brandingPainter = TextPainter(
      text: TextSpan(
        text: 'Cash on Hand',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    brandingPainter.layout();
    brandingPainter.paint(canvas, const Offset(20, 20));
    
    // Tier badge
    final tierBadgeRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(280, 30, 100, 30),
      const Radius.circular(15),
    );
    paint.shader = null;
    paint.color = Colors.white.withOpacity(0.9);
    canvas.drawRRect(tierBadgeRect, paint);
    
    final tierPainter = TextPainter(
      text: TextSpan(
        text: '${achievement.tierName} Tier',
        style: TextStyle(
          color: _getTierColor(achievement.tier),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tierPainter.layout();
    tierPainter.paint(canvas, const Offset(295, 37));
    
    // Achievement emoji (centered)
    final emojiPainter = TextPainter(
      text: TextSpan(
        text: achievement.emoji,
        style: const TextStyle(fontSize: 60),
      ),
      textDirection: TextDirection.ltr,
    );
    emojiPainter.layout();
    emojiPainter.paint(
      canvas, 
      Offset(
        (size.width - emojiPainter.width) / 2,
        90,
      ),
    );
    
    // "Achievement Unlocked!" text
    final unlockedPainter = TextPainter(
      text: const TextSpan(
        text: 'Achievement Unlocked!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    unlockedPainter.layout();
    unlockedPainter.paint(
      canvas,
      Offset(
        (size.width - unlockedPainter.width) / 2,
        165,
      ),
    );
    
    // Achievement title
    final titlePainter = TextPainter(
      text: TextSpan(
        text: achievement.title,
        style: TextStyle(
          color: _getTierColor(achievement.tier),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    titlePainter.layout(maxWidth: size.width - 40);
    titlePainter.paint(canvas, Offset((size.width - titlePainter.width) / 2, 240));
    
    // Achievement description
    final descriptionPainter = TextPainter(
      text: TextSpan(
        text: achievement.description,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          height: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    descriptionPainter.layout(maxWidth: size.width - 60);
    descriptionPainter.paint(canvas, Offset((size.width - descriptionPainter.width) / 2, 290));
    
    // Points badge
    final pointsRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(150, 350, 100, 40),
      const Radius.circular(20),
    );
    paint.color = _getTierColor(achievement.tier).withOpacity(0.1);
    canvas.drawRRect(pointsRect, paint);
    
    // Points border
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    paint.color = _getTierColor(achievement.tier).withOpacity(0.3);
    canvas.drawRRect(pointsRect, paint);
    paint.style = PaintingStyle.fill;
    
    final pointsPainter = TextPainter(
      text: TextSpan(
        text: '+${achievement.points} Points',
        style: TextStyle(
          color: _getTierColor(achievement.tier),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pointsPainter.layout();
    pointsPainter.paint(canvas, Offset((size.width - pointsPainter.width) / 2, 360));
    
    // Footer message
    final footerPainter = TextPainter(
      text: const TextSpan(
        text: 'Keep up the great work on your savings journey!',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    footerPainter.layout(maxWidth: size.width - 60);
    footerPainter.paint(canvas, Offset((size.width - footerPainter.width) / 2, 450));
    
    // Date
    final now = DateTime.now();
    final datePainter = TextPainter(
      text: TextSpan(
        text: 'Unlocked on ${now.month}/${now.day}/${now.year}',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    datePainter.layout();
    datePainter.paint(canvas, Offset((size.width - datePainter.width) / 2, 520));
    
    // Decorative elements
    _drawDecorations(canvas, size, achievement);
  }
  
  /// Draw decorative elements around the achievement
  void _drawDecorations(Canvas canvas, Size size, Achievement achievement) {
    final paint = Paint()
      ..color = _getTierColor(achievement.tier).withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    // Corner decorations
    const cornerRadius = 15.0;
    
    // Top-left decoration
    canvas.drawCircle(const Offset(30, 250), cornerRadius, paint);
    canvas.drawCircle(const Offset(50, 270), cornerRadius * 0.7, paint);
    
    // Top-right decoration
    canvas.drawCircle(const Offset(370, 250), cornerRadius, paint);
    canvas.drawCircle(const Offset(350, 270), cornerRadius * 0.7, paint);
    
    // Bottom decorations
    canvas.drawCircle(const Offset(60, 420), cornerRadius * 0.8, paint);
    canvas.drawCircle(const Offset(340, 420), cornerRadius * 0.8, paint);
    
    // Sparkle effects
    paint.color = _getTierColor(achievement.tier).withOpacity(0.3);
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final x = 200 + 80 * (angle.cos());
      final y = 200 + 80 * (angle.sin());
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }
  
  Color _getTierColor(int tier) {
    switch (tier) {
      case 1: return const Color(0xFFCD7F32); // Bronze
      case 2: return const Color(0xFFC0C0C0); // Silver
      case 3: return const Color(0xFFFFD700); // Gold
      case 4: return const Color(0xFFE5E4E2); // Platinum
      default: return const Color(0xFFCD7F32);
    }
  }
  
  /// Share achievement with text and optional image
  Future<void> shareAchievement(Achievement achievement, {bool includeImage = true}) async {
    final shareText = achievement.defaultShareText;
    
    if (includeImage) {
      final imagePath = await createAchievementImage(achievement);
      if (imagePath != null) {
        await Share.shareXFiles(
          [XFile(imagePath)],
          text: shareText,
          subject: 'Achievement Unlocked: ${achievement.title}',
        );
        return;
      }
    }
    
    // Fallback to text-only sharing
    await Share.share(
      shareText,
      subject: 'Achievement Unlocked: ${achievement.title}',
    );
  }
  
  /// Share streak achievement
  Future<void> shareStreak({
    required int streakCount,
    required String streakType,
    bool includeImage = false,
  }) async {
    final shareText = '''
🔥 I'm on a $streakCount-$streakType savings streak! 
    
Consistent saving is the key to financial success. Join me on this journey! 💪

#SavingsStreak #FinancialGoals #CashOnHand
''';
    
    await Share.share(
      shareText,
      subject: 'My $streakCount-$streakType Savings Streak!',
    );
  }
  
  /// Share goal completion
  Future<void> shareGoalCompletion({
    required String goalTitle,
    required double goalAmount,
    required DateTime completedDate,
  }) async {
    final shareText = '''
🎉 Goal Achieved! 
    
I just completed my "$goalTitle" savings goal of \$${goalAmount.toStringAsFixed(2)}!
    
Every step counts towards financial freedom! 💰

#GoalAchieved #SavingsSuccess #CashOnHand
''';
    
    await Share.share(
      shareText,
      subject: 'Goal Completed: $goalTitle',
    );
  }
}