import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/models/council.dart';
import 'package:amrric_app/models/location.dart';
import 'package:amrric_app/models/location_type.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/services/location_service.dart';
import 'package:amrric_app/services/house_service.dart';
import 'package:amrric_app/screens/house_list_screen.dart';
import 'package:amrric_app/widgets/loading_indicator.dart';
import 'package:amrric_app/widgets/error_display.dart';

class CommunitySelectionScreen extends ConsumerStatefulWidget {
  final Council council;
  final UserRole userRole;

  const CommunitySelectionScreen({
    super.key,
    required this.council,
    required this.userRole,
  });

  @override
  ConsumerState<CommunitySelectionScreen> createState() => _CommunitySelectionScreenState();
}

class _CommunitySelectionScreenState extends ConsumerState<CommunitySelectionScreen> {
  List<Location> _communities = [];
  List<Location> _filteredCommunities = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCommunities();
    _searchController.addListener(_filterCommunities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCommunities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locationService = ref.read(locationsProvider.notifier);
      final communities = await locationService.getLocationsByCouncil(widget.council.id);
      
      setState(() {
        _communities = communities.where((location) => location.isActive).toList();
        _filteredCommunities = _communities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterCommunities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommunities = _communities.where((community) {
        return community.name.toLowerCase().contains(query) ||
               (community.altName?.toLowerCase().contains(query) ?? false) ||
               community.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _selectCommunity(Location community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HouseListScreen(
          council: widget.council,
          community: community,
          userRole: widget.userRole,
        ),
      ),
    );
  }

  String _getLocationTypeDisplay(LocationType locationTypeId) {
    switch (locationTypeId) {
      case LocationType.urban:
        return 'Urban';
      case LocationType.rural:
        return 'Rural';
      case LocationType.indigenous:
        return 'Indigenous Community';
      case LocationType.remote:
        return 'Remote';
      default:
        return 'Other';
    }
  }

  Color _getLocationTypeColor(LocationType locationTypeId) {
    switch (locationTypeId) {
      case LocationType.urban:
        return Colors.blue;
      case LocationType.rural:
        return Colors.green;
      case LocationType.indigenous:
        return Colors.orange;
      case LocationType.remote:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getLocationTypeIcon(LocationType locationTypeId) {
    switch (locationTypeId) {
      case LocationType.urban:
        return Icons.location_city;
      case LocationType.rural:
        return Icons.landscape;
      case LocationType.indigenous:
        return Icons.group;
      case LocationType.remote:
        return Icons.place;
      default:
        return Icons.location_on;
    }
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
        appBar: AppBar(
          title: Text('Communities - ${widget.council.name}'),
        ),
        body: ErrorDisplay(
          error: _error!,
          onRetry: _loadCommunities,
        ),
      );
    }

    final userRoleTitle = widget.userRole == UserRole.veterinaryUser 
        ? 'Veterinary Services' 
        : 'Census Data Collection';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.council.name,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              userRoleTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Icon(Icons.business, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.council.name,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                const Text(
                  'Communities',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search communities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          
          // Communities list
          Expanded(
            child: _filteredCommunities.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_city_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No communities found'),
                        SizedBox(height: 8),
                        Text('Try adjusting your search terms'),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadCommunities,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredCommunities.length,
                      itemBuilder: (context, index) {
                        final community = _filteredCommunities[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: _getLocationTypeColor(community.locationTypeId),
                              child: Icon(
                                _getLocationTypeIcon(community.locationTypeId),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              community.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                if (community.altName != null)
                                  Text('Alt Name: ${community.altName}'),
                                Text('Code: ${community.code}'),
                                Text('Type: ${_getLocationTypeDisplay(community.locationTypeId)}'),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.home,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    FutureBuilder<int>(
                                      future: _getHouseCount(community.id),
                                      builder: (context, snapshot) {
                                        return Text(
                                          '${snapshot.data ?? 0} houses',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _selectCommunity(community),
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

  Future<int> _getHouseCount(String locationId) async {
    try {
      final houseService = HouseService();
      final houses = await houseService.getHousesByLocation(locationId);
      return houses.length;
    } catch (e) {
      return 0;
    }
  }
} 