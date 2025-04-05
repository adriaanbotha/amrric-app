import 'package:flutter/foundation.dart';
import 'dart:convert';

class Vaccination {
  final String id;
  final String animalId;
  final DateTime date;
  final String type;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? notes;
  final String userId; // ID of the vet/user who added this record
  final DateTime createdAt;
  final DateTime updatedAt;

  Vaccination({
    required this.id,
    required this.animalId,
    required this.date,
    required this.type,
    this.batchNumber,
    this.expiryDate,
    this.notes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  Vaccination copyWith({
    String? id,
    String? animalId,
    DateTime? date,
    String? type,
    String? batchNumber,
    DateTime? expiryDate,
    String? notes,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vaccination(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      date: date ?? this.date,
      type: type ?? this.type,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
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
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'notes': notes,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id']?.toString() ?? '',
      animalId: json['animalId']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString() ?? '',
      batchNumber: json['batchNumber']?.toString(),
      expiryDate: DateTime.tryParse(json['expiryDate']?.toString() ?? ''),
      notes: json['notes']?.toString(),
      userId: json['userId']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Vaccination{id: $id, animalId: $animalId, date: $date, type: $type}';
  }
} 