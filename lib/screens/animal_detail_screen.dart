import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/animal.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/services/animal_records_service.dart';
import 'package:amrric_app/providers/animal_records_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAnimalDetails();
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
      onTap: () => _showEditDialog(label, value, onSave, keyboardType),
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
                value.isEmpty ? 'Tap to add' : '$value$suffix',
                style: TextStyle(
                  color: value.isEmpty ? Colors.grey.shade600 : Colors.black87,
                  fontStyle: value.isEmpty ? FontStyle.italic : FontStyle.normal,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(
              Icons.edit_outlined,
              size: 18,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(
    String label,
    String currentValue,
    Function(String) onSave,
    TextInputType keyboardType,
  ) async {
    final controller = TextEditingController(text: currentValue);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
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
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    
    if (result != null && result != currentValue) {
      onSave(result);
    }
    
    controller.dispose();
  }

  Future<void> _updateAnimalField(String field, dynamic value) async {
    if (_animal == null || !mounted) return;
    
    try {
      debugPrint('🔄 Updating animal field: $field = $value');
      
      // Create updated animal with new field value
      final updatedAnimal = _animal!.copyWith(
        breed: field == 'breed' ? value as String? : _animal!.breed,
        color: field == 'color' ? value as String? : _animal!.color,
        estimatedAge: field == 'estimatedAge' ? value as int? : _animal!.estimatedAge,
        weight: field == 'weight' ? value as double? : _animal!.weight,
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
                  child: Column(
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
                      
                      // Gender with icon
                      _buildInfoRow('Gender', _animal!.sex, Icons.pets),
                      const SizedBox(height: 8),
                      
                      // Breed (editable)
                      _buildEditableField(
                        'Breed',
                        _animal!.breed ?? '',
                        (value) => _updateAnimalField('breed', value),
                      ),
                      const SizedBox(height: 8),
                      
                      // Repro status
                      _buildInfoRow('Repro', 'Unknown', Icons.help_outline),
                      const SizedBox(height: 8),
                      
                      // Age (editable)
                      _buildEditableField(
                        'Age',
                        _getAgeDisplay(),
                        (value) => _updateAnimalField('estimatedAge', int.tryParse(value) ?? 0),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 8),
                      
                      // Size
                      _buildInfoRow('Size', 'Unknown', null),
                      const SizedBox(height: 8),
                      
                      // Weight (editable)
                      _buildEditableField(
                        'Weight(kg)',
                        _animal!.weight?.toString() ?? '',
                        (value) => _updateAnimalField('weight', double.tryParse(value) ?? 0.0),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 8),
                      
                      // Microchip
                      _buildInfoRow('MC', _animal!.microchipNumber ?? '', Icons.qr_code),
                      const SizedBox(height: 8),
                      
                      // Registration
                      _buildInfoRow('Registration', _formatDate(_animal!.registrationDate), null),
                      const SizedBox(height: 8),
                      
                      // Colour (editable)
                      _buildEditableField(
                        'Colour',
                        _animal!.color ?? '',
                        (value) => _updateAnimalField('color', value),
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