import 'package:flutter/material.dart';
import 'package:amrric_app/screens/admin/location_management_screen.dart';
import 'package:amrric_app/screens/admin/council_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Council Management'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CouncilManagementScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Community Management'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationManagementScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 