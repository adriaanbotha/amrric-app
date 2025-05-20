import 'package:flutter/material.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/widgets/loading_indicator.dart';
import 'package:amrric_app/widgets/error_display.dart';
import 'package:amrric_app/config/theme.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/services/auth_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final AnimalService _animalService = AnimalService(AuthService());
  List<Animal> _animals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final animals = await _animalService.getAnimals();
      setState(() {
        _animals = animals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load animals: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_error != null) {
      return ErrorDisplay(
        error: _error!,
        onRetry: _loadAnimals,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medication Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Current Medications'),
              Tab(text: 'Medication History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCurrentMedicationsTab(),
            _buildMedicationHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMedicationsTab() {
    final animalsWithMedications = _animals.where((animal) {
      final meds = animal.medicalHistory?['medications'];
      final medications = meds is List ? meds : (meds is Map ? meds.values.toList() : []);
      return medications.isNotEmpty;
    }).toList();

    if (animalsWithMedications.isEmpty) {
      return const Center(
        child: Text('No current medications found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: animalsWithMedications.length,
      itemBuilder: (context, index) {
        final animal = animalsWithMedications[index];
        final meds = animal.medicalHistory?['medications'];
        final medications = meds is List ? meds : (meds is Map ? meds.values.toList() : []);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${animal.name ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${animal.species ?? 'Unknown'} - ${animal.breed ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...medications.map((med) {
                  final medication = med is Map<String, dynamic> ? med : {};
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${medication['name'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Dosage: ${medication['dosage'] ?? 'N/A'}'),
                        Text('Frequency: ${medication['frequency'] ?? 'N/A'}'),
                        Text('Started: ${medication['startDate'] ?? 'N/A'}'),
                        Text('Ends: ${medication['endDate'] ?? 'N/A'}'),
                        Text('Notes: ${medication['notes'] ?? 'N/A'}'),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicationHistoryTab() {
    final animalsWithHistory = _animals.where((animal) {
      final trts = animal.medicalHistory?['treatments'];
      final treatments = trts is List ? trts : (trts is Map ? trts.values.toList() : []);
      return treatments.isNotEmpty;
    }).toList();

    if (animalsWithHistory.isEmpty) {
      return const Center(
        child: Text('No medication history found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: animalsWithHistory.length,
      itemBuilder: (context, index) {
        final animal = animalsWithHistory[index];
        final trts = animal.medicalHistory?['treatments'];
        final treatments = trts is List ? trts : (trts is Map ? trts.values.toList() : []);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${animal.name ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${animal.species ?? 'Unknown'} - ${animal.breed ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...treatments.map((treatment) {
                  final t = treatment is Map<String, dynamic> ? treatment : {};
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t['type'] ?? 'Unknown'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Date: ${t['date'] ?? 'N/A'}'),
                        Text('Medication: ${t['medication'] ?? 'N/A'}'),
                        Text('Dosage: ${t['dosage'] ?? 'N/A'}'),
                        Text('Notes: ${t['notes'] ?? 'N/A'}'),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
} 