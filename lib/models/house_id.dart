import 'package:flutter/foundation.dart';

class HouseId {
  final String id;

  HouseId({
    required this.id,
  });

  HouseId copyWith({
    String? id,
  }) {
    return HouseId(
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory HouseId.fromJson(Map<String, dynamic> json) {
    return HouseId(
      id: json['id']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'HouseId{id: $id}';
  }
} 