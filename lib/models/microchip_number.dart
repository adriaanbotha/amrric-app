import 'package:flutter/foundation.dart';

class MicrochipNumber {
  final String number;
  final DateTime? implantDate;

  MicrochipNumber({
    required this.number,
    this.implantDate,
  });

  MicrochipNumber copyWith({
    String? number,
    DateTime? implantDate,
  }) {
    return MicrochipNumber(
      number: number ?? this.number,
      implantDate: implantDate ?? this.implantDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'implantDate': implantDate?.toIso8601String(),
    };
  }

  factory MicrochipNumber.fromJson(Map<String, dynamic> json) {
    return MicrochipNumber(
      number: json['number']?.toString() ?? '',
      implantDate: DateTime.tryParse(json['implantDate']?.toString() ?? ''),
    );
  }

  @override
  String toString() {
    if (implantDate != null) {
      return 'MicrochipNumber{$number, implanted on ${implantDate!.toIso8601String()}}';
    }
    return 'MicrochipNumber{$number}';
  }
} 