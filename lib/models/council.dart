import 'dart:convert';

class Council {
  final String id;
  final String name;
  final String state;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? configuration;

  Council({
    required this.id,
    required this.name,
    required this.state,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.configuration,
  });

  Council copyWith({
    String? id,
    String? name,
    String? state,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? configuration,
  }) {
    return Council(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      configuration: configuration ?? this.configuration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'state': state,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'configuration': configuration,
    };
  }

  factory Council.fromJson(Map<String, dynamic> json) {
    return Council(
      id: json['id'],
      name: json['name'],
      state: json['state'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      configuration: json['configuration'],
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