// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_note_template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClinicalNoteTemplateImpl _$$ClinicalNoteTemplateImplFromJson(
        Map<String, dynamic> json) =>
    _$ClinicalNoteTemplateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      appliesTo: json['appliesTo'] as String,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      problems: (json['problems'] as List<dynamic>?)
              ?.map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      procedures: (json['procedures'] as List<dynamic>?)
              ?.map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      treatments: (json['treatments'] as List<dynamic>?)
              ?.map((e) => TemplateItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$ClinicalNoteTemplateImplToJson(
        _$ClinicalNoteTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'appliesTo': instance.appliesTo,
      'author': instance.author,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'problems': instance.problems,
      'procedures': instance.procedures,
      'treatments': instance.treatments,
      'description': instance.description,
    };

_$TemplateItemImpl _$$TemplateItemImplFromJson(Map<String, dynamic> json) =>
    _$TemplateItemImpl(
      category: json['category'] as String,
      value: json['value'] as String,
      notes: json['notes'] as String? ?? '',
    );

Map<String, dynamic> _$$TemplateItemImplToJson(_$TemplateItemImpl instance) =>
    <String, dynamic>{
      'category': instance.category,
      'value': instance.value,
      'notes': instance.notes,
    };
