import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/clinical_note_template.dart';
import 'package:amrric_app/providers/clinical_template_provider.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';

class TemplateEditorScreen extends ConsumerStatefulWidget {
  final ClinicalNoteTemplate? existingTemplate;
  
  const TemplateEditorScreen({
    Key? key,
    this.existingTemplate,
  }) : super(key: key);

  @override
  ConsumerState<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _appliesTo = 'All';
  String _author = 'Unknown';
  List<TemplateItem> _problems = [];
  List<TemplateItem> _procedures = [];
  List<TemplateItem> _treatments = [];
  User? _currentUser;
  bool _isSaving = false;

  // Category options (same as clinical notes screen)
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

  @override
  void initState() {
    super.initState();
    final t = widget.existingTemplate;
    _nameController = TextEditingController(text: t?.name ?? '');
    _descriptionController = TextEditingController(text: t?.description ?? '');
    _appliesTo = t?.appliesTo ?? 'All';
    _author = t?.author ?? 'Unknown';
    _problems = List.from(t?.problems ?? []);
    _procedures = List.from(t?.procedures ?? []);
    _treatments = List.from(t?.treatments ?? []);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final authService = ref.read(authServiceProvider);
    _currentUser = await authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _author = _currentUser?.name ?? 'Unknown';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTemplate != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Template' : 'Create Template'),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
                         actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All Templates (Debug)',
            onPressed: () => _clearAllTemplates(),
          ),
          IconButton(
            icon: _isSaving ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ) : const Icon(Icons.save),
            tooltip: 'Save Template',
            onPressed: _isSaving ? null : _saveTemplate,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Name required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _appliesTo,
              decoration: const InputDecoration(
                labelText: 'Applies To',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Male Dogs', child: Text('Male Dogs')),
                DropdownMenuItem(value: 'Female Dogs', child: Text('Female Dogs')),
                DropdownMenuItem(value: 'Male Cats', child: Text('Male Cats')),
                DropdownMenuItem(value: 'Female Cats', child: Text('Female Cats')),
              ],
              onChanged: (val) => setState(() => _appliesTo = val ?? 'All'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
                         const SizedBox(height: 24),
             
             // Problems Section
             _buildSection(
               title: 'Problems',
               icon: Icons.warning,
               color: Colors.red,
               items: _problems,
               onAdd: () => _showProblemPicker(),
               onEdit: (index) => _editProblemNotes(index),
               onDelete: (index) => _deleteProblem(index),
               onReorder: (oldIndex, newIndex) => _reorderProblems(oldIndex, newIndex),
             ),
             
             const SizedBox(height: 24),
             
             // Procedures Section
             _buildSection(
               title: 'Procedures',
               icon: Icons.medical_services,
               color: Colors.blue,
               items: _procedures,
               onAdd: () => _showProcedurePicker(),
               onEdit: (index) => _editProcedureNotes(index),
               onDelete: (index) => _deleteProcedure(index),
               onReorder: (oldIndex, newIndex) => _reorderProcedures(oldIndex, newIndex),
             ),
             
             const SizedBox(height: 24),
             
             // Treatments Section
             _buildSection(
               title: 'Treatments',
               icon: Icons.medication,
               color: Colors.green,
               items: _treatments,
               onAdd: () => _showTreatmentPicker(),
               onEdit: (index) => _editTreatmentNotes(index),
               onDelete: (index) => _deleteTreatment(index),
               onReorder: (oldIndex, newIndex) => _reorderTreatments(oldIndex, newIndex),
             ),
             
             const SizedBox(height: 32),
             
             // Summary
             if (_problems.isNotEmpty || _procedures.isNotEmpty || _treatments.isNotEmpty)
               Card(
                 color: Colors.orange.shade50,
                 child: Padding(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Icon(Icons.summarize, color: Colors.orange.shade600),
                           const SizedBox(width: 8),
                           Text(
                             'Template Summary',
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                               color: Colors.orange.shade600,
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 8),
                       Text('${_problems.length} problems, ${_procedures.length} procedures, ${_treatments.length} treatments'),
                       Text('Total items: ${_problems.length + _procedures.length + _treatments.length}'),
                     ],
                   ),
                 ),
               ),
             
             const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTemplate() async {
    if (!_formKey.currentState!.validate()) return;
    
    final totalItems = _problems.length + _procedures.length + _treatments.length;
    if (totalItems == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one problem, procedure, or treatment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final templateService = ref.read(clinicalTemplateServiceProvider);
      
      final template = ClinicalNoteTemplate(
        id: widget.existingTemplate?.id ?? templateService.generateTemplateId(_nameController.text.trim()),
        name: _nameController.text.trim(),
        appliesTo: _appliesTo,
        author: _author,
        createdAt: widget.existingTemplate?.createdAt ?? DateTime.now(),
        lastUpdated: DateTime.now(),
        problems: _problems,
        procedures: _procedures,
        treatments: _treatments,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      );

      if (widget.existingTemplate != null) {
        await templateService.updateTemplate(template);
      } else {
        await templateService.saveTemplate(template);
      }

      // Refresh the templates list
      ref.invalidate(allClinicalTemplatesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingTemplate != null 
                  ? 'Template updated successfully!' 
                  : 'Template created successfully!'
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<TemplateItem> items,
    required VoidCallback onAdd,
    required Function(int) onEdit,
    required Function(int) onDelete,
    required Function(int, int) onReorder,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add ${title.substring(0, title.length - 1)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'No ${title.toLowerCase()} added yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                onReorder: onReorder,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildItemTile(
                    key: ValueKey('${title}_$index'),
                    item: item,
                    index: index,
                    onEdit: () => onEdit(index),
                    onDelete: () => onDelete(index),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile({
    required Key key,
    required TemplateItem item,
    required int index,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.category,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        title: Text(item.value, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: item.notes.isNotEmpty ? Text(item.notes) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit, size: 20, color: Colors.blue.shade600),
              tooltip: 'Edit notes',
            ),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete, size: 20, color: Colors.red.shade600),
              tooltip: 'Delete item',
            ),
          ],
        ),
      ),
    );
  }

  // Problem picker methods
  void _showProblemPicker() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _CategoryPickerDialog(
        title: 'Add Problem',
        categories: problemCategories,
        options: problemOptions,
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _problems.add(TemplateItem(
          category: result['category']!,
          value: result['value']!,
        ));
      });
    }
  }

  void _editProblemNotes(int index) async {
    if (index >= _problems.length) return;
    final item = _problems[index];
    
    final notes = await _showNotesDialog(item.value, item.notes);
    if (notes != null && mounted) {
      setState(() {
        _problems[index] = TemplateItem(
          category: item.category,
          value: item.value,
          notes: notes,
        );
      });
    }
  }

  void _deleteProblem(int index) {
    if (index >= _problems.length) return;
    setState(() => _problems.removeAt(index));
  }

  void _reorderProblems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _problems.removeAt(oldIndex);
      _problems.insert(newIndex, item);
    });
  }

  // Procedure picker methods
  void _showProcedurePicker() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _CategoryPickerDialog(
        title: 'Add Procedure',
        categories: procedureCategories,
        options: procedureOptions,
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _procedures.add(TemplateItem(
          category: result['category']!,
          value: result['value']!,
        ));
      });
    }
  }

  void _editProcedureNotes(int index) async {
    if (index >= _procedures.length) return;
    final item = _procedures[index];
    
    final notes = await _showNotesDialog(item.value, item.notes);
    if (notes != null && mounted) {
      setState(() {
        _procedures[index] = TemplateItem(
          category: item.category,
          value: item.value,
          notes: notes,
        );
      });
    }
  }

  void _deleteProcedure(int index) {
    if (index >= _procedures.length) return;
    setState(() => _procedures.removeAt(index));
  }

  void _reorderProcedures(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _procedures.removeAt(oldIndex);
      _procedures.insert(newIndex, item);
    });
  }

  // Treatment picker methods
  void _showTreatmentPicker() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _CategoryPickerDialog(
        title: 'Add Treatment',
        categories: treatmentCategories,
        options: treatmentOptions,
      ),
    );
    
    if (result != null && mounted) {
      setState(() {
        _treatments.add(TemplateItem(
          category: result['category']!,
          value: result['value']!,
        ));
      });
    }
  }

  void _editTreatmentNotes(int index) async {
    if (index >= _treatments.length) return;
    final item = _treatments[index];
    
    final notes = await _showNotesDialog(item.value, item.notes);
    if (notes != null && mounted) {
      setState(() {
        _treatments[index] = TemplateItem(
          category: item.category,
          value: item.value,
          notes: notes,
        );
      });
    }
  }

  void _deleteTreatment(int index) {
    if (index >= _treatments.length) return;
    setState(() => _treatments.removeAt(index));
  }

  void _reorderTreatments(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _treatments.removeAt(oldIndex);
      _treatments.insert(newIndex, item);
    });
  }

  Future<void> _clearAllTemplates() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Templates'),
        content: const Text('This will delete ALL clinical templates. This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final templateService = ref.read(clinicalTemplateServiceProvider);
        await templateService.clearAllTemplates();
        
        // Refresh providers
        ref.invalidate(allClinicalTemplatesProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All templates cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing templates: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<String?> _showNotesDialog(String itemName, String currentNotes) async {
    final controller = TextEditingController(text: currentNotes);
    
    try {
      return await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Notes for $itemName'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter notes (optional)',
              border: OutlineInputBorder(),
            ),
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
    } finally {
      controller.dispose();
    }
  }
}

// Category picker dialog
class _CategoryPickerDialog extends StatefulWidget {
  final String title;
  final List<String> categories;
  final Map<String, List<String>> options;

  const _CategoryPickerDialog({
    required this.title,
    required this.categories,
    required this.options,
  });

  @override
  State<_CategoryPickerDialog> createState() => _CategoryPickerDialogState();
}

class _CategoryPickerDialogState extends State<_CategoryPickerDialog> {
  String? selectedCategory;
  String? selectedValue;
  String filter = '';

  @override
  Widget build(BuildContext context) {
    final currentOptions = selectedCategory != null 
        ? (widget.options[selectedCategory!] ?? [])
            .where((option) => option.toLowerCase().contains(filter.toLowerCase()))
            .toList()
        : <String>[];

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        height: 500,
        child: Column(
          children: [
            // Category selection
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: widget.categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              )).toList(),
              onChanged: (value) => setState(() {
                selectedCategory = value;
                selectedValue = null;
                filter = '';
              }),
            ),
            
            if (selectedCategory != null) ...[
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search options...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => filter = value),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: currentOptions.length,
                  itemBuilder: (context, index) {
                    final option = currentOptions[index];
                    return ListTile(
                      title: Text(option),
                      selected: selectedValue == option,
                      selectedTileColor: Colors.orange.withOpacity(0.1),
                      onTap: () => setState(() => selectedValue = option),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedCategory != null && selectedValue != null
              ? () => Navigator.pop(context, {
                  'category': selectedCategory!,
                  'value': selectedValue!,
                })
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade400),
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
} 