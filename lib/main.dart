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
import 'package:cash_on_hand/services/achievement_service.dart';
import 'package:cash_on_hand/services/currency_service.dart';
import 'package:cash_on_hand/paywall/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 MAIN: Starting app initialization...');

  // ONLY run critical initialization that's needed before first frame
  // Configure dependencies (required for DI to work)
  await configureDependencies();
  print('✅ MAIN: Dependencies configured');

  // Load theme settings (needed for initial theme)
  final settingsController = getIt<SettingsController>();
  await settingsController.loadSettings();
  print('✅ MAIN: Theme settings loaded');

  // Subscribe to the purchase stream before the app renders — the plugin
  // will otherwise miss any purchase update delivered from a prior session.
  await SubscriptionService.instance.startListening();
  print('✅ MAIN: Subscription purchase stream attached');

  // Run the app immediately - heavy initialization will happen after first frame
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => getIt<EventNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<AchievementNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<SavingGoalNotifier>(),
        ),
        ChangeNotifierProvider(
          create: (context) => getIt<CurrencyService>(),
        ),
      ],
      child: AppInitializer(settingsController: settingsController),
    ),
  );
}

/// Handles async initialization after the first frame is rendered
class AppInitializer extends StatefulWidget {
  final SettingsController settingsController;

  const AppInitializer({
    super.key,
    required this.settingsController,
  });

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Run heavy initialization AFTER the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      print('🔄 INIT: Starting post-frame initialization...');

      await _runInitialization();

      print('🎉 INIT: Initialization complete!');

      // Mark as initialized and show the main app
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      print('❌ INIT: Initialization failed: $e');
      print('❌ INIT: Stack trace: $stackTrace');
      // Even if initialization fails, show the app
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _runInitialization() async {
    // Critical: Initialize app settings first (needed for everything)
    final appSettingsService = getIt<app_settings.SettingsService>();
    await appSettingsService.initialize();
    print('✅ INIT: App settings initialized');

    // Run other initializations in parallel (they don't depend on each other)
    await Future.wait([
      // Currency service
      () async {
        final currencyService = getIt<CurrencyService>();
        await currencyService.initialize();
        print('✅ INIT: Currency service initialized');
      }(),

      // Load initial events
      () async {
        final eventNotifier = getIt<EventNotifier>();
        await eventNotifier.loadInitialEvents();
        print('✅ INIT: Events loaded');
      }(),

      // Query subscription products and reconcile entitlement with the store
      () async {
        await SubscriptionService.instance.initialize();
        print('✅ INIT: Subscription products loaded');
      }(),
    ]);

    // Non-blocking background tasks - don't wait for these
    Future.microtask(() async {
      // Initialize notification service
      final notificationService = getIt<NotificationService>();
      notificationService.startPeriodicChecks();
      print('✅ INIT: Notification service started');

      // Initialize achievements
      try {
        print('🏆 INIT: Starting achievement initialization...');
        final achievementService = getIt<AchievementService>();
        await achievementService.initializeAchievements();
        print('🏆 INIT: Achievement initialization completed');
      } catch (e, stackTrace) {
        print('❌ INIT: Achievement initialization failed: $e');
        print('❌ INIT: Stack trace: $stackTrace');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show a simple splash screen while initializing
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.green.shade50,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                const SizedBox(height: 24),
                Text(
                  'Cash on Hand',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Once initialized, show the main app
    return MyApp(settingsController: widget.settingsController);
  }
}
