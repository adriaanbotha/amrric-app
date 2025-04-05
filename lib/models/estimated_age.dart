import 'package:flutter/foundation.dart';

class EstimatedAge {
  final int years;
  final int? months;

  EstimatedAge({
    required this.years,
    this.months,
  });

  EstimatedAge copyWith({
    int? years,
    int? months,
  }) {
    return EstimatedAge(
      years: years ?? this.years,
      months: months ?? this.months,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'years': years,
      'months': months,
    };
  }

  factory EstimatedAge.fromJson(Map<String, dynamic> json) {
    return EstimatedAge(
      years: int.tryParse(json['years']?.toString() ?? '0') ?? 0,
      months: int.tryParse(json['months']?.toString() ?? '0'),
    );
  }

  @override
  String toString() {
    if (months != null && months! > 0) {
      return 'EstimatedAge{$years years, $months months}';
    }
    return 'EstimatedAge{$years years}';
  }
} 