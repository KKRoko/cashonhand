import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../data/database/database.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/i_category_repository.dart';
import '../../data/repositories/saving_goal_repository.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/i_event_repository.dart';
import '../../services/category_service.dart';
import '../../services/saving_goal_service.dart';
import '../../services/event_service.dart';
import '../../settings/settings_controller.dart';
import '../../settings/settings_service.dart';
import '../../state/category_notifier.dart';
import '../../state/saving_goal_notifier.dart';
import '../../state/event_notifier.dart';
import '../../services/achievement_service.dart';
import '../../services/allocation_service.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)

// In injection.dart

// Remove this as it's not being used correctly
// @module
// abstract class ServiceModule {
//   @singleton
//   EventNotifier get eventNotifier;

//   @singleton
//   CategoryNotifier get categoryNotifier;
// }

Future<void> configureDependencies() async {
  // Initialize generated dependencies
  getIt.init();

  // Add Event Repository registration
  if (!getIt.isRegistered<IEventRepository>()) {
    getIt.registerLazySingleton<IEventRepository>(
      () => EventRepository(getIt<Database>()),
    );
  }

  // Add Event Service registration
  if (!getIt.isRegistered<EventService>()) {
    getIt.registerLazySingleton<EventService>(
      () => EventService(getIt<IEventRepository>()),
    );
  }

  // Change this to singleton
  if (!getIt.isRegistered<EventNotifier>()) {
    getIt.registerLazySingleton<EventNotifier>(
      () => EventNotifier(getIt<EventService>()),
    );
  }

  // Register saving goal dependencies
  if (!getIt.isRegistered<ISavingGoalRepository>()) {
    getIt.registerLazySingleton<ISavingGoalRepository>(
      () => SavingGoalRepository(getIt<Database>()),
    );
  }

  if (!getIt.isRegistered<SavingGoalService>()) {
    getIt.registerLazySingleton<SavingGoalService>(
      () => SavingGoalService(
        getIt<ISavingGoalRepository>(),
        getIt<AchievementService>(),
      ),
    );
  }

  if (!getIt.isRegistered<SavingGoalNotifier>()) {
    getIt.registerFactory<SavingGoalNotifier>(
      () => SavingGoalNotifier(getIt<SavingGoalService>()),
    );
  }

  if (!getIt.isRegistered<ICategoryRepository>()) {
    getIt.registerLazySingleton<ICategoryRepository>(
      () => CategoryRepository(getIt<Database>()),
    );
  }

  // Add Category Service registration
  if (!getIt.isRegistered<CategoryService>()) {
    getIt.registerLazySingleton<CategoryService>(
      () => CategoryService(getIt<ICategoryRepository>()),
    );
  }

  // Change this to singleton
  if (!getIt.isRegistered<CategoryNotifier>()) {
    getIt.registerLazySingleton<CategoryNotifier>(
      () => CategoryNotifier(getIt<CategoryService>()),
    );
  }

  // Add Allocation Service registration
  if (!getIt.isRegistered<AllocationService>()) {
    getIt.registerLazySingleton<AllocationService>(
      () => AllocationService(getIt<Database>()),
    );
  }

  // Update Settings Service registration to include all dependencies
  if (!getIt.isRegistered<SettingsService>()) {
    getIt.registerLazySingleton<SettingsService>(
      () => SettingsService(
        getIt<Database>(),
        getIt<EventNotifier>(),
        getIt<CategoryNotifier>(),
      ),
    );
  }

  if (!getIt.isRegistered<SettingsController>()) {
    getIt.registerLazySingleton<SettingsController>(
      () => SettingsController(getIt<SettingsService>()),
    );
  }
}
