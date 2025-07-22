import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../data/models/freezed/round_up_preferences.dart';
import '../../state/saving_goal_notifier.dart';
import '../../utils/formatters.dart';

class RoundUpSettingsScreen extends StatefulWidget {
  static const routeName = '/roundUpSettings';

  const RoundUpSettingsScreen({super.key});

  @override
  State<RoundUpSettingsScreen> createState() => _RoundUpSettingsScreenState();
}

class _RoundUpSettingsScreenState extends State<RoundUpSettingsScreen> {
  late SettingsService _settingsService;
  late RoundUpPreferences _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
    _preferences = _settingsService.roundUpPreferences;
  }

  Future<void> _updatePreferences(RoundUpPreferences newPrefs) async {
    setState(() {
      _isLoading = true;
    });

    final result = await _settingsService.updateRoundUpPreferences(newPrefs);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${failure.message}')),
        );
      },
      (_) {
        setState(() {
          _preferences = newPrefs;
        });
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Round-Up Savings'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.blue.shade600,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Automatic Round-Up Savings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Round up your purchases to the nearest dollar and automatically save the difference',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.blue.shade700,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Enable/Disable Toggle
                  Card(
                    child: SwitchListTile(
                      title: const Text(
                        'Enable Round-Up Savings',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _preferences.isEnabled 
                          ? 'Automatically round up your transactions'
                          : 'Round-up savings is disabled',
                      ),
                      value: _preferences.isEnabled,
                      onChanged: (value) {
                        _updatePreferences(_preferences.copyWith(isEnabled: value));
                      },
                      activeColor: Colors.green,
                    ),
                  ),

                  if (_preferences.isEnabled) ...[
                    const SizedBox(height: 16),

                    // Round-Up Strategy
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Round-Up Strategy',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _buildStrategyOption(
                              RoundUpStrategy.nearestDollar,
                              'Nearest Dollar',
                              'Round \$4.25 up to \$5.00 (save \$0.75)',
                            ),
                            _buildStrategyOption(
                              RoundUpStrategy.nearestFive,
                              'Nearest \$5',
                              'Round \$12.30 up to \$15.00 (save \$2.70)',
                            ),
                            _buildStrategyOption(
                              RoundUpStrategy.nearestTen,
                              'Nearest \$10',
                              'Round \$23.40 up to \$30.00 (save \$6.60)',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Round-Up Limits
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Round-Up Limits',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildLimitInput(
                                    'Minimum',
                                    _preferences.minimumRoundUp,
                                    (value) => _updatePreferences(
                                      _preferences.copyWith(minimumRoundUp: value),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildLimitInput(
                                    'Maximum',
                                    _preferences.maximumRoundUp,
                                    (value) => _updatePreferences(
                                      _preferences.copyWith(maximumRoundUp: value),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Goal Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Default Savings Goal',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Consumer<SavingGoalNotifier>(
                              builder: (context, notifier, child) {
                                return _buildGoalSelector(notifier.goals.toList());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Additional Options
                    Card(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Expenses Only'),
                            subtitle: const Text('Only apply round-up to expense transactions'),
                            value: _preferences.onlyOnExpenses,
                            onChanged: (value) {
                              _updatePreferences(_preferences.copyWith(onlyOnExpenses: value));
                            },
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text('Auto-Select Goal'),
                            subtitle: const Text('Automatically choose a goal if none is set'),
                            value: _preferences.autoSelectGoal,
                            onChanged: (value) {
                              _updatePreferences(_preferences.copyWith(autoSelectGoal: value));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Round-Up History Button
                  Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.history,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Round-Up History',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: const Text('View your round-up transactions and statistics'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pushNamed(context, '/round-up-history');
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildStrategyOption(RoundUpStrategy strategy, String title, String example) {
    return RadioListTile<RoundUpStrategy>(
      title: Text(title),
      subtitle: Text(
        example,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      value: strategy,
      groupValue: _preferences.strategy,
      onChanged: (value) {
        if (value != null) {
          _updatePreferences(_preferences.copyWith(strategy: value));
        }
      },
      dense: true,
    );
  }

  Widget _buildLimitInput(String label, double currentValue, Function(double) onChanged) {
    final controller = TextEditingController(text: currentValue.toStringAsFixed(2));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: '\$',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            isDense: true,
          ),
          onFieldSubmitted: (value) {
            final parsedValue = double.tryParse(value);
            if (parsedValue != null && parsedValue >= 0) {
              onChanged(parsedValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildGoalSelector(List<dynamic> goals) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _preferences.defaultGoalId,
          hint: const Text('Select a goal for round-up savings'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Auto-select goal'),
            ),
            ...goals.map((goal) => DropdownMenuItem<int?>(
              value: goal.id,
              child: Text(goal.title),
            )),
          ],
          onChanged: (goalId) {
            _updatePreferences(_preferences.copyWith(defaultGoalId: goalId));
          },
        ),
      ),
    );
  }
}