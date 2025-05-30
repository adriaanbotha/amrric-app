import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'animal_image.freezed.dart';
part 'animal_image.g.dart';

@freezed
class AnimalImage with _$AnimalImage {
  const factory AnimalImage({
    required String id,
    required String url,
    String? caption,
    DateTime? takenAt,
    String? location,
    Map<String, dynamic>? metadata,
  }) = _AnimalImage;

  factory AnimalImage.fromJson(Map<String, dynamic> json) => _$AnimalImageFromJson(json);
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      debugPrint('Error parsing DateTime: $e');
      return null;
    }
  }
  return null;
} 