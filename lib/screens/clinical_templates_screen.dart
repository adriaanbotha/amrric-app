import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/providers/clinical_template_provider.dart';
import 'package:amrric_app/models/clinical_note_template.dart';
import 'package:amrric_app/screens/template_detail_screen.dart';
import 'package:amrric_app/screens/template_editor_screen.dart';

class ClinicalTemplatesScreen extends ConsumerWidget {
  const ClinicalTemplatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(allClinicalTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Note Templates'),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _createNewTemplate(context, ref),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading templates: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(allClinicalTemplatesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (templates) {
          if (templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No clinical note templates yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first template to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _createNewTemplate(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Template'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return _buildTemplateCard(context, template, ref);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createNewTemplate(context, ref),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, ClinicalNoteTemplate template, WidgetRef ref) {
    final totalItems = template.problems.length + template.procedures.length + template.treatments.length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.medical_services, color: Colors.white),
        ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Applies to: ${template.appliesTo}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Text(
              _getTemplateItemsSummary(template),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Last updated: ${_formatDate(template.lastUpdated)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const Spacer(),
                Text(
                  template.author,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey),
          ],
        ),
        onTap: () => _viewTemplate(context, template),
      ),
    );
  }

  String _getTemplateItemsSummary(ClinicalNoteTemplate template) {
    final List<String> parts = [];
    
    if (template.problems.isNotEmpty) {
      parts.add('${template.problems.length} problem${template.problems.length != 1 ? 's' : ''}');
    }
    if (template.procedures.isNotEmpty) {
      parts.add('${template.procedures.length} procedure${template.procedures.length != 1 ? 's' : ''}');
    }
    if (template.treatments.isNotEmpty) {
      parts.add('${template.treatments.length} treatment${template.treatments.length != 1 ? 's' : ''}');
    }
    
    if (parts.isEmpty) return 'No items';
    return parts.join(', ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}-${_getMonthName(date.month)}-${date.year.toString().substring(2)}';
    }
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  void _createNewTemplate(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TemplateEditorScreen(),
      ),
    );
    
    // If a template was created/updated, refresh the list
    if (result == true) {
      // Refresh the templates list
      ref.refresh(allClinicalTemplatesProvider);
    }
  }

  void _viewTemplate(BuildContext context, ClinicalNoteTemplate template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TemplateDetailScreen(template: template),
      ),
    );
  }
} 