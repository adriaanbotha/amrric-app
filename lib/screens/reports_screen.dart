import 'package:flutter/material.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/models/user.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/widgets/loading_indicator.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _selectedReportType;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  List<Map<String, dynamic>> _reportData = [];
  Map<String, dynamic> _reportSummary = {};
  List<String> _availableReportTypes = [];
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _loadReportTypes();
  }

  Future<void> _loadReportTypes() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        print('Current user role: ${user.role}'); // Debug print
        final reportTypes = _getAvailableReportTypes(user.role);
        print('Available report types: $reportTypes'); // Debug print
        setState(() {
          _availableReportTypes = reportTypes;
        });
      } else {
        print('No user found'); // Debug print
      }
    } catch (e) {
      print('Error loading report types: $e'); // Debug print
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report types: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> _getAvailableReportTypes(UserRole role) {
    switch (role) {
      case UserRole.systemAdmin:
        return [
          'User Activity',
          'System Usage',
          'Data Retention',
          'Audit Log',
        ];
      case UserRole.municipalityAdmin:
        return [
          'Municipality Overview',
          'Animal Population',
          'Treatment Statistics',
          'Census Data',
        ];
      case UserRole.veterinaryUser:
        return [
          'Treatment Records',
          'Animal Health',
          'Medication Usage',
          'Veterinary Services',
        ];
      case UserRole.censusUser:
        return [
          'Population Census',
          'Animal Distribution',
          'Breed Statistics',
          'Location Data',
        ];
      default:
        return [];
    }
  }

  Future<void> _generateReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      switch (_selectedReportType) {
        case 'User Activity':
          // Get all users
          final users = await _authService.getAllUsers();
          
          // Filter users based on date range and extract activity logs
          final reportData = <Map<String, dynamic>>[];
          for (final user in users) {
            final userActivities = user.activityLog.where((log) {
              final timestamp = DateTime.parse(log['timestamp']);
              return timestamp.isAfter(_startDate) && timestamp.isBefore(_endDate);
            }).map((log) => {
              ...log,
              'userId': user.id,
              'userEmail': user.email,
              'userName': user.name,
              'userRole': user.role.toString().split('.').last,
            }).toList();
            
            reportData.addAll(userActivities);
          }
          
          // Sort by timestamp
          reportData.sort((a, b) => 
            DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp']))
          );
          
          setState(() {
            _reportData = reportData;
            _reportSummary = _calculateReportSummary(reportData);
          });
          break;
          
        case 'System Usage':
          // Get all users
          final users = await _authService.getAllUsers();
          
          // Filter and process system usage data
          final reportData = <Map<String, dynamic>>[];
          for (final user in users) {
            // Filter login events within date range
            final loginEvents = user.activityLog.where((log) {
              final timestamp = DateTime.parse(log['timestamp']);
              return timestamp.isAfter(_startDate) && 
                     timestamp.isBefore(_endDate) &&
                     (log['action'] == 'login_success' || log['action'] == 'logout');
            }).map((log) => {
              ...log,
              'userId': user.id,
              'userEmail': user.email,
              'userName': user.name,
              'userRole': user.role.toString().split('.').last,
              'sessionDuration': log['action'] == 'logout' && log['sessionStartTime'] != null
                  ? DateTime.parse(log['timestamp']).difference(DateTime.parse(log['sessionStartTime'])).inMinutes
                  : null,
            }).toList();
            
            reportData.addAll(loginEvents);
          }
          
          // Sort by timestamp
          reportData.sort((a, b) => 
            DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp']))
          );
          
          setState(() {
            _reportData = reportData;
            _reportSummary = _calculateReportSummary(reportData);
          });
          break;
          
        case 'Data Retention':
          // Get all users and their data
          final users = await _authService.getAllUsers();
          
          // Process data retention metrics
          final reportData = <Map<String, dynamic>>[];
          
          for (final user in users) {
            // Calculate data age and last modification metrics
            final activityLogRetention = user.activityLog.map((log) {
              final timestamp = DateTime.parse(log['timestamp']);
              final ageInDays = DateTime.now().difference(timestamp).inDays;
              return {
                'dataType': 'Activity Log',
                'recordId': log['id'] ?? 'N/A',
                'userId': user.id,
                'userEmail': user.email,
                'timestamp': timestamp.toIso8601String(),
                'ageInDays': ageInDays,
                'dataSize': log.toString().length, // Approximate size in characters
                'retentionStatus': ageInDays > 365 ? 'Review Required' : 'Within Policy',
                'lastModified': timestamp.toIso8601String(),
              };
            }).where((record) => 
              DateTime.parse(record['timestamp']).isAfter(_startDate) && 
              DateTime.parse(record['timestamp']).isBefore(_endDate)
            );
            
            // Add user profile data retention info
            reportData.add({
              'dataType': 'User Profile',
              'recordId': user.id,
              'userId': user.id,
              'userEmail': user.email,
              'timestamp': user.createdAt.toIso8601String(),
              'ageInDays': DateTime.now().difference(user.createdAt).inDays,
              'dataSize': user.toString().length, // Approximate size in characters
              'retentionStatus': 'Active',
              'lastModified': user.updatedAt.toIso8601String(),
            });
            
            reportData.addAll(activityLogRetention);
          }
          
          // Sort by age (oldest first)
          reportData.sort((a, b) => b['ageInDays'].compareTo(a['ageInDays']));
          
          setState(() {
            _reportData = reportData;
            _reportSummary = _calculateReportSummary(reportData);
          });
          break;
          
        default:
          // Handle other report types
          final reportKey = 'reports:${user.role.name}:$_selectedReportType';
          final reportData = await UpstashConfig.redis.get(reportKey);
          
          if (reportData != null) {
            setState(() {
              _reportData = List<Map<String, dynamic>>.from(reportData);
              _reportSummary = _calculateReportSummary(_reportData);
            });
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No data available for this report')),
              );
            }
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _calculateReportSummary(List<Map<String, dynamic>> data) {
    switch (_selectedReportType) {
      case 'User Activity':
        final uniqueUsers = data.map((item) => item['userId']).toSet().length;
        final actionCounts = <String, int>{};
        for (final item in data) {
          final action = item['action'] as String;
          actionCounts[action] = (actionCounts[action] ?? 0) + 1;
        }
        
        return {
          'totalActivities': data.length,
          'uniqueUsers': uniqueUsers,
          'actionBreakdown': actionCounts,
          'dateRange': {
            'start': _startDate.toIso8601String(),
            'end': _endDate.toIso8601String(),
          },
        };
      case 'System Usage':
        final uniqueUsers = data.map((item) => item['userId']).toSet().length;
        final loginCount = data.where((item) => item['action'] == 'login_success').length;
        final logoutCount = data.where((item) => item['action'] == 'logout').length;
        
        // Calculate average session duration
        final sessionDurations = data
            .where((item) => item['sessionDuration'] != null)
            .map((item) => item['sessionDuration'] as int)
            .toList();
            
        final avgSessionDuration = sessionDurations.isNotEmpty
            ? sessionDurations.reduce((a, b) => a + b) / sessionDurations.length
            : 0;
            
        // Group by user role
        final roleUsage = _groupBy(data, 'userRole');
        
        // Calculate usage by hour of day
        final usageByHour = <int, int>{};
        for (final item in data) {
          final hour = DateTime.parse(item['timestamp']).hour;
          usageByHour[hour] = (usageByHour[hour] ?? 0) + 1;
        }
        
        return {
          'totalLogins': loginCount,
          'totalLogouts': logoutCount,
          'uniqueUsers': uniqueUsers,
          'averageSessionDuration': '${avgSessionDuration.toStringAsFixed(1)} minutes',
          'usageByRole': roleUsage,
          'peakUsageHour': usageByHour.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key,
          'dateRange': {
            'start': _startDate.toIso8601String(),
            'end': _endDate.toIso8601String(),
          },
        };
      case 'Data Retention':
        // Calculate total data size
        final totalDataSize = data.fold<int>(
          0, (sum, item) => sum + (item['dataSize'] as int)
        );
        
        // Group by data type
        final dataTypeBreakdown = _groupBy(data, 'dataType');
        
        // Calculate retention metrics
        final recordsNeedingReview = data
            .where((item) => item['retentionStatus'] == 'Review Required')
            .length;
            
        // Calculate average age of records
        final totalAge = data.fold<int>(
          0, (sum, item) => sum + (item['ageInDays'] as int)
        );
        final averageAge = data.isNotEmpty ? totalAge / data.length : 0;
        
        // Find oldest and newest records
        final oldestRecord = data.reduce(
          (a, b) => a['ageInDays'] > b['ageInDays'] ? a : b
        );
        final newestRecord = data.reduce(
          (a, b) => a['ageInDays'] < b['ageInDays'] ? a : b
        );
        
        return {
          'totalRecords': data.length,
          'totalDataSize': '${(totalDataSize / 1024).toStringAsFixed(2)} KB',
          'recordsByType': dataTypeBreakdown,
          'recordsNeedingReview': recordsNeedingReview,
          'averageRecordAge': '${averageAge.toStringAsFixed(1)} days',
          'oldestRecord': '${oldestRecord['ageInDays']} days (${oldestRecord['dataType']})',
          'newestRecord': '${newestRecord['ageInDays']} days (${newestRecord['dataType']})',
          'dateRange': {
            'start': _startDate.toIso8601String(),
            'end': _endDate.toIso8601String(),
          },
        };
      case 'Treatment Records':
        return {
          'totalTreatments': data.length,
          'completedTreatments': data.where((t) => t['status'] == 'completed').length,
          'pendingTreatments': data.where((t) => t['status'] == 'pending').length,
        };
      case 'Population Census':
        return {
          'totalAnimals': data.length,
          'bySpecies': _groupBy(data, 'species'),
          'byLocation': _groupBy(data, 'location'),
        };
      default:
        return {'totalRecords': data.length};
    }
  }

  Map<String, int> _groupBy(List<Map<String, dynamic>> data, String field) {
    final groups = <String, int>{};
    for (final item in data) {
      final value = item[field]?.toString() ?? 'Unknown';
      groups[value] = (groups[value] ?? 0) + 1;
    }
    return groups;
  }

  Widget _buildReportForm() {
    print('Building form with available types: $_availableReportTypes'); // Debug print
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_availableReportTypes.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'No report types available',
                style: TextStyle(color: Colors.red),
              ),
            ),
          DropdownButtonFormField<String>(
            value: _selectedReportType,
            decoration: const InputDecoration(
              labelText: 'Report Type',
              border: OutlineInputBorder(),
              errorStyle: TextStyle(color: Colors.red),
            ),
            items: _availableReportTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
            onChanged: (value) {
              print('Selected value: $value'); // Debug print
              setState(() => _selectedReportType = value);
            },
            validator: (value) =>
                value == null || value.isEmpty ? 'Please select a report type' : null,
            hint: const Text('Select a report type'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _startDate.toString().split(' ')[0],
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _endDate.toString().split(' ')[0],
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading || _availableReportTypes.isEmpty ? null : _generateReport,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Generate Report'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSummary() {
    if (_reportSummary.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._reportSummary.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(entry.value.toString()),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildReportData() {
    if (_reportData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _reportData.first.keys
              .map((key) => DataColumn(label: Text(key)))
              .toList(),
          rows: _reportData.map((row) {
            return DataRow(
              cells: row.values
                  .map((value) => DataCell(Text(value.toString())))
                  .toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReportForm(),
                  const SizedBox(height: 24),
                  _buildReportSummary(),
                  const SizedBox(height: 24),
                  _buildReportData(),
                ],
              ),
            ),
    );
  }
} 