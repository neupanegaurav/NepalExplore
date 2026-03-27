import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nepal_explore/core/layout/adaptive_layout.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/core/theme/theme.dart';

class AddSpotScreen extends ConsumerStatefulWidget {
  const AddSpotScreen({super.key});

  @override
  ConsumerState<AddSpotScreen> createState() => _AddSpotScreenState();
}

class _AddSpotScreenState extends ConsumerState<AddSpotScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  SpotCategory _category = SpotCategory.historicalSites;
  LatLng? _selectedLocation;
  final List<XFile> _selectedImages = [];
  final MapController _miniMapController = MapController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Post New Spot')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useTabletLayout = AppAdaptiveLayout.useTabletLayout(
            context,
            width: constraints.maxWidth,
          );

          return SingleChildScrollView(
            child: ResponsiveContent(
              maxWidth: AppAdaptiveLayout.contentMaxWidthFor(
                constraints.maxWidth,
              ),
              child: Form(
                key: _formKey,
                child: useTabletLayout
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeaderCard(theme),
                                const SizedBox(height: 24),
                                _buildBasicDetailsSection(theme),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLocationSection(theme),
                                const SizedBox(height: 24),
                                _buildImageSection(theme),
                                const SizedBox(height: 28),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeaderCard(theme),
                          const SizedBox(height: 24),
                          _buildBasicDetailsSection(theme),
                          const SizedBox(height: 24),
                          _buildLocationSection(theme),
                          const SizedBox(height: 24),
                          _buildImageSection(theme),
                          const SizedBox(height: 28),
                          _buildSubmitButton(),
                          const SizedBox(height: 24),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_location_alt,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Share a Hidden Gem!', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Help travelers discover Nepal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicDetailsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Spot Name',
            prefixIcon: Icon(Icons.place),
          ),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Please enter a name' : null,
          onSaved: (value) => _name = value!,
        ),
        const SizedBox(height: 14),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Description',
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
          validator: (value) => (value == null || value.isEmpty)
              ? 'Please enter a description'
              : null,
          onSaved: (value) => _description = value!,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<SpotCategory>(
          initialValue: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category),
          ),
          items: SpotCategory.values
              .where((category) {
                return category != SpotCategory.hotels &&
                    category != SpotCategory.dining &&
                    category != SpotCategory.touristAgents &&
                    category != SpotCategory.tickets &&
                    category != SpotCategory.guides;
              })
              .map((category) {
                final label = category.name.replaceAll(
                  RegExp(r'(?<!^)(?=[A-Z])'),
                  ' ',
                );
                return DropdownMenuItem(
                  value: category,
                  child: Text(label[0].toUpperCase() + label.substring(1)),
                );
              })
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _category = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tap to set location', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          height: 220,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: FlutterMap(
            mapController: _miniMapController,
            options: MapOptions(
              initialCenter: LatLng(28.3949, 84.1240),
              initialZoom: 7.0,
              onTap: (_, latlng) => setState(() => _selectedLocation = latlng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.nepal_explore',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.accentRed,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Images (up to 5)', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: _selectedImages.isEmpty ? 100 : null,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
            ),
            child: _selectedImages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 28,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap to add photos',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedImages.map((image) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 24),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton.icon(
      onPressed: _isSubmitting ? null : _submitSpot,
      icon: _isSubmitting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.send),
      label: Text(
        _isSubmitting ? 'Submitting...' : 'Submit for Review',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(limit: 5);
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(images.take(5));
      });
    }
  }

  Future<void> _submitSpot() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please tap the map to set a location'),
            backgroundColor: AppTheme.accentOrange,
          ),
        );
        return;
      }
      _formKey.currentState!.save();
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() => _isSubmitting = true);
      try {
        await ref
            .read(spotsProvider.notifier)
            .submitSpot(
              TouristSpot(
                id: newId,
                name: _name,
                description: _description,
                location: _selectedLocation!,
                category: _category,
                imageUrl: '',
                status: ApprovalStatus.pending,
              ),
              images: _selectedImages,
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submitted for review!'),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
        _formKey.currentState!.reset();
        setState(() {
          _name = '';
          _description = '';
          _category = SpotCategory.historicalSites;
          _selectedLocation = null;
          _selectedImages.clear();
        });
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Submission failed: $error'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }
}
