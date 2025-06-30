import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/animal_records_service.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/providers/animal_records_provider.dart';
import 'package:amrric_app/models/user.dart';

class ClinicalNotesScreen extends ConsumerStatefulWidget {
  final String animalId;
  final String animalName;

  const ClinicalNotesScreen({
    Key? key,
    required this.animalId,
    required this.animalName,
  }) : super(key: key);

  @override
  ConsumerState<ClinicalNotesScreen> createState() => _ClinicalNotesScreenState();
}

class _ProblemEntry {
  final String category;
  final String value;
  final String notes;
  final String? recordId; // Add record ID to track database records
  _ProblemEntry({required this.category, required this.value, this.notes = '', this.recordId});
  _ProblemEntry copyWith({String? notes, String? recordId}) => _ProblemEntry(
    category: category, 
    value: value, 
    notes: notes ?? this.notes,
    recordId: recordId ?? this.recordId,
  );
}

class _ProcedureEntry {
  final String category;
  final String value;
  final String notes;
  final String? recordId; // Add record ID to track database records
  _ProcedureEntry({required this.category, required this.value, this.notes = '', this.recordId});
  _ProcedureEntry copyWith({String? notes, String? recordId}) => _ProcedureEntry(
    category: category, 
    value: value, 
    notes: notes ?? this.notes,
    recordId: recordId ?? this.recordId,
  );
}

class _TreatmentEntry {
  final String category;
  final String value;
  final String notes;
  final String? recordId; // Add record ID to track database records
  _TreatmentEntry({required this.category, required this.value, this.notes = '', this.recordId});
  _TreatmentEntry copyWith({String? notes, String? recordId}) => _TreatmentEntry(
    category: category, 
    value: value, 
    notes: notes ?? this.notes,
    recordId: recordId ?? this.recordId,
  );
}

class _ClinicalNotesScreenState extends ConsumerState<ClinicalNotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;

  // Problems tab state
  String selectedProblemCategory = 'Status';
  final List<String> problemCategories = ['Status', 'Clinical Sign', 'Disease'];
  final Map<String, List<String>> problemOptions = {
    'Status': [
      'Biosecurity', 'Cancel Desexing', 'Deceased', 'Fencing Issues', 'Found', 'Lost',
      'Needs Desexing', 'Stolen', 'Suspect Ehrlichia', 'Vet Needed Now', 'Welfare Case',
    ],
    'Clinical Sign': [
      'Blood in Wee', 'Dehydrated', 'Diarrhoea', 'Distended Abdomen', 'Itchy', 'Limping',
      'Lump', 'Open Wound', 'Other Sign', 'Sore Ear', 'Sore Eye', 'Vomiting',
    ],
    'Disease': [
      'Bacterial', 'CTVT', 'Fracture', 'Fungal', 'Other Disease', 'Other Neoplasia',
      'Parasitic', 'Protozoal', 'Soft Tissue', 'Vector-borne', 'Viral',
    ],
  };
  List<_ProblemEntry> addedProblems = [];

  // Procedures tab state
  String selectedProcedureCategory = 'General';
  final List<String> procedureCategories = ['General', 'Desexed', 'Surgical', 'Other'];
  final Map<String, List<String>> procedureOptions = {
    'General': [
      'Trim Nails', 'Clip Coat', 'Microchip', 'Wound Treatment', 'Clinical Exam',
    ],
    'Desexed': [
      'Desex Procedure', 'Ovariohysterectomy', 'Castration',
    ],
    'Surgical': [
      'CTVT debridement', 'Amputation', 'Lump Removal', 'Stitchup',
    ],
    'Other': [
      'Other Procedure',
    ],
  };
  List<_ProcedureEntry> addedProcedures = [];

  // Treatments tab state
  String selectedTreatmentCategory = 'Anaesthetic/Sedative';
  final List<String> treatmentCategories = [
    'Anaesthetic/Sedative', 'Analgesic', 'Antibiotic', 'Anti-Inflam',
  ];
  final Map<String, List<String>> treatmentOptions = {
    'Anaesthetic/Sedative': [
      'Xylazil 20', 'Xylazil 100', 'Zoletil 100', 'Alfaxan', 'Diazepam / Valium®', 'Medetate®/Domitor®', 'Ketamine', 'Lignocaine', 'Iso', 'Methadone', 'Propofol Lipuro 1%', 'Thiobarb', 'Torbugesic® / Butorgesic',
    ],
    'Analgesic': [
      'Carprieve® / Rimadyl® / Carprofen', 'Dexafort / Dexapent',
    ],
    'Antibiotic': [
      'Cephazolin', 'Amoxycillin', 'Clavulox', 'Doxycycline',
    ],
    'Anti-Inflam': [
      'Meloxicam / Metacam® / Loxicom', 'Pred-X / Macralone / Prednil', 'Previcox®', 'Trocoxil(R)',
    ],
  };
  List<_TreatmentEntry> addedTreatments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUser();
    // Load existing notes after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingClinicalNotes();
    });
  }

  Future<void> _loadCurrentUser() async {
    final authService = ref.read(authServiceProvider);
    _currentUser = await authService.getCurrentUser();
  }

  Future<void> _loadExistingClinicalNotes() async {
    try {
      debugPrint('📖 Loading existing clinical notes for animal: ${widget.animalId}');
      
      final recordsService = ref.read(animalRecordsServiceProvider);
      final records = await recordsService.getAnimalRecords(widget.animalId);
      
      // Filter for clinical_notes records only
      final clinicalRecords = records.where((record) => 
        record['type'] == AnimalRecordsService.typeClinicalNotes).toList();
      
      debugPrint('📋 Found ${clinicalRecords.length} clinical note records');
      
      if (clinicalRecords.isNotEmpty && mounted) {
        setState(() {
          _parseClinicalRecords(clinicalRecords);
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading clinical notes: $e');
    }
  }

  void _parseClinicalRecords(List<dynamic> records) {
    // Clear existing lists
    addedProblems.clear();
    addedProcedures.clear();
    addedTreatments.clear();
    
    for (final record in records) {
      try {
        final recordMap = record as Map<String, dynamic>;
        
        // Try both locations: direct fields and additionalData
        String? clinicalType = recordMap['clinicalType'] as String?;
        String? category = recordMap['category'] as String?;
        String? value = recordMap['value'] as String?;
        
        // If not found directly, check additionalData
        if (clinicalType == null || category == null || value == null) {
          final additionalData = recordMap['additionalData'] as Map<String, dynamic>?;
          if (additionalData != null) {
            clinicalType ??= additionalData['clinicalType'] as String?;
            category ??= additionalData['category'] as String?;
            value ??= additionalData['value'] as String?;
          }
        }
        
        final notes = recordMap['notes'] as String? ?? '';
        final recordId = recordMap['id'] as String?;
        
        debugPrint('🔍 Parsing record: id=$recordId, type=$clinicalType, category=$category, value=$value');
        
        if (clinicalType == null || category == null || value == null) {
          debugPrint('⚠️ Skipping record due to missing clinical data');
          continue;
        }
        
        switch (clinicalType) {
          case 'problem':
            addedProblems.add(_ProblemEntry(
              category: category,
              value: value,
              notes: notes,
              recordId: recordId,
            ));
            break;
          case 'procedure':
            addedProcedures.add(_ProcedureEntry(
              category: category,
              value: value,
              notes: notes,
              recordId: recordId,
            ));
            break;
          case 'treatment':
            addedTreatments.add(_TreatmentEntry(
              category: category,
              value: value,
              notes: notes,
              recordId: recordId,
            ));
            break;
        }
      } catch (e) {
        debugPrint('❌ Error parsing clinical record: $e');
      }
    }
    
    debugPrint('✅ Loaded ${addedProblems.length} problems, ${addedProcedures.length} procedures, ${addedTreatments.length} treatments');
  }

  void refreshData() {
    debugPrint('🔄 Refreshing clinical notes data...');
    _loadExistingClinicalNotes();
  }

  Future<void> _deleteClinicalNote(String? recordId, String type, String category, String value) async {
    if (recordId == null) {
      debugPrint('⚠️ Cannot delete record: no record ID');
      return;
    }

    try {
      debugPrint('🗑️ Deleting clinical $type record: $recordId');
      
      final recordsService = ref.read(animalRecordsServiceProvider);
      await recordsService.deleteRecord(widget.animalId, recordId);
      
      debugPrint('✅ Clinical note deleted successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$category removed from clinical notes'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting clinical note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting clinical note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveClinicalNote(String type, String category, String value, String notes) async {
    if (_currentUser == null) return;
    
    try {
      debugPrint('💾 Saving clinical $type: $category - $value');
      
      final recordsService = ref.read(animalRecordsServiceProvider);
      
      // Create description from category and value
      final description = '$category: $value';
      
      await recordsService.addRecord(
        animalId: widget.animalId,
        recordType: AnimalRecordsService.typeClinicalNotes,
        description: description,
        author: _currentUser!,
        specificValue: '$type:$category',
        notes: notes,
        additionalData: {
          'clinicalType': type,
          'category': category,
          'value': value,
          'animalName': widget.animalName,
        },
      );
      
      debugPrint('✅ Clinical note saved successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$category added to clinical notes'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving clinical note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving clinical note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Notes'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.green.shade200,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Problems'),
            Tab(text: 'Procedures'),
            Tab(text: 'Treatments'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProblemsTab(),
          _buildProceduresTab(),
          _buildTreatmentsTab(),
        ],
      ),
    );
  }

  Widget _buildProblemsTab() {
    return RefreshIndicator(
      onRefresh: () async => refreshData(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Subcategory buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: problemCategories.map((cat) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(cat),
                selected: selectedProblemCategory == cat,
                onSelected: (_) => setState(() => selectedProblemCategory = cat),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          // Add button
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text('Add ${selectedProblemCategory}'),
              onPressed: () => _showProblemPicker(context, selectedProblemCategory),
            ),
          ),
          const SizedBox(height: 16),
          // List of added problems
          Expanded(
            child: addedProblems.isEmpty
                ? const Center(child: Text('No problems added'))
                : ListView.builder(
                    itemCount: addedProblems.length,
                    itemBuilder: (context, idx) {
                      final entry = addedProblems[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(entry.value),
                          subtitle: entry.notes.isNotEmpty ? Text(entry.notes) : null,
                          leading: Text(entry.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final entry = addedProblems[idx];
                              await _deleteClinicalNote(entry.recordId, 'problem', entry.category, entry.value);
                              // Remove from local list and refresh data
                              setState(() => addedProblems.removeAt(idx));
                              refreshData(); // Reload from database to ensure consistency
                            },
                          ),
                          onTap: () => _editProblemNotes(context, idx),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    );
  }

  void _showProblemPicker(BuildContext context, String category) async {
    final options = problemOptions[category] ?? [];
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) => _PickerDialog(
        title: 'Select $category',
        options: options,
      ),
    );
    if (selected != null && selected.isNotEmpty && mounted) {
      setState(() {
        addedProblems.add(_ProblemEntry(category: category, value: selected));
      });
      // Save to database immediately
      await _saveClinicalNote('problem', category, selected, '');
    }
  }

  void _editProblemNotes(BuildContext context, int idx) async {
    if (idx >= addedProblems.length) return;
    final entry = addedProblems[idx];
    final controller = TextEditingController(text: entry.notes);
    
    try {
      String? updated = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Notes for ${entry.value}'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter notes (optional)'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (updated != null && mounted && idx < addedProblems.length) {
        setState(() {
          addedProblems[idx] = entry.copyWith(notes: updated);
        });
        // Update the saved record with new notes
        await _saveClinicalNote('problem', entry.category, entry.value, updated);
      }
    } finally {
      controller.dispose();
    }
  }

  Widget _buildProceduresTab() {
    return RefreshIndicator(
      onRefresh: () async => refreshData(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Subcategory buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: procedureCategories.map((cat) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(cat),
                selected: selectedProcedureCategory == cat,
                onSelected: (_) => setState(() => selectedProcedureCategory = cat),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          // Add button
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text('Add ${selectedProcedureCategory} Procedure'),
              onPressed: () => _showProcedurePicker(context, selectedProcedureCategory),
            ),
          ),
          const SizedBox(height: 16),
          // List of added procedures
          Expanded(
            child: addedProcedures.isEmpty
                ? const Center(child: Text('No procedures added'))
                : ListView.builder(
                    itemCount: addedProcedures.length,
                    itemBuilder: (context, idx) {
                      final entry = addedProcedures[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(entry.value),
                          subtitle: entry.notes.isNotEmpty ? Text(entry.notes) : null,
                          leading: Text(entry.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final entry = addedProcedures[idx];
                              await _deleteClinicalNote(entry.recordId, 'procedure', entry.category, entry.value);
                              // Remove from local list and refresh data
                              setState(() => addedProcedures.removeAt(idx));
                              refreshData(); // Reload from database to ensure consistency
                            },
                          ),
                          onTap: () => _editProcedureNotes(context, idx),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    );
  }

  void _showProcedurePicker(BuildContext context, String category) async {
    final options = procedureOptions[category] ?? [];
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) => _PickerDialog(
        title: 'Select $category Procedure',
        options: options,
      ),
    );
    if (selected != null && selected.isNotEmpty && mounted) {
      setState(() {
        addedProcedures.add(_ProcedureEntry(category: category, value: selected));
      });
      // Save to database immediately
      await _saveClinicalNote('procedure', category, selected, '');
    }
  }

  void _editProcedureNotes(BuildContext context, int idx) async {
    if (idx >= addedProcedures.length) return;
    final entry = addedProcedures[idx];
    final controller = TextEditingController(text: entry.notes);
    
    try {
      String? updated = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Notes for ${entry.value}'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter notes (optional)'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (updated != null && mounted && idx < addedProcedures.length) {
        setState(() {
          addedProcedures[idx] = entry.copyWith(notes: updated);
        });
        // Update the saved record with new notes
        await _saveClinicalNote('procedure', entry.category, entry.value, updated);
      }
    } finally {
      controller.dispose();
    }
  }

  Widget _buildTreatmentsTab() {
    return RefreshIndicator(
      onRefresh: () async => refreshData(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Subcategory buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: treatmentCategories.map((cat) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ChoiceChip(
                label: Text(cat),
                selected: selectedTreatmentCategory == cat,
                onSelected: (_) => setState(() => selectedTreatmentCategory = cat),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          // Add button
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text('Add ${selectedTreatmentCategory}'),
              onPressed: () => _showTreatmentPicker(context, selectedTreatmentCategory),
            ),
          ),
          const SizedBox(height: 16),
          // List of added treatments
          Expanded(
            child: addedTreatments.isEmpty
                ? const Center(child: Text('No treatments added'))
                : ListView.builder(
                    itemCount: addedTreatments.length,
                    itemBuilder: (context, idx) {
                      final entry = addedTreatments[idx];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(entry.value),
                          subtitle: entry.notes.isNotEmpty ? Text(entry.notes) : null,
                          leading: Text(entry.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final entry = addedTreatments[idx];
                              await _deleteClinicalNote(entry.recordId, 'treatment', entry.category, entry.value);
                              // Remove from local list and refresh data
                              setState(() => addedTreatments.removeAt(idx));
                              refreshData(); // Reload from database to ensure consistency
                            },
                          ),
                          onTap: () => _editTreatmentNotes(context, idx),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    );
  }

  void _showTreatmentPicker(BuildContext context, String category) async {
    final options = treatmentOptions[category] ?? [];
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) => _PickerDialog(
        title: 'Select $category',
        options: options,
      ),
    );
    if (selected != null && selected.isNotEmpty && mounted) {
      setState(() {
        addedTreatments.add(_TreatmentEntry(category: category, value: selected));
      });
      // Save to database immediately
      await _saveClinicalNote('treatment', category, selected, '');
    }
  }

  void _editTreatmentNotes(BuildContext context, int idx) async {
    if (idx >= addedTreatments.length) return;
    final entry = addedTreatments[idx];
    final controller = TextEditingController(text: entry.notes);
    
    try {
      String? updated = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Notes for ${entry.value}'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter notes (optional)'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (updated != null && mounted && idx < addedTreatments.length) {
        setState(() {
          addedTreatments[idx] = entry.copyWith(notes: updated);
        });
        // Update the saved record with new notes
        await _saveClinicalNote('treatment', entry.category, entry.value, updated);
      }
    } finally {
      controller.dispose();
    }
  }
}

// Separate dialog widget to avoid StatefulBuilder issues
class _PickerDialog extends StatefulWidget {
  final String title;
  final List<String> options;

  const _PickerDialog({
    required this.title,
    required this.options,
  });

  @override
  State<_PickerDialog> createState() => _PickerDialogState();
}

class _PickerDialogState extends State<_PickerDialog> {
  String filter = '';
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    final filteredOptions = widget.options
        .where((o) => o.toLowerCase().contains(filter.toLowerCase()))
        .toList();

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(hintText: 'Search...'),
            onChanged: (val) => setState(() => filter = val),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            width: 300,
            child: ListView.builder(
              itemCount: filteredOptions.length,
              itemBuilder: (context, index) {
                final option = filteredOptions[index];
                return ListTile(
                  title: Text(option),
                  selected: selectedOption == option,
                  selectedTileColor: Colors.green.withOpacity(0.1),
                  onTap: () => setState(() => selectedOption = option),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedOption != null 
              ? () => Navigator.pop(context, selectedOption) 
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
} 