import '../../theme/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/freezed/budget_template.dart';
import '../../services/budget_template_service.dart';
import '../../theme/design_tokens.dart';

class BudgetTemplateLibraryScreen extends StatefulWidget {
  const BudgetTemplateLibraryScreen({super.key});

  @override
  State<BudgetTemplateLibraryScreen> createState() =>
      _BudgetTemplateLibraryScreenState();
}

class _BudgetTemplateLibraryScreenState
    extends State<BudgetTemplateLibraryScreen> {
  final _templateService = GetIt.instance<BudgetTemplateService>();

  List<BudgetTemplate> _presetTemplates = [];
  List<BudgetTemplate> _customTemplates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final presetsResult = await _templateService.getPresetTemplates();
    final customResult = await _templateService.getCustomTemplates();

    presetsResult.fold(
      (failure) {
        setState(() {
          _error = 'Failed to load templates: ${failure.message}';
          _isLoading = false;
        });
      },
      (presets) {
        customResult.fold(
          (failure) {
            setState(() {
              _error = 'Failed to load custom templates: ${failure.message}';
              _isLoading = false;
            });
          },
          (custom) {
            setState(() {
              _presetTemplates = presets;
              _customTemplates = custom;
              _isLoading = false;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Templates'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: TextStyle(color: DesignTokens.color('error'))),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTemplates,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_presetTemplates.isNotEmpty) ...[
                        Text(
                          'Preset Templates',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose from professionally crafted budget templates',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...presetTemplates.map(
                            (template) => _buildTemplateCard(template, true)),
                        const SizedBox(height: 32),
                      ],
                      if (_customTemplates.isNotEmpty) ...[
                        Text(
                          'My Templates',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your custom budget templates',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._customTemplates.map(
                            (template) => _buildTemplateCard(template, false)),
                      ] else if (_presetTemplates.isNotEmpty) ...[
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.library_add_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No custom templates yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create your own templates from your budgets',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildTemplateCard(BudgetTemplate template, bool isPreset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => _showTemplateDetails(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                template.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isPreset) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'PRESET',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.percentageDisplay,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                template.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPercentagePill('Needs', template.needsPercentage,
                      Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  _buildPercentagePill('Wants', template.wantsPercentage,
                      DesignTokens.color('info')),
                  const SizedBox(width: 8),
                  _buildPercentagePill('Savings', template.savingsPercentage,
                      DesignTokens.color('warning')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPercentagePill(String label, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label ${(percentage * 100).toInt()}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showTemplateDetails(BudgetTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplateDetailsSheet(
        template: template,
        onApply: () {
          Navigator.pop(context);
          Navigator.pop(
              context, template); // Return template to previous screen
        },
        onDelete: template.isPreset
            ? null
            : () async {
                final confirmed = await _showDeleteConfirmation(template);
                if (confirmed == true && context.mounted) {
                  Navigator.pop(context);
                  await _deleteTemplate(template);
                }
              },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BudgetTemplate template) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: DesignTokens.color('error')),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTemplate(BudgetTemplate template) async {
    if (template.id == null) return;

    final result = await _templateService.deleteTemplate(template.id!);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete template: ${failure.message}'),
              backgroundColor: DesignTokens.color('error'),
            ),
          );
        }
      },
      (success) {
        if (success) {
          _loadTemplates(); // Reload the list
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Template deleted')),
            );
          }
        }
      },
    );
  }

  List<BudgetTemplate> get presetTemplates => _presetTemplates;
}

class _TemplateDetailsSheet extends StatelessWidget {
  final BudgetTemplate template;
  final VoidCallback onApply;
  final VoidCallback? onDelete;

  const _TemplateDetailsSheet({
    required this.template,
    required this.onApply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    template.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (template.isPreset) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'PRESET TEMPLATE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              template.description,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Budget Allocation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _buildAllocationRow(context, 'Needs', template.needsPercentage,
                Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            _buildAllocationRow(context, 'Wants', template.wantsPercentage,
                DesignTokens.color('info')),
            const SizedBox(height: 12),
            _buildAllocationRow(context, 'Savings', template.savingsPercentage,
                DesignTokens.color('warning')),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Use This Template',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: DesignTokens.color('error'),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Delete Template'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationRow(
      BuildContext context, String label, double percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          '${(percentage * 100).toInt()}%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
