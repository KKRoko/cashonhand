import '../../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalIntegrationOnboarding extends StatefulWidget {
  final VoidCallback? onComplete;

  const GoalIntegrationOnboarding({
    super.key,
    this.onComplete,
  });

  static const String _onboardingKey = 'goal_integration_onboarding_completed';

  // Flag to force onboarding to be shown even if completed
  // This is used during app reset to work around hot restart caching
  static bool _forceShowOnboarding = false;

  /// Force onboarding to be shown on next check (used during reset)
  static void forceShowOnboarding() {
    print('🎯 Onboarding: Force flag set - will show onboarding on next check');
    _forceShowOnboarding = true;
  }

  /// Check if the user has already seen the onboarding
  static Future<bool> shouldShowOnboarding() async {
    // Check force flag first (handles hot restart case)
    if (_forceShowOnboarding) {
      print('🎯 Onboarding check: Force flag is set, returning shouldShow=true');
      _forceShowOnboarding = false; // Reset flag after checking
      return true;
    }

    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_onboardingKey) ?? false;
    print('🎯 Onboarding check: key=$_onboardingKey, completed=$completed, shouldShow=${!completed}');
    return !completed;
  }

  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    _forceShowOnboarding = false; // Clear force flag
  }

  /// Show onboarding if needed
  static Future<void> showIfNeeded(BuildContext context, {VoidCallback? onComplete}) async {
    if (await shouldShowOnboarding()) {
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GoalIntegrationOnboarding(onComplete: onComplete),
            fullscreenDialog: true,
          ),
        );
      }
    }
  }

  @override
  State<GoalIntegrationOnboarding> createState() => _GoalIntegrationOnboardingState();
}

class _GoalIntegrationOnboardingState extends State<GoalIntegrationOnboarding>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentPage = 0;
  static const int _totalPages = 5;
  
  final TextEditingController _yearEndGoalController = TextEditingController();
  bool _hasYearEndGoal = false;

  @override
  void initState() {
    super.initState();
    print('🎯 GoalIntegrationOnboarding: initState called');
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations (fast - 150-200ms)
    print('🎯 GoalIntegrationOnboarding: Starting fast animations at ${DateTime.now()}');
    _fadeController.forward();
    _slideController.forward();
    print('🎯 GoalIntegrationOnboarding: initState complete');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _yearEndGoalController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    print('🎯 GoalIntegrationOnboarding: _completeOnboarding() called');
    // Save year-end goal if set
    if (_hasYearEndGoal && _yearEndGoalController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('year_end_goal', double.tryParse(_yearEndGoalController.text) ?? 0.0);
    }

    await GoalIntegrationOnboarding.markOnboardingCompleted();
    print('🎯 GoalIntegrationOnboarding: Onboarding marked complete, calling onComplete callback');
    if (mounted) {
      // Don't call Navigator.pop() when used as a direct widget (not modal)
      // Just call the completion callback which will handle the transition
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎯 GoalIntegrationOnboarding: build() called at ${DateTime.now()}');

    // Check when first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎯 GoalIntegrationOnboarding: ✅ FIRST FRAME RENDERED at ${DateTime.now()}');
    });

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header with skip button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cash on Hand',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.color('success'),
                        ),
                      ),
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Page indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index 
                            ? DesignTokens.color('success')
                            : Theme.of(context).colorScheme.outline,
                        ),
                      );
                    }),
                  ),
                ),
                
                // Content pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      // Dismiss keyboard when changing pages
                      FocusScope.of(context).unfocus();
                      setState(() => _currentPage = page);
                    },
                    children: [
                      _buildWelcomePage(),
                      _buildSmartSavingsPage(),
                      _buildTrackingPage(),
                      _buildCelebrationPage(),
                      _buildYearEndGoalPage(),
                    ],
                  ),
                ),
                
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: DesignTokens.color('success').withOpacity(0.3)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Previous',
                              style: TextStyle(color: DesignTokens.color('success')),
                            ),
                          ),
                        )
                      else
                        const Expanded(child: SizedBox()),
                      
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignTokens.color('success'),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _currentPage == _totalPages - 1 ? 'Get Started!' : 'Next',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    print('🎯 GoalIntegrationOnboarding: _buildWelcomePage() called at ${DateTime.now()}');
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Welcome animation/illustration
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'assets/images/CashOnHand.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_balance_wallet,
                      size: 80,
                      color: Colors.green.shade600,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Welcome to Cash on Hand!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.color('success'),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'See Your Financial Future Today',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSmartSavingsPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Year-end forecast illustration
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 40, color: Colors.green.shade600),
                const SizedBox(height: 8),
                Text(
                  'Dec 31, ${DateTime.now().year}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$12,450',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Projected Cash',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'See Your Year-End Cash',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Know exactly how much money you\'ll have by December 31st based on your current spending and income patterns.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Feature highlights
          _buildFeatureRow(Icons.trending_up, 'Real-time year-end projection'),
          _buildFeatureRow(Icons.insights, 'Based on your actual patterns'),
          _buildFeatureRow(Icons.update, 'Updates with every transaction'),
        ],
      ),
      ),
    );
  }

  Widget _buildTrackingPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Motivational insights illustration
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, size: 40, color: Colors.blue.shade600),
                const SizedBox(height: 8),
                Text(
                  'Smart Motivation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.trending_up, size: 16, color: Colors.green.shade600),
                      const SizedBox(height: 2),
                      Text(
                        'You\'re 85% to your goal!',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Keep up the momentum',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.green.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Stay Motivated Daily',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            'Get personalized insights that motivate better financial decisions. See how small changes today create big results by year-end.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          _buildFeatureRow(Icons.lightbulb, 'Smart spending insights'),
          _buildFeatureRow(Icons.track_changes, 'Progress tracking'),
          _buildFeatureRow(Icons.chat_bubble, 'Motivational messages'),
        ],
      ),
      ),
    );
  }

  Widget _buildCelebrationPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Control/Future illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.control_camera,
                  size: 80,
                  color: Colors.purple.shade600,
                ),
                // Future visualization elements
                Positioned(
                  top: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${DateTime.now().year}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Take Control of Your Future',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Your financial future is in your hands. Make informed decisions today and watch your year-end cash grow. Change your habits, change your life.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          _buildFeatureRow(Icons.gps_fixed, 'Set your year-end goal'),
          _buildFeatureRow(Icons.timeline, 'Track your progress'),
          _buildFeatureRow(Icons.auto_awesome, 'Transform your habits'),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignTokens.color('success').withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DesignTokens.color('success').withOpacity(0.3)),
            ),
            child: Text(
              '🚀 Ready to see your financial future?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: DesignTokens.color('success'),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: DesignTokens.color('success')),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProgressBar(double progress, Color color) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSparkles() {
    return [
      Positioned(
        top: 40,
        left: 40,
        child: Icon(Icons.auto_awesome, size: 16, color: DesignTokens.color('warning')),
      ),
      Positioned(
        top: 60,
        right: 30,
        child: Icon(Icons.auto_awesome, size: 12, color: DesignTokens.color('warning')),
      ),
      Positioned(
        bottom: 50,
        left: 30,
        child: Icon(Icons.auto_awesome, size: 14, color: DesignTokens.color('warning').withOpacity(0.5)),
      ),
      Positioned(
        bottom: 40,
        right: 40,
        child: Icon(Icons.auto_awesome, size: 18, color: DesignTokens.color('warning').withOpacity(0.5)),
      ),
    ];
  }

  Widget _buildYearEndGoalPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // Year-end goal illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: DesignTokens.color('success').withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 50,
                    color: DesignTokens.color('success'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '2025',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.color('success'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Set Your Year-End Goal',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignTokens.color('success'),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'How much cash do you want to have on hand by the end of 2025?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Goal toggle
          Row(
            children: [
              Checkbox(
                value: _hasYearEndGoal,
                onChanged: (value) {
                  setState(() {
                    _hasYearEndGoal = value ?? false;
                    if (!_hasYearEndGoal) {
                      _yearEndGoalController.clear();
                    }
                  });
                },
                activeColor: DesignTokens.color('success'),
              ),
              Expanded(
                child: Text(
                  'Set a year-end cash goal',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          
          if (_hasYearEndGoal) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearEndGoalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Year-end goal amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: DesignTokens.color('success').withOpacity(0.5), width: 2),
                ),
                hintText: 'e.g., 10000',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This goal will help you track your progress throughout the year and celebrate when you reach it!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      ),
    );
  }
}

/// Helper class to show onboarding from anywhere in the app
class OnboardingManager {
  static Future<void> checkAndShowOnboarding(BuildContext context) async {
    await GoalIntegrationOnboarding.showIfNeeded(context);
  }
}