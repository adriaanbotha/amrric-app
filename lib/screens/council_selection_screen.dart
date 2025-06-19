import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/council.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/services/council_service.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/screens/community_selection_screen.dart';
import 'package:amrric_app/widgets/loading_indicator.dart';
import 'package:amrric_app/widgets/error_display.dart';

class CouncilSelectionScreen extends ConsumerStatefulWidget {
  const CouncilSelectionScreen({super.key});

  @override
  ConsumerState<CouncilSelectionScreen> createState() => _CouncilSelectionScreenState();
}

class _CouncilSelectionScreenState extends ConsumerState<CouncilSelectionScreen> {
  List<Council> _councils = [];
  List<Council> _filteredCouncils = [];
  bool _isLoading = true;
  String? _error;
  User? _currentUser;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterCouncils);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      _currentUser = await authService.getCurrentUser();
      
      final councilService = ref.read(councilServiceProvider);
      final councils = await councilService.getCouncils();
      
      // Filter councils based on user role and permissions
      final filteredCouncils = _filterCouncilsByUserRole(councils);
      
      setState(() {
        _councils = filteredCouncils;
        _filteredCouncils = filteredCouncils;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Council> _filterCouncilsByUserRole(List<Council> councils) {
    final user = _currentUser;
    if (user == null) return [];

    switch (user.role) {
      case UserRole.veterinaryUser:
      case UserRole.censusUser:
        // For now, show all active councils
        // In a real implementation, you might filter by user permissions
        return councils.where((council) => council.isActive).toList();
      default:
        return councils;
    }
  }

  void _filterCouncils() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCouncils = _councils.where((council) {
        return council.name.toLowerCase().contains(query) ||
               council.state.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _selectCouncil(Council council) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunitySelectionScreen(
          council: council,
          userRole: _currentUser!.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingIndicator(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Council')),
        body: ErrorDisplay(
          error: _error!,
          onRetry: _loadData,
        ),
      );
    }

    final userRoleTitle = _currentUser?.role == UserRole.veterinaryUser 
        ? 'Veterinary Services' 
        : 'Census Data Collection';

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Council - $userRoleTitle'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search councils...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Council list
          Expanded(
            child: _filteredCouncils.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No councils found'),
                        SizedBox(height: 8),
                        Text('Try adjusting your search terms'),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCouncils.length,
                      itemBuilder: (context, index) {
                        final council = _filteredCouncils[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                council.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              council.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('State: ${council.state}'),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      council.isActive ? Icons.check_circle : Icons.cancel,
                                      size: 16,
                                      color: council.isActive ? Colors.green : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      council.isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color: council.isActive ? Colors.green : Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _selectCouncil(council),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
} 