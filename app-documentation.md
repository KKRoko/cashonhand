# Personal Finance Management Application Documentation

## 1. Architecture Overview

### 1.1 Core Architecture Patterns
- **Clean Layered Architecture**
  ```
  UI Layer → State Management → Service Layer → Data Layer
  ```
- **Dependency Injection** using `injectable`
- **State Management** using Provider pattern with ChangeNotifier
- **Repository Pattern** for data access
- **Immutable Data Models** using Freezed

### 1.2 Layer Responsibilities

#### Data Layer (`/data`)
- **Models**: Immutable data classes using Freezed
- **Repositories**: Data access and persistence
- **Database**: Local storage implementation

#### Service Layer (`/services`)
- Business logic orchestration
- Repository coordination
- Error handling with Either pattern (dartz)

#### State Management (`/state`)
- Provider-based state management
- Cached data management
- UI state coordination

#### UI Layer (`/ui`)
- Screen implementations
- Reusable widgets
- Dialog management

## 2. Core Domain Model

### 2.1 Event (Financial Transaction)
```dart
Event
├── Core Properties
│   ├── id: int?
│   ├── title: String
│   ├── categoryId: int
│   ├── amount: double
│   └── dateTime: DateTime
├── Recurring Properties
│   ├── repeatOption: RepeatOption
│   ├── isRecurring: bool
│   └── customRecurrence: CustomRecurrence?
└── Metadata
    ├── notes: String?
    ├── createdAt: DateTime
    ├── updatedAt: DateTime
    └── isYearEndSummary: bool
```

### 2.2 Category
```dart
Category
├── id: int
├── name: String
├── type: CategoryType
├── color: String?
└── isActive: bool
```

### 2.3 SavingGoal
```dart
SavingGoal
├── Basic Properties
│   ├── id: String
│   ├── title: String
│   ├── description: String
│   ├── targetAmount: double
│   └── currentAmount: double
├── Goal Configuration
│   ├── goalType: GoalType
│   ├── deadlineDate: DateTime?
│   ├── recurringPeriod: RecurringPeriod?
│   └── recurringTargetAmount: double?
└── Progress Tracking
    ├── isCompleted: bool
    ├── createdAt: DateTime
    └── checkpoints: List<DateTime>?
```

## 3. Data Flow

### 3.1 Event Management Flow
1. UI requests events through EventNotifier
2. EventNotifier delegates to EventService
3. EventService coordinates with IEventRepository
4. Repository performs data operations
5. Results flow back through the same chain
6. UI updates based on notifier changes

### 3.2 State Management Pattern
```
UI Layer
   ↓
EventNotifier (ChangeNotifier)
   ├── Manages event cache (_events Map)
   ├── Handles loading states
   ├── Error management
   └── CRUD operations
   ↓
EventService
   ├── Business logic
   ├── Error handling (Either)
   └── Repository coordination
   ↓
IEventRepository
   └── Data persistence
```

## 4. Key Features

### 4.1 Financial Event Tracking
- Single and recurring transactions
- Category-based organization
- Date-based filtering and grouping
- Comprehensive CRUD operations

### 4.2 Saving Goals System
- Three goal types:
  1. Simple (target amount only)
  2. Deadline-based (target with timeframe)
  3. Recurring (periodic targets)
- Progress tracking
- Expected amount calculations
- Completion monitoring

### 4.3 Achievement Tracking
- Monitors saving progress
- Based on financial milestones
- Tracks goal completion

## 5. Implementation Details

### 5.1 State Management
```dart
EventNotifier
├── Cache Management
│   ├── _events: Map<DateTime, List<Event>>
│   └── Cache operations
├── Loading State
│   ├── _isLoading: bool
│   └── _error: String?
└── CRUD Operations
    ├── addEvent()
    ├── updateEvent()
    ├── deleteEvent()
    └── loadEvents()
```

### 5.2 Event Operations
- **Single Events**
  - Direct CRUD operations
  - Immediate state updates
- **Recurring Events**
  - Pattern-based generation
  - Deletion options:
    - Single occurrence
    - All occurrences
    - Future only
    - Past only

### 5.3 Data Validation
- Amount validation
- Date range checks
- Goal progress validation
- Category relationship validation

## 6. File Structure Reference

```
lib/
├── core/                 # Core utilities and configurations
├── data/                 # Data layer implementation
├── services/            # Business logic layer
├── state/               # State management
├── ui/                  # User interface components
└── utils/               # Utility functions
```

## 7. Development Guidelines

### 7.1 State Management
- Use EventNotifier for all event-related state
- Maintain single source of truth
- Handle loading and error states consistently

### 7.2 Data Operations
- Always use service layer for business logic
- Handle errors with Either type
- Maintain data consistency across layers

### 7.3 UI Implementation
- Follow widget composition pattern
- Use dedicated dialog components
- Implement proper loading states
- Handle error scenarios gracefully
