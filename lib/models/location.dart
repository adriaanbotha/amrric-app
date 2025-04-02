import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:amrric_app/models/location_type.dart';
import 'package:flutter/foundation.dart';

class Location {
  final String id;
  final String name;
  final String? altName;
  final String code;
  final LocationType locationTypeId;
  final String councilId;
  final bool useLotNumber;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  Location({
    required this.id,
    required this.name,
    this.altName,
    required this.code,
    required this.locationTypeId,
    required this.councilId,
    required this.useLotNumber,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory Location.create() {
    return Location(
      id: const Uuid().v4(),
      name: '',
      code: '',
      locationTypeId: LocationType.urban,
      councilId: '',
      useLotNumber: false,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Location copyWith({
    String? id,
    String? name,
    String? altName,
    String? code,
    LocationType? locationTypeId,
    String? councilId,
    bool? useLotNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      altName: altName ?? this.altName,
      code: code ?? this.code,
      locationTypeId: locationTypeId ?? this.locationTypeId,
      councilId: councilId ?? this.councilId,
      useLotNumber: useLotNumber ?? this.useLotNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    try {
      final json = {
        'id': id,
        'name': name,
        'altName': altName,
        'code': code,
        'locationTypeId': locationTypeId.toString().split('.').last,
        'councilId': councilId,
        'useLotNumber': useLotNumber.toString(),
        'isActive': isActive.toString(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

      if (metadata != null) {
        json['metadata'] = jsonEncode(metadata);
      }

      return json;
    } catch (e, stack) {
      debugPrint('Error converting location to JSON: $e\n$stack');
      rethrow;
    }
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    try {
      return Location(
        id: json['id'] as String,
        name: json['name'] as String,
        altName: json['altName'] as String?,
        code: json['code'] as String,
        locationTypeId: LocationType.values.firstWhere(
          (e) => e.toString().split('.').last == json['locationTypeId'].toString().split('.').last,
          orElse: () => LocationType.urban,
        ),
        councilId: json['councilId'] as String,
        useLotNumber: json['useLotNumber'].toString().toLowerCase() == 'true',
        isActive: json['isActive'].toString().toLowerCase() == 'true',
        createdAt: DateTime.parse(json['createdAt'].toString()),
        updatedAt: DateTime.parse(json['updatedAt'].toString()),
        metadata: json['metadata'] is Map ? json['metadata'] as Map<String, dynamic> : null,
      );
    } catch (e, stack) {
      debugPrint('Error parsing location from JSON: $e\n$stack');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  bool validate() {
    if (name.isEmpty || name.length > 100) return false;
    if (altName != null && altName!.length > 100) return false;
    if (code.isEmpty || code.length > 20) return false;
    if (councilId.isEmpty) return false;
    return true;
  }

  static const List<String> validLocationTypes = [
    'urban',
    'rural',
    'remote',
    'indigenous',
    'other',
  ];

  static const Map<String, String> locationTypeNames = {
    'urban': 'Urban Community',
    'rural': 'Rural Community',
    'remote': 'Remote Community',
    'indigenous': 'Indigenous Community',
    'other': 'Other',
  };
} 