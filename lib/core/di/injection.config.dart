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
import '../../data/repositories/allocation_template_repository.dart' as _i120;
import '../../data/repositories/base_achievement_repository.dart' as _i812;
import '../../data/repositories/budget_repository.dart' as _i931;
import '../../data/repositories/budget_template_repository.dart' as _i631;
import '../../data/repositories/category_repository.dart' as _i282;
import '../../data/repositories/event_repository.dart' as _i655;
import '../../data/repositories/i_category_repository.dart' as _i269;
import '../../data/repositories/i_event_repository.dart' as _i561;
import '../../data/repositories/saving_goal_repository.dart' as _i38;
import '../../data/repositories/year_end_goal_repository.dart' as _i105;
import '../../services/achievement_service.dart' as _i91;
import '../../services/achievement_sharing_service.dart' as _i16;
import '../../services/allocation_service.dart' as _i114;
import '../../services/allocation_template_service.dart' as _i1017;
import '../../services/analytics_service.dart' as _i155;
import '../../services/auto_allocation_rules_engine.dart' as _i294;
import '../../services/budget_analytics_service.dart' as _i610;
import '../../services/budget_service.dart' as _i460;
import '../../services/budget_template_service.dart' as _i1030;
import '../../services/category_bucket_mapper.dart' as _i147;
import '../../services/category_service.dart' as _i576;
import '../../services/currency_service.dart' as _i351;
import '../../services/event_service.dart' as _i762;
import '../../services/financial_suggestions_engine.dart' as _i991;
import '../../services/notification_service.dart' as _i85;
import '../../services/round_up_service.dart' as _i78;
import '../../services/saving_goal_service.dart' as _i578;
import '../../services/savings_opportunity_detector.dart' as _i685;
import '../../services/settings_service.dart' as _i583;
import '../../services/smart_categorization_service.dart' as _i229;
import '../../services/surplus_allocation_service.dart' as _i132;
import '../../settings/settings_service.dart' as _i882;
import '../../state/achievement_state.dart' as _i682;
import '../../state/budget_notifier.dart' as _i460;
import '../../state/category_notifier.dart' as _i930;
import '../../state/event_notifier.dart' as _i184;
import '../../state/saving_goal_notifier.dart' as _i986;

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
    gh.factory<_i16.AchievementSharingService>(
        () => _i16.AchievementSharingService());
    gh.singleton<_i495.Database>(() => _i495.Database());
    gh.singleton<_i583.SettingsService>(() => _i583.SettingsService());
    gh.singleton<_i351.CurrencyService>(() => _i351.CurrencyService());
    gh.singleton<_i147.CategoryBucketMapper>(
        () => _i147.CategoryBucketMapper());
    gh.lazySingleton<_i631.IBudgetTemplateRepository>(
        () => _i631.BudgetTemplateRepository(gh<_i495.Database>()));
    gh.factory<_i114.AllocationService>(
        () => _i114.AllocationService(gh<_i495.Database>()));
    gh.factory<_i229.SmartCategorizationService>(
        () => _i229.SmartCategorizationService(gh<_i495.Database>()));
    gh.factory<_i269.ICategoryRepository>(
        () => _i282.CategoryRepository(gh<_i495.Database>()));
    gh.factory<_i576.CategoryService>(
        () => _i576.CategoryService(gh<_i269.ICategoryRepository>()));
    gh.factory<_i1030.BudgetTemplateService>(() =>
        _i1030.BudgetTemplateService(gh<_i631.IBudgetTemplateRepository>()));
    gh.factory<_i812.BaseAchievementRepository>(
        () => _i434.AchievementRepository(gh<_i495.Database>()));
    gh.factory<_i38.ISavingGoalRepository>(
        () => _i38.SavingGoalRepository(gh<_i495.Database>()));
    gh.factory<_i120.IAllocationTemplateRepository>(
        () => _i120.AllocationTemplateRepository(gh<_i495.Database>()));
    gh.factory<_i105.IYearEndGoalRepository>(
        () => _i105.YearEndGoalRepository(gh<_i495.Database>()));
    gh.factory<_i931.IBudgetRepository>(
        () => _i931.BudgetRepository(gh<_i495.Database>()));
    gh.factory<_i930.CategoryNotifier>(
        () => _i930.CategoryNotifier(gh<_i576.CategoryService>()));
    gh.factory<_i682.AchievementNotifier>(
        () => _i682.AchievementNotifier(gh<_i812.BaseAchievementRepository>()));
    gh.factory<_i155.AnalyticsService>(() => _i155.AnalyticsService(
          gh<_i495.Database>(),
          gh<_i38.ISavingGoalRepository>(),
        ));
    gh.factory<_i294.AutoAllocationRulesEngine>(
        () => _i294.AutoAllocationRulesEngine(
              gh<_i495.Database>(),
              gh<_i38.ISavingGoalRepository>(),
            ));
    gh.factory<_i610.BudgetAnalyticsService>(() => _i610.BudgetAnalyticsService(
          gh<_i931.IBudgetRepository>(),
          gh<_i105.IYearEndGoalRepository>(),
        ));
    gh.factory<_i991.FinancialSuggestionsEngine>(
        () => _i991.FinancialSuggestionsEngine(
              gh<_i495.Database>(),
              gh<_i38.ISavingGoalRepository>(),
              gh<_i576.CategoryService>(),
            ));
    gh.factory<_i685.SavingsOpportunityDetector>(
        () => _i685.SavingsOpportunityDetector(
              gh<_i495.Database>(),
              gh<_i38.ISavingGoalRepository>(),
              gh<_i576.CategoryService>(),
            ));
    gh.factory<_i78.RoundUpService>(
        () => _i78.RoundUpService(gh<_i38.ISavingGoalRepository>()));
    gh.factory<_i85.NotificationService>(() => _i85.NotificationService(
          gh<_i38.ISavingGoalRepository>(),
          gh<_i991.FinancialSuggestionsEngine>(),
          gh<_i610.BudgetAnalyticsService>(),
        ));
    gh.singleton<_i1017.AllocationTemplateService>(
        () => _i1017.AllocationTemplateService(
              gh<_i120.IAllocationTemplateRepository>(),
              gh<_i931.IBudgetRepository>(),
              gh<_i269.ICategoryRepository>(),
              gh<_i147.CategoryBucketMapper>(),
            ));
    gh.singleton<_i460.BudgetService>(() => _i460.BudgetService(
          gh<_i931.IBudgetRepository>(),
          gh<_i269.ICategoryRepository>(),
          gh<_i147.CategoryBucketMapper>(),
        ));
    gh.factory<_i460.BudgetNotifier>(() => _i460.BudgetNotifier(
          gh<_i460.BudgetService>(),
          gh<_i1017.AllocationTemplateService>(),
          gh<_i85.NotificationService>(),
          gh<_i132.SurplusAllocationService>(),
        ));
    gh.factory<_i561.IEventRepository>(() => _i655.EventRepository(
          gh<_i495.Database>(),
          gh<_i78.RoundUpService>(),
          gh<_i583.SettingsService>(),
          gh<_i294.AutoAllocationRulesEngine>(),
        ));
    gh.factory<_i132.SurplusAllocationService>(
        () => _i132.SurplusAllocationService(
              gh<_i495.Database>(),
              gh<_i561.IEventRepository>(),
              gh<_i38.ISavingGoalRepository>(),
            ));
    gh.factory<_i762.EventService>(
        () => _i762.EventService(gh<_i561.IEventRepository>()));
    gh.factory<_i184.EventNotifier>(
        () => _i184.EventNotifier(gh<_i762.EventService>()));
    gh.factory<_i91.AchievementService>(() => _i91.AchievementService(
          gh<_i812.BaseAchievementRepository>(),
          gh<_i762.EventService>(),
          gh<_i682.AchievementNotifier>(),
          gh<_i38.ISavingGoalRepository>(),
          gh<_i495.Database>(),
        ));
    gh.factory<_i578.SavingGoalService>(() => _i578.SavingGoalService(
          gh<_i38.ISavingGoalRepository>(),
          gh<_i91.AchievementService>(),
        ));
    gh.factory<_i986.SavingGoalNotifier>(
        () => _i986.SavingGoalNotifier(gh<_i578.SavingGoalService>()));
    gh.factory<_i882.SettingsService>(() => _i882.SettingsService(
          gh<_i495.Database>(),
          gh<_i184.EventNotifier>(),
          gh<_i930.CategoryNotifier>(),
          gh<_i986.SavingGoalNotifier>(),
          gh<_i682.AchievementNotifier>(),
          gh<_i460.BudgetNotifier>(),
        ));
    return this;
  }
}
