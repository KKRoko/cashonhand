pubspec.yaml
lib/
├── core/
│   ├── di/
│   │   ├── injection.dart
│   │   ├── injection.config.dart
│   └── error/
│       ├── failures.dart
│       └── exceptions.dart
├── data/
│   ├── database/
│   │   ├── database.dart
│   │   ├── database.g.dart
│   │   ├── tables.dart
│   │   └── type_converters.dart
│   ├── models/
│   │   ├── enums/
│   │   │   ├── category_type.dart
│   │   │   ├── delete_option.dart
│   │   │   ├── goal_type.dart
│   │   │   ├── recurring_period.dart
│   │   │   └── repeat_option.dart
│   │   └── freezed/
│   │       ├── achievement_base_implementation.dart
│   │       ├── achievement_base_implementation.freezed.dart
│   │       ├── achievement_base_implementation.g.dart
│   │       ├── category.dart
│   │       ├── category.freezed.dart
│   │       ├── category.g.dart
│   │       ├── custom_recurrence.dart
│   │       ├── custom_recurrence.freezed.dart
│   │       ├── custom_recurrence.g.dart
│   │       ├── event.dart
│   │       ├── event.freezed.dart
│   │       ├── event.g.dart
│   │       ├── saving_goal.dart
│   │       ├── saving_goal.freezed.dart
│   │       └── saving_goal.g.dart
│   └── repositories/
│       ├── achievement_repository.dart
│       ├── base_achievement_repository.dart
│       ├── base_repository.dart
│       ├── category_repository.dart
│       ├── event_repository.dart
│       ├── i_category_repository.dart
│       ├── i_event_repository.dart
│       └── saving_goal_repository.dart
├── localization/
│   └── app_en.arb
├── services/
│   ├── achievement_service.dart
│   ├── category_service.dart
│   ├── event_service.dart
│   └── saving_goal_service.dart
├── settings/
│   ├── settings_controller.dart
│   ├── settings_service.dart
│   └── settings_view.dart
├── state/
│   ├── achievement_state.dart
│   ├── category_notifier.dart
│   ├── event_notifier.dart
│   └── saving_goal_notifier.dart
├── theme/
│   └── app_theme.dart
├── ui/
│   ├── achievements/
│   │   ├── widgets/
│   │   │   ├── achievement_card.dart
│   │   │   ├── achievement_list_view.dart
│   │   │   ├── achievement_notification.dart
│   │   │   ├── achievement_progress_indicator.dart
│   │   │   └── index.dart
│   │   └── achievement_screen.dart
│   ├── calendar/
│   │   ├──  widgets/
│   │   │   └── calendar_widget.dart
│   │   │   ├── event_list_item.dart
│   │   │   ├── event_list_widget.dart
│   │   │   └── index.dart
│   │   └── calendar_screen.dart
│   ├── cash_on_hand/
│   │   └── cash_on_hand_screen.dart
│   ├── dialogs/
│   │   ├── add_edit_event_dialog.dart
│   │   └── delete_event_dialog.dart
│   ├── saving_goals/
│   │   ├── widgets/
│   │   │   ├── goal_list_item.dart
│   │   │   ├── goal_statistics_widget.dart
│   │   │   └── add_edit_goal_dialog.dart
│   │   └── saving_goals_screen.dart
├── utils/
│   ├── event_date_utils.dart
│   ├── formatters.dart
│   └── migration_utils.dart
├── app.dart
└── main.dart