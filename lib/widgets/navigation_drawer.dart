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