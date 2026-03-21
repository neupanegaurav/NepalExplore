import 'package:flutter/material.dart';
import 'package:nepal_explore/features/spots/domain/tourist_spot.dart';
import 'package:latlong2/latlong.dart';
import 'package:nepal_explore/features/admin/presentation/location_picker_screen.dart';

class BusinessPromotionFormScreen extends StatefulWidget {
  const BusinessPromotionFormScreen({super.key});

  @override
  State<BusinessPromotionFormScreen> createState() => _BusinessPromotionFormScreenState();
}

class _BusinessPromotionFormScreenState extends State<BusinessPromotionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  SpotCategory? _selectedCategory;
  String _selectedTier = 'Show in Featured (\$\$)';
  String _selectedPriceRange = '\$\$';
  LatLng? _selectedLocation;

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
              Text('Reach More Tourists', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Submit your business details below to get listed in our local directory and map.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Name and Email Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Contact Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Contact Email', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contact Phone Number', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _selectedLocation == null ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5) : Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: _selectedLocation == null ? Colors.red : Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Business Location', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                          if (_selectedLocation != null)
                            Text('${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}', style: Theme.of(context).textTheme.bodySmall)
                          else
                            Text('Required', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                        ],
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: () async {
                        final LatLng? picked = await Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationPickerScreen()));
                        if (picked != null) {
                          setState(() => _selectedLocation = picked);
                        }
                      },
                      child: Text(_selectedLocation == null ? 'Pick on Map' : 'Change'),
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
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: SpotCategory.values.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat.name.toUpperCase(), overflow: TextOverflow.ellipsis));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriceRange,
                      decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                      items: ['\$', '\$\$', '\$\$\$', '\$\$\$\$'].map((p) {
                        return DropdownMenuItem(value: p, child: Text(p));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPriceRange = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTier,
                decoration: const InputDecoration(labelText: 'Promotion Tier', border: OutlineInputBorder()),
                items: [
                  'Standard Map Marker (Free)', 
                  'Show in Featured (\$\$ / month)', 
                  'Top of my List (\$\$\$ / month)'
                ].map((tier) {
                  return DropdownMenuItem(value: tier, child: Text(tier));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTier = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Promotional Message to Tourists', 
                  hintText: 'e.g., Show this app for 10% off!',
                  border: OutlineInputBorder()
                ),
              ),
              const SizedBox(height: 16),
              // Photo Upload Mock
              InkWell(
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image picker would open here.')));
                },
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      Text('Upload Business Photo', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                     if (_selectedLocation == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a business location on the map.'), backgroundColor: Colors.red));
                        return;
                     }
                     if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Our admin will contact you shortly for the process.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                        Navigator.pop(context);
                     }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Submit Request', style: TextStyle(fontSize: 16)),
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
