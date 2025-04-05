import 'package:flutter/foundation.dart';
import 'dart:convert';

class LastUpdated {
  final DateTime date;

  LastUpdated({
    required this.date,
  });

  LastUpdated copyWith({
    DateTime? date,
  }) {
    return LastUpdated(
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
    };
  }

  factory LastUpdated.fromJson(Map<String, dynamic> json) {
    return LastUpdated(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'LastUpdated{date: $date}';
  }
} 