import 'package:flutter/foundation.dart';

class LocationId {
  final String id;

  LocationId({
    required this.id,
  });

  LocationId copyWith({
    String? id,
  }) {
    return LocationId(
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory LocationId.fromJson(Map<String, dynamic> json) {
    return LocationId(
      id: json['id']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'LocationId{id: $id}';
  }
} 