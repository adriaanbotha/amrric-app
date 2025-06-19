import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../house_management_screen.dart';

class SystemAdminScreen extends StatefulWidget {
  const SystemAdminScreen({super.key});

  @override
  _SystemAdminScreenState createState() => _SystemAdminScreenState();
}

class _SystemAdminScreenState extends State<SystemAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Administration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              'House Management',
              Icons.home,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HouseManagementScreen()),
              ),
            ),
            _buildMenuCard(
              context,
              'User Management',
              Icons.people,
              Colors.green,
              () {
                // TODO: Navigate to user management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User Management - Coming Soon')),
                );
              },
            ),
            _buildMenuCard(
              context,
              'Location Management',
              Icons.location_on,
              Colors.orange,
              () {
                // TODO: Navigate to location management
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location Management - Coming Soon')),
                );
              },
            ),
            _buildMenuCard(
              context,
              'Reports',
              Icons.assessment,
              Colors.purple,
              () {
                // TODO: Navigate to reports
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports - Coming Soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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