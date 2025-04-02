import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/screens/login_screen.dart';
import 'package:amrric_app/screens/admin/user_management_screen.dart';
import 'package:amrric_app/screens/admin/system_settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final authService = ref.watch(authServiceProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AMRRIC'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (user.role == UserRole.systemAdmin) ...[
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('User Management'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserManagementScreen(),
                    ),
                  );
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await authService.logout();
                ref.read(authStateProvider.notifier).state = null;
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: _buildRoleBasedContent(context, user),
    );
  }

  Widget _buildRoleBasedContent(BuildContext context, User user) {
    switch (user.role) {
      case UserRole.systemAdmin:
        return _buildSystemAdminContent(context);
      case UserRole.municipalityAdmin:
        return _buildMunicipalityAdminContent(context);
      case UserRole.veterinaryUser:
        return _buildVeterinaryUserContent(context);
      case UserRole.censusUser:
        return _buildCensusUserContent(context);
    }
  }

  Widget _buildSystemAdminContent(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _buildMenuCard(
          context,
          'User Management',
          Icons.people,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserManagementScreen(),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          'System Settings',
          Icons.settings,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SystemSettingsScreen(),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          'Reports',
          Icons.assessment,
          () {
            // TODO: Implement reports
          },
        ),
        _buildMenuCard(
          context,
          'Audit Log',
          Icons.history,
          () {
            // TODO: Implement audit log
          },
        ),
      ],
    );
  }

  Widget _buildMunicipalityAdminContent(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _buildMenuCard(
          context,
          'Municipality Data',
          Icons.location_city,
          () {
            // TODO: Implement municipality data management
          },
        ),
        _buildMenuCard(
          context,
          'Reports',
          Icons.assessment,
          () {
            // TODO: Implement reports
          },
        ),
      ],
    );
  }

  Widget _buildVeterinaryUserContent(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _buildMenuCard(
          context,
          'Animal Records',
          Icons.pets,
          () {
            // TODO: Implement animal records
          },
        ),
        _buildMenuCard(
          context,
          'Treatments',
          Icons.medical_services,
          () {
            // TODO: Implement treatments
          },
        ),
      ],
    );
  }

  Widget _buildCensusUserContent(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _buildMenuCard(
          context,
          'Census Data',
          Icons.people_alt,
          () {
            // TODO: Implement census data
          },
        ),
        _buildMenuCard(
          context,
          'Reports',
          Icons.assessment,
          () {
            // TODO: Implement reports
          },
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 