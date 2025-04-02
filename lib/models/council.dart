import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class Council {
  final String id;
  final String name;
  final String state;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;

  Council({
    required this.id,
    required this.name,
    required this.state,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  factory Council.create() {
    final now = DateTime.now();
    return Council(
      id: const Uuid().v4(),
      name: '',
      state: '',
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  Council copyWith({
    String? id,
    String? name,
    String? state,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
  }) {
    return Council(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    debugPrint('Converting Council to JSON: $this');
    return {
      'id': id,
      'name': name,
      'state': state,
      'isActive': isActive.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory Council.fromJson(Map<String, dynamic> json) {
    debugPrint('Creating Council from JSON: $json');
    try {
      return Council(
        id: json['id'] as String,
        name: json['name'] as String,
        state: json['state'] as String,
        isActive: json['isActive'].toString().toLowerCase() == 'true',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        imageUrl: json['imageUrl'] as String?,
      );
    } catch (e, stack) {
      debugPrint('Error creating Council from JSON: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'Council(id: $id, name: $name, state: $state, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, imageUrl: $imageUrl)';
  }

  static const List<String> validStates = [
    'NT',
    'WA',
    'SA',
    'QLD',
    'NSW',
    'VIC',
    'TAS',
    'ACT',
  ];

  static const Map<String, String> stateNames = {
    'NT': 'Northern Territory',
    'WA': 'Western Australia',
    'SA': 'South Australia',
    'QLD': 'Queensland',
    'NSW': 'New South Wales',
    'VIC': 'Victoria',
    'TAS': 'Tasmania',
    'ACT': 'Australian Capital Territory',
  };

  bool validate() {
    if (name.isEmpty || name.length > 100) return false;
    if (state.isEmpty || state.length > 50) return false;
    if (!validStates.contains(state)) return false;
    return true;
  }
} 