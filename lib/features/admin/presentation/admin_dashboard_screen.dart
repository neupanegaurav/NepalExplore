import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nepal_explore/features/admin/presentation/providers/admin_spots_controller.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';

enum AdminSpotFilter { all, pending, approved, rejected }

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  AdminSpotFilter _filter = AdminSpotFilter.pending;

  List<TouristSpot> _applyFilter(List<TouristSpot> spots) {
    switch (_filter) {
      case AdminSpotFilter.pending:
        return spots
            .where((spot) => spot.status == ApprovalStatus.pending)
            .toList();
      case AdminSpotFilter.approved:
        return spots
            .where((spot) => spot.status == ApprovalStatus.approved)
            .toList();
      case AdminSpotFilter.rejected:
        return spots
            .where((spot) => spot.status == ApprovalStatus.rejected)
            .toList();
      case AdminSpotFilter.all:
        return spots;
    }
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Action failed: $error')));
    }
  }

  Future<void> _showEditDialog(TouristSpot spot) async {
    final updatedSpot = await showDialog<TouristSpot>(
      context: context,
      builder: (context) => _EditSpotDialog(spot: spot),
    );

    if (updatedSpot == null) {
      return;
    }

    await _runAction(
      () =>
          ref.read(adminSpotsControllerProvider.notifier).saveSpot(updatedSpot),
      'Spot details saved.',
    );
  }

  Future<void> _refreshDashboard() async {
    final previousSpots = ref.read(adminSpotsControllerProvider).maybeWhen(
      data: (spots) => spots,
      orElse: () => const <TouristSpot>[],
    );
    final previousPendingIds = previousSpots
        .where((spot) => spot.status == ApprovalStatus.pending)
        .map((spot) => spot.id)
        .toSet();

    try {
      final refreshedSpots = await ref
          .read(adminSpotsControllerProvider.notifier)
          .refresh(showLoading: false);
      final newPendingSpots = refreshedSpots
          .where(
            (spot) =>
                spot.status == ApprovalStatus.pending &&
                !previousPendingIds.contains(spot.id),
          )
          .toList();

      if (!mounted) {
        return;
      }

      final message = newPendingSpots.isNotEmpty
          ? 'Found ${newPendingSpots.length} new pending submission${newPendingSpots.length == 1 ? '' : 's'}.'
          : 'No new pending submissions found. Dashboard is up to date.';

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Refresh failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = Supabase.instance.client.auth.currentUser;
    final spotsAsync = ref.watch(adminSpotsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
      body: spotsAsync.when(
        data: (spots) {
          final filteredSpots = _applyFilter(spots);
          final pendingCount = spots
              .where((spot) => spot.status == ApprovalStatus.pending)
              .length;
          final approvedCount = spots
              .where((spot) => spot.status == ApprovalStatus.approved)
              .length;
          final rejectedCount = spots
              .where((spot) => spot.status == ApprovalStatus.rejected)
              .length;

          return RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 260,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Signed in as',
                                style: theme.textTheme.labelLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentUser?.email ?? 'Unknown admin',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                        _AdminStatCard(
                          label: 'Pending',
                          value: pendingCount,
                          color: Colors.orange,
                        ),
                        _AdminStatCard(
                          label: 'Approved',
                          value: approvedCount,
                          color: Colors.green,
                        ),
                        _AdminStatCard(
                          label: 'Rejected',
                          value: rejectedCount,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final filter in AdminSpotFilter.values)
                      ChoiceChip(
                        label: Text(_filterLabel(filter)),
                        selected: _filter == filter,
                        onSelected: (_) => setState(() => _filter = filter),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (filteredSpots.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No submissions match the current filter.'),
                    ),
                  )
                else
                  ...filteredSpots.map(
                    (spot) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _AdminSpotCard(
                        spot: spot,
                        onApprove: () => _runAction(
                          () => ref
                              .read(adminSpotsControllerProvider.notifier)
                              .approveSpot(spot.id),
                          '${spot.name} approved.',
                        ),
                        onReject: () => _runAction(
                          () => ref
                              .read(adminSpotsControllerProvider.notifier)
                              .rejectSpot(spot.id),
                          '${spot.name} rejected.',
                        ),
                        onToggleFeatured: () => _runAction(
                          () => ref
                              .read(adminSpotsControllerProvider.notifier)
                              .toggleFeatured(spot.id, !spot.isFeatured),
                          spot.isFeatured
                              ? '${spot.name} removed from featured.'
                              : '${spot.name} marked as featured.',
                        ),
                        onDelete: () => _runAction(
                          () => ref
                              .read(adminSpotsControllerProvider.notifier)
                              .deleteSpot(spot.id),
                          '${spot.name} deleted.',
                        ),
                        onEdit: () => _showEditDialog(spot),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load submissions: $error'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _refreshDashboard,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _filterLabel(AdminSpotFilter filter) {
    switch (filter) {
      case AdminSpotFilter.all:
        return 'All';
      case AdminSpotFilter.pending:
        return 'Pending';
      case AdminSpotFilter.approved:
        return 'Approved';
      case AdminSpotFilter.rejected:
        return 'Rejected';
    }
  }
}

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _AdminSpotCard extends StatelessWidget {
  const _AdminSpotCard({
    required this.spot,
    required this.onApprove,
    required this.onReject,
    required this.onToggleFeatured,
    required this.onDelete,
    required this.onEdit,
  });

  final TouristSpot spot;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onToggleFeatured;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(spot.name, style: theme.textTheme.titleLarge),
                _StatusChip(status: spot.status),
                Chip(label: Text(spot.category.name)),
                Chip(label: Text(spot.submissionKind.storageKey)),
                if (spot.isFeatured) const Chip(label: Text('featured')),
              ],
            ),
            const SizedBox(height: 10),
            Text(spot.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  'Location: ${spot.location.latitude.toStringAsFixed(4)}, ${spot.location.longitude.toStringAsFixed(4)}',
                ),
                if (spot.priceRange != null) Text('Price: ${spot.priceRange}'),
                if (spot.contactName != null)
                  Text('Contact: ${spot.contactName}'),
                if (spot.contactPhone != null)
                  Text('Phone: ${spot.contactPhone}'),
                if (spot.contactEmail != null)
                  Text('Email: ${spot.contactEmail}'),
                if (spot.promotionTier != null)
                  Text('Tier: ${spot.promotionTier}'),
              ],
            ),
            if (spot.promotionalMessage != null &&
                spot.promotionalMessage!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Promo: ${spot.promotionalMessage}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Approve'),
                ),
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Reject'),
                ),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleFeatured,
                  icon: Icon(spot.isFeatured ? Icons.star_outline : Icons.star),
                  label: Text(spot.isFeatured ? 'Unfeature' : 'Feature'),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ApprovalStatus.pending => Colors.orange,
      ApprovalStatus.approved => Colors.green,
      ApprovalStatus.rejected => Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.name,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EditSpotDialog extends StatefulWidget {
  const _EditSpotDialog({required this.spot});

  final TouristSpot spot;

  @override
  State<_EditSpotDialog> createState() => _EditSpotDialogState();
}

class _EditSpotDialogState extends State<_EditSpotDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceRangeController;
  late final TextEditingController _contactNameController;
  late final TextEditingController _contactPhoneController;
  late final TextEditingController _contactEmailController;
  late final TextEditingController _promotionMessageController;
  late final TextEditingController _promotionTierController;
  late SpotCategory _category;
  late ApprovalStatus _status;
  late bool _isFeatured;

  @override
  void initState() {
    super.initState();
    final spot = widget.spot;
    _nameController = TextEditingController(text: spot.name);
    _descriptionController = TextEditingController(text: spot.description);
    _priceRangeController = TextEditingController(text: spot.priceRange ?? '');
    _contactNameController = TextEditingController(
      text: spot.contactName ?? '',
    );
    _contactPhoneController = TextEditingController(
      text: spot.contactPhone ?? '',
    );
    _contactEmailController = TextEditingController(
      text: spot.contactEmail ?? '',
    );
    _promotionMessageController = TextEditingController(
      text: spot.promotionalMessage ?? '',
    );
    _promotionTierController = TextEditingController(
      text: spot.promotionTier ?? '',
    );
    _category = spot.category;
    _status = spot.status;
    _isFeatured = spot.isFeatured;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceRangeController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _promotionMessageController.dispose();
    _promotionTierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit submission'),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SpotCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: SpotCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ApprovalStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ApprovalStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceRangeController,
                decoration: const InputDecoration(labelText: 'Price range'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contactNameController,
                decoration: const InputDecoration(labelText: 'Contact name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(labelText: 'Contact phone'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contactEmailController,
                decoration: const InputDecoration(labelText: 'Contact email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _promotionTierController,
                decoration: const InputDecoration(labelText: 'Promotion tier'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _promotionMessageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Promotional message',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isFeatured,
                onChanged: (value) => setState(() => _isFeatured = value),
                title: const Text('Featured'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              widget.spot.copyWith(
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                category: _category,
                status: _status,
                priceRange: _trimToNull(_priceRangeController.text),
                contactName: _trimToNull(_contactNameController.text),
                contactPhone: _trimToNull(_contactPhoneController.text),
                contactEmail: _trimToNull(_contactEmailController.text),
                promotionTier: _trimToNull(_promotionTierController.text),
                promotionalMessage: _trimToNull(
                  _promotionMessageController.text,
                ),
                isFeatured: _isFeatured,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String? _trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
