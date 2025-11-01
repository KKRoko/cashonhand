import '../../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import '../../services/alert_preferences.dart';
import '../../theme/design_tokens.dart';

class AlertSettingsScreen extends StatefulWidget {
  const AlertSettingsScreen({super.key});

  @override
  State<AlertSettingsScreen> createState() => _AlertSettingsScreenState();
}

class _AlertSettingsScreenState extends State<AlertSettingsScreen> {
  late AlertPreferences _preferences;
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await AlertPreferences.load();
    setState(() {
      _preferences = prefs;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    await _preferences.save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert settings saved'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _hasChanges = false;
      });
    }
  }

  void _updatePreferences(AlertPreferences newPrefs) {
    setState(() {
      _preferences = newPrefs;
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _savePreferences,
              child: Text(
                'Save',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThresholdsSection(),
                  const SizedBox(height: 32),
                  _buildTogglesSection(),
                  const SizedBox(height: 32),
                  _buildPreviewSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildThresholdsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert Thresholds',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set when alerts should trigger based on spending percentage',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Warning threshold slider
        _buildThresholdSlider(
          label: 'Warning Threshold',
          value: _preferences.warningThreshold,
          color: DesignTokens.color('warning'),
          onChanged: (value) {
            _updatePreferences(_preferences.copyWith(warningThreshold: value));
          },
        ),
        const SizedBox(height: 24),

        // Critical threshold slider
        _buildThresholdSlider(
          label: 'Critical Threshold',
          value: _preferences.criticalThreshold,
          color: DesignTokens.color('error'),
          onChanged: (value) {
            _updatePreferences(_preferences.copyWith(criticalThreshold: value));
          },
        ),
      ],
    );
  }

  Widget _buildThresholdSlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    final percentage = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: 0.50,
            max: 1.50,
            divisions: 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTogglesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert Options',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        _buildToggle(
          title: 'Bucket-Level Alerts',
          subtitle: 'Show alerts for overall Needs/Wants/Savings buckets',
          value: _preferences.enableBucketAlerts,
          onChanged: (value) {
            _updatePreferences(_preferences.copyWith(enableBucketAlerts: value));
          },
        ),
        const Divider(height: 32),

        _buildToggle(
          title: 'Category-Level Alerts',
          subtitle: 'Show alerts for individual categories',
          value: _preferences.enableCategoryAlerts,
          onChanged: (value) {
            _updatePreferences(_preferences.copyWith(enableCategoryAlerts: value));
          },
        ),
        const Divider(height: 32),

        _buildToggle(
          title: 'Alert Banner',
          subtitle: 'Show alert banner at top of budget screen',
          value: _preferences.showAlertBanner,
          onChanged: (value) {
            _updatePreferences(_preferences.copyWith(showAlertBanner: value));
          },
        ),
        const Divider(height: 32),

        _buildToggle(
          title: 'Show Percentages',
          subtitle: 'Display percentages instead of dollar amounts in alerts',
          value: _preferences.showPercentage,
          onChanged: (value) {
            _updatePreferences(_preferences.copyWith(showPercentage: value));
          },
        ),
        const Divider(height: 32),

        _buildToggle(
          title: 'Income Variance Alerts',
          subtitle: 'Alert when actual income is significantly below budgeted income',
          value: _preferences.enableIncomeVarianceAlerts,
          onChanged: (value) {
            _updatePreferences(_preferences.copyWith(enableIncomeVarianceAlerts: value));
          },
        ),
      ],
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'With current settings:',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Warning at ${_preferences.warningPercentage}% spent',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '• Critical at ${_preferences.criticalPercentage}% spent',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (!_preferences.isValid) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignTokens.color('error').withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error,
                    color: DesignTokens.color('error'),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Warning threshold must be less than critical threshold',
                      style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.color('error'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
