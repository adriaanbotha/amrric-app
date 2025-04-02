import 'package:flutter/material.dart';
import 'package:upstash_redis/upstash_redis.dart';
import '../../models/council.dart';
import '../../services/council_service.dart';
import '../../services/upstash_config.dart';
import 'location_management_screen.dart';

class CouncilManagementScreen extends StatefulWidget {
  const CouncilManagementScreen({Key? key}) : super(key: key);

  @override
  _CouncilManagementScreenState createState() => _CouncilManagementScreenState();
}

class _CouncilManagementScreenState extends State<CouncilManagementScreen> {
  final _councilService = CouncilService(UpstashConfig.redis);
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<Council> _councils = [];
  String _selectedState = '';

  @override
  void initState() {
    super.initState();
    _loadCouncils();
  }

  Future<void> _loadCouncils() async {
    setState(() => _isLoading = true);
    try {
      final councils = await _councilService.getCouncils();
      setState(() => _councils = councils);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showAddEditCouncilDialog({Council? council}) async {
    final nameController = TextEditingController(text: council?.name);
    final stateController = TextEditingController(text: council?.state);
    final imageUrlController = TextEditingController(text: council?.imageUrl);

    final result = await showDialog<Council>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(council == null ? 'Add Council' : 'Edit Council'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: stateController,
              decoration: const InputDecoration(labelText: 'State'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a state';
                }
                return null;
              },
            ),
            TextFormField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty || stateController.text.isEmpty) {
                _showError('Please fill in all required fields');
                return;
              }
              final updatedCouncil = Council(
                id: council?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                state: stateController.text,
                imageUrl: imageUrlController.text,
                isActive: council?.isActive ?? true,
                createdAt: council?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );
              Navigator.pop(context, updatedCouncil);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        if (council == null) {
          await _councilService.createCouncil(result);
        } else {
          await _councilService.updateCouncil(result);
        }
        _loadCouncils();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _confirmDelete(Council council) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Council'),
        content: Text('Are you sure you want to delete ${council.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _councilService.deleteCouncil(council.id);
        _loadCouncils();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Widget _buildCouncilList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_councils.isEmpty) {
      return const Center(child: Text('No councils found'));
    }

    return ListView.builder(
      itemCount: _councils.length,
      itemBuilder: (context, index) {
        final council = _councils[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: council.imageUrl != null
                ? NetworkImage(council.imageUrl!)
                : null,
            child: council.imageUrl == null
                ? const Icon(Icons.account_balance)
                : null,
          ),
          title: Text(council.name),
          subtitle: Text('${council.state} - ${council.isActive ? 'Active' : 'Inactive'}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.location_city),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationManagementScreen(
                      councilId: council.id,
                      councilName: council.name,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showAddEditCouncilDialog(council: council),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(council),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Council Management'),
      ),
      body: _buildCouncilList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCouncilDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
} 