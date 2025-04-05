import 'package:flutter/foundation.dart';
import 'dart:convert';

class Treatment {
  final String id;
  final String animalId;
  final DateTime date;
  final String type;
  final String? medication;
  final String? dosage;
  final String? notes;
  final String userId; // ID of the vet/user who added this record
  final DateTime createdAt;
  final DateTime updatedAt;

  Treatment({
    required this.id,
    required this.animalId,
    required this.date,
    required this.type,
    this.medication,
    this.dosage,
    this.notes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Treatment copyWith({
    String? id,
    String? animalId,
    DateTime? date,
    String? type,
    String? medication,
    String? dosage,
    String? notes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Treatment(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      date: date ?? this.date,
      type: type ?? this.type,
      medication: medication ?? this.medication,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalId': animalId,
      'date': date.toIso8601String(),
      'type': type,
      'medication': medication,
      'dosage': dosage,
      'notes': notes,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id']?.toString() ?? '',
      animalId: json['animalId']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString() ?? '',
      medication: json['medication']?.toString(),
      dosage: json['dosage']?.toString(),
      notes: json['notes']?.toString(),
      userId: json['userId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Treatment{id: $id, animalId: $animalId, date: $date, type: $type}';
  }
} 