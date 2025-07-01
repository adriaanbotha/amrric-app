import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/clinical_note_template.dart';
import 'package:amrric_app/screens/template_editor_screen.dart';
import 'package:amrric_app/providers/clinical_template_provider.dart';

class TemplateDetailScreen extends ConsumerWidget {
  final ClinicalNoteTemplate template;

  const TemplateDetailScreen({
    Key? key,
    required this.template,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(template.name),
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          const Icon(Icons.public, color: Colors.white),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              width: double.infinity,
              color: Colors.orange.shade400,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.appliesTo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Last updated: ${_formatDate(template.lastUpdated)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        template.author,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Template Items
            _buildItemSection('Problems', template.problems, Icons.warning, Colors.red),
            _buildItemSection('Procedures', template.procedures, Icons.medical_services, Colors.blue),
            _buildItemSection('Treatments', template.treatments, Icons.medication, Colors.green),
            
            const SizedBox(height: 100), // Space for floating action button
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editTemplate(context),
        backgroundColor: Colors.orange.shade400,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildItemSection(String title, List<TemplateItem> items, IconData icon, Color color) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildItemCard(item, title)).toList(),
      ],
    );
  }

  Widget _buildItemCard(TemplateItem item, String type) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          item.value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: item.notes.isNotEmpty 
            ? Text(item.notes)
            : null,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: Text(
          type.substring(0, type.length - 1), // Remove 's' from end
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      final timeDiff = now.difference(date).inHours;
      if (timeDiff < 1) {
        return '${now.difference(date).inMinutes} min ago';
      }
      return '${timeDiff}h ago';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}-${_getMonthName(date.month)}-${date.year.toString().substring(2)} ${_formatTime(date)}';
    }
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:${date.second.toString().padLeft(2, '0')} $period';
  }

  void _editTemplate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TemplateEditorScreen(existingTemplate: template),
      ),
    );
  }
} 