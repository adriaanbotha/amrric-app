import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:amrric_app/models/treatment.dart';

class Treatments {
  final List<Treatment> treatments;

  Treatments({
    required this.treatments,
  });

  Treatments copyWith({
    List<Treatment>? treatments,
  }) {
    return Treatments(
      treatments: treatments ?? this.treatments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treatments': treatments.map((treatment) => treatment.toJson()).toList(),
    };
  }

  factory Treatments.fromJson(Map<String, dynamic> json) {
    List<dynamic> treatmentList = json['treatments'] ?? [];
    return Treatments(
      treatments: treatmentList.map((treatment) => Treatment.fromJson(treatment)).toList(),
    );
  }

  @override
  String toString() {
    return 'Treatments{count: ${treatments.length}}';
  }
} 