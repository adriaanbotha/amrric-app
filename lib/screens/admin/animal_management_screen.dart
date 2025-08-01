import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/utils/permission_helper.dart';
import 'package:amrric_app/screens/animal_detail_screen.dart';
import 'package:amrric_app/screens/admin/animal_form_screen.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/widgets/animal_photo_gallery.dart';
import 'package:amrric_app/services/photo_sync_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/widgets/app_scaffold.dart';
import 'package:amrric_app/utils/debug_helper.dart';

class AnimalManagementScreen extends ConsumerStatefulWidget {
  const AnimalManagementScreen({super.key});

  @override
  ConsumerState<AnimalManagementScreen> createState() => _AnimalManagementScreenState();
}

class _AnimalManagementScreenState extends ConsumerState<AnimalManagementScreen> {
  String? selectedCouncil;
  String searchQuery = '';
  List<Animal> _allAnimals = [];
  List<Animal> _filteredAnimals = [];
  bool _isLoading = true;
  String? _error;
  late final TextEditingController _searchController;
  User? _user;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: searchQuery);
    _searchController.addListener(() {
      if (_searchController.text != searchQuery) {
        setState(() {
          searchQuery = _searchController.text;
          _applySearch();
        });
      }
    });
    _fetchUserAndAnimals();
  }

  Future<void> _fetchUserAndAnimals() async {
    final authService = ref.read(authServiceProvider);
    final user = await authService.getCurrentUser();
    setState(() {
      _user = user;
    });
    await _loadAnimals();
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
      // Debug: Check all animals in database
      await DebugHelper.printAllAnimals();
      await DebugHelper.printAnimalsWithDefaultHouse();
      
      // Cleanup: Remove animals with default house (run once)
      await DebugHelper.cleanupAnimalsWithDefaultHouse();
      
      final animalService = ref.read(animalsProvider.notifier);
      final user = _user;
      if (user == null) {
        setState(() {
          _allAnimals = [];
          _filteredAnimals = [];
          _isLoading = false;
        });
        return;
      }
      List<Animal> animals;
      switch (user.role) {
        case UserRole.systemAdmin:
          animals = await animalService.getAnimals();
          break;
        case UserRole.municipalityAdmin:
          animals = await animalService.getAnimalsByCouncil(user.councilId);
          break;
        case UserRole.veterinaryUser:
          animals = await animalService.getAnimalsWithMedicalFocus();
          break;
        case UserRole.censusUser:
          animals = await animalService.getAnimalsByBasicInfo();
          break;
        default:
          animals = [];
      }
      setState(() {
        _allAnimals = animals;
        _applySearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applySearch() {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredAnimals = List.from(_allAnimals);
    } else {
      _filteredAnimals = _allAnimals.where((animal) {
        final name = animal.name?.toLowerCase() ?? '';
        final species = animal.species.toLowerCase();
        final breed = animal.breed?.toLowerCase() ?? '';
        final id = animal.id.toLowerCase();
        return name.contains(query) ||
            species.contains(query) ||
            breed.contains(query) ||
            id.contains(query);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Animal Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAnimalDialog(),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    final authService = ref.watch(authServiceProvider);
    final user = _user;
    final permissions = AnimalPermissions(authService);
    if (user == null) {
      return const Center(
        child: Text('Please log in to access animal management'),
      );
    }
    return SafeArea(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search animals...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          // Main Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: \\$_error',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAnimals,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredAnimals.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.pets,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No animals found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<bool>(
                                  future: permissions.canAddAnimal(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const SizedBox.shrink();
                                    }
                                    if (snapshot.data == true) {
                                      return ElevatedButton.icon(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const AnimalFormScreen(),
                                          ),
                                        ).then((_) => _loadAnimals()),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Animal'),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadAnimals,
                            child: ListView.builder(
                              itemCount: _filteredAnimals.length,
                              itemBuilder: (context, index) {
                                final animal = _filteredAnimals[index];
                                return FutureBuilder<Map<String, bool>>(
                                  future: Future.wait([
                                    permissions.canEditAnimal(),
                                    permissions.canDeleteAnimal(),
                                    permissions.canViewMedicalHistory(),
                                  ]).then((results) => {
                                        'canEdit': results[0],
                                        'canDelete': results[1],
                                        'canViewMedical': results[2],
                                      }),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    final perms = snapshot.data ?? {
                                      'canEdit': false,
                                      'canDelete': false,
                                      'canViewMedical': false,
                                    };
                                    return _buildAnimalCard(
                                      animal: animal,
                                      canEdit: perms['canEdit']!,
                                      canDelete: perms['canDelete']!,
                                      canViewMedical: perms['canViewMedical']!,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard({
    required Animal animal,
    required bool canEdit,
    required bool canDelete,
    required bool canViewMedical,
  }) {
    final name = animal.name ?? 'Unknown';
    final id = animal.id ?? 'Unknown ID';
    
    // Check if animal has medical history
    final hasTreatments = animal.medicalHistory != null && 
                         animal.medicalHistory!.containsKey('treatments') &&
                         animal.medicalHistory!['treatments'] is List &&
                         (animal.medicalHistory!['treatments'] as List).isNotEmpty;
    
    final hasMedications = animal.medicalHistory != null && 
                          animal.medicalHistory!.containsKey('medications') &&
                          animal.medicalHistory!['medications'] is List &&
                          (animal.medicalHistory!['medications'] as List).isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $id'),
            if (hasTreatments || hasMedications)
              Row(
                children: [
                  if (hasTreatments)
                    Tooltip(
                      message: 'Has treatments',
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.medical_services,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ),
                    ),
                  if (hasMedications)
                    Tooltip(
                      message: 'Has medications',
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.medication,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canViewMedical)
              Tooltip(
                message: 'View medical history',
                child: IconButton(
                  icon: const Icon(Icons.medical_services),
                  onPressed: () => _showMedicalHistory(animal),
                ),
              ),
            if (canEdit)
              Tooltip(
                message: 'Edit animal',
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editAnimal(animal),
                ),
              ),
            if (canDelete)
              Tooltip(
                message: 'Delete animal',
                child: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteAnimal(animal),
                ),
              ),
          ],
        ),
        onTap: () => _showAnimalDetails(animal),
      ),
    );
  }

  void _showAnimalDetails(Animal animal) {
    final name = animal.name ?? 'Unknown';
    final id = animal.id ?? 'Unknown ID';
    final species = animal.species ?? 'Unknown species';
    final breed = animal.breed ?? 'Unknown breed';
    final age = animal.estimatedAge?.toString() ?? 'Unknown';
    final location = animal.locationId ?? 'Unknown location';
    final council = animal.councilId ?? 'Unknown council';

    showDialog(
      context: context,
      builder: (context) => FutureBuilder<Box<Map<dynamic, dynamic>>>(
        future: Hive.openBox<Map<dynamic, dynamic>>('photos'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return AlertDialog(
              content: Text('Error: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          }
          final box = snapshot.data!;
          return AlertDialog(
            title: Text(name),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: $id'),
                  Text('Species: $species'),
                  Text('Breed: $breed'),
                  Text('Age: $age'),
                  Text('Location: $location'),
                  Text('Council: $council'),
                  const SizedBox(height: 16),
                  AnimalPhotoGallery(
                    animalId: animal.id,
                    photoSyncService: PhotoSyncService(UpstashConfig.redis, box),
                    existingPhotos: animal.photoUrls,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showMedicalHistory(Animal animal) {
    if (animal.medicalHistory == null || animal.medicalHistory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No medical history available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Medical History - ${animal.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (animal.medicalHistory!.containsKey('vaccinations'))
                _buildMedicalSection('Vaccinations', animal.medicalHistory!['vaccinations']),
              if (animal.medicalHistory!.containsKey('treatments'))
                _buildMedicalSection('Treatments', animal.medicalHistory!['treatments']),
              if (animal.medicalHistory!.containsKey('notes'))
                _buildMedicalSection('Notes', animal.medicalHistory!['notes']),
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

  Widget _buildMedicalSection(String title, dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (data is List)
          ...data.map((item) => Text('- $item')).toList()
        else if (data is String)
          Text(data)
        else
          const Text('No data available'),
        const SizedBox(height: 16),
      ],
    );
  }

  void _editAnimal(Animal animal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalDetailScreen(
          animalId: animal.id,
          animalName: animal.name ?? 'Unknown',
        ),
      ),
    ).then((_) {
      // Always reload animals when returning from detail screen
      _loadAnimals();
    });
  }

  Future<void> _deleteAnimal(Animal animal) async {
    final id = animal.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete animal: Invalid ID')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Animal'),
        content: Text('Are you sure you want to delete \\${animal.name ?? 'this animal'}?'),
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
        await ref.read(animalsProvider.notifier).deleteAnimal(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animal deleted successfully')),
          );
          _loadAnimals();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting animal: \\$e')),
          );
        }
      }
    }
  }

  void _showAddAnimalDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnimalFormScreen(),
      ),
    );
    if (result == true) {
      _loadAnimals();
    }
  }
} 