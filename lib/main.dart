import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_service.dart';
import 'package:cash_on_hand/state/event_notifier.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(
    ChangeNotifierProvider(
      create: (context) {
        final eventNotifier = EventNotifier();
        eventNotifier.loadEvents(); // Load initial events
        return eventNotifier;
      },
      child: MyApp(settingsController: settingsController),
    ),
  );
}

