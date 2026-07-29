# Architecture — Cash on Hand

> Living document — updated as the project evolves.

---

## Overview

Cash on Hand is a personal finance Flutter app for iOS and Android. It helps users track cash flow, build saving goals, manage budgets, and develop saving habits through automatic allocations, round-ups, and gamified achievements. It runs fully offline with a local SQLite database — no backend or accounts required. The one exception is Cash on Hand Premium, a real auto-renewable subscription processed through StoreKit (iOS) / Play Billing (Android) — see [Subscription Paywall](#13-subscription-paywall) below.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (iOS + Android) |
| Language | Dart 3.5+ |
| State management | Provider (`ChangeNotifier` / `ChangeNotifierProvider`) |
| Local database | Drift (SQLite) — schema v17 |
| Dependency injection | GetIt + Injectable |
| Models | Freezed + json_serializable |
| Error handling | dartz (`Either<Failure, T>`) |
| Charts | fl_chart |
| Calendar | table_calendar |
| Sharing | share_plus |
| Animations | lottie, confetti |
| Currency | decimal |
| Preferences | shared_preferences |
| In-app purchases | in_app_purchase (StoreKit / Play Billing) |
| Deep links | url_launcher (opens platform subscription management) |
| Localization | Flutter ARB (English only) |

> **Note:** State management uses Provider, not Riverpod. The global `flutter.md` standard specifies Riverpod — this is a known divergence.

---

## Project Structure

```
lib/
├── app.dart                    # Root widget, theme setup, navigation shell, route map
├── main.dart                   # Entry point — DI init, settings load, app launch
├── core/
│   ├── di/                     # GetIt/Injectable dependency injection setup
│   ├── error/                  # Failure types and exception classes
│   └── architecture/           # In-app architecture viewer (dev tool)
├── data/
│   ├── database/               # Drift database, table definitions, type converters
│   ├── models/                 # Freezed models + enums for all domain entities
│   └── repositories/           # Data access layer — interfaces + implementations
├── services/                   # Business logic layer — all feature engines live here
├── state/                      # ChangeNotifier state classes (Provider)
├── ui/
│   ├── achievements/           # Achievements screen + celebration widgets
│   ├── allocation_rules/       # Auto-allocation rule management
│   ├── budget/                 # Budget setup, analytics, templates, surplus, alerts
│   ├── calendar/               # Calendar view with event overlay
│   ├── cash_on_hand/           # Main dashboard — balance, projections, quick-add
│   ├── components/             # Shared cash-domain UI components
│   ├── dialogs/                # Add/edit event dialog
│   ├── onboarding/             # Goal integration onboarding flow
│   ├── round_up/               # Round-up history screen
│   ├── saving_goals/           # Goals list, goal detail, allocation history
│   ├── settings/               # Manage categories, round-up settings
│   ├── suggestions/            # AI-style financial insights and suggestions
│   ├── transactions/           # Full transaction history
│   └── widgets/                # Shared widgets (currency selector, goal allocation, category selector)
├── paywall/                     # Real subscription paywall (in_app_purchase, client-side verification)
├── settings/                   # App settings controller + view (theme, etc.)
├── theme/                      # Design tokens, app theme, enhanced theme, design system guide
├── localization/               # ARB localization files
├── navigation-xxx/             # Route constants (stub — routes primarily defined in app.dart)
└── utils/                      # Formatters, money math, date utils, category helpers
```

---

## Key Systems

### 1. Cash on Hand Dashboard
The primary screen. Shows current balance, week/month/year projections, and recent transactions. Calculates totals from all events in the local DB. Has a debounced rebuild strategy to prevent flicker when events change. Quick-add button for fast transaction entry.

### 2. Events (Transactions)
Core data primitive. An event has a title, category, amount (positive = income, negative = expense), date, and optional recurrence. Recurring events are expanded virtually — only the original is stored; instances are computed on read. Managed by `EventService` and `EventNotifier`.

### 3. Saving Goals
Users create saving goals with a target amount, optional deadline, and optional recurring contribution target. Goals can have checkpoints. Progress is tracked via `GoalAllocation` records linking events to goals. Three allocation types: `manual`, `auto`, `round_up`. Managed by `SavingGoalService` and `SavingGoalNotifier`.

### 4. Budget System
Monthly budget with three buckets: **Needs** (default 50%), **Wants** (30%), **Savings** (20%) — the 50/30/20 rule. Each category is mapped to a bucket. Budget analytics compare actuals to budgeted amounts by bucket and category. Users can set alert thresholds per bucket. Templates let users save and reapply budget configurations. Managed by `BudgetService` and `BudgetAnalyticsService`.

### 5. Auto-Allocation Rules Engine
Rules automatically allocate a portion of income or expense transactions to saving goals. Trigger types: `income`, `expense`, `category`. Allocation methods: `percentage`, `fixed_amount`, `round_up`. Rules have optional minimum trigger amounts and maximum allocation caps. Managed by `AutoAllocationRulesEngine`.

### 6. Round-Up System
Rounds up expense transactions to the nearest dollar (or configurable target) and allocates the difference to a saving goal. Configurable: enable/disable, strategy (nearest dollar, custom), expense-only mode, excluded categories. History viewable in `RoundUpHistoryScreen`. Managed by `RoundUpService`.

### 7. Financial Suggestions Engine
Analyses transaction history and goal progress to generate up to 10 actionable suggestions. Five analysis passes: spending patterns, savings opportunities, goal progress, unusual activity detection, and allocation rule optimisation. Rule-based (not AI/LLM). Results shown in the Insights tab.

### 8. Achievements
Gamification layer. Checks 12 achievement types: saving milestones, streaks, year-end target, allocation consistency, multi-goal saver, round-up master, smart allocator, goal completer, savings streak, weekly habit, monthly champion. Unlocked achievements trigger celebration overlays (lottie + confetti). Shareable via share_plus.

### 9. Year-End Goals
Annual percentage targets for each bucket (needs/wants/savings). Stored per year. Compared to actual year-to-date spending to show progress toward yearly allocation goals. Managed by `YearEndGoalService`.

### 10. Categories
Hierarchical — categories can have parent categories. Two types: `income` and `expense`. System-seeded presets (isSystem = true) are protected. Users can create custom categories, toggle active/inactive, and manage mappings to budget buckets via `CategoryBucketMapper`. Managed by `CategoryService` and `CategoryNotifier`.

### 11. Smart Categorization
`SmartCategorizationService` attempts to auto-suggest a category when a user types an event title, based on keyword matching against existing category names and past transaction history.

### 12. Onboarding
Single onboarding flow (`GoalIntegrationOnboarding`) shown on first launch. Uses SharedPreferences flag to track completion. Can be force-shown in dev via a flag. Introduces the goal and allocation concept.

### 13. Subscription Paywall
Real auto-renewable subscription flow via the `in_app_purchase` plugin (StoreKit on iOS, Play Billing on Android) — "Cash on Hand Premium" (Monthly, Annual — single subscription group, prices come live from the store). `PaywallScreen` → `PurchaseConfirmationScreen` (awaits the real purchase result: success, cancel, or error) → `ManageSubscriptionScreen`. State lives in `SubscriptionService`, a `ChangeNotifier` singleton wrapping `InAppPurchase.instance`; entitlement is persisted locally via `shared_preferences` and reconciled with the store on every launch via `restorePurchases()`.

**Verification is client-side only** — there is no backend, so nothing re-validates the receipt server-side. This is a deliberate trade-off (documented, not accidental): a jailbroken device could theoretically spoof local entitlement, but the subscription only gates app features, not money movement. "Change plan" re-purchases the other product in the group (the store handles proration automatically). "Cancel" cannot be done by the app — it deep-links to the platform's own subscription management page via `url_launcher`, since neither StoreKit nor Play Billing expose a client-side cancel API. The displayed renewal date is a local estimate (purchase date + interval), not authoritative — exact billing lives in the platform's subscription settings.

Product IDs (must match App Store Connect / Play Console exactly): `com.cashonhand.premium.monthly`, `com.cashonhand.premium.annually`.

---

## Data Flow

```
User Action (UI)
      │
      ▼
State Notifier (Provider)          ← ChangeNotifier, holds UI-visible state
      │
      ▼
Service Layer                      ← Business logic, validation, cross-entity coordination
      │
      ▼
Repository                         ← Data access interface (Either<Failure, T>)
      │
      ▼
Drift Database (SQLite)            ← Local only, no sync, no backend
```

- All async operations return `Either<Failure, T>` (dartz) — errors are typed, never thrown raw to UI
- State notifiers (`EventNotifier`, `CategoryNotifier`, `SavingGoalNotifier`, `BudgetNotifier`, `AchievementNotifier`) are the bridge between services and widgets
- `TabChangeNotifier` (global) coordinates calendar visibility optimisation across tab switches

---

## Database Schema

**Current schema version:** 17

| Table | Purpose |
|---|---|
| `categories` | Income/expense categories, hierarchical, system + user |
| `events` | All transactions (income and expenses), with recurrence support |
| `saving_goals` | Saving goals with targets, deadlines, recurring targets, checkpoints |
| `goal_allocations` | Links events to goals — tracks which transactions funded which goals |
| `auto_allocation_rules` | Automated rules that trigger goal contributions from events |
| `budgets` | Monthly budget definitions (income + bucket percentages + cycle start day) |
| `category_budgets` | Per-category dollar allocations within a budget month |
| `budget_templates` | Saved budget configurations (preset + user-created) |
| `year_end_goals` | Annual bucket percentage targets |
| `allocation_templates` | Saved category allocation split configurations |
| `allocation_template_items` | Line items within an allocation template |
| `achievements` | Gamification achievements — progress + unlock state |

**Migration pattern:** All column additions use `_addColumnIfNotExists()` helper to guard against duplicate column crashes from non-linear upgrade paths (e.g. TestFlight → production).

---

## Screens / Routes

### Bottom Navigation (5 tabs)

| Tab | Screen | Route |
|---|---|---|
| Cash | `CashOnHandScreen` | `/cashOnHand` |
| Goals | `SavingGoalsScreen` | `/savingGoals` |
| Calendar | `CalendarScreen` | `/calendar` |
| Budget | `BudgetScreen` | `/budget` |
| Insights | `SuggestionsScreen` | `/suggestions` |

### Navigated-to Screens

| Screen | Route | Purpose |
|---|---|---|
| `GoalDetailScreen` | (pushed from Goals) | Individual goal detail + allocation history |
| `TransactionsScreen` | `/transactions` | Full transaction log |
| `AchievementsScreen` | `/achievements` | Achievement list + progress |
| `BudgetSetupScreen` | (pushed from Budget) | Create/edit a monthly budget |
| `BudgetSettingsScreen` | (pushed from Budget) | Budget preferences |
| `BudgetAnalyticsScreen` | (pushed from Budget) | Spending analytics vs budget |
| `BudgetMonthSummaryScreen` | (pushed from Budget) | Monthly summary view |
| `AlertSettingsScreen` | (pushed from Budget) | Budget alert thresholds |
| `SurplusAllocationScreen` | (pushed from Budget) | Allocate budget surplus to goals |
| `CategoryAllocationScreen` | (pushed from Budget) | Per-category budget amounts |
| `BudgetTemplateLibraryScreen` | (pushed from Budget) | Browse/apply budget templates |
| `AllocationTemplateLibraryScreen` | (pushed from Budget) | Browse/apply allocation templates |
| `AllocationRulesScreen` | `/allocationRules` | Manage auto-allocation rules |
| `RoundUpSettingsScreen` | `/roundUpSettings` | Configure round-up behaviour |
| `RoundUpHistoryScreen` | `/roundUpHistory` | History of round-up allocations |
| `ManageCategoriesScreen` | (pushed from Settings) | Add/edit/deactivate categories |
| `SettingsView` | `/settings` | Theme, preferences |
| `PaywallScreen` | `/paywall` | Subscription paywall (real StoreKit/Play Billing) |
| `PurchaseConfirmationScreen` | (pushed from Paywall) | Purchase loading/success/error |
| `ManageSubscriptionScreen` | `/manageSubscription` | Manage subscription — real entitlement |
| `GoalIntegrationOnboarding` | (shown at launch) | First-run onboarding |

---

## External Services

**App Store / Play Store (subscriptions only).** Cash on Hand Premium purchases go through StoreKit (iOS) / Play Billing (Android) via the `in_app_purchase` plugin — see [Subscription Paywall](#13-subscription-paywall). No server-side receipt validation; verification is client-side.

Everything else is fully local. No analytics, no crash reporting, no backend API, no accounts. All non-subscription data lives in the device's SQLite database.

---

## Dev Tooling

```bash
# Run the app
flutter run

# Build for release
flutter build appbundle --release     # Android
flutter build ipa --release           # iOS

# Generate code (Freezed, Drift, Injectable)
dart run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Static analysis
flutter analyze

# Check dependency tree
flutter pub deps
```

**Current version:** 1.1.2+16  
**Current branch:** `production-prep` (acts as main — see Git section in CLAUDE.md)
