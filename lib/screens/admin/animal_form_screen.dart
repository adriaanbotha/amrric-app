import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/utils/permission_helper.dart';
import 'package:amrric_app/models/user.dart';

class AnimalFormScreen extends ConsumerStatefulWidget {
  final Animal? animal;

  const AnimalFormScreen({super.key, this.animal});

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

    final animalService = ref.read(animalServiceProvider);
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;

    try {
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
        houseId: widget.animal?.houseId ?? 'default', // TODO: Implement house selection
        locationId: widget.animal?.locationId ?? currentUser?.locationId ?? 'default',
        councilId: widget.animal?.councilId ?? currentUser?.councilId ?? 'council1', // Match test data
        ownerId: widget.animal?.ownerId,
        photoUrls: widget.animal?.photoUrls ?? [],
        medicalHistory: widget.animal?.medicalHistory,
        censusData: widget.animal?.censusData,
        metadata: widget.animal?.metadata,
      );

      if (widget.animal == null) {
        await animalService.addAnimal(animal);
      } else {
        await animalService.updateAnimal(animal);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final permissions = AnimalPermissions(authService);
    final isVetUser = authService.currentUser?.role == UserRole.veterinaryUser;
    final isCensusUser = authService.currentUser?.role == UserRole.censusUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animal == null ? 'Add Animal' : 'Edit Animal'),
      ),
      body: Form(
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

              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _saveAnimal,
                child: Text(widget.animal == null ? 'Add Animal' : 'Update Animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 