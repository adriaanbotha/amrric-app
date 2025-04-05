import 'package:flutter/foundation.dart';
import 'dart:convert';

class MedicalHistory {
  final String id;
  final String animalId;
  final DateTime date;
  final String? diagnosis;
  final String? treatment;
  final String? medication;
  final String? notes;
  final String userId; // ID of the vet/user who added this record
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalHistory({
    required this.id,
    required this.animalId,
    required this.date,
    this.diagnosis,
    this.treatment,
    this.medication,
    this.notes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  MedicalHistory copyWith({
    String? id,
    String? animalId,
    DateTime? date,
    String? diagnosis,
    String? treatment,
    String? medication,
    String? notes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalHistory(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      date: date ?? this.date,
      diagnosis: diagnosis ?? this.diagnosis,
      treatment: treatment ?? this.treatment,
      medication: medication ?? this.medication,
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
      'diagnosis': diagnosis,
      'treatment': treatment,
      'medication': medication,
      'notes': notes,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MedicalHistory.fromJson(Map<String, dynamic> json) {
    return MedicalHistory(
      id: json['id']?.toString() ?? '',
      animalId: json['animalId']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      diagnosis: json['diagnosis']?.toString(),
      treatment: json['treatment']?.toString(),
      medication: json['medication']?.toString(),
      notes: json['notes']?.toString(),
      userId: json['userId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MedicalHistory{id: $id, animalId: $animalId, date: $date}';
  }
} 