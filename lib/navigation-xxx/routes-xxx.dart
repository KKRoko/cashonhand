// lib/navigation/routes.dart (create if it doesn't exist)
import 'package:flutter/material.dart';

import '../ui/achievements/achievement_screen.dart';
import '../ui/calendar/calendar_screen.dart';
import '../ui/cash_on_hand/cash_on_hand_screen.dart';
import '../ui/saving_goals/saving_goals_screen.dart';

class AppRoutes {
  // Existing routes
  static const cashOnHand = '/cashOnHand';
  static const achievements = '/achievements';
  static const calendar = '/calendar';
  
  // New route
  static const savingGoals = '/savingGoals';

  static final routes = {
    cashOnHand: (context) => const CashOnHandScreen(),
    achievements: (context) => const AchievementsScreen(),
    calendar: (context) => const CalendarScreen(),
    savingGoals: (context) => const SavingGoalsScreen(),
  };
}

