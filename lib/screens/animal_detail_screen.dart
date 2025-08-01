import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/models/house.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/services/animal_records_service.dart';
import 'package:amrric_app/services/house_service.dart';
import 'package:amrric_app/providers/animal_records_provider.dart';
import 'package:amrric_app/providers/house_provider.dart';
import 'package:amrric_app/screens/clinical_notes_screen.dart';
import 'package:amrric_app/widgets/animal_photo_gallery.dart';
import 'package:amrric_app/services/photo_sync_service.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/utils/permission_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AnimalDetailScreen extends ConsumerStatefulWidget {
  final String animalId;
  final String animalName;

  const AnimalDetailScreen({
    super.key,
    required this.animalId,
    required this.animalName,
  });

  @override
  ConsumerState<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends ConsumerState<AnimalDetailScreen> {
  Animal? _animal;
  bool _isLoading = true;
  String? _error;
  User? _currentUser;
  PhotoSyncService? _photoSyncService;
  bool _photoSyncServiceReady = false;
  
  // Form-related state
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _colorController;
  late TextEditingController _microchipController;
  late TextEditingController _weightController;
  String _sex = 'Male';
  int _estimatedAge = 0;
  bool _isActive = true;
  List<String> _photoUrls = [];
  String? _selectedHouseId;
  List<House> _houses = [];
  bool _isLoadingHouses = true;

  // Dropdown options for specific fields
  static const List<String> _speciesOptions = ['Cat', 'Dog'];
  static const List<String> _genderOptions = ['Male', 'Female'];
  static const List<String> _colorOptions = [
    'Black', 'White', 'Brown', 'Gray', 'Orange', 'Cream', 'Tan', 'Brindle', 
    'Tricolor', 'Black and White', 'Brown and White', 'Gray and White', 
    'Orange and White', 'Calico', 'Tabby', 'Tortoiseshell', 'Other'
  ];
  static const List<String> _reproOptions = [
    'Unknown', 'Intact', 'Desexed', 'Pregnant', 'Lactating'
  ];
  static const List<String> _sizeOptions = [
    'Unknown', 'Very Small', 'Small', 'Medium', 'Large', 'Very Large'
  ];

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadAnimalDetails();
    _initPhotoSyncService();
    _loadHouses();
  }
  
  void _initControllers() {
    _nameController = TextEditingController();
    _speciesController = TextEditingController();
    _breedController = TextEditingController();
    _colorController = TextEditingController();
    _microchipController = TextEditingController();
    _weightController = TextEditingController();
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

  Future<void> _initPhotoSyncService() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>('photos');
    setState(() {
      _photoSyncService = PhotoSyncService(UpstashConfig.redis, box);
      _photoSyncServiceReady = true;
    });
  }
  
  Future<void> _loadHouses() async {
    try {
      final houseService = ref.read(houseServiceProvider);
      final houses = await houseService.getHouses();
      setState(() {
        _houses = houses;
        _isLoadingHouses = false;
      });
    } catch (e) {
      debugPrint('Error loading houses: $e');
      setState(() {
        _isLoadingHouses = false;
      });
    }
  }
  
  void _populateControllers(Animal animal) {
    _nameController.text = animal.name ?? '';
    _speciesController.text = animal.species;
    _breedController.text = animal.breed ?? '';
    _colorController.text = animal.color ?? '';
    _microchipController.text = animal.microchipNumber ?? '';
    _weightController.text = animal.weight?.toString() ?? '';
    _sex = animal.sex;
    _estimatedAge = animal.estimatedAge ?? 0;
    _isActive = animal.isActive ?? true;
    _photoUrls = List<String>.from(animal.photoUrls);
    _selectedHouseId = animal.houseId;
  }
  
  Widget _buildAnimalForm() {
    final authService = ref.watch(authServiceProvider);
    final currentUser = _currentUser;
    final isVetUser = currentUser?.role == UserRole.veterinaryUser;
    final isCensusUser = currentUser?.role == UserRole.censusUser;
    
    if (_isEditMode) {
      return _buildEditForm(isVetUser, isCensusUser);
    } else {
      return _buildViewContent();
    }
  }
  
  Widget _buildViewContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status row with icon
        Row(
          children: [
            Icon(
              Icons.health_and_safety,
              color: Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Alive', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              _formatDate(_animal!.registrationDate),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Name (large display)
        Text(
          _animal!.name ?? widget.animalName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Owner field
        _buildInfoRow('Owner', _animal!.ownerId ?? '', null),
        const SizedBox(height: 8),
        
        // Gender
        _buildInfoRow('Gender', _animal!.sex, null),
        const SizedBox(height: 8),
        
        // Species
        _buildInfoRow('Species', _animal!.species, null),
        const SizedBox(height: 8),
        
        // Breed
        _buildInfoRow('Breed', _animal!.breed ?? '', null),
        const SizedBox(height: 8),
        
        // Repro status
        _buildInfoRow('Repro', _animal!.reproductiveStatus ?? 'Unknown', null),
        const SizedBox(height: 8),
        
        // Age
        _buildInfoRow('Age', _getAgeDisplay(), null),
        const SizedBox(height: 8),
        
        // Size
        _buildInfoRow('Size', _animal!.size ?? 'Unknown', null),
        const SizedBox(height: 8),
        
        // Weight
        _buildInfoRow('Weight(kg)', _animal!.weight?.toString() ?? '', null),
        const SizedBox(height: 8),
        
        // Microchip
        _buildInfoRow('MC', _animal!.microchipNumber ?? '', null),
        const SizedBox(height: 8),
        
        // Registration
        _buildInfoRow('Registration', _formatDate(_animal!.registrationDate), null),
        const SizedBox(height: 8),
        
        // Colour
        _buildInfoRow('Colour', _animal!.color ?? '', null),
      ],
    );
  }
  
  Widget _buildEditForm(bool isVetUser, bool isCensusUser) {
    return Column(
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
      ],
    );
  }

  Future<void> _loadAnimalDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('🐕 Loading animal details for: ${widget.animalId}');
      
      // Get current user
      final authService = ref.read(authServiceProvider);
      _currentUser = await authService.getCurrentUser();
      
      // Load animal data only when needed
      final animalService = ref.read(animalsProvider.notifier);
      final animal = await animalService.getAnimal(widget.animalId);
      
      if (animal == null) {
        throw Exception('Animal not found');
      }
      
      debugPrint('✅ Animal loaded: ${animal.name} - ${animal.species}');
      
      // Populate form controllers with animal data
      _populateControllers(animal);
      
      setState(() {
        _animal = animal;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading animal: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addRecord(String recordType) async {
    if (_animal == null || _currentUser == null) return;

    // Navigate to the comprehensive clinical notes screen for clinical notes
    if (recordType == 'clinical_notes') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ClinicalNotesScreen(
            animalId: widget.animalId,
            animalName: _animal!.name ?? widget.animalName,
            animalSpecies: _animal?.species,
            animalSex: _animal?.sex,
          ),
        ),
      );
      return;
    }

    // For other record types, use the existing dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RecordDialog(
        recordType: recordType,
        animalName: _animal!.name ?? widget.animalName,
      ),
    );

    if (result != null) {
      await _saveRecord(recordType, result);
      await _loadAnimalDetails(); // Refresh data
    }
  }

  Future<void> _saveRecord(String recordType, Map<String, dynamic> recordData) async {
    if (_currentUser == null) return;
    
    try {
      debugPrint('💾 Saving $recordType record for ${widget.animalId}');
      
      final recordsService = ref.read(animalRecordsServiceProvider);
      
      // Handle condition assessment data
      if (recordType == 'condition' && recordData.containsKey('conditionAssessment')) {
        await recordsService.addRecord(
          animalId: widget.animalId,
          recordType: recordType,
          description: recordData['description'] ?? '',
          author: _currentUser!,
          specificValue: recordData['conditionSummary'], // Use the summary as specific value
          notes: recordData['notes'],
          locationId: _animal?.locationId,
          additionalData: {
            'conditionAssessment': recordData['conditionAssessment'],
            'conditionSummary': recordData['conditionSummary'],
          },
        );
      } else {
        // Handle other record types (behavior, comment, clinical_notes)
        await recordsService.addRecord(
          animalId: widget.animalId,
          recordType: recordType,
          description: recordData['description'] ?? '',
          author: _currentUser!,
          specificValue: recordData['condition'] ?? recordData['behaviour'],
          notes: recordData['notes'],
          locationId: _animal?.locationId,
        );
      }
      
      // Invalidate the records provider to refresh the UI
      ref.invalidate(animalRecordsProvider(widget.animalId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${recordType.replaceAll('_', ' ')} record added successfully')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving record: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving record: $e')),
        );
      }
    }
  }

  Widget _buildEditableField(
    String label,
    String value,
    Function(String) onSave, {
    String suffix = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return GestureDetector(
      onTap: () => _showFieldEditor(label, value, onSave, keyboardType),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? 'Tap to select' : '$value$suffix',
                style: TextStyle(
                  color: value.isEmpty ? Colors.grey.shade600 : Colors.black87,
                  fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              _getFieldIcon(label),
              size: 18,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFieldIcon(String label) {
    switch (label.toLowerCase()) {
      case 'species': return Icons.pets;
      case 'gender': return Icons.wc;
      case 'colour': return Icons.palette;
      case 'repro': return Icons.favorite;
      case 'size': return Icons.straighten;
      case 'mc': return Icons.qr_code;
      case 'microchip': return Icons.qr_code;
      default: return Icons.edit_outlined;
    }
  }

  Future<void> _showFieldEditor(
    String label,
    String currentValue,
    Function(String) onSave,
    TextInputType keyboardType,
  ) async {
    String? result;
    
         // Use dropdown for specific fields
     switch (label.toLowerCase()) {
       case 'species':
         result = await _showDropdownDialog(label, currentValue, _speciesOptions);
         break;
       case 'gender':
         result = await _showDropdownDialog(label, currentValue, _genderOptions);
         break;
       case 'colour':
         result = await _showDropdownDialog(label, currentValue, _colorOptions);
         break;
       case 'repro':
         result = await _showDropdownDialog(label, currentValue, _reproOptions);
         break;
       case 'size':
         result = await _showDropdownDialog(label, currentValue, _sizeOptions);
         break;
       default:
        // Use text input for other fields
        result = await showDialog<String>(
          context: context,
          builder: (context) => _EditDialog(
            label: label,
            currentValue: currentValue,
            keyboardType: keyboardType,
          ),
        );
        break;
    }
    
    if (result != null && result != currentValue && mounted) {
      onSave(result);
    }
  }

  Future<String?> _showDropdownDialog(
    String label,
    String currentValue,
    List<String> options,
  ) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => _DropdownDialog(
        label: label,
        currentValue: currentValue,
        options: options,
      ),
    );
  }

  Future<void> _saveAnimal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_animal == null || _selectedHouseId == null) return;

    final authService = ref.read(authServiceProvider);
    final currentUser = await authService.getCurrentUser();
    
    try {
      // Only store file names in photoUrls
      final photoFileNames = _photoUrls.map((p) => p.split('/').last).toList();
      debugPrint('Saving animal with photoUrls: $photoFileNames');
      
      final updatedAnimal = Animal(
        id: _animal!.id,
        name: _nameController.text.isEmpty ? null : _nameController.text,
        species: _speciesController.text,
        breed: _breedController.text.isEmpty ? null : _breedController.text,
        color: _colorController.text.isEmpty ? null : _colorController.text,
        sex: _sex,
        estimatedAge: _estimatedAge,
        weight: double.tryParse(_weightController.text),
        microchipNumber: _microchipController.text.isEmpty ? null : _microchipController.text,
        registrationDate: _animal!.registrationDate,
        lastUpdated: DateTime.now(),
        isActive: _isActive,
        houseId: _selectedHouseId!,
        locationId: _animal!.locationId,
        councilId: _animal!.councilId,
        ownerId: _animal!.ownerId,
        photoUrls: photoFileNames,
        medicalHistory: _animal!.medicalHistory,
        censusData: _animal!.censusData,
        metadata: _animal!.metadata,
      );

      final animalService = ref.read(animalsProvider.notifier);
      await animalService.updateAnimal(updatedAnimal);

      // Sync photos after updating animal
      if (_photoSyncServiceReady && _photoSyncService != null) {
        await _photoSyncService!.syncPhotos();
      }

      if (!mounted) return;
      
      setState(() {
        _animal = updatedAnimal;
        _isEditMode = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal updated successfully')),
      );
    } catch (e) {
      debugPrint('Error saving animal: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateAnimalField(String field, dynamic value) async {
    if (_animal == null || !mounted) return;
    
    try {
      debugPrint('🔄 Updating animal field: $field = $value');
      
      // Create updated animal with new field value
      final updatedAnimal = _animal!.copyWith(
        species: field == 'species' ? value as String : _animal!.species,
        sex: field == 'sex' ? value as String : _animal!.sex,
        breed: field == 'breed' ? value as String? : _animal!.breed,
        color: field == 'color' ? value as String? : _animal!.color,
        estimatedAge: field == 'estimatedAge' ? value as int? : _animal!.estimatedAge,
        weight: field == 'weight' ? value as double? : _animal!.weight,
        reproductiveStatus: field == 'reproductiveStatus' ? value as String? : _animal!.reproductiveStatus,
        size: field == 'size' ? value as String? : _animal!.size,
        microchipNumber: field == 'microchipNumber' ? value as String? : _animal!.microchipNumber,
        lastUpdated: DateTime.now(),
      );
      
      // Update local state first for immediate UI response
      if (mounted) {
        setState(() {
          _animal = updatedAnimal;
        });
      }
      
      // Then update in database
      final animalService = ref.read(animalsProvider.notifier);
      await animalService.updateAnimal(updatedAnimal);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${field.replaceAll('_', ' ')} updated successfully')),
        );
      }
      
      debugPrint('✅ Animal field updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating animal field: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating ${field.replaceAll('_', ' ')}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.animalName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.animalName)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: _loadAnimalDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_animal == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.animalName)),
        body: const Center(child: Text('Animal not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // Animal Header with Photo
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            actions: [
              IconButton(
                icon: Icon(_isEditMode ? Icons.save : Icons.edit),
                onPressed: () async {
                  if (_isEditMode) {
                    await _saveAnimal();
                  } else {
                    setState(() {
                      _isEditMode = true;
                    });
                  }
                },
              ),
              if (_isEditMode)
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    _populateControllers(_animal!); // Reset controllers
                    setState(() {
                      _isEditMode = false;
                    });
                  },
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _animal!.name ?? widget.animalName,
                style: const TextStyle(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),
          ),
          
          // Animal Info Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: _buildAnimalForm(),
                  ),
                ),
              ),
            ),
          ),
          
          // Photo Gallery
          if (_photoSyncServiceReady && _animal != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Photos',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        AnimalPhotoGallery(
                          animalId: _animal!.id,
                          existingPhotos: _photoUrls,
                          photoSyncService: _photoSyncService!,
                          onPhotoListChanged: (updatedList) {
                            setState(() {
                              _photoUrls = List<String>.from(updatedList.map((p) => p.split('/').last));
                            });
                            
                            // If not in edit mode, save immediately
                            if (!_isEditMode && _animal != null) {
                              final updatedAnimal = _animal!.copyWith(
                                photoUrls: _photoUrls,
                                lastUpdated: DateTime.now(),
                              );
                              setState(() {
                                _animal = updatedAnimal;
                              });
                              // Update in database
                              ref.read(animalsProvider.notifier).updateAnimal(updatedAnimal);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Record Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add to ${_animal!.name ?? widget.animalName}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildRecordButton('Condition', Icons.health_and_safety, Colors.red, AnimalRecordsService.typeCondition),
                      _buildRecordButton('Behaviour', Icons.psychology, Colors.orange, AnimalRecordsService.typeBehaviour),
                      _buildRecordButton('Comment', Icons.comment, Colors.blue, AnimalRecordsService.typeComment),
                      _buildRecordButton('Clinical Notes', Icons.medical_services, Colors.green, AnimalRecordsService.typeClinicalNotes),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Recent Records
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer(
                builder: (context, ref, child) {
                final recordsAsync = ref.watch(animalRecordsProvider(widget.animalId));
                
                return recordsAsync.when(
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (error, stack) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error loading records: $error'),
                    ),
                  ),
                  data: (records) {
                    if (records.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No records yet'),
                        ),
                      );
                    }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Recent Records',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...records.take(5).map((record) => _buildRecordTile(record)),
                      if (records.length > 5)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to full records view
                            },
                            child: Text('View all ${records.length} records'),
                          ),
                        ),
                    ],
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

  Widget _buildRecordButton(String title, IconData icon, Color color, String recordType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _addRecord(recordType),
          icon: Icon(icon, color: Colors.white),
          label: Text(title, style: const TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordTile(Map<String, dynamic> record) {
    final type = record['type'] ?? '';
    final timestamp = record['timestamp'] ?? '';
    final author = record['author'] ?? 'Unknown';
    final description = record['description'] ?? '';
    final specificValue = record['specificValue'] ?? '';
    final notes = record['notes'] ?? '';
    final conditionSummary = record['conditionSummary'] ?? '';
    
    Color getTypeColor(String type) {
      switch (type) {
        case 'condition': return Colors.red;
        case 'behaviour': return Colors.orange;
        case 'comment': return Colors.blue;
        case 'clinical_notes': return Colors.green;
        default: return Colors.grey;
      }
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getTypeColor(type),
          child: Icon(
            _getTypeIcon(type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(
              type.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (type == 'condition' && conditionSummary.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: getTypeColor(type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Assessment',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ]
            else if (specificValue.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: getTypeColor(type).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  specificValue,
                  style: TextStyle(
                    color: getTypeColor(type),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(description),
            ],
            if (type == 'condition' && conditionSummary.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  conditionSummary,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Notes: $notes',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '$author • ${_formatTimestamp(timestamp)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'condition': return Icons.health_and_safety;
      case 'behaviour': return Icons.psychology;
      case 'comment': return Icons.comment;
      case 'clinical_notes': return Icons.medical_services;
      default: return Icons.note;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    } catch (e) {
      return timestamp;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getAgeDisplay() {
    if (_animal!.estimatedAge == null) {
      return 'Unknown';
    } else {
      return '${_animal!.estimatedAge} years';
    }
  }

  Widget _buildInfoRow(String label, String value, IconData? icon) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '$label: $value',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// Dropdown dialog widget for predefined options
class _DropdownDialog extends StatefulWidget {
  final String label;
  final String currentValue;
  final List<String> options;

  const _DropdownDialog({
    required this.label,
    required this.currentValue,
    required this.options,
  });

  @override
  State<_DropdownDialog> createState() => _DropdownDialogState();
}

class _DropdownDialogState extends State<_DropdownDialog> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    // Set initial selection if current value exists in options
    selectedValue = widget.options.contains(widget.currentValue) ? widget.currentValue : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.label}'),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.options.map((option) {
              final isSelected = selectedValue == option;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  title: Text(
                    option,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                      fontSize: 14,
                    ),
                  ),
                  leading: Radio<String>(
                    value: option,
                    groupValue: selectedValue,
                    onChanged: (value) => setState(() => selectedValue = value),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  tileColor: isSelected 
                      ? Theme.of(context).primaryColor.withOpacity(0.1) 
                      : null,
                  onTap: () => setState(() => selectedValue = option),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedValue != null 
              ? () => Navigator.pop(context, selectedValue) 
              : null,
          child: const Text('Select'),
        ),
      ],
    );
  }
}

class _RecordDialog extends StatefulWidget {
  final String recordType;
  final String animalName;

  const _RecordDialog({
    required this.recordType,
    required this.animalName,
  });

  @override
  State<_RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<_RecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCondition;
  String? _selectedBehaviour;
  
  // Condition assessment sliders (1-10 scale)
  double _bodyCondition = 5.0;
  double _hairSkinCondition = 5.0;
  double _ticksCondition = 5.0;
  double _fleasCondition = 5.0;

  final List<String> _conditions = AnimalRecordsService.conditions;
  final List<String> _behaviours = AnimalRecordsService.behaviours;

  @override
  void dispose() {
    _contentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getConditionLabel(double value) {
    if (value <= 1) return 'Unknown';
    if (value <= 3) return 'Poor';
    if (value <= 5) return 'Fair';
    if (value <= 7) return 'Good';
    if (value <= 9) return 'Excellent';
    return 'Perfect';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.recordType.replaceAll('_', ' ').toUpperCase()}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Recording for: ${widget.animalName}'),
                const SizedBox(height: 16),
                
                // Condition-specific sliders
                if (widget.recordType == 'condition')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Condition Assessment',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      
                      // Body Condition
                      _buildConditionSlider(
                        'Body Condition',
                        _bodyCondition,
                        (value) => setState(() => _bodyCondition = value),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Hair & Skin
                      _buildConditionSlider(
                        'Hair & Skin',
                        _hairSkinCondition,
                        (value) => setState(() => _hairSkinCondition = value),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Ticks
                      _buildConditionSlider(
                        'Ticks',
                        _ticksCondition,
                        (value) => setState(() => _ticksCondition = value),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Fleas
                      _buildConditionSlider(
                        'Fleas',
                        _fleasCondition,
                        (value) => setState(() => _fleasCondition = value),
                      ),
                    ],
                  ),
                
                // Behaviour-specific selection with categories
                if (widget.recordType == 'behaviour')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Behaviour:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      ...AnimalRecordsService.behaviourCategories.entries.map((category) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (category.key != 'General') const SizedBox(height: 16),
                            Text(
                              category.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: category.value.map((behaviour) {
                                final isSelected = _selectedBehaviour == behaviour;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedBehaviour = behaviour;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.orange.withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected 
                                            ? Colors.orange
                                            : Colors.grey.withOpacity(0.3),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      behaviour,
                                      style: TextStyle(
                                        color: isSelected 
                                            ? Colors.orange.shade700
                                            : Colors.black87,
                                        fontWeight: isSelected 
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }).toList(),
                      if (_selectedBehaviour == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Please select a behaviour',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                
                const SizedBox(height: 16),
                
                // Description/Content field
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: widget.recordType == 'clinical_notes' ? 'Clinical Notes' : 'Description',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    // Description is optional for condition and behaviour records (they have their own data)
                    if (widget.recordType != 'condition' && 
                        widget.recordType != 'behaviour' && 
                        (value == null || value.isEmpty)) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Additional notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveRecord,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildConditionSlider(String title, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getConditionLabel(value),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            inactiveTrackColor: Colors.orange.withOpacity(0.3),
            thumbColor: Colors.orange,
            overlayColor: Colors.orange.withOpacity(0.2),
            valueIndicatorColor: Colors.orange,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: value,
            min: 1.0,
            max: 10.0,
            divisions: 9,
            label: '${value.round()}/10',
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text('5', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            Text('10', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  void _saveRecord() {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;
    
    // Validate specific selections
    if (widget.recordType == 'behaviour' && _selectedBehaviour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a behaviour')),
      );
      return;
    }

    final recordData = <String, dynamic>{
      'description': _contentController.text,
      'notes': _notesController.text,
    };

    if (widget.recordType == 'condition') {
      // Save condition assessment scores
      recordData['conditionAssessment'] = {
        'bodyCondition': _bodyCondition.round(),
        'hairSkinCondition': _hairSkinCondition.round(),
        'ticksCondition': _ticksCondition.round(),
        'fleasCondition': _fleasCondition.round(),
      };
      
      // Create a summary for the condition
      final assessmentSummary = [
        'Body: ${_getConditionLabel(_bodyCondition)} (${_bodyCondition.round()}/10)',
        'Hair/Skin: ${_getConditionLabel(_hairSkinCondition)} (${_hairSkinCondition.round()}/10)',
        'Ticks: ${_getConditionLabel(_ticksCondition)} (${_ticksCondition.round()}/10)',
        'Fleas: ${_getConditionLabel(_fleasCondition)} (${_fleasCondition.round()}/10)',
      ].join(', ');
      
      recordData['conditionSummary'] = assessmentSummary;
    }

    if (widget.recordType == 'behaviour' && _selectedBehaviour != null) {
      recordData['behaviour'] = _selectedBehaviour;
    }

    Navigator.pop(context, recordData);
  }
}

// Separate dialog widget to properly manage TextEditingController lifecycle
class _EditDialog extends StatefulWidget {
  final String label;
  final String currentValue;
  final TextInputType keyboardType;

  const _EditDialog({
    required this.label,
    required this.currentValue,
    required this.keyboardType,
  });

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.label}'),
      content: TextField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          labelText: widget.label,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
} 