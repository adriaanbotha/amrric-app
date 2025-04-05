import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SystemAdminScreen extends StatefulWidget {
  // ... (existing code)
  @override
  _SystemAdminScreenState createState() => _SystemAdminScreenState();
}

class _SystemAdminScreenState extends State<SystemAdminScreen> {
  // ... (existing code)

  @override
  Widget build(BuildContext context) {
    // ... (existing code)
  }

  Widget _buildActivityLog(List<Map<String, dynamic>> activityLog) {
    if (activityLog.isEmpty) {
      return const Center(child: Text('No activity log available'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activityLog.length,
      itemBuilder: (context, index) {
        final entry = activityLog[index];
        try {
          final timestamp = entry['timestamp']?.toString();
          final action = entry['action']?.toString() ?? 'Unknown action';
          final details = entry['details']?.toString() ?? 'No details available';

          return ListTile(
            title: Text(action),
            subtitle: Text(details),
            trailing: timestamp != null
                ? Text(
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(timestamp)),
                    style: const TextStyle(fontSize: 12),
                  )
                : const Text('No timestamp'),
          );
        } catch (e) {
          debugPrint('Error parsing activity log entry: $e');
          return ListTile(
            title: const Text('Invalid activity log entry'),
            subtitle: Text('Raw data: ${entry.toString()}'),
          );
        }
      },
    );
  }
} 