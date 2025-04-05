import 'package:flutter/foundation.dart';
import 'dart:convert';

class PhotoUrl {
  final String url;
  final DateTime uploadedAt;
  final String? caption;

  PhotoUrl({
    required this.url,
    required this.uploadedAt,
    this.caption,
  });

  PhotoUrl copyWith({
    String? url,
    DateTime? uploadedAt,
    String? caption,
  }) {
    return PhotoUrl(
      url: url ?? this.url,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      caption: caption ?? this.caption,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
      'caption': caption,
    };
  }

  factory PhotoUrl.fromJson(Map<String, dynamic> json) {
    return PhotoUrl(
      url: json['url']?.toString() ?? '',
      uploadedAt: DateTime.tryParse(json['uploadedAt']?.toString() ?? '') ?? DateTime.now(),
      caption: json['caption']?.toString(),
    );
  }

  @override
  String toString() {
    return 'PhotoUrl{url: $url, uploadedAt: $uploadedAt}';
  }
} 