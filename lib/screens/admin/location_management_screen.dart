import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/location.dart';
import '../../models/location_type.dart';
import '../../models/council.dart';
import '../../services/location_service.dart';
import '../../services/council_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_display.dart';

class LocationManagementScreen extends ConsumerStatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  ConsumerState<LocationManagementScreen> createState() => _LocationManagementScreenState();
}

class _LocationManagementScreenState extends ConsumerState<LocationManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _altNameController = TextEditingController();
  final _codeController = TextEditingController();
  String? _selectedCouncilId;
  LocationType? _selectedLocationType;
  bool _useLotNumber = false;
  bool _isActive = true;
  String? _selectedFilter;

  @override
  void dispose() {
    _nameController.dispose();
    _altNameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _altNameController.clear();
    _codeController.clear();
    _selectedCouncilId = null;
    _selectedLocationType = null;
    _useLotNumber = false;
    _isActive = true;
  }

  void _showAddLocationDialog() {
    _resetForm();
    _showLocationDialog(isEdit: false);
  }

  void _showEditLocationDialog(Location location) {
    _nameController.text = location.name;
    _altNameController.text = location.altName ?? '';
    _codeController.text = location.code;
    _selectedCouncilId = location.councilId;
    _selectedLocationType = location.locationTypeId;
    _useLotNumber = location.useLotNumber;
    _isActive = location.isActive;
    _showLocationDialog(isEdit: true, location: location);
  }

  void _showLocationDialog({required bool isEdit, Location? location}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Community' : 'Add New Community'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Community Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a community name';
                    }
                    if (value.length > 100) {
                      return 'Community name must be less than 100 characters';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _altNameController,
                  decoration: const InputDecoration(labelText: 'Alternative Name (Optional)'),
                ),
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(labelText: 'Community Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a community code';
                    }
                    if (value.length > 10) {
                      return 'Community code must be less than 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, child) {
                    final councilsAsync = ref.watch(councilsProvider);
                    return councilsAsync.when(
                      data: (councils) => DropdownButtonFormField<String>(
                        value: _selectedCouncilId,
                        decoration: const InputDecoration(labelText: 'Council'),
                        items: councils.map((council) {
                          return DropdownMenuItem(
                            value: council.id,
                            child: Text(council.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCouncilId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a council';
                          }
                          return null;
                        },
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error loading councils: $error'),
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<LocationType>(
                  value: _selectedLocationType,
                  decoration: const InputDecoration(labelText: 'Location Type'),
                  items: LocationType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLocationType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a location type';
                    }
                    return null;
                  },
                ),
                SwitchListTile(
                  title: const Text('Use Lot Numbers'),
                  value: _useLotNumber,
                  onChanged: (value) {
                    setState(() {
                      _useLotNumber = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final locationService = ref.read(locationsProvider.notifier);
                final updatedLocation = Location.create().copyWith(
                  id: isEdit ? location!.id : null,
                  name: _nameController.text,
                  altName: _altNameController.text.isEmpty ? null : _altNameController.text,
                  code: _codeController.text,
                  locationTypeId: _selectedLocationType!,
                  councilId: _selectedCouncilId!,
                  useLotNumber: _useLotNumber,
                  isActive: _isActive,
                  createdAt: isEdit ? location!.createdAt : null,
                );

                try {
                  if (isEdit) {
                    await locationService.updateLocation(updatedLocation);
                  } else {
                    await locationService.addLocation(updatedLocation);
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'Community updated successfully' : 'Community added successfully'
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit ? 'Error updating community: $e' : 'Error adding community: $e'
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(locationsProvider);
    final councilsAsync = ref.watch(councilsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Management'),
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: _selectedFilter,
            hint: const Text('Filter by Type'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Types'),
              ),
              ...LocationType.values.map((type) {
                return DropdownMenuItem(
                  value: type.toString(),
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: locationsAsync.when(
        data: (locations) => councilsAsync.when(
          data: (councils) {
            if (councils.isEmpty) {
              return const Center(
                child: Text('No councils found. Please add a council first.'),
              );
            }

            // Filter locations based on selected type
            final filteredLocations = _selectedFilter == null
                ? locations
                : locations.where((loc) => 
                    loc.locationTypeId.toString() == _selectedFilter).toList();

            // Group locations by council
            final locationsByCouncil = <String, List<Location>>{};
            for (final location in filteredLocations) {
              final councilId = location.councilId;
              if (!locationsByCouncil.containsKey(councilId)) {
                locationsByCouncil[councilId] = [];
              }
              locationsByCouncil[councilId]!.add(location);
            }

            if (locationsByCouncil.isEmpty && _selectedFilter != null) {
              return Center(
                child: Text('No communities found for type: ${_selectedFilter!.split('.').last}'),
              );
            }

            if (locationsByCouncil.isEmpty) {
              return const Center(
                child: Text('No communities found. Click the + button to add one.'),
              );
            }

            return ListView.builder(
              itemCount: councils.length,
              itemBuilder: (context, index) {
                final council = councils[index];
                final councilLocations = locationsByCouncil[council.id] ?? [];

                return ExpansionTile(
                  title: Text(council.name),
                  subtitle: Text('${councilLocations.length} communities'),
                  children: councilLocations.map((location) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(location.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (location.altName != null)
                              Text('Also known as: ${location.altName}'),
                            Text('Type: ${location.locationTypeId.toString().split('.').last}'),
                            Text('Code: ${location.code}'),
                            Text('Lot Numbers: ${location.useLotNumber ? 'Yes' : 'No'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditLocationDialog(location),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Community'),
                                    content: Text(
                                      'Are you sure you want to delete ${location.name}?'
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  try {
                                    await ref.read(locationsProvider.notifier)
                                        .deleteLocation(location.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Community deleted successfully'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error deleting community: $e'),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading councils: $error'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading locations: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 