import 'package:shared_preferences/shared_preferences.dart';

class YearEndGoalService {
  static const String _keyYearEndGoal = 'year_end_goal';
  
  static Future<double?> getYearEndGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyYearEndGoal);
  }
  
  static Future<void> setYearEndGoal(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyYearEndGoal, amount);
  }
  
  static Future<void> removeYearEndGoal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyYearEndGoal);
  }
  
  static Future<bool> hasYearEndGoal() async {
    final goal = await getYearEndGoal();
    return goal != null && goal > 0;
  }
  
  static double calculateProgress(double currentBalance, double goalAmount) {
    if (goalAmount <= 0) return 0.0;
    return (currentBalance / goalAmount).clamp(0.0, 1.0);
  }
  
  static int getDaysRemainingInYear([DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    final endOfYear = DateTime(now.year, 12, 31);
    return endOfYear.difference(now).inDays;
  }
  
  static double getDailyTargetToReachGoal(double currentBalance, double goalAmount, [DateTime? currentDate]) {
    final remaining = goalAmount - currentBalance;
    if (remaining <= 0) return 0.0;
    
    final daysLeft = getDaysRemainingInYear(currentDate);
    return daysLeft > 0 ? remaining / daysLeft : 0.0;
  }
}