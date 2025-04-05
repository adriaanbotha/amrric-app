import 'package:flutter/foundation.dart';

class CouncilId {
  final String id;

  CouncilId({
    required this.id,
  });

  CouncilId copyWith({
    String? id,
  }) {
    return CouncilId(
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  factory CouncilId.fromJson(Map<String, dynamic> json) {
    return CouncilId(
      id: json['id']?.toString() ?? '',
    );
  }

  @override
  String toString() {
    return 'CouncilId{id: $id}';
  }
} 