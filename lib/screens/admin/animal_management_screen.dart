import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/utils/permission_helper.dart';
import 'package:amrric_app/screens/admin/animal_form_screen.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/user.dart';

class AnimalManagementScreen extends ConsumerStatefulWidget {
  const AnimalManagementScreen({super.key});

  @override
  ConsumerState<AnimalManagementScreen> createState() => _AnimalManagementScreenState();
}

class _AnimalManagementScreenState extends ConsumerState<AnimalManagementScreen> {
  String? selectedCouncil;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final permissions = AnimalPermissions(authService);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to access animal management'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AnimalFormScreen(),
              ),
            ).then((_) => setState(() {})),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search animals...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: FutureBuilder<List<Animal>>(
                  future: _getAnimalsList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
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
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final animals = snapshot.data ?? [];

                    if (animals.isEmpty) {
                      return Center(
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
                            if (permissions.canAddAnimal())
                              ElevatedButton.icon(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AnimalFormScreen(),
                                  ),
                                ).then((_) => setState(() {})),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Animal'),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: animals.length,
                      itemBuilder: (context, index) {
                        final animal = animals[index];
                        return _buildAnimalCard(
                          animal: animal,
                          canEdit: permissions.canEditAnimal(),
                          canDelete: permissions.canDeleteAnimal(),
                          canViewMedical: permissions.canViewMedicalHistory(),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: permissions.canAddAnimal()
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnimalFormScreen(),
                ),
              ).then((_) => setState(() {})),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<List<Animal>> _getAnimalsList() async {
    final animalService = ref.read(animalServiceProvider);
    final user = ref.read(authServiceProvider).currentUser;
    
    if (user == null) {
      return [];
    }

    try {
      List<Animal> animals;
      
      switch (user.role) {
        case UserRole.systemAdmin:
          animals = await animalService.getAnimals();
        case UserRole.municipalityAdmin:
          animals = await animalService.getAnimalsByCouncil(user.councilId);
        case UserRole.veterinaryUser:
          animals = await animalService.getAnimalsWithMedicalFocus();
        case UserRole.censusUser:
          animals = await animalService.getAnimalsByBasicInfo();
        default:
          animals = [];
      }
      
      // Filter animals based on search query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return animals.where((animal) {
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
      
      return animals;
    } catch (e) {
      debugPrint('Error getting animals: $e');
      return [];
    }
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
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: $id'),
            Text('Species: $species'),
            Text('Breed: $breed'),
            Text('Age: $age'),
            Text('Location: $location'),
            Text('Council: $council'),
          ],
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
        builder: (context) => AnimalFormScreen(animal: animal),
      ),
    );
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
        content: Text('Are you sure you want to delete ${animal.name ?? 'this animal'}?'),
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
        await ref.read(animalServiceProvider).deleteAnimal(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Animal deleted successfully')),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting animal: $e')),
          );
        }
      }
    }
  }
} 