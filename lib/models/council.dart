import 'dart:convert';

class Council {
  final String id;
  final String name;
  final String state;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Council({
    required this.id,
    required this.name,
    required this.state,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Council.fromMap(Map<String, dynamic> map) {
    bool parseIsActive(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return Council(
      id: map['id'] as String,
      name: map['name'] as String,
      state: map['state'] as String,
      imageUrl: map['imageUrl'] as String,
      isActive: parseIsActive(map['isActive']),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'imageUrl': imageUrl,
      'isActive': isActive.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Council copyWith({
    String? id,
    String? name,
    String? state,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Council(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Council(id: $id, name: $name, state: $state, isActive: $isActive)';
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
    return name.isNotEmpty && validStates.contains(state);
  }
} 