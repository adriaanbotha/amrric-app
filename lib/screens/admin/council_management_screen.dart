import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/council.dart';
import 'package:amrric_app/services/councils_notifier.dart';

class CouncilManagementScreen extends ConsumerStatefulWidget {
  const CouncilManagementScreen({super.key});

  @override
  ConsumerState<CouncilManagementScreen> createState() => _CouncilManagementScreenState();
}

class _CouncilManagementScreenState extends ConsumerState<CouncilManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stateController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isActive = true;

  @override
  void dispose() {
    _nameController.dispose();
    _stateController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _stateController.clear();
    _imageUrlController.clear();
    _isActive = true;
  }

  void _showAddCouncilDialog() {
    _resetForm();
    _showCouncilDialog(isEdit: false);
  }

  void _showEditCouncilDialog(Council council) {
    _nameController.text = council.name;
    _stateController.text = council.state;
    _imageUrlController.text = council.imageUrl ?? '';
    _isActive = council.isActive;
    _showCouncilDialog(isEdit: true, council: council);
  }

  void _showCouncilDialog({required bool isEdit, Council? council}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Council' : 'Add New Council'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Council Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a council name';
                  }
                  if (value.length > 100) {
                    return 'Council name must be less than 100 characters';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _stateController.text.isEmpty ? null : _stateController.text,
                decoration: const InputDecoration(labelText: 'State'),
                items: Council.validStates.map((state) {
                  return DropdownMenuItem(
                    value: state,
                    child: Text('${state} - ${Council.stateNames[state]}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _stateController.text = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a state';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
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
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updatedCouncil = Council(
                  id: isEdit ? council!.id : DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  state: _stateController.text,
                  imageUrl: _imageUrlController.text,
                  isActive: _isActive,
                  createdAt: isEdit ? council!.createdAt : DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                try {
                  if (isEdit) {
                    await ref.read(councilsProvider.notifier).updateCouncil(updatedCouncil);
                  } else {
                    await ref.read(councilsProvider.notifier).addCouncil(updatedCouncil);
                  }
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit ? 'Council updated successfully' : 'Council added successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Error updating council: $e' : 'Error adding council: $e')),
                    );
                  }
                }
              }
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final councilsAsync = ref.watch(councilsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Council Management'),
        centerTitle: true,
      ),
      body: councilsAsync.when(
        data: (councils) => councils.isEmpty
            ? const Center(child: Text('No councils found'))
            : ListView.builder(
                itemCount: councils.length,
                itemBuilder: (context, index) {
                  final council = councils[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: council.imageUrl != null
                            ? NetworkImage(council.imageUrl!)
                            : null,
                        child: council.imageUrl == null
                            ? const Icon(Icons.business)
                            : null,
                      ),
                      title: Text(council.name),
                      subtitle: Text('${council.state} - ${council.isActive ? 'Active' : 'Inactive'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditCouncilDialog(council),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Council'),
                                  content: Text('Are you sure you want to delete ${council.name}?'),
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
                                  await ref.read(councilsProvider.notifier).deleteCouncil(council.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Council deleted successfully')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error deleting council: $e')),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading councils: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCouncilDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
} 