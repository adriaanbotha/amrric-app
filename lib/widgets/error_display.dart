import 'package:flutter/material.dart';

class ErrorDisplay extends StatelessWidget {
  final Object error;

  const ErrorDisplay({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${error.toString()}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 