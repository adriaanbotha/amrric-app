import 'dart:convert';

class House {
  final String id;
  final String locationId;
  final String councilId;
  final String? houseNumber;
  final String? streetName;
  final String? suburb;
  final String? postcode;
  final double? latitude;
  final double? longitude;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  House({
    required this.id,
    required this.locationId,
    required this.councilId,
    this.houseNumber,
    this.streetName,
    this.suburb,
    this.postcode,
    this.latitude,
    this.longitude,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  House copyWith({
    String? id,
    String? locationId,
    String? councilId,
    String? houseNumber,
    String? streetName,
    String? suburb,
    String? postcode,
    double? latitude,
    double? longitude,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return House(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      councilId: councilId ?? this.councilId,
      houseNumber: houseNumber ?? this.houseNumber,
      streetName: streetName ?? this.streetName,
      suburb: suburb ?? this.suburb,
      postcode: postcode ?? this.postcode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locationId': locationId,
      'councilId': councilId,
      'houseNumber': houseNumber,
      'streetName': streetName,
      'suburb': suburb,
      'postcode': postcode,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory House.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse double values
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.isEmpty) return null;
        return double.tryParse(value);
      }
      return null;
    }

    // Helper function to safely parse boolean values
    bool parseBool(dynamic value) {
      if (value == null) return true;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      return true;
    }

    return House(
      id: json['id']?.toString() ?? '',
      locationId: json['locationId']?.toString() ?? '',
      councilId: json['councilId']?.toString() ?? '',
      houseNumber: json['houseNumber']?.toString().isEmpty == true ? null : json['houseNumber']?.toString(),
      streetName: json['streetName']?.toString().isEmpty == true ? null : json['streetName']?.toString(),
      suburb: json['suburb']?.toString().isEmpty == true ? null : json['suburb']?.toString(),
      postcode: json['postcode']?.toString().isEmpty == true ? null : json['postcode']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      description: json['description']?.toString().isEmpty == true ? null : json['description']?.toString(),
      isActive: parseBool(json['isActive']),
      createdAt: DateTime.parse(json['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'] is String ? jsonDecode(json['metadata']) : json['metadata'],
    );
  }

  bool validate() {
    return locationId.isNotEmpty && councilId.isNotEmpty;
  }

  String get fullAddress {
    final parts = <String>[];
    if (houseNumber != null) parts.add(houseNumber!);
    if (streetName != null) parts.add(streetName!);
    if (suburb != null) parts.add(suburb!);
    if (postcode != null) parts.add(postcode!);
    return parts.join(', ');
  }
} 