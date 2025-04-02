import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/location.dart';
import '../../services/location_service.dart';
import '../../services/upstash_config.dart';
import '../../widgets/loading_indicator.dart';

class LocationManagementScreen extends StatefulWidget {
  final String councilId;
  final String councilName;

  const LocationManagementScreen({
    Key? key,
    required this.councilId,
    required this.councilName,
  }) : super(key: key);

  @override
  State<LocationManagementScreen> createState() => _LocationManagementScreenState();
}

class _LocationManagementScreenState extends State<LocationManagementScreen> {
  final _locationService = LocationService(UpstashConfig.redis);
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Location> _locations = [];
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    try {
      final locations = await _locationService.getLocationsByCouncil(widget.councilId);
      setState(() {
        _locations = locations;
        if (_selectedType.isNotEmpty) {
          _locations = locations.where((l) => l.locationTypeId == _selectedType).toList();
        }
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _showAddEditLocationDialog([Location? location]) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: location?.name);
    final altNameController = TextEditingController(text: location?.altName);
    final codeController = TextEditingController(text: location?.code);
    String selectedType = location?.locationTypeId ?? Location.validLocationTypes.first;
    bool useLotNumber = location?.useLotNumber ?? false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location == null ? 'Add Location' : 'Edit Location'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    if (value.length > 100) {
                      return 'Name must be 100 characters or less';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: altNameController,
                  decoration: const InputDecoration(labelText: 'Alternative Name (Optional)'),
                  validator: (value) {
                    if (value != null && value.length > 100) {
                      return 'Alternative name must be 100 characters or less';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Code'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Code is required';
                    }
                    if (value.length > 20) {
                      return 'Code must be 20 characters or less';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Location Type'),
                  items: Location.validLocationTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(Location.locationTypeNames[type] ?? type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Use Lot Number for Addresses'),
                  value: useLotNumber,
                  onChanged: (value) {
                    useLotNumber = value;
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
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final now = DateTime.now();
                  final newLocation = Location(
                    id: location?.id ?? const Uuid().v4(),
                    name: nameController.text,
                    altName: altNameController.text.isEmpty ? null : altNameController.text,
                    code: codeController.text,
                    locationTypeId: selectedType,
                    councilId: widget.councilId,
                    useLotNumber: useLotNumber,
                    createdAt: location?.createdAt ?? now,
                    updatedAt: now,
                  );

                  if (location == null) {
                    await _locationService.createLocation(newLocation);
                  } else {
                    await _locationService.updateLocation(newLocation);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _loadLocations();
                  }
                } catch (e) {
                  if (mounted) {
                    _showError(e.toString());
                  }
                }
              }
            },
            child: Text(location == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Location location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text('Are you sure you want to delete ${location.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _locationService.deleteLocation(location.id);
        _loadLocations();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Widget _buildTypeFilter() {
    return DropdownButton<String>(
      value: _selectedType.isEmpty ? null : _selectedType,
      hint: const Text('Filter by Type'),
      items: [
        const DropdownMenuItem(
          value: '',
          child: Text('All Types'),
        ),
        ...Location.validLocationTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(Location.locationTypeNames[type] ?? type),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedType = value ?? '';
          if (_selectedType.isEmpty) {
            _loadLocations();
          } else {
            _locations = _locations.where((l) => l.locationTypeId == _selectedType).toList();
          }
        });
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search Locations',
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              if (_searchController.text.isNotEmpty) {
                setState(() => _isLoading = true);
                try {
                  final results = await _locationService.searchLocations(
                    widget.councilId,
                    _searchController.text,
                  );
                  setState(() {
                    _locations = results;
                    if (_selectedType.isNotEmpty) {
                      _locations = results.where((l) => l.locationTypeId == _selectedType).toList();
                    }
                  });
                } catch (e) {
                  _showError(e.toString());
                } finally {
                  setState(() => _isLoading = false);
                }
              }
            },
          ),
        ),
        onSubmitted: (_) async {
          if (_searchController.text.isNotEmpty) {
            setState(() => _isLoading = true);
            try {
              final results = await _locationService.searchLocations(
                widget.councilId,
                _searchController.text,
              );
              setState(() {
                _locations = results;
                if (_selectedType.isNotEmpty) {
                  _locations = results.where((l) => l.locationTypeId == _selectedType).toList();
                }
              });
            } catch (e) {
              _showError(e.toString());
            } finally {
              setState(() => _isLoading = false);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.councilName} - Locations'),
        actions: [
          _buildTypeFilter(),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_isLoading)
            const Expanded(child: LoadingIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: _locations.length,
                itemBuilder: (context, index) {
                  final location = _locations[index];
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (location.altName != null) Text('Alt: ${location.altName}'),
                        Text('Code: ${location.code}'),
                        Text('Type: ${Location.locationTypeNames[location.locationTypeId]}'),
                        Text('Use Lot Number: ${location.useLotNumber ? 'Yes' : 'No'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditLocationDialog(location),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(location),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditLocationDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 