import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:amrric_app/models/vaccination.dart';

class Vaccinations {
  final List<Vaccination> vaccinations;

  Vaccinations({
    required this.vaccinations,
  });

  Vaccinations copyWith({
    List<Vaccination>? vaccinations,
  }) {
    return Vaccinations(
      vaccinations: vaccinations ?? this.vaccinations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccinations': vaccinations.map((vaccination) => vaccination.toJson()).toList(),
    };
  }

  factory Vaccinations.fromJson(Map<String, dynamic> json) {
    List<dynamic> vaccinationList = json['vaccinations'] ?? [];
    return Vaccinations(
      vaccinations: vaccinationList.map((vaccination) => Vaccination.fromJson(vaccination)).toList(),
    );
  }

  @override
  String toString() {
    return 'Vaccinations{count: ${vaccinations.length}}';
  }
} 