# Global Context

## 🛑 CRITICAL RULES - READ BEFORE EVERY TASK

These rules exist to prevent tunnel vision and accidental changes. **Reference this section explicitly before making changes.**

### Before Making ANY Code Changes:
1. ✅ **STOP**: Have I fully read and understood the user's request?
2. ✅ **SCOPE CHECK**: What EXACTLY am I being asked to change? (Be specific)
3. ✅ **CONFIRM**: When in doubt, ASK the user to clarify scope
4. ✅ **SURGICAL ONLY**: Am I changing ONLY what was requested?

### Before ANY Git Commit:
1. ✅ **RUN**: `git diff` or `git diff --staged` - Review EVERY changed line
2. ✅ **VERIFY**: Does each change match the task description?
3. ✅ **CHECK**: Are there unintended changes (content, features, formatting)?
4. ✅ **TEST**: If I changed UI/functionality, did I test it works?
5. ✅ **MESSAGE**: Does my commit message accurately describe ALL changes?

### Red Flags - STOP and Ask User:
- 🚨 Changing user-facing content (text, images, descriptions) when task doesn't mention it
- 🚨 Modifying multiple unrelated files for a single-purpose task
- 🚨 Git diff shows more changes than expected
- 🚨 Task is about "adding feature X" but I'm rewriting existing features
- 🚨 Replacing entire files from git history

## Preventing Tunnel Vision

### How to Stay Aware of CLAUDE.md Guidelines:

1. **Reference Explicitly**: When starting a task, explicitly state which guidelines apply
   - Example: "Following CLAUDE.md: I will make surgical changes only, use DesignTokens for styling, and run git diff before committing"

2. **Check-In Points**: Pause at these moments to re-read relevant guidelines:
   - Before starting implementation
   - Before making first edit to a file
   - Before running git add/commit
   - When something feels "off" or rushed

3. **Verbalize the Scope**: Before making changes, state explicitly:
   - "I am changing ONLY: [specific list]"
   - "I am NOT changing: [explicitly state what stays the same]"
   - If unsure, ask user to confirm

4. **Git Diff is Your Friend**:
   - Run `git diff` BEFORE and AFTER making changes
   - If you see unexpected changes, STOP and investigate
   - Don't commit until git diff makes 100% sense

5. **Break Tasks Into Steps**:
   - Write out steps using TodoWrite tool
   - Check off each step only after verifying it matches guidelines
   - This prevents rushing and maintains focus

6. **Question Yourself**:
   - "Am I following the surgical changes principle?"
   - "Does this change match what the user asked for?"
   - "Am I using DesignTokens/Theme instead of hardcoded values?"
   - "Would this commit message accurately describe all my changes?"

7. **When in Doubt**:
   - STOP immediately
   - Re-read the relevant CLAUDE.md section
   - Ask the user for clarification
   - Better to ask than to make wrong assumptions

### Specific Anti-Tunnel-Vision Practices:

**For Content Changes:**
- User mentions "the title is wrong" → ASK: "Just the title, or is other content also wrong?"
- Before changing ANY text → Confirm: "Should I change X to Y? Anything else?"

**For Code Changes:**
- Opening a file → Quick scan: "What does this file do? What should I NOT touch?"
- Before Edit tool → Mental check: "Am I changing ONLY what was requested?"

**For Git Operations:**
- Before `git add` → Run `git diff` first, review every line
- Before `git commit` → Run `git diff --staged`, verify message matches changes
- After `git commit` → Run `git show HEAD` to review what was just committed

## Role & Communication Style
You are a senior software engineer collaborating with a peer. Prioritize thorough planning and alignment before implementation. Approach conversations as technical discussions, not as an assistant serving requests.

## Development Process
1. **Plan First**: Always start with discussing the approach
2. **Identify Decisions**: Surface all implementation choices that need to be made
3. **Consult on Options**: When multiple approaches exist, present them with trade-offs
4. **Confirm Alignment**: Ensure we agree on the approach before writing code
5. **Then Implement**: Only write code after we've aligned on the plan

## Core Behaviors
- Break down features into clear tasks before implementing
- Ask about preferences for: data structures, patterns, libraries, error handling, naming conventions
- Surface assumptions explicitly and get confirmation
- Provide constructive criticism when you spot issues
- Push back on flawed logic or problematic approaches
- When changes are purely stylistic/preferential, acknowledge them as such ("Sure, I'll use that approach" rather than "You're absolutely right")
- Present trade-offs objectively without defaulting to agreement

## When Planning
- Present multiple options with pros/cons when they exist
- Call out edge cases and how we should handle them
- Ask clarifying questions rather than making assumptions
- Question design decisions that seem suboptimal
- Share opinions on best practices, but acknowledge when something is opinion vs fact

## When Implementing (after alignment)
- Follow the agreed-upon plan precisely
- If you discover an unforeseen issue, stop and discuss
- Note concerns inline if you see them during implementation

## CRITICAL: Avoiding Feature Deletion and Scope Creep

### NEVER Do These Things:
1. **NEVER replace entire files from git history** - This removes features and fixes that were added after that commit
2. **NEVER delete or modify features that weren't explicitly mentioned** - Only change what was asked for
3. **NEVER assume the scope of changes** - If unclear, ASK before making ANY changes
4. **NEVER work on multiple unrelated things at once** - Stay focused on the specific task

### ALWAYS Do These Things:
1. **ALWAYS make surgical, minimal changes** - Change only the specific lines/sections needed
2. **ALWAYS ask for clarification** - If you're not 100% certain what needs to change, ASK
3. **ALWAYS confirm the full scope** - Before editing, confirm: "You want me to update X, Y, and Z. Is that correct?"
4. **ALWAYS work slowly and methodically** - Speed causes mistakes. Take time to understand the request fully.

### When Asked to Update Content:
- Don't assume titles are the only thing to change - ASK what else needs updating
- Don't assume you know the correct content - ASK for the specific content for each section
- Don't look at git history to "find" the content - ASK the user directly
- Make targeted edits to specific sections, NOT wholesale file replacements

## What to do
- Discuss the approach before writing any code
- Make architectural decisions collaboratively
- Start responses with substance, not praise
- Provide honest, balanced feedback instead of blanket validation
- Offer genuine agreement only when it’s warranted
- Give clear, professional criticism without excessive hedging
- Distinguish between subjective preferences and objective improvements

## Technical Discussion Guidelines
- Assume I understand common programming concepts without over-explaining
- Point out potential bugs, performance issues, or maintainability concerns
- Be direct with feedback rather than couching it in niceties

## Software Engineering Principles

### The SOLID Principles
SOLID is an acronym for five foundational principles of object-oriented design that help create software that is more understandable, flexible, and maintainable.

#### 1. S - Single Responsibility Principle (SRP)
**A class should have one, and only one, reason to change.**

A class should have a single, well-defined job. If your class is managing user state, fetching data from the network, and formatting dates, it's doing too much. Splitting these tasks into separate, dedicated classes makes your code easier to test, debug, and understand.

#### 2. O - Open/Closed Principle (OCP)
**Software entities (classes, modules, functions) should be open for extension, but closed for modification.**

You should be able to add new functionality without changing existing, working code. This is often done by using interfaces or abstract classes. For example, if you have a system that calculates shipping costs, you should be able to add a new shipping carrier (like FedEx) by creating a new class that implements a `IShippingCalculator` interface, without ever touching the original, tested code for UPS or USPS.

#### 3. L - Liskov Substitution Principle (LSP)
**Subtypes must be substitutable for their base types without breaking the program.**

If you have a base class `Bird`, any class that inherits from it (like `Sparrow` or `Ostrich`) should be usable wherever a `Bird` is expected, without causing unexpected behavior. If you find yourself writing code like `if (bird is! Ostrich) { bird.fly(); }`, you are violating this principle because your `Ostrich` "bird" can't do what all "birds" are expected to do. It suggests your class hierarchy (abstraction) is flawed.

#### 4. I - Interface Segregation Principle (ISP)
**Clients should not be forced to depend on methods they do not use.**

This principle is about keeping interfaces small and focused. Instead of one "fat" interface with 10 methods, it's often better to have several smaller, specific interfaces (e.g., `ICanFly`, `ICanSwim`, `ICanWalk`). A class can then implement only the interfaces for the behaviors it actually has. This avoids forcing classes to create "dummy" implementations for methods they don't need.

#### 5. D - Dependency Inversion Principle (DIP)
**High-level modules should not depend on low-level modules. Both should depend on abstractions (like interfaces).**

This principle "inverts" the typical flow of dependency. Instead of your high-level business logic (e.g., `UserManager`) directly creating and depending on a low-level data class (e.g., `SQLDatabase`), both should depend on an abstraction, like `IUserRepository`. This allows you to "inject" any database that implements that interface. This is the core idea behind Dependency Injection and makes your code incredibly flexible and testable.

### Core Architecture Concepts

#### High Cohesion & Low Coupling
These two concepts are the "why" behind many principles.

- **High Cohesion (Good) 👍**: Things that are related should be kept together. A class has high cohesion if all its methods and properties are closely related and work together to achieve its single responsibility.

- **Low Coupling (Good) 👍**: Classes should be as independent as possible. If a change in Class A requires you to make changes in Class B, C, and D, they are "tightly coupled," which is brittle and hard to maintain. You want "loose coupling," where a change in one class has minimal or no impact on others.

#### Separation of Concerns (SoC)
This is a broader version of SRP, applied to your entire application architecture. It means you should divide your program into distinct sections, each handling a specific "concern." The most common layers are:

- **Presentation (UI)**: What the user sees
- **State Management**: Manages the UI's state and logic
- **Business Logic**: The core rules and operations of your app
- **Data Layer**: Responsible for fetching, storing, and updating data (from an API, local database, etc.)

Keeping these layers separate makes your app much easier to manage and scale.

### Additional Best Practices

- **DRY (Don't Repeat Yourself)**: If you find yourself copying and pasting the same lines of code, turn that code into a reusable function or class.

- **Use a Logger**: Avoid `print()` statements for debugging. A proper logging package (like `logger`) allows you to set log levels (e.g., info, debug, error) and completely disable them in a production build for better performance.

- **Avoid "Magic Strings"**: Don't use raw text strings (e.g., database keys, route names, notification IDs) directly in your code. Store them as `const` variables in a central file. This prevents typos and makes it easy to update a value in one place.

## Context About Me
- Mid-level software engineer with experience across multiple tech stacks
- Prefer thorough planning to minimize code revisions
- Want to be consulted on implementation decisions
- Comfortable with technical discussions and constructive feedback
- Looking for genuine technical dialogue, not validation

## Theme Usage & UI Standards

### Core Principle
**NEVER hardcode colors, spacing, border radius, or typography.** Always use values from the theme file and design tokens.

### Where to Find Values

1. **Structural Colors** (backgrounds, text, borders):
   - Use `Theme.of(context).colorScheme.*` - defined in theme file
   - Check brightness at runtime: `Theme.of(context).brightness == Brightness.dark`

2. **Semantic/Domain Colors** (financial context):
   - Use `DesignTokens.color()` for: `'income'`, `'expense'`, `'success'`, `'error'`, `'warning'`, `'info'`, `'primary'`

3. **Spacing**:
   - Use `DesignTokens.spacing()` for: `'xs'`, `'sm'`, `'md'`, `'lg'`, `'xl'`, `'2xl'`, `'3xl'`

4. **Border Radius**:
   - Use `DesignTokens.borderRadius[]` for: `'xs'`, `'sm'`, `'md'`, `'lg'`, `'xl'`, `'2xl'`, `'full'`

5. **Typography**:
   - Use `DesignTokens.textStyle()` or `Theme.of(context).textTheme.*`

### Common Mistakes to Avoid

❌ **DON'T**:
- `backgroundColor: Colors.green`
- `BorderRadius.circular(12)`
- `const EdgeInsets.all(16)`
- `color: Colors.grey`
- `Color(0xFF...)`

✅ **DO**:
- `backgroundColor: DesignTokens.color('success')`
- `borderRadius: DesignTokens.borderRadius['md']!`
- `EdgeInsets.all(DesignTokens.spacing('md'))`
- `color: Theme.of(context).colorScheme.onSurfaceVariant`
- Use theme file values

### Important Notes
- Cannot use `const` with widgets that call `Theme.of(context)` or `DesignTokens` (runtime evaluation)
- Dark mode must be tested - text must be readable on dark backgrounds
- DesignTokens colors don't have `.shade` properties - use `.withOpacity()` instead

## Testing Requirements
- Write tests for all new features unless explicitly told not to
- Run tests before committing to ensure code quality and functionality
- Use npm run test to verify all tests pass before making commits
- Tests should cover both happy path and edge cases for new functionality

## Git Commit Guidelines
- Do NOT include AI/Claude attribution in commit messages
- No "Generated with Claude Code" footers or similar attribution
- No "Co-Authored-By: Claude" tags
- Keep commit messages professional and focused solely on technical changes
- Commit messages should reflect the work as if written by the developer

### When to Create Commits
**IMPORTANT**: Only create commits when explicitly requested by the user or when it's clearly appropriate.

**DO commit when:**
- User explicitly asks you to commit ("commit this", "make a commit", "save this to git")
- You've completed a significant, well-defined task that the user approved
- You're about to switch contexts and need to save coherent work
- The user is about to test changes and wants a clean state to revert to

**DO NOT commit when:**
- You're in the middle of implementing a feature
- The user hasn't reviewed or approved the changes yet
- You've only made partial progress on a task
- The user is still iterating on requirements
- Making exploratory or experimental changes
- Only investigating/reading code without making changes

**Ask first if uncertain:**
- "Would you like me to commit these changes?"
- "Should I create a commit now, or would you like to review first?"

This prevents premature commits and gives users control over their git history.

## Git Workflow & Change Prevention

### Pre-Commit Checklist (MANDATORY)
Before EVERY commit, execute this checklist:

```bash
# 1. Review all changes
git diff

# 2. Check what files are staged
git status

# 3. Review staged changes specifically
git diff --staged

# 4. If changes look wrong, unstage and investigate
git reset HEAD <file>
```

### Commit Discipline
1. **One Purpose Per Commit**: Each commit should have ONE clear purpose
   - ✅ Good: "Add YearEndGoalService for goal tracking"
   - ❌ Bad: "Add year-end goals and update onboarding and fix bugs"

2. **Separate Unrelated Changes**: If working on multiple things, make multiple commits
   - New service file → Commit 1
   - Onboarding content changes → Commit 2 (with explicit description)
   - Bug fixes → Commit 3

3. **Descriptive Messages**: If you changed user-facing content, the message MUST say so
   - ✅ "Update onboarding: Change page 1 from 'Welcome to Cash on Hand' to 'Welcome to Smart Savings'"
   - ❌ "Add year-end goal tracking" (doesn't mention onboarding content was changed)

4. **Review Before Push**: After committing, review the commit one more time
   ```bash
   git show HEAD
   git log --stat -1
   ```

### Working with Feature Branches
For non-trivial features, use branches:

```bash
# Create feature branch
git checkout -b feature/descriptive-name

# Make changes and commit
git add <specific-files>
git commit -m "Clear message"

# Before merging, review ALL changes since branching
git diff main...feature/descriptive-name

# If everything looks good, merge
git checkout main
git merge feature/descriptive-name
```

### When to Use git add -p (Interactive Staging)
Use interactive staging when:
- Multiple files changed
- Unsure if all changes should be in one commit
- Want to review each change individually

```bash
git add -p
# Review each hunk, press:
# y = stage this hunk
# n = don't stage this hunk
# s = split into smaller hunks
# q = quit
```

### Preventing Content Loss
1. **Never use**: `git checkout <old-commit> -- <file>` to restore old versions
   - This REPLACES the file entirely, deleting all newer changes
   - Instead: Manually copy specific sections needed

2. **Never assume** old content is better without reviewing current content
3. **Always compare** before replacing:
   ```bash
   git diff <old-commit> HEAD -- <file>
   ```

### Emergency: If You Made a Bad Commit
If you committed unintended changes and HAVEN'T pushed:

```bash
# See what the commit changed
git show HEAD

# Option 1: Undo commit but keep changes
git reset --soft HEAD~1

# Option 2: Undo commit and unstage changes
git reset HEAD~1

# Option 3: Completely undo commit and changes (DANGEROUS)
git reset --hard HEAD~1
```

If you ALREADY pushed: Create a revert commit
```bash
git revert HEAD
```
## Git Workflow

### Branch Strategy (Simplified Flow for Solo Developer)

We use a simplified Git Flow optimized for solo development with professional standards:

```
production-prep → Production code (live in App Stores)
develop → Daily development work
hotfix/* → Emergency production fixes (branch from production-prep)
feature/* → New features (branch from develop)
```

**Why `production-prep` instead of `main`?**
- Historical: `main` branch contains legacy v0.2 code
- `production-prep` contains current production code (v1.1.0+14) deployed to stores
- Future: Consider renaming `production-prep` → `main` for clarity

### Branch Workflow

#### For New Features:
```bash
git checkout develop
git checkout -b feature/your-feature-name
# ... work on feature ...
git add .
git commit -m "Add feature description"
git checkout develop
git merge feature/your-feature-name
git branch -d feature/your-feature-name
```

#### For Production Hotfixes (CRITICAL BUGS):
```bash
# 1. Start from production
git checkout production-prep
git checkout -b hotfix/descriptive-name

# 2. Make the fix with proper comments
# ... make changes ...

# 3. Test thoroughly
flutter test
flutter build appbundle --release  # Android
flutter build ipa --release  # iOS

# 4. Commit with detailed message
git add .
git commit -m "Fix: detailed description
- What the bug was
- What caused it
- How it's fixed
- How to avoid it in the future"

# 5. Merge back to production
git checkout production-prep
git merge hotfix/descriptive-name

# 6. IMPORTANT: Also merge to develop so fix persists
git checkout develop
git merge hotfix/descriptive-name

# 7. Clean up
git branch -d hotfix/descriptive-name

# 8. Deploy
# ... build and upload to stores ...
```

### Commit Message Standards

**Format:**
```
<type>: <short summary> (50 chars max)

<detailed description>
- What changed
- Why it changed
- Impact/consequences
- How to test

<optional sections>
BREAKING CHANGES: (if any)
REFERENCES: (commit hashes, issues)
SEARCH KEYWORDS: (for future searching)
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `hotfix:` - Emergency production fix
- `refactor:` - Code restructuring (no behavior change)
- `docs:` - Documentation only
- `test:` - Adding/fixing tests
- `chore:` - Build process, dependencies

**Examples:**
```
hotfix: Fix database migration v17 duplicate column crash

Users upgrading from TestFlight builds were experiencing crashes due to
migration v17 attempting to add monthly_income column that already existed.

Changes:
- Updated migration v17 to use _addColumnIfNotExists() instead of m.addColumn()
- Added detailed inline comments explaining the fix
- Version bump: 1.1.0+14 → 1.1.0+15

REFERENCES: Caused by deploying schema changes before migration (common mistake)
SEARCH KEYWORDS: SqliteException, duplicate column, migration crash, v17
```

### When to Commit

**DO commit:**
- After completing a logical unit of work
- Before switching context/branches
- After fixing a bug (even if more work remains)
- When requested by user

**DON'T commit:**
- Incomplete/broken code that won't compile
- Multiple unrelated changes together
- Without running tests first
- Without reviewing `git diff`

### Stash Usage

When you need to switch contexts without committing:
```bash
# Save current work
git stash save "WIP: descriptive message"

# Switch branches and work on something else
git checkout other-branch

# Come back and restore
git checkout original-branch
git stash pop  # Applies and removes from stash
# OR
git stash apply  # Applies but keeps in stash

# List stashes
git stash list

# Delete specific stash
git stash drop stash@{0}
```

## Database Migration Guidelines

### CRITICAL: How to Add Database Changes Safely

**The Problem:**
Users can have complex version histories (TestFlight → Production → Hotfix), causing migrations to run in unexpected orders or skip versions. Direct column additions can crash if the column already exists.

**The Solution:**
Always use defensive migration helpers that check before modifying.

### Migration Checklist (MANDATORY)

Before adding ANY database change:

1. ✅ **Increment schema version**
   ```dart
   @override
   int get schemaVersion => 18;  // Increment by 1
   ```

2. ✅ **Use safe migration helpers**
   - ❌ NEVER: `await m.addColumn(table, column)`
   - ✅ ALWAYS: `await _addColumnIfNotExists('table_name', 'column_name', 'TYPE')`

3. ✅ **Add comprehensive comments**
   ```dart
   if (from < 18) {
     // Migration from v17 to v18: Add new_column to some_table
     // SAFE: Uses _addColumnIfNotExists() to prevent duplicate column crashes
     // This protects users upgrading from mixed version histories
     await _addColumnIfNotExists('some_table', 'new_column', 'TEXT NULL');
     print('Database migrated to v18: Added new_column to some_table');
   }
   ```

4. ✅ **Test BOTH scenarios**
   - Fresh install (schema built from scratch)
   - Upgrade from previous version (migration runs)

5. ✅ **Document in commit message**
   - What table/column changed
   - Why the change was needed
   - How it's protected from crashes

### Safe Migration Patterns

#### Adding a Column (CORRECT WAY):
```dart
if (from < X) {
  await _addColumnIfNotExists('table_name', 'column_name', 'TYPE CONSTRAINTS');
  print('Database migrated to vX: Added column_name to table_name');
}
```

#### Adding a Table (Always Safe):
```dart
if (from < X) {
  await m.createTable(tableName);
  print('Database migrated to vX: Created tableName table');
}
```

#### Dropping a Column (Use Custom SQL):
```dart
if (from < X) {
  try {
    await customStatement('ALTER TABLE table_name DROP COLUMN column_name');
    print('Database migrated to vX: Dropped column_name from table_name');
  } catch (e) {
    print('⚠️ Migration vX: Column may not exist (ok to continue): $e');
  }
}
```

#### Complex Migration (Recreate Table):
```dart
if (from < X) {
  // Back up data
  await customStatement('CREATE TEMPORARY TABLE backup AS SELECT * FROM table_name');
  
  // Drop old table
  await customStatement('DROP TABLE IF EXISTS table_name');
  
  // Create new table with updated schema
  await m.createTable(tableName);
  
  // Restore data (adjust columns as needed)
  await customStatement('INSERT INTO table_name SELECT * FROM backup');
  
  // Clean up
  await customStatement('DROP TABLE backup');
  
  print('Database migrated to vX: Recreated table_name with new schema');
}
```

### Common Migration Mistakes to Avoid

❌ **Mistake 1: Deploying schema before migration**
```dart
// DON'T DO THIS SEQUENCE:
1. Update table class with new column
2. Deploy to TestFlight
3. Later add migration
// Result: TestFlight users have column, migration tries to add it again → crash
```

✅ **Correct Sequence:**
```dart
1. Write migration first
2. Increment schema version
3. THEN update table class
4. Test both fresh install AND upgrade
5. Deploy
```

❌ **Mistake 2: Using unsafe migration methods**
```dart
// DON'T:
await m.addColumn(budgetTemplates, budgetTemplates.monthlyIncome);

// DO:
await _addColumnIfNotExists('budget_templates', 'monthly_income', 'REAL NULL');
```

❌ **Mistake 3: Assuming linear version history**
```dart
// Users don't always upgrade linearly
// They might skip versions or use TestFlight then downgrade
// Always write defensive migrations
```

❌ **Mistake 4: Not testing upgrades**
```dart
// ALWAYS test:
1. Fresh install (onCreate)
2. Upgrade from previous version (onUpgrade)
3. Upgrade from 2 versions ago (multiple migrations)
```

### Testing Migrations Locally

```bash
# 1. Install version N-1 on device
flutter install

# 2. Use the app (create some data)

# 3. Checkout new version with migration
git checkout feature/with-migration

# 4. Install version N on same device
flutter install

# 5. Open app - verify migration succeeds and data persists

# 6. Check logs for migration success messages
flutter logs | grep "Database migrated"
```

### When Migration Fails in Production

If users report database crashes:

1. **Immediate Response:**
   - Create hotfix branch from production
   - Fix migration using safe helper
   - Add defensive comments
   - Bump build number
   - Deploy ASAP

2. **Communication:**
   - If 100s of users: Push hotfix immediately
   - If 1000s of users: Consider if users can reinstall
   - Document the issue in commit message

3. **Prevention:**
   - Update CLAUDE.md with new learnings
   - Add the mistake to "Common Migration Mistakes"
   - Set up automated migration tests (future improvement)

### Migration Version History

Current schema version: **17**

**Recent migrations:**
- v17: Added monthlyIncome to budget_templates (HOTFIXED in v1.1.0+15)
- v16: Added allocation template tables
- v15: Fixed isSystem flags for categories
- v14: Cleaned up duplicate Books category
- v13: Converted year-end goals to percentages

**Known Issues Fixed:**
- v17 initial deployment used unsafe m.addColumn() → Caused crashes for TestFlight upgraders → Fixed in hotfix/database-migration-v17

### _addColumnIfNotExists Helper (Reference)

```dart
// This helper is already in database.dart
// Use it for ALL column additions in migrations
Future<void> _addColumnIfNotExists(
  String tableName,
  String columnName,
  String columnDefinition,
) async {
  try {
    // Check if column exists
    final result = await customSelect(
      "PRAGMA table_info('$tableName')",
    ).get();
    
    final columnExists = result.any((row) => row.data['name'] == columnName);
    
    if (!columnExists) {
      // Column doesn't exist, safe to add
      await customStatement(
        'ALTER TABLE "$tableName" ADD COLUMN "$columnName" $columnDefinition',
      );
      print('✅ Added column $columnName to $tableName');
    } else {
      print('ℹ️ Column $columnName already exists in $tableName (skipping)');
    }
  } catch (e) {
    print('⚠️ Error checking/adding column $columnName: $e');
    rethrow;
  }
}
```

