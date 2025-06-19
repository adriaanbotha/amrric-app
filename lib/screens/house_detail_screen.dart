import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/house.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/screens/admin/animal_form_screen.dart';
import 'package:amrric_app/widgets/loading_indicator.dart';
import 'package:amrric_app/widgets/error_display.dart';

class HouseDetailScreen extends ConsumerStatefulWidget {
  final House house;
  final UserRole userRole;

  const HouseDetailScreen({
    super.key,
    required this.house,
    required this.userRole,
  });

  @override
  ConsumerState<HouseDetailScreen> createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends ConsumerState<HouseDetailScreen> {
  List<Animal> _animals = [];
  List<Animal> _filteredAnimals = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAnimals();
    _searchController.addListener(_filterAnimals);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnimals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Debug: Print current house information
      debugPrint('=== HOUSE DETAIL DEBUG ===');
      debugPrint('Current house ID: ${widget.house.id}');
      debugPrint('Current house address: ${widget.house.fullAddress}');
      
      final animalService = ref.read(animalsProvider.notifier);
      
      // OPTIMIZED: Use getAnimalsByHouse instead of getAnimals
      final houseAnimals = await animalService.getAnimalsByHouse(widget.house.id);
      
      // Debug: Print results
      debugPrint('Animals found for house ${widget.house.id}: ${houseAnimals.length}');
      for (final animal in houseAnimals) {
        debugPrint('Animal: ${animal.name ?? animal.id} - ${animal.species}');
      }
      debugPrint('=== END HOUSE DETAIL DEBUG ===');
      
      setState(() {
        _animals = houseAnimals;
        _filteredAnimals = houseAnimals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading animals for house: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterAnimals() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAnimals = _animals.where((animal) {
        return (animal.name?.toLowerCase().contains(query) ?? false) ||
               animal.species.toLowerCase().contains(query) ||
               (animal.breed?.toLowerCase().contains(query) ?? false) ||
               (animal.color?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  void _addAnimal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalFormScreen(
          animal: null,
          preselectedHouse: widget.house,
        ),
      ),
    ).then((_) {
      _loadAnimals();
    });
  }

  void _viewAnimal(Animal animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalFormScreen(
          animal: animal,
        ),
      ),
    ).then((_) {
      _loadAnimals();
    });
  }

  String _getUserRoleTitle() {
    return widget.userRole == UserRole.veterinaryUser 
        ? 'Veterinary Services' 
        : 'Census Data Collection';
  }

  String _getAnimalStatusText(Animal animal) {
    if (widget.userRole == UserRole.veterinaryUser) {
      // For veterinary users, show medical status
      final medicalHistory = animal.medicalHistory;
      if (medicalHistory != null && medicalHistory['lastTreatment'] != null) {
        return 'Last treated: ${medicalHistory['lastTreatment']}';
      }
      return 'No recent treatments';
    } else {
      // For census users, show census status
      final censusData = animal.censusData;
      if (censusData != null && censusData['lastCount'] != null) {
        return 'Last counted: ${censusData['lastCount']}';
      }
      return 'Not counted recently';
    }
  }

  Color _getAnimalStatusColor(Animal animal) {
    if (widget.userRole == UserRole.veterinaryUser) {
      // For veterinary users, color based on medical status
      final medicalHistory = animal.medicalHistory;
      if (medicalHistory != null && medicalHistory['needsAttention'] == true) {
        return Colors.red;
      }
      if (medicalHistory != null && medicalHistory['lastTreatment'] != null) {
        return Colors.green;
      }
      return Colors.orange;
    } else {
      // For census users, color based on census status
      final censusData = animal.censusData;
      if (censusData != null && censusData['condition'] == 'healthy') {
        return Colors.green;
      }
      if (censusData != null && censusData['condition'] == 'needs attention') {
        return Colors.red;
      }
      return Colors.grey;
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
        appBar: AppBar(
          title: Text('House Details'),
        ),
        body: ErrorDisplay(
          error: _error!,
          onRetry: _loadAnimals,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.house.fullAddress,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              _getUserRoleTitle(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // House information card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.house.fullAddress,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.house.description != null) ...[
                    Text(
                      'Description: ${widget.house.description}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (widget.house.latitude != null && widget.house.longitude != null) ...[
                    Text(
                      'GPS: ${widget.house.latitude!.toStringAsFixed(4)}, ${widget.house.longitude!.toStringAsFixed(4)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_animals.length} animals',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search animals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Animals list
          Expanded(
            child: _filteredAnimals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _animals.isEmpty ? 'No animals found' : 'No animals match your search',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_animals.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add an animal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadAnimals,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredAnimals.length,
                      itemBuilder: (context, index) {
                        final animal = _filteredAnimals[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: _getAnimalStatusColor(animal),
                              child: Icon(
                                animal.species.toLowerCase() == 'dog' 
                                    ? Icons.pets 
                                    : Icons.pets,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              animal.name ?? 'Unnamed ${animal.species}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('${animal.species} • ${animal.sex} • Age: ${animal.estimatedAge ?? 'Unknown'}'),
                                if (animal.breed != null)
                                  Text('Breed: ${animal.breed}'),
                                Text('Color: ${animal.color}'),
                                const SizedBox(height: 4),
                                Text(
                                  _getAnimalStatusText(animal),
                                  style: TextStyle(
                                    color: _getAnimalStatusColor(animal),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!animal.isActive)
                                  const Text(
                                    'Inactive',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _viewAnimal(animal),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAnimal,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
} 