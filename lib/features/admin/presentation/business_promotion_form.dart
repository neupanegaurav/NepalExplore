import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:nepal_explore/core/config/app_config.dart';
import 'package:nepal_explore/features/admin/presentation/location_picker_screen.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';

class BusinessPromotionFormScreen extends ConsumerStatefulWidget {
  const BusinessPromotionFormScreen({super.key});

  @override
  ConsumerState<BusinessPromotionFormScreen> createState() =>
      _BusinessPromotionFormScreenState();
}

class _BusinessPromotionFormScreenState
    extends ConsumerState<BusinessPromotionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _promotionMessageController = TextEditingController();
  SpotCategory? _selectedCategory;
  String _selectedTier = 'Show in Featured (\$\$)';
  String _selectedPriceRange = '\$\$';
  LatLng? _selectedLocation;
  XFile? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _promotionMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Business')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reach More Tourists',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Submit your business details below to get listed in our local directory and map.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Business Description',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Name and Email Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _contactNameController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _contactEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty || !v.contains('@')
                          ? 'Valid email required'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedLocation == null
                        ? Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.5)
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: _selectedLocation == null
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (_selectedLocation != null)
                            Text(
                              '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            )
                          else
                            Text(
                              'Required',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () async {
                        final LatLng? picked = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LocationPickerScreen(),
                          ),
                        );
                        if (picked != null) {
                          setState(() => _selectedLocation = picked);
                        }
                      },
                      child: Text(
                        _selectedLocation == null ? 'Pick on Map' : 'Change',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<SpotCategory>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: SpotCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(
                            cat.name.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPriceRange,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      items: ['\$', '\$\$', '\$\$\$', '\$\$\$\$'].map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedPriceRange = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedTier,
                decoration: const InputDecoration(
                  labelText: 'Promotion Tier',
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                      'Standard Map Marker (Free)',
                      'Show in Featured (\$\$ / month)',
                      'Top of my List (\$\$\$ / month)',
                    ].map((tier) {
                      return DropdownMenuItem(value: tier, child: Text(tier));
                    }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTier = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _promotionMessageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Promotional Message to Tourists',
                  hintText: 'e.g., Show this app for 10% off!',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Photo Upload Mock
              InkWell(
                onTap: () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() => _selectedImage = image);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedImage == null
                            ? 'Upload Business Photo'
                            : _selectedImage!.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_selectedLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please pick a business location on the map.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (_formKey.currentState!.validate()) {
                            final selectedCategory = _selectedCategory;
                            if (selectedCategory == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please choose a category.'),
                                ),
                              );
                              return;
                            }

                            setState(() => _isSubmitting = true);
                            final newId = DateTime.now().millisecondsSinceEpoch
                                .toString();
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);

                            try {
                              await ref
                                  .read(spotsProvider.notifier)
                                  .submitSpot(
                                    TouristSpot(
                                      id: newId,
                                      name: _businessNameController.text.trim(),
                                      description: _descriptionController.text
                                          .trim(),
                                      location: _selectedLocation!,
                                      category: selectedCategory,
                                      imageUrl: AppConfig.fallbackSpotImageUrl(
                                        newId,
                                      ),
                                      status: ApprovalStatus.pending,
                                      priceRange: _selectedPriceRange,
                                      contactName: _contactNameController.text
                                          .trim(),
                                      contactPhone: _contactPhoneController.text
                                          .trim(),
                                      contactEmail: _contactEmailController.text
                                          .trim(),
                                      promotionalMessage:
                                          _promotionMessageController.text
                                              .trim(),
                                      promotionTier: _selectedTier,
                                      submissionKind: SubmissionKind.business,
                                    ),
                                    images: [?_selectedImage],
                                  );
                              if (!mounted) {
                                return;
                              }
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Your ${selectedCategory.name.toUpperCase()} request was submitted. The admin can review it on the web dashboard now.',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              navigator.pop();
                            } catch (error) {
                              if (!mounted) {
                                return;
                              }
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Submission failed: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          }
                        },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
