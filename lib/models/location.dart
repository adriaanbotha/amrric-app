import 'dart:convert';

class Location {
  final String id;
  final String name;
  final String? altName;
  final String code;
  final String locationTypeId;
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
    this.useLotNumber = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  Location copyWith({
    String? id,
    String? name,
    String? altName,
    String? code,
    String? locationTypeId,
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
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'altName': altName,
      'code': code,
      'locationTypeId': locationTypeId,
      'councilId': councilId,
      'useLotNumber': useLotNumber,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      altName: json['altName'],
      code: json['code'],
      locationTypeId: json['locationTypeId'],
      councilId: json['councilId'],
      useLotNumber: json['useLotNumber'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'],
    );
  }

  bool validate() {
    if (name.isEmpty || name.length > 100) return false;
    if (altName != null && altName!.length > 100) return false;
    if (code.isEmpty || code.length > 20) return false;
    if (locationTypeId.isEmpty) return false;
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