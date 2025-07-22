import 'package:cash_on_hand/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'settings/settings_controller.dart';
import 'services/settings_service.dart' as app_settings;
import 'package:cash_on_hand/state/event_notifier.dart';
import 'package:cash_on_hand/state/achievement_state.dart';
import 'package:cash_on_hand/state/saving_goal_notifier.dart';
import 'package:cash_on_hand/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure dependencies first
  await configureDependencies();

  // Get the injected SettingsController
  final settingsController = getIt<SettingsController>();

  // Load the user's preferred theme
  await settingsController.loadSettings();

  // Initialize app settings service
  final appSettingsService = getIt<app_settings.SettingsService>();
  await appSettingsService.initialize();

  // Initialize notification service with periodic checks
  final notificationService = getIt<NotificationService>();
  notificationService.startPeriodicChecks();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            final eventNotifier = getIt<EventNotifier>();
            eventNotifier.loadInitialEvents();
            return eventNotifier;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<AchievementNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<SavingGoalNotifier>(),
        ),
      ],
      child: MyApp(settingsController: settingsController),
    ),
  );
}
