import 'package:flutter/foundation.dart';
import 'dart:convert';

class IsActive {
  final bool value;

  IsActive({
    required this.value,
  });

  IsActive copyWith({
    bool? value,
  }) {
    return IsActive(
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }

  factory IsActive.fromJson(Map<String, dynamic> json) {
    return IsActive(
      value: json['value']?.toString().toLowerCase() == 'true' || json['value'] == true,
    );
  }

  @override
  String toString() {
    return 'IsActive{value: $value}';
  }
} 