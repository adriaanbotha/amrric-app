import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/house.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/utils/permission_helper.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/widgets/animal_photo_gallery.dart';
import 'package:amrric_app/services/photo_sync_service.dart';
import 'package:amrric_app/services/location_service.dart';
import 'package:amrric_app/services/council_service.dart';
import 'package:amrric_app/services/house_service.dart';
import 'package:amrric_app/providers/house_provider.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:amrric_app/widgets/app_scaffold.dart';

class AnimalFormScreen extends ConsumerStatefulWidget {
  final Animal? animal;
  final House? preselectedHouse;

  const AnimalFormScreen({
    super.key, 
    this.animal,
    this.preselectedHouse,
  });

  @override
  ConsumerState<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends ConsumerState<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _colorController;
  late TextEditingController _microchipController;
  late TextEditingController _weightController;
  String _sex = 'Male';
  int _estimatedAge = 0;
  bool _isActive = true;
  PhotoSyncService? _photoSyncService;
  bool _photoSyncServiceReady = false;
  List<String> _photoUrls = [];
  String? _selectedHouseId;
  List<House> _houses = [];
  bool _isLoadingHouses = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.animal?.name);
    _speciesController = TextEditingController(text: widget.animal?.species);
    _breedController = TextEditingController(text: widget.animal?.breed);
    _colorController = TextEditingController(text: widget.animal?.color);
    _microchipController = TextEditingController(text: widget.animal?.microchipNumber);
    _weightController = TextEditingController(text: widget.animal?.weight?.toString());
    _sex = widget.animal?.sex ?? 'Male';
    _estimatedAge = widget.animal?.estimatedAge ?? 0;
    _isActive = widget.animal?.isActive ?? true;
    _photoUrls = List<String>.from(widget.animal?.photoUrls ?? []);
    
    // Set selected house: prioritize existing animal's house, then preselected house
    _selectedHouseId = widget.animal?.houseId ?? widget.preselectedHouse?.id;
    
    _initPhotoSyncService();
    _loadHouses();
  }

  Future<void> _initPhotoSyncService() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>('photos');
    setState(() {
      _photoSyncService = PhotoSyncService(UpstashConfig.redis, box);
      _photoSyncServiceReady = true;
    });
  }

  Future<void> _loadHouses() async {
    setState(() {
      _isLoadingHouses = true;
    });
    
    try {
      List<House> houses;
      
      // If we have a preselected house and no existing animal, we can just use that house
      if (widget.preselectedHouse != null && widget.animal == null) {
        houses = [widget.preselectedHouse!];
        debugPrint('=== OPTIMIZED HOUSE LOADING ===');
        debugPrint('Using preselected house: ${widget.preselectedHouse!.id} - ${widget.preselectedHouse!.fullAddress}');
        debugPrint('Skipping full house list load for performance');
      } else {
        // Load all houses for editing existing animals or when no preselection
        final houseService = ref.read(houseServiceProvider);
        houses = await houseService.getHouses();
        
        debugPrint('=== FULL HOUSE LOADING ===');
        debugPrint('Loading all houses because: ${widget.animal != null ? 'editing existing animal' : 'no preselected house'}');
        debugPrint('Available houses for selection: ${houses.length}');
      }
      
      // Debug: Print available houses
      for (final house in houses) {
        debugPrint('House: ${house.id} - ${house.fullAddress}');
      }
      debugPrint('Currently selected house ID: $_selectedHouseId');
      debugPrint('=== END HOUSE LOADING DEBUG ===');
      
      setState(() {
        _houses = houses;
        _isLoadingHouses = false;
      });
    } catch (e) {
      debugPrint('Error loading houses: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading houses: $e')),
      );
      setState(() {
        _isLoadingHouses = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _microchipController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for house selection
    if (_selectedHouseId == null || _selectedHouseId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a house for the animal')),
      );
      return;
    }

    // Debug: Print what house is selected
    debugPrint('=== ANIMAL SAVE DEBUG ===');
    debugPrint('Selected house ID: $_selectedHouseId');
    debugPrint('Animal name: ${_nameController.text}');
    debugPrint('Animal species: ${_speciesController.text}');

    final animalService = ref.read(animalsProvider.notifier);
    final authService = ref.read(authServiceProvider);
    final currentUser = await authService.getCurrentUser();

    try {
      // Only store file names in photoUrls
      final photoFileNames = _photoUrls.map((p) => p.split('/').last).toList();
      print('Saving animal with photoUrls: [32m$photoFileNames[0m');
      final animal = Animal(
        id: widget.animal?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        species: _speciesController.text,
        breed: _breedController.text,
        color: _colorController.text,
        sex: _sex,
        estimatedAge: _estimatedAge,
        weight: double.tryParse(_weightController.text),
        microchipNumber: _microchipController.text,
        registrationDate: widget.animal?.registrationDate ?? DateTime.now(),
        lastUpdated: DateTime.now(),
        isActive: _isActive,
        houseId: _selectedHouseId!,
        locationId: widget.animal?.locationId ?? currentUser?.locationId ?? 'default',
        councilId: widget.animal?.councilId ?? currentUser?.councilId ?? 'council1', // Match test data
        ownerId: widget.animal?.ownerId,
        photoUrls: photoFileNames,
        medicalHistory: widget.animal?.medicalHistory,
        censusData: widget.animal?.censusData,
        metadata: widget.animal?.metadata,
      );

      debugPrint('Animal object created with houseId: ${animal.houseId}');

      if (widget.animal == null) {
        await animalService.addAnimal(animal);
        debugPrint('Animal added successfully');
      } else {
        await animalService.updateAnimal(animal);
        debugPrint('Animal updated successfully');
      }
      debugPrint('=== END ANIMAL SAVE DEBUG ===');

      // Sync photos after updating/adding animal
      if (_photoSyncServiceReady && _photoSyncService != null) {
        await _photoSyncService!.syncPhotos();
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('Error saving animal: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(widget.animal == null ? 'Add Animal' : 'Edit Animal'),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    final authService = ref.watch(authServiceProvider);
    final permissions = AnimalPermissions(authService);

    return FutureBuilder<User?>(
      future: authService.getCurrentUser(),
      builder: (context, snapshot) {
        final currentUser = snapshot.data;
        final isVetUser = currentUser?.role == UserRole.veterinaryUser;
        final isCensusUser = currentUser?.role == UserRole.censusUser;

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic Information Section
                const Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _speciesController,
                  decoration: const InputDecoration(
                    labelText: 'Species *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the species';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (!isCensusUser) ...[
                  TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(
                      labelText: 'Breed',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _colorController,
                  decoration: const InputDecoration(
                    labelText: 'Color/Markings',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _sex,
                  decoration: const InputDecoration(
                    labelText: 'Sex *',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female'].map((sex) {
                    return DropdownMenuItem(
                      value: sex,
                      child: Text(sex),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _sex = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // House Selection
                if (_isLoadingHouses)
                  const CircularProgressIndicator()
                else
                  DropdownButtonFormField<String>(
                    value: _houses.any((house) => house.id == _selectedHouseId) ? _selectedHouseId : null,
                    decoration: const InputDecoration(
                      labelText: 'House *',
                      border: OutlineInputBorder(),
                    ),
                    items: _houses.map((house) {
                      return DropdownMenuItem(
                        value: house.id,
                        child: Text(house.fullAddress.isNotEmpty ? house.fullAddress : house.id),
                      );
                    }).toList(),
                    onChanged: (value) {
                      debugPrint('House selection changed to: $value');
                      setState(() {
                        _selectedHouseId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a house';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),

                // Advanced Information Section (Not for Census Users)
                if (!isCensusUser) ...[
                  const Text(
                    'Advanced Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _microchipController,
                    decoration: const InputDecoration(
                      labelText: 'Microchip Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // Age Selector
                  Row(
                    children: [
                      const Text('Estimated Age: '),
                      Expanded(
                        child: Slider(
                          value: _estimatedAge.toDouble(),
                          min: 0,
                          max: 20,
                          divisions: 20,
                          label: _estimatedAge.toString(),
                          onChanged: (value) {
                            setState(() {
                              _estimatedAge = value.round();
                            });
                          },
                        ),
                      ),
                      Text('$_estimatedAge years'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Status Section (Not for Census Users)
                if (!isCensusUser) ...[
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

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

                if (_photoSyncServiceReady && widget.animal != null)
                  AnimalPhotoGallery(
                    animalId: widget.animal!.id,
                    existingPhotos: _photoUrls,
                    photoSyncService: _photoSyncService!,
                    onPhotoListChanged: (updatedList) {
                      setState(() {
                        _photoUrls = List<String>.from(updatedList.map((p) => p.split('/').last));
                      });
                    },
                  ),

                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _saveAnimal,
                  child: Text(widget.animal == null ? 'Add Animal' : 'Update Animal'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 