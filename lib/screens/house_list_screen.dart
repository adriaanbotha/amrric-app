import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/council.dart';
import 'package:amrric_app/models/location.dart';
import 'package:amrric_app/models/house.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/services/house_service.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/screens/house_detail_screen.dart';
import 'package:amrric_app/widgets/loading_indicator.dart';
import 'package:amrric_app/widgets/error_display.dart';

class HouseListScreen extends ConsumerStatefulWidget {
  final Council council;
  final Location community;
  final UserRole userRole;

  const HouseListScreen({
    super.key,
    required this.council,
    required this.community,
    required this.userRole,
  });

  @override
  ConsumerState<HouseListScreen> createState() => _HouseListScreenState();
}

class _HouseListScreenState extends ConsumerState<HouseListScreen> {
  List<House> _houses = [];
  List<House> _filteredHouses = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHouses();
    _searchController.addListener(_filterHouses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHouses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final houseService = HouseService();
      final houses = await houseService.getHousesByLocation(widget.community.id);
      
      setState(() {
        _houses = houses.where((house) => house.isActive).toList();
        _filteredHouses = _houses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterHouses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredHouses = _houses.where((house) {
        return house.fullAddress.toLowerCase().contains(query) ||
               (house.description?.toLowerCase().contains(query) ?? false) ||
               house.houseNumber?.toLowerCase().contains(query) == true ||
               house.streetName?.toLowerCase().contains(query) == true;
      }).toList();
    });
  }

  void _selectHouse(House house) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HouseDetailScreen(
          house: house,
          userRole: widget.userRole,
        ),
      ),
    );
  }

  void _showAddHouseDialog() {
    showDialog(
      context: context,
      builder: (context) => _HouseDialog(
        community: widget.community,
        council: widget.council,
        onHouseAdded: () {
          _loadHouses();
        },
      ),
    );
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
        appBar: AppBar(
          title: Text('Houses - ${widget.community.name}'),
        ),
        body: ErrorDisplay(
          error: _error!,
          onRetry: _loadHouses,
        ),
      );
    }

    final userRoleTitle = widget.userRole == UserRole.veterinaryUser 
        ? 'Veterinary Services' 
        : 'Census Data Collection';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.community.name,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              userRoleTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(Icons.business, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.council.name,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.community.name,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  'Houses',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search houses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Houses list
          Expanded(
            child: _filteredHouses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No houses found'),
                        SizedBox(height: 8),
                        Text('Tap the + button to add a house'),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadHouses,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredHouses.length,
                      itemBuilder: (context, index) {
                        final house = _filteredHouses[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(
                                Icons.home,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              house.fullAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                if (house.description != null)
                                  Text('Description: ${house.description}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    FutureBuilder<int>(
                                      future: _getAnimalCount(house.id),
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data ?? 0} animals',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                if (house.latitude != null && house.longitude != null)
                                  const SizedBox(height: 4),
                                if (house.latitude != null && house.longitude != null)
                                  Text(
                                    'GPS: ${house.latitude!.toStringAsFixed(4)}, ${house.longitude!.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _selectHouse(house),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHouseDialog,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<int> _getAnimalCount(String houseId) async {
    try {
      final animalService = ref.read(animalsProvider.notifier);
      final animals = await animalService.getAnimals();
      return animals.where((animal) => animal.houseId == houseId).length;
    } catch (e) {
      return 0;
    }
  }
}

class _HouseDialog extends StatefulWidget {
  final Location community;
  final Council council;
  final VoidCallback onHouseAdded;

  const _HouseDialog({
    required this.community,
    required this.council,
    required this.onHouseAdded,
  });

  @override
  State<_HouseDialog> createState() => _HouseDialogState();
}

class _HouseDialogState extends State<_HouseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _houseNumberController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _suburbController = TextEditingController();
  final _postcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void dispose() {
    _houseNumberController.dispose();
    _streetNameController.dispose();
    _suburbController.dispose();
    _postcodeController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _saveHouse() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final house = House(
        id: 'house_${DateTime.now().millisecondsSinceEpoch}',
        locationId: widget.community.id,
        councilId: widget.council.id,
        houseNumber: _houseNumberController.text.isEmpty ? null : _houseNumberController.text,
        streetName: _streetNameController.text.isEmpty ? null : _streetNameController.text,
        suburb: _suburbController.text.isEmpty ? null : _suburbController.text,
        postcode: _postcodeController.text.isEmpty ? null : _postcodeController.text,
        latitude: _latitudeController.text.isEmpty ? null : double.tryParse(_latitudeController.text),
        longitude: _longitudeController.text.isEmpty ? null : double.tryParse(_longitudeController.text),
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final houseService = HouseService();
      await houseService.createHouse(house);

      if (mounted) {
        Navigator.pop(context);
        widget.onHouseAdded();
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New House'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _houseNumberController,
                decoration: const InputDecoration(
                  labelText: 'House Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetNameController,
                decoration: const InputDecoration(
                  labelText: 'Street Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _suburbController,
                decoration: const InputDecoration(
                  labelText: 'Suburb',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postcodeController,
                decoration: const InputDecoration(
                  labelText: 'Postcode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
          onPressed: _saveHouse,
          child: const Text('Save'),
        ),
      ],
    );
  }
} 