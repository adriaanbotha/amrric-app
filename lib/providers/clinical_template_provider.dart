import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/clinical_template_service.dart';
import 'package:amrric_app/models/clinical_note_template.dart';

// Provider for the Clinical Template Service
final clinicalTemplateServiceProvider = Provider<ClinicalTemplateService>((ref) {
  return ClinicalTemplateService();
});

// Provider for all clinical templates
final allClinicalTemplatesProvider = FutureProvider<List<ClinicalNoteTemplate>>((ref) async {
  debugPrint('🔄 Loading all clinical templates...');
  final service = ref.read(clinicalTemplateServiceProvider);
  final templates = await service.getAllTemplates();
  debugPrint('📋 Loaded ${templates.length} templates');
  return templates;
});

// Provider for templates applicable to a specific animal
final animalTemplatesProvider = FutureProvider.family<List<ClinicalNoteTemplate>, Map<String, String>>((ref, animalData) async {
  final service = ref.read(clinicalTemplateServiceProvider);
  final species = animalData['species'] ?? '';
  final sex = animalData['sex'] ?? '';
  debugPrint('🔄 Loading templates for $species $sex...');
  final templates = await service.getTemplatesForAnimal(species, sex);
  debugPrint('📋 Found ${templates.length} templates for $species $sex');
  return templates;
});

// Provider for a specific template by ID
final clinicalTemplateProvider = FutureProvider.family<ClinicalNoteTemplate?, String>((ref, templateId) async {
  final service = ref.read(clinicalTemplateServiceProvider);
  return await service.getTemplate(templateId);
}); 