import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/screens/login_screen.dart';

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
      case UserRole.veterinary:
        return _buildVeterinaryContent(context);
      case UserRole.normal:
        return _buildNormalContent(context);
    }
  }

  Widget _buildSystemAdminContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('System Administration'),
        _buildFeatureCard(
          context,
          'User Management',
          Icons.people,
          () {
            // Navigate to user management
          },
        ),
        _buildFeatureCard(
          context,
          'System Configuration',
          Icons.settings,
          () {
            // Navigate to system configuration
          },
        ),
        _buildFeatureCard(
          context,
          'Global Reports',
          Icons.analytics,
          () {
            // Navigate to global reports
          },
        ),
      ],
    );
  }

  Widget _buildMunicipalityAdminContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Municipality Administration'),
        _buildFeatureCard(
          context,
          'Council Management',
          Icons.business,
          () {
            // Navigate to council management
          },
        ),
        _buildFeatureCard(
          context,
          'Location Management',
          Icons.location_city,
          () {
            // Navigate to location management
          },
        ),
        _buildFeatureCard(
          context,
          'Council Reports',
          Icons.assessment,
          () {
            // Navigate to council reports
          },
        ),
      ],
    );
  }

  Widget _buildVeterinaryContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Veterinary Mode'),
        _buildFeatureCard(
          context,
          'Animal Health',
          Icons.pets,
          () {
            // Navigate to animal health
          },
        ),
        _buildFeatureCard(
          context,
          'Clinical Notes',
          Icons.note_add,
          () {
            // Navigate to clinical notes
          },
        ),
        _buildFeatureCard(
          context,
          'Treatments',
          Icons.medical_services,
          () {
            // Navigate to treatments
          },
        ),
        _buildFeatureCard(
          context,
          'Census Data',
          Icons.people,
          () {
            // Navigate to census data
          },
        ),
      ],
    );
  }

  Widget _buildNormalContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Census Mode'),
        _buildFeatureCard(
          context,
          'House Registration',
          Icons.house,
          () {
            // Navigate to house registration
          },
        ),
        _buildFeatureCard(
          context,
          'Animal Registration',
          Icons.pets,
          () {
            // Navigate to animal registration
          },
        ),
        _buildFeatureCard(
          context,
          'Census Collection',
          Icons.people,
          () {
            // Navigate to census collection
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
} 