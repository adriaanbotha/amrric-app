import 'package:flutter/foundation.dart';

class Weight {
  final double value;
  final String unit;

  Weight({
    required this.value,
    this.unit = 'kg',
  });

  Weight copyWith({
    double? value,
    String? unit,
  }) {
    return Weight(
      value: value ?? this.value,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      value: double.tryParse(json['value']?.toString() ?? '0') ?? 0,
      unit: json['unit']?.toString() ?? 'kg',
    );
  }

  @override
  String toString() {
    return 'Weight{$value $unit}';
  }
} 