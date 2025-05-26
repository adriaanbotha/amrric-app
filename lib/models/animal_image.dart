import 'package:flutter/foundation.dart';

class AnimalImage {
  final String id;
  final String url;
  final DateTime createdAt;

  AnimalImage({
    required this.id,
    required this.url,
    required this.createdAt,
  });

  factory AnimalImage.fromJson(Map<String, dynamic> json) {
    return AnimalImage(
      id: json['id'] as String,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 