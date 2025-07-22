// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/database/database.dart' as _i495;
import '../../data/repositories/achievement_repository.dart' as _i434;
import '../../data/repositories/base_achievement_repository.dart' as _i812;
import '../../data/repositories/category_repository.dart' as _i282;
import '../../data/repositories/event_repository.dart' as _i655;
import '../../data/repositories/i_category_repository.dart' as _i269;
import '../../data/repositories/i_event_repository.dart' as _i561;
import '../../data/repositories/saving_goal_repository.dart' as _i38;
import '../../services/achievement_service.dart' as _i91;
import '../../services/allocation_service.dart' as _i114;
import '../../services/auto_allocation_rules_engine.dart' as _i294;
import '../../services/category_service.dart' as _i576;
import '../../services/event_service.dart' as _i762;
import '../../services/round_up_service.dart' as _i78;
import '../../services/settings_service.dart' as _i583;
import '../../settings/settings_service.dart' as _i882;
import '../../state/achievement_state.dart' as _i682;
import '../../state/category_notifier.dart' as _i930;
import '../../state/event_notifier.dart' as _i184;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i495.Database>(() => _i495.Database());
    gh.singleton<_i583.SettingsService>(() => _i583.SettingsService());
    gh.factory<_i114.AllocationService>(
        () => _i114.AllocationService(gh<_i495.Database>()));
    gh.factory<_i269.ICategoryRepository>(
        () => _i282.CategoryRepository(gh<_i495.Database>()));
    gh.factory<_i576.CategoryService>(
        () => _i576.CategoryService(gh<_i269.ICategoryRepository>()));
    gh.factory<_i812.BaseAchievementRepository>(
        () => _i434.AchievementRepository(gh<_i495.Database>()));
    gh.factory<_i38.ISavingGoalRepository>(
        () => _i38.SavingGoalRepository(gh<_i495.Database>()));
    gh.factory<_i930.CategoryNotifier>(
        () => _i930.CategoryNotifier(gh<_i576.CategoryService>()));
    gh.factory<_i682.AchievementNotifier>(
        () => _i682.AchievementNotifier(gh<_i812.BaseAchievementRepository>()));
    gh.factory<_i294.AutoAllocationRulesEngine>(
        () => _i294.AutoAllocationRulesEngine(
              gh<_i495.Database>(),
              gh<_i38.ISavingGoalRepository>(),
            ));
    gh.factory<_i78.RoundUpService>(
        () => _i78.RoundUpService(gh<_i38.ISavingGoalRepository>()));
    gh.factory<_i561.IEventRepository>(() => _i655.EventRepository(
          gh<_i495.Database>(),
          gh<_i78.RoundUpService>(),
          gh<_i583.SettingsService>(),
          gh<_i294.AutoAllocationRulesEngine>(),
        ));
    gh.factory<_i762.EventService>(
        () => _i762.EventService(gh<_i561.IEventRepository>()));
    gh.factory<_i184.EventNotifier>(
        () => _i184.EventNotifier(gh<_i762.EventService>()));
    gh.factory<_i91.AchievementService>(() => _i91.AchievementService(
          gh<_i812.BaseAchievementRepository>(),
          gh<_i762.EventService>(),
          gh<_i682.AchievementNotifier>(),
        ));
    gh.factory<_i882.SettingsService>(() => _i882.SettingsService(
          gh<_i495.Database>(),
          gh<_i184.EventNotifier>(),
          gh<_i930.CategoryNotifier>(),
        ));
    return this;
  }
}
