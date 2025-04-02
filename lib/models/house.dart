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
    return House(
      id: json['id'],
      locationId: json['locationId'],
      councilId: json['councilId'],
      houseNumber: json['houseNumber'],
      streetName: json['streetName'],
      suburb: json['suburb'],
      postcode: json['postcode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metadata: json['metadata'],
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