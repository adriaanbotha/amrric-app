import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:amrric_app/models/animal_image.dart';

part 'animal.freezed.dart';
part 'animal.g.dart';

@freezed
@JsonSerializable()
class Animal with _$Animal {
  const Animal._();

  const factory Animal({
    required String id,
    String? name,
    required String species,
    String? breed,
    String? color,
    required String sex,
    @JsonKey(fromJson: _parseEstimatedAge) int? estimatedAge,
    @JsonKey(fromJson: _parseWeight) double? weight,
    String? microchipNumber,
    String? reproductiveStatus,
    String? size,
    @JsonKey(fromJson: _parseRequiredDateTime) required DateTime registrationDate,
    @JsonKey(fromJson: _parseRequiredDateTime) required DateTime lastUpdated,
    required bool isActive,
    required String houseId,
    required String locationId,
    required String councilId,
    String? ownerId,
    required List<String> photoUrls,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? censusData,
    Map<String, dynamic>? metadata,
    @JsonKey(fromJson: _parseImages) List<AnimalImage>? images,
  }) = _Animal;

  factory Animal.fromJson(Map<String, dynamic> json) {
    // Ensure photoUrls is always a List<String>
    if (json['photoUrls'] != null) {
      if (json['photoUrls'] is List) {
        json['photoUrls'] = (json['photoUrls'] as List).map((e) => e.toString()).toList();
      } else {
        json['photoUrls'] = [];
      }
    } else {
      json['photoUrls'] = [];
    }
    return _$AnimalFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AnimalToJson(this);
}

// Helper functions for JSON parsing
int? _parseEstimatedAge(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    try {
      return int.tryParse(value);
    } catch (e) {
      debugPrint('Error parsing estimatedAge: $e');
      return null;
    }
  }
  return null;
}

double? _parseWeight(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    try {
      return double.tryParse(value);
    } catch (e) {
      debugPrint('Error parsing weight: $e');
      return null;
    }
  }
  return null;
}

DateTime _parseRequiredDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (e) {
      debugPrint('Error parsing required DateTime: $e');
      throw FormatException('Invalid DateTime format: $value');
    }
  }
  throw FormatException('Invalid DateTime value: $value');
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

List<AnimalImage>? _parseImages(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    try {
      return value.map((e) => AnimalImage.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error parsing images: $e');
      return null;
    }
  }
  return null;
} 