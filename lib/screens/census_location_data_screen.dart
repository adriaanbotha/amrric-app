import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/location.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/services/location_service.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/widgets/loading_indicator.dart';
import 'package:amrric_app/widgets/error_display.dart';
import 'dart:convert';

class CensusLocationDataScreen extends ConsumerStatefulWidget {
  const CensusLocationDataScreen({super.key});

  @override
  ConsumerState<CensusLocationDataScreen> createState() => _CensusLocationDataScreenState();
}

class _CensusLocationDataScreenState extends ConsumerState<CensusLocationDataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Location? _userLocation;
  List<Map<String, dynamic>> _houses = [];
  List<Animal> _locationAnimals = [];
  bool _isLoading = true;
  String? _error;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserLocationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserLocationData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      _currentUser = await authService.getCurrentUser();
      
      if (_currentUser?.locationId == null) {
        throw Exception('Census user must have an assigned location');
      }

      // Load location details
      final locationService = ref.read(locationsProvider.notifier);
      _userLocation = await locationService.getLocation(_currentUser!.locationId!);
      
      if (_userLocation == null) {
        throw Exception('Location not found');
      }

      // Load houses in this location
      await _loadHouses();
      
      // Load animals in this location
      await _loadLocationAnimals();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadHouses() async {
    try {
      final redis = UpstashConfig.redis;
      final houseKeys = await redis.keys('house:*');
      final houses = <Map<String, dynamic>>[];

      for (final key in houseKeys) {
        final houseData = await redis.hgetall(key);
        if (houseData != null && 
            houseData['locationId'] == _currentUser!.locationId) {
          houses.add(houseData.map((k, v) => MapEntry(k, v.toString())));
        }
      }

      setState(() {
        _houses = houses;
      });
    } catch (e) {
      debugPrint('Error loading houses: $e');
    }
  }

  Future<void> _loadLocationAnimals() async {
    try {
      final animalService = ref.read(animalsProvider.notifier);
      final allAnimals = await animalService.getAnimals();
      
      final locationAnimals = allAnimals.where((animal) => 
        animal.locationId == _currentUser!.locationId).toList();

      setState(() {
        _locationAnimals = locationAnimals;
      });
    } catch (e) {
      debugPrint('Error loading location animals: $e');
    }
  }

  Future<void> _addHouse() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _HouseDialog(),
    );

    if (result != null) {
      try {
        final redis = UpstashConfig.redis;
        final houseId = 'house_${DateTime.now().millisecondsSinceEpoch}';
        final houseData = {
          'id': houseId,
          'address': result['address'] ?? '',
          'lotNumber': result['lotNumber'] ?? '',
          'ownerName': result['ownerName'] ?? '',
          'ownerContact': result['ownerContact'] ?? '',
          'locationId': _currentUser!.locationId!,
          'councilId': _userLocation!.councilId,
          'gpsCoordinates': result['gpsCoordinates'] ?? '',
          'animalCount': '0',
          'notes': result['notes'] ?? '',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        await redis.hset('house:$houseId', houseData);
        await redis.sadd('houses', [houseId]);
        
        await _loadHouses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('House added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding house: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Location Data')),
        body: ErrorDisplay(
          error: _error!,
          onRetry: _loadUserLocationData,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Location: ${_userLocation?.name ?? 'Unknown'}'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.location_on), text: 'Location Info'),
            Tab(icon: Icon(Icons.home), text: 'Houses'),
            Tab(icon: Icon(Icons.pets), text: 'Animals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLocationInfoTab(),
          _buildHousesTab(),
          _buildAnimalsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _addHouse,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildLocationInfoTab() {
    if (_userLocation == null) {
      return const Center(child: Text('No location data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Name', _userLocation!.name),
                  if (_userLocation!.altName != null)
                    _buildInfoRow('Alternative Name', _userLocation!.altName!),
                  _buildInfoRow('Code', _userLocation!.code),
                  _buildInfoRow('Type', _userLocation!.locationTypeId.toString().split('.').last),
                  _buildInfoRow('Council ID', _userLocation!.councilId),
                  _buildInfoRow('Uses Lot Numbers', _userLocation!.useLotNumber ? 'Yes' : 'No'),
                  _buildInfoRow('Status', _userLocation!.isActive ? 'Active' : 'Inactive'),
                  _buildInfoRow('Created', _userLocation!.createdAt.toString().substring(0, 16)),
                  _buildInfoRow('Updated', _userLocation!.updatedAt.toString().substring(0, 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Census Statistics',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Total Houses', _houses.length.toString()),
                  _buildInfoRow('Total Animals', _locationAnimals.length.toString()),
                  _buildInfoRow('Dogs', _locationAnimals.where((a) => a.species.toLowerCase() == 'dog').length.toString()),
                  _buildInfoRow('Cats', _locationAnimals.where((a) => a.species.toLowerCase() == 'cat').length.toString()),
                  _buildInfoRow('Active Animals', _locationAnimals.where((a) => a.isActive).length.toString()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHousesTab() {
    return RefreshIndicator(
      onRefresh: _loadHouses,
      child: _houses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No houses found in this location'),
                  SizedBox(height: 8),
                  Text('Tap the + button to add a house'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _houses.length,
              itemBuilder: (context, index) {
                final house = _houses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.home),
                    ),
                    title: Text(house['address'] ?? 'No address'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (house['lotNumber']?.isNotEmpty == true)
                          Text('Lot: ${house['lotNumber']}'),
                        if (house['ownerName']?.isNotEmpty == true)
                          Text('Owner: ${house['ownerName']}'),
                        Text('Animals: ${house['animalCount'] ?? '0'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => _showHouseDetails(house),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAnimalsTab() {
    return RefreshIndicator(
      onRefresh: _loadLocationAnimals,
      child: _locationAnimals.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No animals found in this location'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _locationAnimals.length,
              itemBuilder: (context, index) {
                final animal = _locationAnimals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: animal.species.toLowerCase() == 'dog' 
                          ? Colors.blue : Colors.orange,
                      child: Icon(
                        animal.species.toLowerCase() == 'dog' 
                            ? Icons.pets : Icons.pets,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(animal.name ?? 'Unnamed ${animal.species}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${animal.species} • ${animal.sex} • Age: ${animal.estimatedAge ?? 'Unknown'}'),
                        Text('Color: ${animal.color} • House: ${animal.houseId}'),
                        if (!animal.isActive)
                          const Text('Inactive', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    trailing: Icon(
                      animal.isActive ? Icons.check_circle : Icons.cancel,
                      color: animal.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showHouseDetails(Map<String, dynamic> house) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('House Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Address', house['address'] ?? 'N/A'),
              _buildInfoRow('Lot Number', house['lotNumber'] ?? 'N/A'),
              _buildInfoRow('Owner', house['ownerName'] ?? 'N/A'),
              _buildInfoRow('Contact', house['ownerContact'] ?? 'N/A'),
              _buildInfoRow('GPS', house['gpsCoordinates'] ?? 'N/A'),
              _buildInfoRow('Animal Count', house['animalCount'] ?? '0'),
              if (house['notes']?.isNotEmpty == true)
                _buildInfoRow('Notes', house['notes']),
              _buildInfoRow('Created', house['createdAt'] ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _HouseDialog extends StatefulWidget {
  @override
  State<_HouseDialog> createState() => _HouseDialogState();
}

class _HouseDialogState extends State<_HouseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _lotNumberController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _ownerContactController = TextEditingController();
  final _gpsController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _lotNumberController.dispose();
    _ownerNameController.dispose();
    _ownerContactController.dispose();
    _gpsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New House'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  hintText: 'e.g., 123 Main Street',
                ),
                validator: (value) {
                  if (value?.isEmpty == true) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lotNumberController,
                decoration: const InputDecoration(
                  labelText: 'Lot Number (Optional)',
                  hintText: 'e.g., Lot 45',
                ),
              ),
              TextFormField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name (Optional)',
                  hintText: 'e.g., John Smith',
                ),
              ),
              TextFormField(
                controller: _ownerContactController,
                decoration: const InputDecoration(
                  labelText: 'Owner Contact (Optional)',
                  hintText: 'e.g., phone or email',
                ),
              ),
              TextFormField(
                controller: _gpsController,
                decoration: const InputDecoration(
                  labelText: 'GPS Coordinates (Optional)',
                  hintText: 'e.g., -12.4634, 130.8456',
                ),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Any additional information',
                ),
                maxLines: 3,
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
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              Navigator.pop(context, {
                'address': _addressController.text,
                'lotNumber': _lotNumberController.text,
                'ownerName': _ownerNameController.text,
                'ownerContact': _ownerContactController.text,
                'gpsCoordinates': _gpsController.text,
                'notes': _notesController.text,
              });
            }
          },
          child: const Text('Add House'),
        ),
      ],
    );
  }
} 