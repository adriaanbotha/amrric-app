import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:amrric_app/models/animal_image.dart';

part 'animal.freezed.dart';
part 'animal.g.dart';

@freezed
class Animal with _$Animal {
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
    required DateTime registrationDate,
    required DateTime lastUpdated,
    required bool isActive,
    required String houseId,
    required String locationId,
    required String councilId,
    String? ownerId,
    required List<String> photoUrls,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? censusData,
    Map<String, dynamic>? metadata,
    List<AnimalImage>? images,
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