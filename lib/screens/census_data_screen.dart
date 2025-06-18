import 'package:flutter/material.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'dart:convert';

class CensusDataScreen extends StatefulWidget {
  const CensusDataScreen({Key? key}) : super(key: key);

  @override
  State<CensusDataScreen> createState() => _CensusDataScreenState();
}

class _CensusDataScreenState extends State<CensusDataScreen> {
  List<Animal> _censusAnimals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCensusAnimals();
  }

  Future<void> _loadCensusAnimals() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final redis = UpstashConfig.redis;
      final ids = await redis.smembers('animals');
      final animals = <Animal>[];
      for (final id in ids) {
        final data = await redis.hgetall('animal:$id');
        if (data != null && data.isNotEmpty) {
          try {
            animals.add(Animal.fromJson(data));
          } catch (_) {}
        }
      }
      setState(() {
        _censusAnimals = animals;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteAnimal(String id) async {
    final redis = UpstashConfig.redis;
    await redis.del(['animal:$id']);
    await redis.srem('animals', [id]);
    await _loadCensusAnimals();
  }

  void _showEditDialog([Animal? animal]) async {
    final result = await showDialog<Animal>(
      context: context,
      builder: (context) => _CensusAnimalDialog(animal: animal),
    );
    if (result != null) {
      await _saveAnimal(result);
      await _loadCensusAnimals();
    }
  }

  Future<void> _saveAnimal(Animal animal) async {
    final redis = UpstashConfig.redis;
    final key = 'animal:${animal.id}';
    final redisData = animal.toJson().map((k, v) {
      if (v is List || v is Map) {
        return MapEntry(k, jsonEncode(v));
      } else {
        return MapEntry(k, v.toString());
      }
    });
    await redis.hset(key, redisData);
    await redis.sadd('animals', [animal.id]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Census Data')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _censusAnimals.length,
                  itemBuilder: (context, i) {
                    final animal = _censusAnimals[i];
                    return ListTile(
                      title: Text(animal.name ?? animal.id),
                      subtitle: Text('${animal.species} (${animal.sex}), Age: ${animal.estimatedAge ?? '-'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog(animal),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteAnimal(animal.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _CensusAnimalDialog extends StatefulWidget {
  final Animal? animal;
  const _CensusAnimalDialog({this.animal});

  @override
  State<_CensusAnimalDialog> createState() => _CensusAnimalDialogState();
}

class _CensusAnimalDialogState extends State<_CensusAnimalDialog> {
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _sexController;
  late TextEditingController _ageController;
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.animal?.name ?? '');
    _speciesController = TextEditingController(text: widget.animal?.species ?? '');
    _sexController = TextEditingController(text: widget.animal?.sex ?? '');
    _ageController = TextEditingController(text: widget.animal?.estimatedAge?.toString() ?? '');
    _colorController = TextEditingController(text: widget.animal?.color ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _sexController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.animal == null ? 'Add Animal' : 'Edit Animal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _speciesController,
              decoration: const InputDecoration(labelText: 'Species'),
            ),
            TextField(
              controller: _sexController,
              decoration: const InputDecoration(labelText: 'Sex'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Estimated Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(labelText: 'Color'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final now = DateTime.now();
            final animal = Animal(
              id: widget.animal?.id ?? 'census_animal_${now.millisecondsSinceEpoch}',
              name: _nameController.text,
              species: _speciesController.text,
              sex: _sexController.text,
              estimatedAge: int.tryParse(_ageController.text),
              color: _colorController.text,
              breed: null,
              registrationDate: now,
              lastUpdated: now,
              isActive: true,
              houseId: widget.animal?.houseId ?? 'house_1',
              locationId: widget.animal?.locationId ?? 'location_1',
              councilId: widget.animal?.councilId ?? 'council_1',
              photoUrls: const [],
              medicalHistory: null,
              censusData: widget.animal?.censusData ?? {},
              metadata: null,
              images: null,
              ownerId: null,
              weight: null,
              microchipNumber: null,
            );
            Navigator.pop(context, animal);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 