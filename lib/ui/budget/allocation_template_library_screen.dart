import 'package:flutter/material.dart';
import '../../core/di/injection.dart';
import '../../data/models/enums/bucket_type.dart';
import '../../data/models/freezed/allocation_template.dart';
import '../../data/models/freezed/allocation_template_item.dart';
import '../../services/allocation_template_service.dart';
import '../../state/budget_notifier.dart';
import '../../theme/design_tokens.dart';

class AllocationTemplateLibraryScreen extends StatefulWidget {
  const AllocationTemplateLibraryScreen({super.key});

  @override
  State<AllocationTemplateLibraryScreen> createState() =>
      _AllocationTemplateLibraryScreenState();
}

class _AllocationTemplateLibraryScreenState
    extends State<AllocationTemplateLibraryScreen> {
  final _budgetNotifier = getIt<BudgetNotifier>();

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

    await _budgetNotifier.loadTemplates();

    setState(() {
      _isLoading = false;
      if (_budgetNotifier.error != null) {
        _error = _budgetNotifier.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocation Templates'),
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
                      Text(
                        _error!,
                        style: TextStyle(color: DesignTokens.color('error')),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTemplates,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _budgetNotifier.templates.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.library_add_outlined,
                              size: 80,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Allocation Templates',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Save your category allocations as templates for quick reuse',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'To create a template:\n1. Go to Budget Screen\n2. Allocate to Categories\n3. Tap "Save Allocation Template"',
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
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _budgetNotifier.templates.length,
                      itemBuilder: (context, index) {
                        final template = _budgetNotifier.templates[index];
                        return _buildTemplateCard(template);
                      },
                    ),
    );
  }

  Widget _buildTemplateCard(AllocationTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadius['md']!),
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: () => _showTemplateDetails(template),
        borderRadius: DesignTokens.borderRadius['md']!,
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
                        Text(
                          template.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: \$${template.totalAmount.toStringAsFixed(2)}',
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
              if (template.description != null &&
                  template.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  template.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Created ${_formatDate(template.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }

  void _showTemplateDetails(AllocationTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplateDetailsSheet(
        template: template,
        budgetNotifier: _budgetNotifier,
        onApply: () {
          Navigator.pop(context);
          Navigator.pop(
              context, template.id); // Return template ID to budget screen
        },
        onDelete: () async {
          final confirmed = await _showDeleteConfirmation(template);
          if (confirmed == true && context.mounted) {
            Navigator.pop(context);
            await _deleteTemplate(template);
          }
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(AllocationTemplate template) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Delete Template',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${template.name}"?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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

  Future<void> _deleteTemplate(AllocationTemplate template) async {
    final success = await _budgetNotifier.deleteTemplate(template.id);

    if (success) {
      await _loadTemplates(); // Reload the list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Template deleted'),
            backgroundColor: DesignTokens.color('success'),
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to delete template: ${_budgetNotifier.error ?? "Unknown error"}'),
          backgroundColor: DesignTokens.color('error'),
        ),
      );
    }
  }
}

class _TemplateDetailsSheet extends StatefulWidget {
  final AllocationTemplate template;
  final BudgetNotifier budgetNotifier;
  final VoidCallback onApply;
  final VoidCallback onDelete;

  const _TemplateDetailsSheet({
    required this.template,
    required this.budgetNotifier,
    required this.onApply,
    required this.onDelete,
  });

  @override
  State<_TemplateDetailsSheet> createState() => _TemplateDetailsSheetState();
}

class _TemplateDetailsSheetState extends State<_TemplateDetailsSheet> {
  List<AllocationTemplateItem>? _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplateItems();
  }

  Future<void> _loadTemplateItems() async {
    final templateService = getIt<AllocationTemplateService>();
    final result = await templateService.getTemplateItems(widget.template.id);

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      (items) {
        if (mounted) {
          setState(() {
            _items = items;
            _isLoading = false;
          });
        }
      },
    );
  }

  Color _getBucketColor(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return Theme.of(context).colorScheme.primary;
      case BucketType.wants:
        return DesignTokens.color('info');
      case BucketType.savings:
        return DesignTokens.color('warning');
    }
  }

  String _getBucketLabel(BucketType bucket) {
    switch (bucket) {
      case BucketType.needs:
        return 'Needs';
      case BucketType.wants:
        return 'Wants';
      case BucketType.savings:
        return 'Savings';
    }
  }

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
                    widget.template.name,
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
            const SizedBox(height: 8),
            Text(
              'Total: \$${widget.template.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (widget.template.description != null &&
                widget.template.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                widget.template.description!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Category Allocations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_items == null || _items!.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No categories in this template',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ..._buildCategoryGroups(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: DesignTokens.borderRadius['md']!,
                  ),
                ),
                child: const Text(
                  'Use This Template',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: widget.onDelete,
                style: TextButton.styleFrom(
                  foregroundColor: DesignTokens.color('error'),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Delete Template'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryGroups() {
    if (_items == null) return [];

    // Group items by bucket type
    final needs =
        _items!.where((item) => item.bucketType == BucketType.needs).toList();
    final wants =
        _items!.where((item) => item.bucketType == BucketType.wants).toList();
    final savings =
        _items!.where((item) => item.bucketType == BucketType.savings).toList();

    final widgets = <Widget>[];

    if (needs.isNotEmpty) {
      widgets.add(_buildBucketSection(BucketType.needs, needs));
      widgets.add(const SizedBox(height: 16));
    }

    if (wants.isNotEmpty) {
      widgets.add(_buildBucketSection(BucketType.wants, wants));
      widgets.add(const SizedBox(height: 16));
    }

    if (savings.isNotEmpty) {
      widgets.add(_buildBucketSection(BucketType.savings, savings));
    }

    return widgets;
  }

  Widget _buildBucketSection(
      BucketType bucket, List<AllocationTemplateItem> items) {
    final total =
        items.fold<double>(0.0, (sum, item) => sum + item.allocatedAmount);

    return Container(
      decoration: BoxDecoration(
        color: _getBucketColor(bucket).withOpacity(0.1),
        borderRadius: DesignTokens.borderRadius['md']!,
        border: Border.all(
          color: _getBucketColor(bucket).withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getBucketColor(bucket),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getBucketLabel(bucket),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getBucketColor(bucket),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        item.categoryName ?? 'Unknown Category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      '\$${item.allocatedAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
