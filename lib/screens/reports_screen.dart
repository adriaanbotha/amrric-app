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
    _authService = AuthService(UpstashConfig.redis);
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

      // Get report data from Redis
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
    // Calculate summary statistics based on report type
    switch (_selectedReportType) {
      case 'User Activity':
        return {
          'totalUsers': data.length,
          'activeUsers': data.where((user) => user['isActive'] == true).length,
          'lastLogin': data.map((user) => user['lastLogin']).reduce((a, b) => a.compareTo(b) > 0 ? a : b),
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