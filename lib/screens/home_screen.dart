import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/screens/login_screen.dart';
import 'package:amrric_app/screens/admin/user_management_screen.dart';
import 'package:amrric_app/screens/admin/system_settings_screen.dart';
import 'package:amrric_app/screens/reports_screen.dart';
import 'package:amrric_app/screens/admin/council_management_screen.dart';
import 'package:amrric_app/screens/profile_screen.dart';
import 'package:amrric_app/screens/admin/location_management_screen.dart';
import 'package:amrric_app/screens/admin/animal_management_screen.dart';
import 'package:amrric_app/screens/census_data_screen.dart';
import 'package:amrric_app/screens/census_location_data_screen.dart';
import 'package:amrric_app/screens/house_management_screen.dart';
import 'package:amrric_app/widgets/app_scaffold.dart';
import 'package:amrric_app/screens/council_selection_screen.dart';

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

    return AppScaffold(
      appBar: AppBar(
        title: const Text('AMRRIC'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user.name),
              accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            // Profile Section
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            // Admin Section
            if (user.role == UserRole.systemAdmin) ...[
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('User Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.business),
                title: const Text('Council Management'),
                onTap: () {
                  Navigator.pop(context);
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LocationManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('House Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HouseManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('System Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SystemSettingsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_applications),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Divider(),
            ],
            // Veterinary User Section
            if (user.role == UserRole.veterinaryUser) ...[
              ListTile(
                leading: const Icon(Icons.pets),
                title: const Text('Animals'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/animals');
                },
              ),
              ListTile(
                leading: const Icon(Icons.medication),
                title: const Text('Medications'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/medications');
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_services),
                title: const Text('Clinical Templates'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/clinical-templates');
                },
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('House Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HouseManagementScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
            ],
            // Census User Section
            if (user.role == UserRole.censusUser) ...[
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Census Data'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CensusDataScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('House Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HouseManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.pets),
                title: const Text('Animal Records'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnimalManagementScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location Data'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CensusLocationDataScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
            ],
            // Reports Section
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await authService.logout();
                await authService.clearLastLoggedInEmail();
                ref.read(authStateProvider.notifier).state = null;
                ref.invalidate(authServiceProvider);
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
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
        return _buildVeterinaryUserContent(context, user);
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
          'House Management',
          Icons.home,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HouseManagementScreen(),
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
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportsScreen(),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          'Council Management',
          Icons.location_city,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CouncilManagementScreen(),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          'Settings',
          Icons.settings_applications,
          () => Navigator.pushNamed(context, '/settings'),
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
          'Council Data',
          Icons.location_city,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CouncilManagementScreen(),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          'Community Management',
          Icons.location_on,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationManagementScreen(),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          'Reports',
          Icons.assessment,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportsScreen(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVeterinaryUserContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user.name}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Veterinary Services',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildMenuCard(
                context,
                'Start Work',
                Icons.business,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CouncilSelectionScreen(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                'Clinical Templates',
                Icons.medical_services,
                () => Navigator.pushNamed(context, '/clinical-templates'),
              ),
              _buildMenuCard(
                context,
                'Reports',
                Icons.assessment,
                () => Navigator.pushNamed(context, '/reports'),
              ),
              _buildMenuCard(
                context,
                'Settings',
                Icons.settings,
                () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCensusUserContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Census Data Collection',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Population tracking and house management',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildMenuCard(
                context,
                'Start Census',
                Icons.business,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CouncilSelectionScreen(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                'Reports',
                Icons.assessment,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
                ),
              ),
              _buildMenuCard(
                context,
                'Settings',
                Icons.settings,
                () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ],
      ),
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