import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/house.dart';
import '../providers/house_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class HouseManagementScreen extends ConsumerStatefulWidget {
  const HouseManagementScreen({super.key});

  @override
  ConsumerState<HouseManagementScreen> createState() => _HouseManagementScreenState();
}

class _HouseManagementScreenState extends ConsumerState<HouseManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCouncil;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
    // Load initial data after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(housesProvider.notifier).loadHouses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddHouseDialog() {
    showDialog(
      context: context,
      builder: (context) => _HouseDialog(
        onSave: (house) async {
          try {
            await ref.read(housesProvider.notifier).createHouse(house);
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('House added successfully')),
              );
            }
          } catch (e) {
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding house: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditHouseDialog(House house) {
    showDialog(
      context: context,
      builder: (context) => _HouseDialog(
        house: house,
        onSave: (updatedHouse) async {
          try {
            await ref.read(housesProvider.notifier).updateHouse(updatedHouse);
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('House updated successfully')),
              );
            }
          } catch (e) {
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating house: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteHouse(House house) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete House'),
        content: Text('Are you sure you want to delete ${house.fullAddress.isNotEmpty ? house.fullAddress : 'this house'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(housesProvider.notifier).deleteHouse(house.id);
                if (mounted && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('House deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting house: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseList(List<House> houses) {
    final filteredHouses = houses.where((house) {
      final matchesSearch = house.fullAddress.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          house.description?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
      final matchesCouncil = _selectedCouncil == null || house.councilId == _selectedCouncil;
      final matchesLocation = _selectedLocation == null || house.locationId == _selectedLocation;
      return matchesSearch && matchesCouncil && matchesLocation;
    }).toList();

    if (filteredHouses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No houses found'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredHouses.length,
      itemBuilder: (context, index) {
        final house = filteredHouses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.home),
            ),
            title: Text(house.fullAddress.isNotEmpty ? house.fullAddress : 'No address'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (house.description != null) Text('${house.description}'),
                Text('Location: ${house.locationId}'),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showHouseDetails(house);
                    break;
                  case 'edit':
                    _showEditHouseDialog(house);
                    break;
                  case 'delete':
                    _deleteHouse(house);
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return ref.watch(houseStatisticsProvider).when(
          data: (statistics) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatisticCard(
                'Total Houses',
                statistics['totalHouses']?.toString() ?? '0',
                Icons.home,
              ),
              _buildStatisticCard(
                'Active Houses',
                statistics['activeHouses']?.toString() ?? '0',
                Icons.check_circle,
              ),
              _buildStatisticCard(
                'Houses with GPS',
                statistics['housesWithCoordinates']?.toString() ?? '0',
                Icons.location_on,
              ),
              _buildStatisticCard(
                'Average Houses per Location',
                statistics['averageHousesPerLocation']?.toString() ?? '0',
                Icons.analytics,
              ),
            ],
          ),
          loading: () => const LoadingIndicator(),
          error: (error, stack) => ErrorDisplay(
            error: error.toString(),
            onRetry: () => ref.refresh(houseStatisticsProvider),
          ),
        );
  }

  Widget _buildStatisticCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHouseDetails(House house) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('House Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Full Address', house.fullAddress.isNotEmpty ? house.fullAddress : 'No address'),
              if (house.houseNumber != null)
                _buildDetailRow('House Number', house.houseNumber!),
              if (house.streetName != null)
                _buildDetailRow('Street Name', house.streetName!),
              if (house.suburb != null)
                _buildDetailRow('Suburb', house.suburb!),
              if (house.postcode != null)
                _buildDetailRow('Postcode', house.postcode!),
              _buildDetailRow('Location ID', house.locationId),
              _buildDetailRow('Council ID', house.councilId),
              if (house.latitude != null && house.longitude != null)
                _buildDetailRow('GPS', '${house.latitude}, ${house.longitude}'),
              _buildDetailRow('Created', house.createdAt.toString()),
              _buildDetailRow('Updated', house.updatedAt.toString()),
              if (house.description != null && house.description!.isNotEmpty)
                _buildDetailRow('Description', house.description!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Management'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Houses'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_tabController.index == 0)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search houses...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Houses Tab
                ref.watch(housesProvider).when(
                      data: (houses) => _buildHouseList(houses),
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => ErrorDisplay(
                        error: error.toString(),
                        onRetry: () => ref.refresh(housesProvider),
                      ),
                    ),
                // Statistics Tab
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddHouseDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _HouseDialog extends StatefulWidget {
  final House? house;
  final Function(House) onSave;

  const _HouseDialog({
    this.house,
    required this.onSave,
  });

  @override
  State<_HouseDialog> createState() => _HouseDialogState();
}

class _HouseDialogState extends State<_HouseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _houseNumberController;
  late TextEditingController _streetNameController;
  late TextEditingController _suburbController;
  late TextEditingController _postcodeController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _descriptionController;
  late String _locationId;
  late String _councilId;

  @override
  void initState() {
    super.initState();
    final house = widget.house;
    _houseNumberController = TextEditingController(text: house?.houseNumber);
    _streetNameController = TextEditingController(text: house?.streetName);
    _suburbController = TextEditingController(text: house?.suburb);
    _postcodeController = TextEditingController(text: house?.postcode);
    _latitudeController = TextEditingController(text: house?.latitude?.toString());
    _longitudeController = TextEditingController(text: house?.longitude?.toString());
    _descriptionController = TextEditingController(text: house?.description);
    _locationId = house?.locationId ?? 'location_nt_001'; // Default location
    _councilId = house?.councilId ?? 'council_nt_001'; // Default council
  }

  @override
  void dispose() {
    _houseNumberController.dispose();
    _streetNameController.dispose();
    _suburbController.dispose();
    _postcodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.house == null ? 'Add House' : 'Edit House'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _houseNumberController,
                decoration: const InputDecoration(labelText: 'House Number'),
              ),
              TextFormField(
                controller: _streetNameController,
                decoration: const InputDecoration(labelText: 'Street Name *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a street name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _suburbController,
                decoration: const InputDecoration(labelText: 'Suburb'),
              ),
              TextFormField(
                controller: _postcodeController,
                decoration: const InputDecoration(labelText: 'Postcode'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
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
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final house = House(
                id: widget.house?.id ?? 'house_${DateTime.now().millisecondsSinceEpoch}',
                houseNumber: _houseNumberController.text.isNotEmpty ? _houseNumberController.text : null,
                streetName: _streetNameController.text.isNotEmpty ? _streetNameController.text : null,
                suburb: _suburbController.text.isNotEmpty ? _suburbController.text : null,
                postcode: _postcodeController.text.isNotEmpty ? _postcodeController.text : null,
                latitude: double.tryParse(_latitudeController.text),
                longitude: double.tryParse(_longitudeController.text),
                description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
                locationId: _locationId,
                councilId: _councilId,
                createdAt: widget.house?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
                isActive: true,
              );
              widget.onSave(house);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 