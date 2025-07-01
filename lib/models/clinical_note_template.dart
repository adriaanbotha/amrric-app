import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical_note_template.freezed.dart';
part 'clinical_note_template.g.dart';

@freezed
class ClinicalNoteTemplate with _$ClinicalNoteTemplate {
  const factory ClinicalNoteTemplate({
    required String id,
    required String name,
    required String appliesTo, // e.g., "Male Dogs", "Female Dogs", "All"
    required String author,
    required DateTime createdAt,
    required DateTime lastUpdated,
    @Default([]) List<TemplateItem> problems,
    @Default([]) List<TemplateItem> procedures,
    @Default([]) List<TemplateItem> treatments,
    String? description,
  }) = _ClinicalNoteTemplate;

  factory ClinicalNoteTemplate.fromJson(Map<String, dynamic> json) =>
      _$ClinicalNoteTemplateFromJson(json);
}

@freezed
class TemplateItem with _$TemplateItem {
  const factory TemplateItem({
    required String category,
    required String value,
    @Default('') String notes,
  }) = _TemplateItem;

  factory TemplateItem.fromJson(Map<String, dynamic> json) =>
      _$TemplateItemFromJson(json);
} 