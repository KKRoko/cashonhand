// Cash on Hand - Design System Usage Guide
// Comprehensive documentation and examples for using the design system

import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'enhanced_theme.dart';
import '../ui/components/cash_components.dart';

/// 📚 DESIGN SYSTEM USAGE GUIDE
/// This file serves as living documentation for the Cash on Hand design system.
/// It provides examples and guidelines for consistent implementation.

/// 🎯 DESIGN PRINCIPLES
/// 
/// 1. **Financial Clarity** - Clear visual hierarchy for financial data
///    - Use FinancialAmount for all monetary values
///    - Apply consistent color coding (green=income, red=expense, grey=neutral)
///    - Ensure proper contrast for accessibility
/// 
/// 2. **Action-Oriented** - Easy identification of positive/negative/neutral states
///    - Use FinancialButton for income/expense actions
///    - Apply contextual colors consistently
///    - Provide clear visual feedback for interactions
/// 
/// 3. **Accessible First** - WCAG 2.1 AA compliance minimum
///    - All color combinations meet contrast requirements
///    - Touch targets are minimum 44x44px
///    - Screen reader support built-in
/// 
/// 4. **Responsive** - Fluid across all device sizes
///    - Use ResponsiveBuilder for layout variations
///    - Apply consistent spacing across breakpoints
///    - Scale typography appropriately
/// 
/// 5. **Consistent** - Predictable patterns and behaviors
///    - Use design tokens for all styling decisions
///    - Follow established component patterns
///    - Maintain consistent spacing and timing

/// 🎨 COLOR USAGE EXAMPLES
class ColorUsageExamples extends StatelessWidget {
  const ColorUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Financial Color Usage
        Text('Financial Colors', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        // Income Example
        CashCard(
          financialContext: FinancialContext.income,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Income Transaction', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              FinancialAmount(amount: 1250.00),
            ],
          ),
        ),
        
        // Expense Example
        CashCard(
          financialContext: FinancialContext.expense,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expense Transaction', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              FinancialAmount(amount: -850.75),
            ],
          ),
        ),
        
        // Neutral Example
        CashCard(
          financialContext: FinancialContext.neutral,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Neutral State', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              FinancialAmount(amount: 0.00),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🔤 TYPOGRAPHY USAGE EXAMPLES
class TypographyUsageExamples extends StatelessWidget {
  const TypographyUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Styles - Hero text
        Text('Hero Section', style: DesignTokens.textStyle('displayLarge')),
        Text('Supporting headline', style: DesignTokens.textStyle('displayMedium')),
        VSpace('lg'),
        
        // Headlines - Page titles
        Text('Page Title', style: DesignTokens.textStyle('headlineLarge')),
        Text('Section Header', style: DesignTokens.textStyle('headlineMedium')),
        Text('Subsection', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('lg'),
        
        // Titles - Component headers
        Text('Card Title', style: DesignTokens.textStyle('titleLarge')),
        Text('List Item Title', style: DesignTokens.textStyle('titleMedium')),
        Text('Small Component Title', style: DesignTokens.textStyle('titleSmall')),
        VSpace('lg'),
        
        // Body Text - Main content
        Text('Primary body text for main content', style: DesignTokens.textStyle('bodyLarge')),
        Text('Secondary body text for descriptions', style: DesignTokens.textStyle('bodyMedium')),
        Text('Small body text for captions', style: DesignTokens.textStyle('bodySmall')),
        VSpace('lg'),
        
        // Labels - UI elements
        Text('Button Label', style: DesignTokens.textStyle('labelLarge')),
        Text('Form Label', style: DesignTokens.textStyle('labelMedium')),
        Text('Chip Label', style: DesignTokens.textStyle('labelSmall')),
        VSpace('lg'),
        
        // Financial Amounts - Special formatting
        FinancialAmount(amount: 12345.67, size: FinancialAmountSize.large),
        FinancialAmount(amount: 567.89, size: FinancialAmountSize.medium),
        FinancialAmount(amount: 12.34, size: FinancialAmountSize.small),
      ],
    );
  }
}

/// 🔘 BUTTON USAGE EXAMPLES
class ButtonUsageExamples extends StatelessWidget {
  const ButtonUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Button Sizes', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        // Primary Buttons
        Row(
          children: [
            PrimaryButton(
              onPressed: () {},
              size: ButtonSize.small,
              child: const Text('Small'),
            ),
            HSpace('sm'),
            PrimaryButton(
              onPressed: () {},
              size: ButtonSize.medium,
              child: const Text('Medium'),
            ),
            HSpace('sm'),
            PrimaryButton(
              onPressed: () {},
              size: ButtonSize.large,
              child: const Text('Large'),
            ),
          ],
        ),
        VSpace('lg'),
        
        // Financial Buttons
        Text('Financial Action Buttons', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        Row(
          children: [
            Expanded(
              child: FinancialButton(
                onPressed: () {},
                financialType: FinancialButtonType.income,
                icon: Icons.add,
                child: const Text('Add Income'),
              ),
            ),
            HSpace('md'),
            Expanded(
              child: FinancialButton(
                onPressed: () {},
                financialType: FinancialButtonType.expense,
                icon: Icons.remove,
                child: const Text('Add Expense'),
              ),
            ),
          ],
        ),
        VSpace('lg'),
        
        // Button States
        Text('Button States', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        Column(
          children: [
            PrimaryButton(
              onPressed: () {},
              child: const Text('Enabled'),
            ),
            VSpace('sm'),
            PrimaryButton(
              onPressed: null,
              child: const Text('Disabled'),
            ),
            VSpace('sm'),
            PrimaryButton(
              onPressed: () {},
              loading: true,
              child: const Text('Loading'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 🃏 CARD USAGE EXAMPLES
class CardUsageExamples extends StatelessWidget {
  const CardUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Card Variations', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        // Basic Card
        CashCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Basic Card', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              Text('Standard card with default styling', style: DesignTokens.textStyle('bodyMedium')),
            ],
          ),
        ),
        
        // Financial Context Cards
        CashCard(
          financialContext: FinancialContext.income,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Income Card', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              FinancialAmount(amount: 1500.00),
            ],
          ),
        ),
        
        CashCard(
          financialContext: FinancialContext.expense,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expense Card', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              FinancialAmount(amount: -750.25),
            ],
          ),
        ),
        
        // Interactive Card
        CashCard(
          onTap: () {
            // Handle tap
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Interactive Card', style: DesignTokens.textStyle('titleMedium')),
              VSpace('sm'),
              Text('Tap to interact', style: DesignTokens.textStyle('bodyMedium')),
            ],
          ),
        ),
      ],
    );
  }
}

/// 📊 PROGRESS INDICATOR EXAMPLES
class ProgressIndicatorExamples extends StatelessWidget {
  const ProgressIndicatorExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress Indicators', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        // Goal Progress - Income Context
        FinancialProgressBar(
          value: 3500,
          total: 5000,
          label: 'Emergency Fund',
          financialContext: FinancialContext.income,
        ),
        VSpace('lg'),
        
        // Budget Progress - Expense Context
        FinancialProgressBar(
          value: 1200,
          total: 2000,
          label: 'Monthly Budget Used',
          financialContext: FinancialContext.expense,
        ),
        VSpace('lg'),
        
        // Neutral Progress
        FinancialProgressBar(
          value: 25,
          total: 100,
          label: 'Profile Completion',
          financialContext: FinancialContext.neutral,
        ),
      ],
    );
  }
}

/// 🏷 CHIP USAGE EXAMPLES
class ChipUsageExamples extends StatelessWidget {
  const ChipUsageExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Chips', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        // Size Variations
        Wrap(
          spacing: DesignTokens.space('sm'),
          runSpacing: DesignTokens.space('xs'),
          children: [
            CategoryChip(
              name: 'Small',
              size: ChipSize.small,
              icon: '🏠',
            ),
            CategoryChip(
              name: 'Medium',
              size: ChipSize.medium,
              icon: '🍕',
            ),
            CategoryChip(
              name: 'Large',
              size: ChipSize.large,
              icon: '🚗',
            ),
          ],
        ),
        VSpace('lg'),
        
        // Financial Context
        Wrap(
          spacing: DesignTokens.space('sm'),
          runSpacing: DesignTokens.space('xs'),
          children: [
            CategoryChip(
              name: 'Salary',
              icon: '💼',
              financialContext: FinancialContext.income,
            ),
            CategoryChip(
              name: 'Groceries',
              icon: '🛒',
              financialContext: FinancialContext.expense,
            ),
            CategoryChip(
              name: 'Transfer',
              icon: '🔄',
              financialContext: FinancialContext.neutral,
            ),
          ],
        ),
        VSpace('lg'),
        
        // Selection States
        Wrap(
          spacing: DesignTokens.space('sm'),
          runSpacing: DesignTokens.space('xs'),
          children: [
            CategoryChip(
              name: 'Selected',
              icon: '✅',
              selected: true,
            ),
            CategoryChip(
              name: 'Unselected',
              icon: '⭕',
              selected: false,
            ),
          ],
        ),
      ],
    );
  }
}

/// 🎬 ANIMATION EXAMPLES
class AnimationExamples extends StatefulWidget {
  const AnimationExamples({super.key});

  @override
  State<AnimationExamples> createState() => _AnimationExamplesState();
}

class _AnimationExamplesState extends State<AnimationExamples> {
  bool _fadeVisible = true;
  bool _slideVisible = true;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Animations', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        // Fade Animation
        Row(
          children: [
            PrimaryButton(
              onPressed: () => setState(() => _fadeVisible = !_fadeVisible),
              size: ButtonSize.small,
              child: const Text('Toggle Fade'),
            ),
            HSpace('md'),
            CashComponents.FadeTransition(
              visible: _fadeVisible,
              child: Container(
                width: 100,
                height: 50,
                color: DesignTokens.color('primary'),
                child: Center(
                  child: Text(
                    'Fade',
                    style: DesignTokens.textStyle('labelMedium').copyWith(
                      color: DesignTokens.color('onPrimary'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        VSpace('lg'),
        
        // Slide Animation
        Row(
          children: [
            PrimaryButton(
              onPressed: () => setState(() => _slideVisible = !_slideVisible),
              size: ButtonSize.small,
              child: const Text('Toggle Slide'),
            ),
            HSpace('md'),
            CashComponents.SlideTransition(
              visible: _slideVisible,
              direction: SlideDirection.left,
              child: Container(
                width: 100,
                height: 50,
                color: DesignTokens.color('secondary'),
                child: Center(
                  child: Text(
                    'Slide',
                    style: DesignTokens.textStyle('labelMedium').copyWith(
                      color: DesignTokens.color('onSecondary'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        VSpace('lg'),
        
        // Expand Animation
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              size: ButtonSize.small,
              child: Text(_expanded ? 'Collapse' : 'Expand'),
            ),
            VSpace('sm'),
            ExpandTransition(
              expanded: _expanded,
              child: CashCard(
                child: Column(
                  children: [
                    Text('Expandable Content', style: DesignTokens.textStyle('titleMedium')),
                    VSpace('sm'),
                    Text('This content expands and collapses smoothly using design token timing.', 
                         style: DesignTokens.textStyle('bodyMedium')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 📏 SPACING EXAMPLES
class SpacingExamples extends StatelessWidget {
  const SpacingExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Spacing System', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        // Spacing Scale Visualization
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSpacingExample('xs', DesignTokens.space('xs')),
            _buildSpacingExample('sm', DesignTokens.space('sm')),
            _buildSpacingExample('md', DesignTokens.space('md')),
            _buildSpacingExample('lg', DesignTokens.space('lg')),
            _buildSpacingExample('xl', DesignTokens.space('xl')),
            _buildSpacingExample('2xl', DesignTokens.space('2xl')),
          ],
        ),
        VSpace('lg'),
        
        // Usage with Helper Widgets
        Text('Using Spacing Helpers', style: DesignTokens.textStyle('titleMedium')),
        VSpace('sm'),
        
        Row(
          children: [
            Text('Item 1', style: DesignTokens.textStyle('bodyMedium')),
            HSpace('md'), // Horizontal space
            Text('Item 2', style: DesignTokens.textStyle('bodyMedium')),
            HSpace('lg'), // Larger horizontal space
            Text('Item 3', style: DesignTokens.textStyle('bodyMedium')),
          ],
        ),
        VSpace('md'), // Vertical space
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vertical Item 1', style: DesignTokens.textStyle('bodyMedium')),
            VSpace('sm'), // Small vertical space
            Text('Vertical Item 2', style: DesignTokens.textStyle('bodyMedium')),
            VSpace('lg'), // Large vertical space
            Text('Vertical Item 3', style: DesignTokens.textStyle('bodyMedium')),
          ],
        ),
      ],
    );
  }

  Widget _buildSpacingExample(String token, double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignTokens.space('sm')),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(token, style: DesignTokens.textStyle('labelMedium')),
          ),
          Container(
            width: value,
            height: 20,
            color: DesignTokens.color('primary'),
          ),
          HSpace('sm'),
          Text('${value.toInt()}px', style: DesignTokens.textStyle('bodySmall')),
        ],
      ),
    );
  }
}

/// 📱 RESPONSIVE EXAMPLES
class ResponsiveExamples extends StatelessWidget {
  const ResponsiveExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Responsive Design', style: DesignTokens.textStyle('headlineSmall')),
        VSpace('md'),
        
        // Responsive Layout
        ResponsiveBuilder(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
        VSpace('lg'),
        
        // Responsive Values
        ResponsiveValue<int>(
          mobile: 1,
          tablet: 2,
          desktop: 3,
          builder: (columns) => GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            crossAxisSpacing: DesignTokens.space('md'),
            mainAxisSpacing: DesignTokens.space('md'),
            childAspectRatio: 2,
            children: List.generate(6, (index) => 
              CashCard(
                child: Center(
                  child: Text('Item ${index + 1}', 
                             style: DesignTokens.textStyle('labelLarge')),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return CashCard(
      child: Column(
        children: [
          Text('Mobile Layout', style: DesignTokens.textStyle('titleMedium')),
          VSpace('sm'),
          Text('Single column, stacked content', style: DesignTokens.textStyle('bodyMedium')),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return CashCard(
      child: Column(
        children: [
          Text('Tablet Layout', style: DesignTokens.textStyle('titleMedium')),
          VSpace('sm'),
          Text('Two columns, more spacious', style: DesignTokens.textStyle('bodyMedium')),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return CashCard(
      child: Column(
        children: [
          Text('Desktop Layout', style: DesignTokens.textStyle('titleMedium')),
          VSpace('sm'),
          Text('Multi-column, maximum efficiency', style: DesignTokens.textStyle('bodyMedium')),
        ],
      ),
    );
  }
}

/// 📋 IMPLEMENTATION GUIDELINES
/// 
/// ## How to Use This Design System
/// 
/// ### 1. **Always Use Design Tokens**
/// ```dart
/// // ✅ Correct - Using design tokens
/// Container(
///   padding: EdgeInsets.all(DesignTokens.space('md')),
///   color: DesignTokens.color('surface'),
///   child: Text(
///     'Hello World',
///     style: DesignTokens.textStyle('bodyLarge'),
///   ),
/// )
/// 
/// // ❌ Incorrect - Hardcoded values
/// Container(
///   padding: EdgeInsets.all(16),
///   color: Colors.white,
///   child: Text(
///     'Hello World',
///     style: TextStyle(fontSize: 16),
///   ),
/// )
/// ```
/// 
/// ### 2. **Use Pre-built Components**
/// ```dart
/// // ✅ Correct - Using design system components
/// FinancialAmount(amount: 1250.50)
/// 
/// // ❌ Incorrect - Building from scratch
/// Text(
///   '\$1,250.50',
///   style: TextStyle(
///     color: Colors.green,
///     fontWeight: FontWeight.bold,
///   ),
/// )
/// ```
/// 
/// ### 3. **Follow Financial Context Patterns**
/// ```dart
/// // ✅ Correct - Using financial context
/// CashCard(
///   financialContext: FinancialContext.income,
///   child: FinancialAmount(amount: 1000),
/// )
/// 
/// // ❌ Incorrect - Manual color coding
/// Container(
///   color: Colors.green.shade50,
///   child: Text('\$1,000', style: TextStyle(color: Colors.green)),
/// )
/// ```
/// 
/// ### 4. **Use Consistent Animations**
/// ```dart
/// // ✅ Correct - Using design system animations
/// FadeTransition(
///   visible: isVisible,
///   duration: 'normal',
///   child: MyWidget(),
/// )
/// 
/// // ❌ Incorrect - Custom animation timing
/// AnimatedOpacity(
///   opacity: isVisible ? 1.0 : 0.0,
///   duration: Duration(milliseconds: 300),
///   child: MyWidget(),
/// )
/// ```
/// 
/// ### 5. **Implement Responsive Design**
/// ```dart
/// // ✅ Correct - Using responsive helpers
/// ResponsiveBuilder(
///   mobile: MobileLayout(),
///   tablet: TabletLayout(),
///   desktop: DesktopLayout(),
/// )
/// 
/// // ❌ Incorrect - Manual breakpoint detection
/// MediaQuery.of(context).size.width > 768 
///   ? DesktopLayout() 
///   : MobileLayout()
/// ```

/// 🔍 ACCESSIBILITY GUIDELINES
/// 
/// ### Color Contrast
/// - All color combinations meet WCAG 2.1 AA standards (4.5:1 for normal text)
/// - Large text meets 3:1 minimum contrast ratio
/// - Interactive elements maintain proper contrast in all states
/// 
/// ### Touch Targets
/// - All interactive elements are minimum 44x44px
/// - Adequate spacing between touch targets
/// - Clear visual feedback for interactions
/// 
/// ### Typography
/// - Font sizes are readable at standard viewing distances
/// - Line heights provide comfortable reading experience
/// - Font weights provide clear hierarchy
/// 
/// ### Screen Reader Support
/// - All components include proper semantic HTML/Widget structure
/// - Interactive elements have appropriate labels
/// - Financial amounts include currency and context information

/// 🚀 MIGRATION GUIDE
/// 
/// ### From Old Theme to Design System
/// 
/// 1. **Replace AppTheme with EnhancedTheme**
/// ```dart
/// // Old
/// theme: AppTheme.lightTheme()
/// 
/// // New
/// theme: EnhancedTheme.lightTheme().copyWith(
///   extensions: [
///     FinancialTheme.light(),
///     MotionTokens(),
///   ],
/// )
/// ```
/// 
/// 2. **Update Color Usage**
/// ```dart
/// // Old
/// color: Colors.green
/// 
/// // New
/// color: DesignTokens.color('income')
/// // or
/// color: context.financial.incomeColor
/// ```
/// 
/// 3. **Replace Hardcoded Spacing**
/// ```dart
/// // Old
/// padding: EdgeInsets.all(16)
/// 
/// // New
/// padding: EdgeInsets.all(DesignTokens.space('md'))
/// ```
/// 
/// 4. **Use Component Library**
/// ```dart
/// // Old
/// Text('\$${amount.toStringAsFixed(2)}')
/// 
/// // New
/// FinancialAmount(amount: amount)
/// ```

/// 🎯 BEST PRACTICES CHECKLIST
/// 
/// Before implementing any UI component, ask:
/// 
/// ✅ Am I using design tokens instead of hardcoded values?
/// ✅ Am I using pre-built components where available?
/// ✅ Does my color usage follow financial context patterns?
/// ✅ Are my animations using consistent timing from design tokens?
/// ✅ Is my layout responsive across different screen sizes?
/// ✅ Does my implementation meet accessibility requirements?
/// ✅ Am I following established spacing and typography hierarchy?
/// ✅ Are interactive elements properly sized and spaced?

// Create alias for easier imports
typedef CashComponents = CashCard;