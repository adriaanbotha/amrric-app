import 'package:flutter/foundation.dart';
import 'dart:convert';

class Animal {
  final String id;
  final String? name;
  final String species;
  final String? breed;
  final String? color;
  final String sex;
  final int? estimatedAge;
  final double? weight;
  final String? microchipNumber;
  final DateTime registrationDate;
  final DateTime lastUpdated;
  final bool isActive;
  final String houseId;
  final String locationId;
  final String councilId;
  final String? ownerId;
  final List<String> photoUrls;
  final Map<String, dynamic>? medicalHistory;
  final Map<String, dynamic>? censusData;
  final Map<String, dynamic>? metadata;

  Animal({
    required this.id,
    this.name,
    required this.species,
    this.breed,
    this.color,
    required this.sex,
    this.estimatedAge,
    this.weight,
    this.microchipNumber,
    required this.registrationDate,
    required this.lastUpdated,
    required this.isActive,
    required this.houseId,
    required this.locationId,
    required this.councilId,
    this.ownerId,
    required this.photoUrls,
    this.medicalHistory,
    this.censusData,
    this.metadata,
  });

  Animal copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    String? color,
    String? sex,
    int? estimatedAge,
    double? weight,
    String? microchipNumber,
    DateTime? registrationDate,
    DateTime? lastUpdated,
    bool? isActive,
    String? houseId,
    String? locationId,
    String? councilId,
    String? ownerId,
    List<String>? photoUrls,
    Map<String, dynamic>? medicalHistory,
    Map<String, dynamic>? censusData,
    Map<String, dynamic>? metadata,
  }) {
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      sex: sex ?? this.sex,
      estimatedAge: estimatedAge ?? this.estimatedAge,
      weight: weight ?? this.weight,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      registrationDate: registrationDate ?? this.registrationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      houseId: houseId ?? this.houseId,
      locationId: locationId ?? this.locationId,
      councilId: councilId ?? this.councilId,
      ownerId: ownerId ?? this.ownerId,
      photoUrls: photoUrls ?? this.photoUrls,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      censusData: censusData ?? this.censusData,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Animal.fromJson(Map<String, dynamic> json) {
    // Parse complex types
    Map<String, dynamic>? parseMedicalHistory(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is String) {
        try {
          return Map<String, dynamic>.from(jsonDecode(value));
        } catch (e) {
          debugPrint('Error parsing medicalHistory: $e');
          return null;
        }
      }
      return null;
    }

    Map<String, dynamic>? parseCensusData(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is String) {
        try {
          return Map<String, dynamic>.from(jsonDecode(value));
        } catch (e) {
          debugPrint('Error parsing censusData: $e');
          return null;
        }
      }
      return null;
    }

    Map<String, dynamic>? parseMetadata(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is String) {
        try {
          return Map<String, dynamic>.from(jsonDecode(value));
        } catch (e) {
          debugPrint('Error parsing metadata: $e');
          return null;
        }
      }
      return null;
    }

    List<String> parsePhotoUrls(dynamic value) {
      if (value == null) return [];
      if (value is List<String>) return value;
      if (value is List) return List<String>.from(value.map((e) => e.toString()));
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return List<String>.from(decoded.map((e) => e.toString()));
          }
        } catch (e) {
          debugPrint('Error parsing photoUrls: $e');
        }
      }
      return [];
    }

    // Parse numeric fields with proper type conversion
    int? parseEstimatedAge(dynamic value) {
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

    double? parseWeight(dynamic value) {
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

    return Animal(
      id: json['id'] as String,
      name: json['name'] as String?,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      color: json['color'] as String?,
      sex: json['sex'] as String,
      estimatedAge: parseEstimatedAge(json['estimatedAge']),
      weight: parseWeight(json['weight']),
      microchipNumber: json['microchipNumber'] as String?,
      registrationDate: DateTime.parse(json['registrationDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isActive: json['isActive'] as bool,
      houseId: json['houseId'] as String,
      locationId: json['locationId'] as String,
      councilId: json['councilId'] as String,
      ownerId: json['ownerId'] as String?,
      photoUrls: parsePhotoUrls(json['photoUrls']),
      medicalHistory: parseMedicalHistory(json['medicalHistory']),
      censusData: parseCensusData(json['censusData']),
      metadata: parseMetadata(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'color': color,
      'sex': sex,
      'estimatedAge': estimatedAge,
      'weight': weight,
      'microchipNumber': microchipNumber,
      'registrationDate': registrationDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isActive': isActive,
      'houseId': houseId,
      'locationId': locationId,
      'councilId': councilId,
      'ownerId': ownerId,
      'photoUrls': photoUrls,
      'medicalHistory': medicalHistory != null ? jsonEncode(medicalHistory) : null,
      'censusData': censusData != null ? jsonEncode(censusData) : null,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  @override
  String toString() {
    return 'Animal{id: $id, name: $name, species: $species}';
  }
} 