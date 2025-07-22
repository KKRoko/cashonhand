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

  /// Check if the user has already seen the onboarding
  static Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.getBool(_onboardingKey, defaultValue: false);
  }

  /// Mark onboarding as completed
  static Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
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
  static const int _totalPages = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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
    await GoalIntegrationOnboarding.markOnboardingCompleted();
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          color: Colors.green.shade700,
                        ),
                      ),
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(color: Colors.grey.shade600),
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
                            ? Colors.green 
                            : Colors.grey.shade300,
                        ),
                      );
                    }),
                  ),
                ),
                
                // Content pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildWelcomePage(),
                      _buildSmartSavingsPage(),
                      _buildTrackingPage(),
                      _buildCelebrationPage(),
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
                              side: BorderSide(color: Colors.green.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'Previous',
                              style: TextStyle(color: Colors.green.shade700),
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
                            backgroundColor: Colors.green,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Welcome animation/illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: Icon(
                Icons.savings,
                size: 80,
                color: Colors.green.shade600,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Welcome to Smart Savings!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Transform your spending into smart savings with our integrated goal system. Let\'s show you how!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSmartSavingsPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Smart allocations illustration
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
                Icon(Icons.flash_on, size: 40, color: Colors.blue.shade600),
                const SizedBox(height: 8),
                Text(
                  'Smart Allocation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    const Expanded(child: Text('Emergency Fund')),
                    const Text('\$50'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: Colors.orange.shade600),
                    const SizedBox(width: 4),
                    const Expanded(child: Text('Vacation')),
                    const Text('\$30'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Automatic Goal Allocation',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Every transaction can automatically contribute to your savings goals. Set up rules for round-ups, percentage allocations, and more!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Feature highlights
          _buildFeatureRow(Icons.autorenew, 'Auto round-up on purchases'),
          _buildFeatureRow(Icons.percent, 'Percentage-based allocations'),
          _buildFeatureRow(Icons.rule, 'Custom allocation rules'),
        ],
      ),
    );
  }

  Widget _buildTrackingPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Analytics illustration
          Container(
            width: 200,
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics, size: 40, color: Colors.purple.shade600),
                const SizedBox(height: 8),
                Text(
                  'Advanced Analytics',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                // Mock progress bars
                _buildMiniProgressBar(0.7, Colors.green),
                const SizedBox(height: 4),
                _buildMiniProgressBar(0.4, Colors.blue),
                const SizedBox(height: 4),
                _buildMiniProgressBar(0.9, Colors.orange),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Smart Insights & Tracking',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Get powerful insights into your savings velocity, goal predictions, and spending vs. savings balance to make informed decisions.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          _buildFeatureRow(Icons.speed, 'Savings velocity tracking'),
          _buildFeatureRow(Icons.timeline, 'Goal completion predictions'),
          _buildFeatureRow(Icons.balance, 'Spending vs. savings balance'),
        ],
      ),
    );
  }

  Widget _buildCelebrationPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Celebration illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.celebration,
                  size: 80,
                  color: Colors.amber.shade600,
                ),
                // Animated sparkles
                ..._buildSparkles(),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Celebrate Your Success!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Unlock achievements, track streaks, and celebrate milestones! Share your progress and stay motivated on your savings journey.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          _buildFeatureRow(Icons.emoji_events, 'Achievement system'),
          _buildFeatureRow(Icons.local_fire_department, 'Savings streaks'),
          _buildFeatureRow(Icons.share, 'Share your progress'),
          
          const SizedBox(height: 32),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Text(
              '🎉 You\'re ready to start your smart savings journey!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
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
        color: Colors.grey.shade300,
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
        child: Icon(Icons.auto_awesome, size: 16, color: Colors.amber.shade400),
      ),
      Positioned(
        top: 60,
        right: 30,
        child: Icon(Icons.auto_awesome, size: 12, color: Colors.yellow.shade600),
      ),
      Positioned(
        bottom: 50,
        left: 30,
        child: Icon(Icons.auto_awesome, size: 14, color: Colors.orange.shade400),
      ),
      Positioned(
        bottom: 40,
        right: 40,
        child: Icon(Icons.auto_awesome, size: 18, color: Colors.amber.shade500),
      ),
    ];
  }
}

/// Helper class to show onboarding from anywhere in the app
class OnboardingManager {
  static Future<void> checkAndShowOnboarding(BuildContext context) async {
    await GoalIntegrationOnboarding.showIfNeeded(context);
  }
}