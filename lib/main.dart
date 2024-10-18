import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'src/providers/event_provider.dart';
import 'src/services/event_service.dart';
import 'src/repositories/event_repository.dart';

void main() async {
  // Ensure that widget binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  final eventRepository = EventRepository();
  final eventService = EventService(eventRepository);

  runApp(
    ChangeNotifierProvider(
      create: (context) => EventProvider(eventService),
      child: MyApp(settingsController: settingsController),
    ),
  );
}
