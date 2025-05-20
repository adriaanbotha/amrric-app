import 'package:flutter/material.dart';

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'AMRRIC',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Council Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/councils');
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Location Management'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin/locations');
            },
          ),
        ],
      ),
    );
  }
} 