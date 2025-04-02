import 'package:flutter/material.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/config/upstash_config.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  Map<String, dynamic> _settings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settingsJson = await UpstashConfig.redis.get('system:settings');
      setState(() {
        _settings = settingsJson ?? {
          'app': {
            'name': 'AMRRIC App',
            'version': '1.0.0',
            'maintenance_mode': false,
            'allow_registration': false,
          },
          'email': {
            'smtp_host': '',
            'smtp_port': '587',
            'smtp_username': '',
            'smtp_password': '',
            'from_email': '',
            'from_name': 'AMRRIC System',
          },
          'data_retention': {
            'audit_log_days': 90,
            'backup_frequency_days': 7,
            'auto_archive_months': 12,
          },
          'notifications': {
            'email_notifications': true,
            'system_notifications': true,
            'login_alerts': true,
          },
          'security': {
            'session_timeout_minutes': 30,
            'max_login_attempts': 5,
            'password_expiry_days': 90,
          },
        };
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _formKey.currentState?.save();
    setState(() => _isLoading = true);

    try {
      await UpstashConfig.redis.set('system:settings', _settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving settings: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildAppSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['app']['name'],
              decoration: const InputDecoration(
                labelText: 'Application Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter app name' : null,
              onSaved: (value) => _settings['app']['name'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['app']['version'],
              decoration: const InputDecoration(
                labelText: 'Version',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter version' : null,
              onSaved: (value) => _settings['app']['version'] = value,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Maintenance Mode'),
              subtitle: const Text('Enable to put the app in maintenance mode'),
              value: _settings['app']['maintenance_mode'],
              onChanged: (value) {
                setState(() => _settings['app']['maintenance_mode'] = value);
              },
            ),
            SwitchListTile(
              title: const Text('Allow Registration'),
              subtitle: const Text('Allow users to self-register'),
              value: _settings['app']['allow_registration'],
              onChanged: (value) {
                setState(() => _settings['app']['allow_registration'] = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Email Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['email']['smtp_host'],
              decoration: const InputDecoration(
                labelText: 'SMTP Host',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _settings['email']['smtp_host'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['email']['smtp_port'],
              decoration: const InputDecoration(
                labelText: 'SMTP Port',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onSaved: (value) => _settings['email']['smtp_port'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['email']['smtp_username'],
              decoration: const InputDecoration(
                labelText: 'SMTP Username',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _settings['email']['smtp_username'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['email']['smtp_password'],
              decoration: const InputDecoration(
                labelText: 'SMTP Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onSaved: (value) => _settings['email']['smtp_password'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['email']['from_email'],
              decoration: const InputDecoration(
                labelText: 'From Email',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _settings['email']['from_email'] = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['email']['from_name'],
              decoration: const InputDecoration(
                labelText: 'From Name',
                border: OutlineInputBorder(),
              ),
              onSaved: (value) => _settings['email']['from_name'] = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRetentionSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Retention Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['data_retention']['audit_log_days'].toString(),
              decoration: const InputDecoration(
                labelText: 'Audit Log Retention (days)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final days = int.tryParse(value);
                if (days == null || days < 1) {
                  return 'Enter a valid number of days';
                }
                return null;
              },
              onSaved: (value) => _settings['data_retention']['audit_log_days'] =
                  int.parse(value ?? '90'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue:
                  _settings['data_retention']['backup_frequency_days'].toString(),
              decoration: const InputDecoration(
                labelText: 'Backup Frequency (days)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final days = int.tryParse(value);
                if (days == null || days < 1) {
                  return 'Enter a valid number of days';
                }
                return null;
              },
              onSaved: (value) => _settings['data_retention']
                  ['backup_frequency_days'] = int.parse(value ?? '7'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue:
                  _settings['data_retention']['auto_archive_months'].toString(),
              decoration: const InputDecoration(
                labelText: 'Auto Archive After (months)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final months = int.tryParse(value);
                if (months == null || months < 1) {
                  return 'Enter a valid number of months';
                }
                return null;
              },
              onSaved: (value) => _settings['data_retention']
                  ['auto_archive_months'] = int.parse(value ?? '12'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Send notifications via email'),
              value: _settings['notifications']['email_notifications'],
              onChanged: (value) {
                setState(() =>
                    _settings['notifications']['email_notifications'] = value);
              },
            ),
            SwitchListTile(
              title: const Text('System Notifications'),
              subtitle: const Text('Show in-app notifications'),
              value: _settings['notifications']['system_notifications'],
              onChanged: (value) {
                setState(() =>
                    _settings['notifications']['system_notifications'] = value);
              },
            ),
            SwitchListTile(
              title: const Text('Login Alerts'),
              subtitle: const Text('Send alerts for suspicious login attempts'),
              value: _settings['notifications']['login_alerts'],
              onChanged: (value) {
                setState(
                    () => _settings['notifications']['login_alerts'] = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue:
                  _settings['security']['session_timeout_minutes'].toString(),
              decoration: const InputDecoration(
                labelText: 'Session Timeout (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final minutes = int.tryParse(value);
                if (minutes == null || minutes < 1) {
                  return 'Enter a valid number of minutes';
                }
                return null;
              },
              onSaved: (value) => _settings['security']['session_timeout_minutes'] =
                  int.parse(value ?? '30'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _settings['security']['max_login_attempts'].toString(),
              decoration: const InputDecoration(
                labelText: 'Maximum Login Attempts',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final attempts = int.tryParse(value);
                if (attempts == null || attempts < 1) {
                  return 'Enter a valid number of attempts';
                }
                return null;
              },
              onSaved: (value) => _settings['security']['max_login_attempts'] =
                  int.parse(value ?? '5'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue:
                  _settings['security']['password_expiry_days'].toString(),
              decoration: const InputDecoration(
                labelText: 'Password Expiry (days)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                final days = int.tryParse(value);
                if (days == null || days < 1) {
                  return 'Enter a valid number of days';
                }
                return null;
              },
              onSaved: (value) => _settings['security']['password_expiry_days'] =
                  int.parse(value ?? '90'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: _isLoading ? null : _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAppSettings(),
                  const SizedBox(height: 16),
                  _buildEmailSettings(),
                  const SizedBox(height: 16),
                  _buildDataRetentionSettings(),
                  const SizedBox(height: 16),
                  _buildNotificationSettings(),
                  const SizedBox(height: 16),
                  _buildSecuritySettings(),
                ],
              ),
            ),
    );
  }
} 