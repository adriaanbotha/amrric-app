import 'package:flutter/foundation.dart';
import 'dart:convert';

class RegistrationDate {
  final DateTime date;

  RegistrationDate({
    required this.date,
  });

  RegistrationDate copyWith({
    DateTime? date,
  }) {
    return RegistrationDate(
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
    };
  }

  factory RegistrationDate.fromJson(Map<String, dynamic> json) {
    return RegistrationDate(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'RegistrationDate{date: $date}';
  }
} 