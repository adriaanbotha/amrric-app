import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:amrric_app/models/photo_url.dart';

class PhotoUrls {
  final List<PhotoUrl> urls;

  PhotoUrls({
    required this.urls,
  });

  PhotoUrls copyWith({
    List<PhotoUrl>? urls,
  }) {
    return PhotoUrls(
      urls: urls ?? this.urls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urls': urls.map((url) => url.toJson()).toList(),
    };
  }

  factory PhotoUrls.fromJson(Map<String, dynamic> json) {
    List<dynamic> urlList = json['urls'] ?? [];
    return PhotoUrls(
      urls: urlList.map((url) => PhotoUrl.fromJson(url)).toList(),
    );
  }

  @override
  String toString() {
    return 'PhotoUrls{count: ${urls.length}}';
  }
} 