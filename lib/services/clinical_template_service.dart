import 'package:flutter/foundation.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/models/clinical_note_template.dart';
import 'dart:convert';

class ClinicalTemplateService {
  static const String _templatesPrefix = 'clinical_template';
  static const String _templatesIndexKey = 'clinical_templates:all';

  /// Clean up malformed templates - call this once to fix existing data
  Future<void> cleanupMalformedTemplates() async {
    try {
      debugPrint('🧹 Cleaning up malformed templates...');
      
      // Get all template IDs
      final templateIds = await UpstashConfig.redis.smembers(_templatesIndexKey);
      if (templateIds == null || templateIds.isEmpty) return;
      
      for (final templateId in templateIds) {
        try {
          final key = '$_templatesPrefix:$templateId';
          final data = await UpstashConfig.redis.hgetall(key);
          
          if (data != null && data.isNotEmpty) {
            // Check if template data is malformed
            bool isMalformed = false;
            
            debugPrint('🔍 Cleanup checking template $templateId with data keys: ${data.keys}');
            
            for (final field in ['problems', 'procedures', 'treatments']) {
              final value = data[field];
              debugPrint('🔍 Cleanup checking field $field with value: $value (type: ${value.runtimeType})');
              
              if (value != null) {
                try {
                  List<dynamic> listData;
                  
                  if (value is List) {
                    // Already a List - this is fine
                    listData = value;
                    debugPrint('✅ Field $field is already a List with ${listData.length} items');
                  } else if (value is String) {
                    // Try to parse JSON string
                    if (value.isEmpty || value == '[]') {
                      listData = [];
                    } else {
                      listData = jsonDecode(value) as List;
                    }
                    debugPrint('✅ Field $field parsed from JSON string to List with ${listData.length} items');
                  } else {
                    debugPrint('❌ Field $field has unexpected type: ${value.runtimeType}');
                    isMalformed = true;
                    break;
                  }
                  
                  // Check each item in the list
                  for (final item in listData) {
                    if (item is Map) {
                      // Check if it has the required fields
                      if (!item.containsKey('category') || !item.containsKey('value')) {
                        debugPrint('❌ Item missing required fields: $item');
                        isMalformed = true;
                        break;
                      }
                    } else if (item != null) {
                      debugPrint('❌ Non-map item found: $item (type: ${item.runtimeType})');
                      isMalformed = true;
                      break;
                    }
                  }
                  
                  if (isMalformed) break;
                  
                } catch (e) {
                  debugPrint('❌ Error processing field $field: $e');
                  isMalformed = true;
                  break;
                }
              }
            }
            
            if (isMalformed) {
              debugPrint('🗑️ Template $templateId marked as malformed');
            } else {
              debugPrint('✅ Template $templateId passed cleanup validation');
            }
            
            if (isMalformed) {
              debugPrint('🗑️ Deleting malformed template: $templateId');
              await UpstashConfig.redis.del([key]);
              await UpstashConfig.redis.srem(_templatesIndexKey, [templateId]);
            }
          }
        } catch (e) {
          debugPrint('⚠️ Error cleaning template $templateId: $e');
        }
      }
      
      debugPrint('✅ Template cleanup completed');
    } catch (e) {
      debugPrint('❌ Error during template cleanup: $e');
    }
  }

  /// Save a new template
  Future<String> saveTemplate(ClinicalNoteTemplate template) async {
    try {
      debugPrint('💾 Saving clinical template: ${template.name}');
      
      final key = '$_templatesPrefix:${template.id}';
      
      // Convert everything to JSON strings for consistent storage
      final stringData = <String, String>{
        'id': template.id,
        'name': template.name,
        'appliesTo': template.appliesTo,
        'author': template.author,
        'createdAt': template.createdAt.toIso8601String(),
        'lastUpdated': template.lastUpdated.toIso8601String(),
        'problems': jsonEncode(template.problems.map((e) => e.toJson()).toList()),
        'procedures': jsonEncode(template.procedures.map((e) => e.toJson()).toList()),
        'treatments': jsonEncode(template.treatments.map((e) => e.toJson()).toList()),
      };
      
      // Add description if present
      if (template.description != null) {
        stringData['description'] = template.description!;
      }
      
      debugPrint('✅ Prepared data for Redis storage');
      
      // Save template to Redis
      await UpstashConfig.redis.hset(key, stringData);
      
      // Add to index
      await UpstashConfig.redis.sadd(_templatesIndexKey, [template.id]);
      
      debugPrint('✅ Template saved: ${template.id}');
      return template.id;
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving template: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all templates
  Future<List<ClinicalNoteTemplate>> getAllTemplates() async {
    try {
      debugPrint('📖 Loading all clinical templates');
      debugPrint('🔑 Using index key: $_templatesIndexKey');
      
      // Clean up malformed templates first - disabled while debugging
      // await cleanupMalformedTemplates();
      
      final templateIds = await UpstashConfig.redis.smembers(_templatesIndexKey);
      debugPrint('🔍 Found ${templateIds?.length ?? 0} template IDs: $templateIds');
      
      if (templateIds == null || templateIds.isEmpty) {
        debugPrint('⚠️ No template IDs found in index');
        
        // Try to find templates by pattern as fallback
        debugPrint('🔍 Searching for templates by pattern...');
        final keys = await UpstashConfig.redis.keys('$_templatesPrefix:*');
        debugPrint('🔍 Found ${keys?.length ?? 0} template keys: $keys');
        
        if (keys != null && keys.isNotEmpty) {
          // Extract IDs and rebuild index
          final foundIds = keys.map((key) => key.replaceFirst('$_templatesPrefix:', '')).toList();
          debugPrint('🔄 Rebuilding index with IDs: $foundIds');
          
          await UpstashConfig.redis.sadd(_templatesIndexKey, foundIds);
          return await getAllTemplates(); // Retry
        }
        
        return [];
      }
      
      final templates = <ClinicalNoteTemplate>[];
      
      for (final templateId in templateIds) {
        debugPrint('📄 Loading template: $templateId');
        final templateKey = '$_templatesPrefix:$templateId';
        final templateData = await UpstashConfig.redis.hgetall(templateKey);
        debugPrint('📊 Template data for $templateId: ${templateData?.keys}');
        
        if (templateData != null && templateData.isNotEmpty) {
          try {
            final template = _parseTemplate(templateData);
            templates.add(template);
            debugPrint('✅ Successfully parsed template: ${template.name}');
          } catch (e) {
            debugPrint('⚠️ Error parsing template $templateId: $e');
            // Don't delete templates during debugging - just skip them
            debugPrint('⏭️ Skipping template due to parsing error (not deleting)');
          }
        } else {
          debugPrint('⚠️ No data found for template $templateId');
        }
      }
      
      // Sort by name
      templates.sort((a, b) => a.name.compareTo(b.name));
      
      debugPrint('✅ Loaded ${templates.length} clinical templates');
      if (templates.isNotEmpty) {
        debugPrint('📋 Template names: ${templates.map((t) => t.name).join(', ')}');
      }
      return templates;
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading templates: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Get a specific template by ID
  Future<ClinicalNoteTemplate?> getTemplate(String templateId) async {
    try {
      final templateData = await UpstashConfig.redis.hgetall('$_templatesPrefix:$templateId');
      if (templateData != null && templateData.isNotEmpty) {
        return _parseTemplate(templateData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading template $templateId: $e');
      return null;
    }
  }

  /// Update an existing template
  Future<void> updateTemplate(ClinicalNoteTemplate template) async {
    try {
      debugPrint('🔄 Updating clinical template: ${template.name}');
      
      final updatedTemplate = template.copyWith(
        lastUpdated: DateTime.now(),
      );
      
      await saveTemplate(updatedTemplate);
      
      debugPrint('✅ Template updated successfully: ${template.id}');
    } catch (e) {
      debugPrint('❌ Error updating template: $e');
      rethrow;
    }
  }

  /// Delete a template
  Future<void> deleteTemplate(String templateId) async {
    try {
      debugPrint('🗑️ Deleting clinical template: $templateId');
      
      // Remove from index
      await UpstashConfig.redis.srem(_templatesIndexKey, [templateId]);
      
      // Delete the template data
      await UpstashConfig.redis.del(['$_templatesPrefix:$templateId']);
      
      debugPrint('✅ Template deleted successfully: $templateId');
    } catch (e) {
      debugPrint('❌ Error deleting template: $e');
      rethrow;
    }
  }

  /// Get templates that apply to a specific animal type
  Future<List<ClinicalNoteTemplate>> getTemplatesForAnimal(String species, String sex) async {
    try {
      final allTemplates = await getAllTemplates();
      final animalType = '$sex ${species}s'; // e.g., "Male Dogs", "Female Cats"
      
      return allTemplates.where((template) {
        return template.appliesTo == 'All' || 
               template.appliesTo == animalType ||
               template.appliesTo.toLowerCase().contains(species.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting templates for $species/$sex: $e');
      return [];
    }
  }

  /// Create a new template ID
  String generateTemplateId(String name) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedName = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
    return 'template_${sanitizedName}_$timestamp';
  }

  /// Clear all templates - useful for debugging
  Future<void> clearAllTemplates() async {
    try {
      debugPrint('🧹 Clearing all clinical templates...');
      
      // Get all template keys
      final templateKeys = await UpstashConfig.redis.keys('$_templatesPrefix:*');
      debugPrint('🔍 Found ${templateKeys?.length ?? 0} template keys to delete');
      
      if (templateKeys != null && templateKeys.isNotEmpty) {
        // Delete all template data
        await UpstashConfig.redis.del(templateKeys);
        debugPrint('🗑️ Deleted ${templateKeys.length} template entries');
      }
      
      // Clear the index
      await UpstashConfig.redis.del([_templatesIndexKey]);
      debugPrint('🗑️ Cleared template index');
      
      debugPrint('✅ All templates cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing templates: $e');
      rethrow;
    }
  }

  /// Helper method to convert values to string for Redis storage
  String _convertToString(dynamic value) {
    if (value is List) {
      // Check if it's a list of TemplateItem objects (or empty list from template)
      if (value.isEmpty || (value.isNotEmpty && value.first is TemplateItem)) {
        // Convert TemplateItem objects to JSON maps first
        final jsonList = (value as List<TemplateItem>).map((item) => item.toJson()).toList();
        debugPrint('🔢 Converting TemplateItem list (${value.length} items) to JSON: $jsonList');
        return jsonEncode(jsonList);
      } else {
        return jsonEncode(value);
      }
    } else if (value is Map) {
      return jsonEncode(value);
    } else if (value is DateTime) {
      return value.toIso8601String();
    }
    return value.toString();
  }

  /// Helper method to parse template data from Redis
  ClinicalNoteTemplate _parseTemplate(Map<String, dynamic> data) {
    try {
      debugPrint('🔍 Parsing template with keys: ${data.keys}');
      
      // Parse the list fields from JSON strings
      final problems = _parseTemplateItemList(data['problems'] ?? '[]');
      final procedures = _parseTemplateItemList(data['procedures'] ?? '[]');
      final treatments = _parseTemplateItemList(data['treatments'] ?? '[]');
      
      return ClinicalNoteTemplate(
        id: data['id']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        appliesTo: data['appliesTo']?.toString() ?? 'All',
        author: data['author']?.toString() ?? 'Unknown',
        createdAt: DateTime.parse(data['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
        lastUpdated: DateTime.parse(data['lastUpdated']?.toString() ?? DateTime.now().toIso8601String()),
        problems: problems,
        procedures: procedures,
        treatments: treatments,
        description: data['description']?.toString(),
      );
    } catch (e, stack) {
      debugPrint('❌ Error parsing template: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }
  
  /// Helper to parse template item lists from JSON
  List<TemplateItem> _parseTemplateItemList(dynamic value) {
    try {
      if (value == null || value.toString().isEmpty || value.toString() == '[]') {
        return [];
      }
      
      List<dynamic> itemList;
      
      // Check if Redis returned a parsed List directly
      if (value is List) {
        debugPrint('📋 Value is already a List with ${value.length} items');
        itemList = value;
      } else {
        // Try to parse as JSON string
        final jsonString = value.toString();
        debugPrint('📋 Parsing JSON string: $jsonString');
        itemList = jsonDecode(jsonString);
      }
      
      return itemList.map((item) {
        if (item is Map<String, dynamic>) {
          return TemplateItem.fromJson(item);
        } else if (item is Map) {
          // Convert Map<dynamic, dynamic> to Map<String, dynamic>
          final stringMap = <String, dynamic>{};
          item.forEach((k, v) => stringMap[k.toString()] = v);
          debugPrint('🔧 Converted map: $stringMap');
          return TemplateItem.fromJson(stringMap);
        } else {
          throw FormatException('Invalid item format: $item');
        }
      }).toList();
    } catch (e) {
      debugPrint('⚠️ Error parsing template item list: $e, value: $value (type: ${value.runtimeType})');
      return [];
    }
  }
} 