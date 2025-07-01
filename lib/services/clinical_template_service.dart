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
            
            for (final field in ['problems', 'procedures', 'treatments']) {
              final value = data[field]?.toString() ?? '';
              if (value.isNotEmpty) {
                try {
                  // Try to parse the JSON to see if it's valid
                  final decoded = jsonDecode(value);
                  if (decoded is! List) {
                    isMalformed = true;
                    break;
                  }
                  // Check if it contains malformed objects (old format)
                  for (final item in decoded) {
                    if (item is Map && item.containsKey('category') && item['category'] is! String) {
                      isMalformed = true;
                      break;
                    }
                  }
                } catch (e) {
                  // If we can't parse it as JSON, it's malformed
                  isMalformed = true;
                  break;
                }
              }
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
      debugPrint('📊 Template has ${template.problems.length} problems, ${template.procedures.length} procedures, ${template.treatments.length} treatments');
      
      final templateData = template.toJson();
      final key = '$_templatesPrefix:${template.id}';
      
      debugPrint('🔑 Template key: $key');
      debugPrint('📄 Template data keys: ${templateData.keys}');
      
      // Convert template data to string format for Redis with explicit handling
      final stringData = <String, String>{};
      templateData.forEach((key, value) {
        if (key == 'problems' || key == 'procedures' || key == 'treatments') {
          // Handle template item lists specifically
          if (value is List<TemplateItem>) {
            final jsonList = value.map((item) => item.toJson()).toList();
            final jsonString = jsonEncode(jsonList);
            stringData[key] = jsonString;
          } else if (value is List) {
            // Already serialized by toJson() 
            final jsonString = jsonEncode(value);
            stringData[key] = jsonString;
          } else if (value is String) {
            // Already a JSON string
            stringData[key] = value;
          } else {
            // Fallback
            stringData[key] = jsonEncode(value);
          }
          debugPrint('🔢 Serialized $key: ${stringData[key]}');
        } else if (key == 'createdAt' || key == 'lastUpdated') {
          // Handle DateTime fields
          if (value is DateTime) {
            stringData[key] = value.toIso8601String();
          } else if (value is String) {
            // Already serialized by toJson()
            stringData[key] = value;
          } else {
            // Try to parse if it's another type
            stringData[key] = DateTime.parse(value.toString()).toIso8601String();
          }
          debugPrint('📅 Serialized $key: ${stringData[key]}');
        } else {
          stringData[key] = value.toString();
        }
      });
      
      debugPrint('🔢 String data keys: ${stringData.keys}');
      
      // Save template to Redis
      await UpstashConfig.redis.hset(key, stringData);
      debugPrint('✅ Template data saved to Redis');
      
      // Add to index
      await UpstashConfig.redis.sadd(_templatesIndexKey, [template.id]);
      debugPrint('✅ Template ID added to index');
      
      // Verify save by reading back
      final savedData = await UpstashConfig.redis.hgetall(key);
      debugPrint('🔍 Verification - saved data keys: ${savedData?.keys}');
      
      debugPrint('✅ Template saved successfully: ${template.id}');
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
      
      // Clean up malformed templates first
      await cleanupMalformedTemplates();
      
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
            // Delete malformed templates
            debugPrint('🗑️ Deleting malformed template: $templateId');
            await UpstashConfig.redis.del([templateKey]);
            await UpstashConfig.redis.srem(_templatesIndexKey, [templateId]);
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
    // Parse JSON strings back to objects
    final parsedData = <String, dynamic>{};
    
    data.forEach((key, value) {
      if (key == 'problems' || key == 'procedures' || key == 'treatments') {
        try {
          if (value == null || value.toString().isEmpty || value.toString() == 'null') {
            parsedData[key] = <TemplateItem>[];
          } else {
            debugPrint('🔍 Parsing $key with value: $value');
            
            List<dynamic> list;
            if (value is List) {
              // Already parsed as a List (Redis sometimes returns parsed objects)
              list = value;
            } else {
              // Try to parse as JSON string
              final jsonString = value.toString();
              try {
                list = jsonDecode(jsonString) as List;
              } catch (e) {
                debugPrint('⚠️ Failed to parse as JSON, trying as raw data: $e');
                // If JSON parsing fails, treat it as already parsed data
                if (value is List) {
                  list = value;
                } else {
                  throw FormatException('Cannot parse $key data: $value');
                }
              }
            }
            debugPrint('🔍 Decoded list for $key: $list');
            
            parsedData[key] = list.map((item) {
              if (item is Map) {
                // Convert to Map<String, dynamic> if needed
                final Map<String, dynamic> itemMap;
                if (item is Map<String, dynamic>) {
                  itemMap = item;
                } else {
                  // Convert from Map<dynamic, dynamic> to Map<String, dynamic>
                  itemMap = {};
                  item.forEach((k, v) {
                    itemMap[k.toString()] = v;
                  });
                }
                debugPrint('🔍 Creating TemplateItem from: $itemMap');
                return TemplateItem.fromJson(itemMap);
              } else {
                debugPrint('⚠️ Invalid item format in $key: $item (type: ${item.runtimeType})');
                return null;
              }
            }).where((item) => item != null).cast<TemplateItem>().toList();
            
            debugPrint('✅ Successfully parsed ${(parsedData[key] as List).length} items for $key');
          }
        } catch (e, stack) {
          debugPrint('⚠️ Error parsing $key: $e');
          debugPrint('⚠️ Stack trace: $stack');
          debugPrint('⚠️ Value was: $value (type: ${value.runtimeType})');
          parsedData[key] = <TemplateItem>[];
        }
      } else if (key == 'createdAt' || key == 'lastUpdated') {
        try {
          if (value is DateTime) {
            parsedData[key] = value;
          } else if (value is String) {
            parsedData[key] = DateTime.parse(value);
          } else {
            // Handle other types by converting to string first
            parsedData[key] = DateTime.parse(value.toString());
          }
        } catch (e) {
          debugPrint('⚠️ Error parsing DateTime $key: $e, value: $value (type: ${value.runtimeType})');
          // Try a more flexible approach
          try {
            if (value.toString().contains('T')) {
              parsedData[key] = DateTime.parse(value.toString());
            } else {
              parsedData[key] = DateTime.now();
            }
          } catch (e2) {
            parsedData[key] = DateTime.now();
          }
        }
      } else {
        parsedData[key] = value.toString();
      }
    });
    
    debugPrint('📋 Parsed template data keys: ${parsedData.keys}');
    debugPrint('📋 Problems count: ${(parsedData['problems'] as List?)?.length ?? 0}');
    debugPrint('📋 Procedures count: ${(parsedData['procedures'] as List?)?.length ?? 0}');
    debugPrint('📋 Treatments count: ${(parsedData['treatments'] as List?)?.length ?? 0}');
    
    return ClinicalNoteTemplate.fromJson(parsedData);
  }
} 