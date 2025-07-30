
flutter: Debug Database: getAllSavingGoals called
flutter: 🏆 MAIN: Starting achievement initialization...
flutter: 🏆 ACHIEVEMENT: Initializing achievements in database...
flutter: Debug Repository: Converted to 0 SavingGoal models
flutter: 🔔 Notification Service: Processing financial suggestions...
flutter: 🧠 Suggestions Engine: Starting comprehensive analysis...
flutter: 🔍 Analyzing spending patterns...
flutter: 🎯 Analyzing goal progress...
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Database: getAllSavingGoals found 0 goals
flutter: Debug Repository: Database returned 0 goal records
flutter: Debug Repository: Converted to 0 SavingGoal models
flutter: 🧠 Suggestions Engine: Generated 0 suggestions
flutter: 🔔 Notification Service: Comprehensive check complete. 0 total notifications.
flutter: 🏆 ACHIEVEMENT: Initialization complete. Created 0 new achievements out of 12 total.
flutter: 🏆 MAIN: Achievement initialization completed successfully

flutter: 🔍 DEBUG: AddEditGoalDialog._saveGoal called
flutter: 🔍 DEBUG: Form validation: true
flutter: 🔍 DEBUG: Is editing: false, Goal ID: null
flutter: 🔍 DEBUG: Goal object created - ID: 1753903251514, Title: "10k", Target: 2000.0
flutter: 🔍 DEBUG: Calling notifier.addGoal
flutter: Debug Notifier: addGoal called for: 10k
flutter: Debug Service: addGoal called with title: 10k
flutter: Debug Database: Creating saving goal with title: 10k
flutter: Debug Database: Goal created successfully with ID: 43
flutter: Debug Notifier: addGoal succeeded with ID: 43

flutter: 🏆 ACHIEVEMENT: Checking goal completion achievements...
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Database: getAllSavingGoals found 1 goals
flutter: Debug Repository: Database returned 1 goal records
flutter: Debug Repository: Converted to 1 SavingGoal models
flutter: 🏆 ACHIEVEMENT: Found 0 completed goals out of 1 total goals
flutter: 🏆 ACHIEVEMENT: Goal "10k": $0.00/$2000.00 - Completed: false
flutter: 📅 CalendarScreen: Goals Summary (Real-time) - 1 total goals, 1 active, $0.00 total saved

flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: Starting category fetch in database
flutter: Executing query for category type: CategoryType.income
flutter: Query completed, found 7 categories
flutter: ✨ Smart suggestion: Salary (80% confidence)

flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: Debug: Updated allocation 0 to $500.00, remaining: $1500.00
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: 🐛 DEBUG _saveEvent - Start
flutter: 🐛 selectedDate: 2025-07-31 03:19:28.206637
flutter: 🐛 _repeatOption: RepeatOption.today
flutter: 🐛 _customRecurrence: null
flutter: DEBUG - Final CustomRecurrence before save: null
flutter: 🐛 DEBUG - Creating event with dateTime: 2025-07-31 03:19:28.206637
flutter: 🐛 DEBUG - Final _customRecurrence: null
flutter: Dialog result: event created with 1 allocations
flutter: 🔄 UI UPDATE: _setLoading(true) - notifyListeners() called
flutter: ✅ UI UPDATE ALLOWED: _setLoading(true) - calling notifyListeners()
flutter: ✅ CashPage: EventNotifier change allowed - triggering debounced calculation
flutter: 🔍 DEBUG: EventService.addEventWithAllocations called - Title: Cash, Allocations: 1
flutter: Creating event with customRecurrence: Value(null)
flutter: Event created with ID: 9850
flutter: Updated originalEventId for event 9850
flutter: Event after update - ID: 9850, OriginalID: 9850
flutter: Created event - ID: 9850, OriginalID: 9850
flutter: 🎯 EventRepository: Created allocation for event 9850 (2025-07-31 03:19:28.000): 10k - $500.0
flutter: Debug: Broadcasting goal update - Goal 43 updated to $500.00
flutter: Debug Notifier: Loading goals with real-time progress
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Notifier: Received goal update notification - refreshing goals
flutter: 📅 CalendarWidget: Received goal update notification - refreshing allocation data
flutter: 🏆 GOAL UPDATE: Triggering achievement check...
flutter: 🔍 DEBUG: EventNotifier - Event with allocations created successfully
flutter: 🔄 UI UPDATE: _setLoading(true) - notifyListeners() called
flutter: ✅ UI UPDATE ALLOWED: _setLoading(true) - calling notifyListeners()
flutter: ✅ CashPage: EventNotifier change allowed - triggering debounced calculation
flutter: 🔄 UI UPDATE: _setLoading(false) - notifyListeners() called
flutter: ✅ UI UPDATE ALLOWED: _setLoading(false) - calling notifyListeners()
flutter: ✅ CashPage: EventNotifier change allowed - triggering debounced calculation
flutter: Event and allocations saved: 1 allocations
flutter: Event added successfully
flutter: Debug Database: getAllSavingGoals found 1 goals
flutter: Debug Repository: Database returned 1 goal records
flutter: Debug Repository: Converted to 1 SavingGoal models
flutter: 🔄 UI UPDATE: loadEventsForRange success - notifyListeners() called
flutter: ✅ UI UPDATE ALLOWED: loadEventsForRange success - calling notifyListeners()
flutter: ✅ CashPage: EventNotifier change allowed - triggering debounced calculation
flutter: 🔄 UI UPDATE: _setLoading(false) - notifyListeners() called
flutter: ✅ UI UPDATE ALLOWED: _setLoading(false) - calling notifyListeners()
flutter: ✅ CashPage: EventNotifier change allowed - triggering debounced calculation
flutter: 🔍 DEBUG: EventNotifier - Notifying goal system of 1 new allocations
flutter: Debug: Broadcasting general goal updates
flutter: Debug Notifier: Loading goals with real-time progress
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Notifier: Received goal update notification - refreshing goals
flutter: 📅 CalendarWidget: Received goal update notification - refreshing allocation data
flutter: 🏆 GOAL UPDATE: Triggering achievement check...
flutter: Debug Database: getAllSavingGoals found 1 goals
flutter: Debug Repository: Database returned 1 goal records
flutter: Debug Repository: Converted to 1 SavingGoal models
flutter: Debug: Goal 43 has 1 allocations totaling $500.00
flutter: Debug Service: Goal 10k progress: initial $0.00 + allocations $500.00 = $500.00
flutter: Debug Notifier: Loaded 1 goals with real-time progress
flutter:   - 10k: $500.00/$2000.00 (2500%)
flutter: Debug: Goal 43 has 1 allocations totaling $500.00
flutter: Debug Service: Goal 10k progress: initial $0.00 + allocations $500.00 = $500.00
flutter: Debug Notifier: Loaded 1 goals with real-time progress
flutter:   - 10k: $500.00/$2000.00 (2500%)
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Database: getAllSavingGoals found 1 goals
flutter: Debug Repository: Database returned 1 goal records
flutter: Debug Repository: Converted to 1 SavingGoal models
flutter: Debug Database: getAllSavingGoals found 1 goals
flutter: Debug Repository: Database returned 1 goal records
flutter: Debug Repository: Converted to 1 SavingGoal models
flutter: 🏆 ACHIEVEMENT: Checking goal completion achievements...
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: 🏆 ACHIEVEMENT: Checking goal completion achievements...
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Database: getAllSavingGoals found 1 goals
flutter: Debug Repository: Database returned 1 goal records
flutter: Debug Repository: Converted to 1 SavingGoal models
flutter: 🏆 ACHIEVEMENT: Found 0 completed goals out of 1 total goals
flutter: 🏆 ACHIEVEMENT: Goal "10k": $0.00/$2000.00 - Completed: false
flutter: Debug Database: getAllSavingGoals found 1 goals
flutter: Debug Repository: Database returned 1 goal records
flutter: Debug Repository: Converted to 1 SavingGoal models
flutter: 🏆 ACHIEVEMENT: Found 0 completed goals out of 1 total goals
flutter: 🏆 ACHIEVEMENT: Goal "10k": $0.00/$2000.00 - Completed: false
flutter: 🏗️ BUILD: Calendar build() - focused: 31/7/2025, today: 31/7/2025, needs reset: false
flutter: Monthly summary for 7/2025: $2000.00
flutter: 📅 CalendarWidget: didUpdateWidget called

flutter: ✅ UI UPDATE ALLOWED: _setLoading(true) - calling notifyListeners()
flutter: ✅ CashPage: EventNotifier change allowed - triggering debounced calculation
flutter: 🔍 DEBUG: getEvents called for day: 2025-07-30
flutter: 🔍 DEBUG: Found 1 total events in database
flutter: 🔍 DEBUG: Returning 0 events for 2025-07-30
flutter: ✅ CashPage: EventNotifier change allowed - triggering debounced calculation
flutter: 🔄 UI UPDATE: _setLoading(false) - notifyListeners() called
flutter: ✅ UI UPDATE ALLOWED: _setLoading(false) - calling notifyListeners()
flutter: ✅ CashPage: EventNotifier change allowed - triggering debounced calculation
flutter: 🏗️ BUILD: Calendar build() - focused: 30/7/2025, today: 31/7/2025, needs reset: true
flutter: Monthly summary for 7/2025: $2000.00
flutter: 📅 CalendarWidget: didUpdateWidget called
flutter: 📅 OLD: focusedDay: 2025-07-31 03:19:28.000, selectedDay: 2025-07-31 03:19:28.000
flutter: 📅 NEW: focusedDay: 2025-07-30 00:00:00.000Z, selectedDay: 2025-07-30 00:00:00.000Z
flutter: 📅 OLD monthSummary keys: [2025-07-01 00:00:00.000]
flutter: 📅 NEW monthSummary keys: [2025-07-01 00:00:00.000]
flutter: 📅 Summary unchanged: Same keys and values
flutter: 📅 Month changed: false, Summary actually changed: false

flutter: 📅 Month changed: false, Summary actually changed: false
flutter: 📅 Suppressed: false
flutter: 📅 CalendarWidget: Building CalendarWidget with focusedDay: 2025-07-03 00:00:00.000Z, selectedDay: 2025-07-03 00:00:00.000Z
flutter: 📅 CalendarWidget: Building TableCalendar
flutter: 📅 CalendarScreen: Goals Summary (Real-time) - 1 total goals, 1 active, $500.00 total saved
flutter: ✅ CashPage: setState allowed (flag = false)
flutter: ✅ CashPage: setState allowed (flag = false)
flutter: 🔍 DEBUG: Recent transactions debug info:
flutter: 🔍 Now: 2025-07-31T03:22:18.846363
flutter: 🔍 Today boundary: 2025-07-31T00:00:00.000
flutter: 🔍 Past week boundary: 2025-07-24T00:00:00.000
flutter: 🔍 Total events in range: 1
flutter: 🔍 Checking Cash: eventDate=2025-07-31T00:00:00.000, isPastOrToday=true, isNotFuture=true
flutter: 🔍 Filtered recent events (past transactions only): 1
flutter: 📅 Final recent transactions (past week, no future):
flutter:   1. Cash - Event: 2025-07-31T03:19:28.000
flutter: ✅ CashPage: setState allowed (flag = false)
flutter: ✅ CashPage: setState allowed (flag = false)
flutter: Starting _showAddEventDialog
flutter: Debug Database: Total goals in database: 1
flutter: Debug Database: Goal '10k' - isCompleted: false
flutter: Debug Database: Active goals returned: 1
flutter: Debug: Found 1 active goals for allocation
flutter: About to show AddEditEventDialog

flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: Starting category fetch in database
flutter: Executing query for category type: CategoryType.income
flutter: Query completed, found 7 categories
flutter: ✨ Smart suggestion: Salary (80% confidence)
flutter:    Reason: Matched "paycheck" in transaction title
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: Starting category fetch in database
flutter: Executing query for category type: CategoryType.income
flutter: Query completed, found 7 categories
flutter: ✨ Smart suggestion: Investment (60% confidence)
flutter:    Reason: Matched "capital gains" in transaction title
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: DEBUG - Custom Recurrence set to: {interval: daily, frequency: 1, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null}
flutter: DEBUG - Frequency: 1
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: DEBUG - Updated frequency to: 1
flutter: DEBUG - Custom Recurrence: {interval: daily, frequency: 1, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null}
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: DEBUG - Updated frequency to: 6
flutter: DEBUG - Custom Recurrence: {interval: daily, frequency: 6, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null}
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'

flutter: Debug: Updated allocation 0 to $500.00, remaining: $1500.00
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'

flutter: Generating future instances with customRecurrence: Value(CustomRecurrence(interval: RepeatOption.daily, frequency: 6, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null))
flutter: Base event retrieved with customRecurrence: {interval: daily, frequency: 6, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null}
flutter: Generating instances for event: Cash
flutter: Source event ID: 9851, OriginalID: 9851
flutter: Repeat option: RepeatOption.daily
flutter: Custom recurrence: {interval: daily, frequency: 6, selectedDays: [false, false, false, false, false, false, false], dayOfMonth: null, repeatAtEndOfMonth: false, useLastDayOfMonth: false, originalDate: null}

flutter: 🎯 EventRepository: Created allocation for event 9881 (2025-12-30 08:00:00.000): 10k - $500.0

flutter: Debug Notifier: Loading goals with real-time progress
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Notifier: Received goal update notification - refreshing goals
flutter: 📅 CalendarWidget: Received goal update notification - refreshing allocation data
flutter: 🏆 GOAL UPDATE: Triggering achievement check...
flutter: Debug Database: getAllSavingGoals found 1 goals
flutter: Debug Repository: Database returned 1 goal records
flutter: Debug Repository: Converted to 1 SavingGoal models
flutter: Debug: Goal 43 has 32 allocations totaling $16000.00
flutter: Debug Service: Goal 10k progress: initial $0.00 + allocations $16000.00 = $16000.00
flutter: Debug Notifier: Loaded 1 goals with real-time progress
flutter:   - 10k: $16000.00/$2000.00 (10000%)
flutter: Debug: Goal 43 has 32 allocations totaling $16000.00
flutter: Debug Service: Goal 10k progress: initial $0.00 + allocations $16000.00 = $16000.00
flutter: Debug Notifier: Loaded 1 goals with real-time progress
flutter:   - 10k: $16000.00/$2000.00 (10000%)

flutter: 🏆 ACHIEVEMENT: Found 0 completed goals out of 1 total goals
flutter: 🏆 ACHIEVEMENT: Goal "10k": $0.00/$2000.00 - Completed: false
flutter: Debug Goal Allocation: availableGoals.length = 1, amount = 2000.0, amountText = '2,000.00'
flutter: 🏗️ BUILD: Calendar build() - focused: 3/7/2025, today: 31/7/2025, needs reset: true
flutter: Monthly summary for 7/2025: $12000.00
flutter: 📅 CalendarWidget: didUpdateWidget called
flutter: 📅 OLD: focusedDay: 2025-07-03 00:00:00.000Z, selectedDay: 2025-07-03 00:00:00.000Z
flutter: 📅 NEW: focusedDay: 2025-07-03 08:00:00.000, selectedDay: 2025-07-03 08:00:00.000
flutter: 📅 OLD monthSummary keys: [2025-07-01 00:00:00.000]
flutter: 📅 NEW monthSummary keys: [2025-07-01 00:00:00.000]
flutter: 📅 Summary change: Different value for 2025-07-01 00:00:00.000 (2000.0 vs 12000.0)
flutter: 📅 Month changed: false, Summary actually changed: true
flutter: 📅 Suppressed: false
flutter: 📅 CalendarWidget: Monthly summary actually changed - loading monthly breakdown
flutter: 📅 CalendarWidget: _loadMonthlyBreakdown called - triggering setState
flutter: ✅ CalendarWidget: setState allowed
flutter: 📅 CalendarWidget: Building CalendarWidget with focusedDay: 2025-07-03 08:00:00.000, selectedDay: 2025-07-03 08:00:00.000
flutter: 📅 CalendarWidget: Building TableCalendar
flutter: 🔍 EventListItem: initState for event ID: 9851, title: 'Cash'
flutter: 🔍 EventListItem: Loading allocations for event ID: 9851, title: 'Cash'
flutter: 📅 CalendarScreen: Goals Summary (Real-time) - 1 total goals, 0 active, $16000.00 total saved
flutter: Debug Notifier: Loading goals with real-time progress
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: 📅 CalendarWidget: _loadGoalData called - triggering setState
flutter: ✅ CalendarWidget: setState allowed
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: Debug Notifier: Loading goals with real-time progress
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
flutter: 📅 CalendarWidget: _loadGoalData called - triggering setState
flutter: ✅ CalendarWidget: setState allowed
flutter: Debug Repository: getAllGoals called
flutter: Debug Database: getAllSavingGoals called
