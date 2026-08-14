import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/services/cache_service.dart';

class SettingsSection extends ConsumerStatefulWidget {
  const SettingsSection({super.key});

  @override
  ConsumerState<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends ConsumerState<SettingsSection> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  bool _autoCategorize = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final cacheService = ref.read(cacheServiceProvider);
    setState(() {
      _notificationsEnabled = cacheService.getNotificationsEnabled();
      _darkMode = cacheService.getThemeMode() == 'dark';
      _autoCategorize = true; // Default enabled
    });
  }

  Future<void> _saveSettings() async {
    final themeMode = _darkMode ? 'dark' : 'light';
    await ref.read(themeModeProvider.notifier).setTheme(themeMode);
    final cacheService = ref.read(cacheServiceProvider);
    await cacheService.saveNotificationsEnabled(_notificationsEnabled);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Theme updated to ${_darkMode ? 'Dark' : 'Light'} Mode')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: AppTextStyles.h5),
          const SizedBox(height: AppSpacing.lg),
          Card(
            color: const Color(0x0A1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive expense reminders'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSettings();
              },
            ),
          ),
          const Divider(),
          Card(
            color: const Color(0x0A1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                _saveSettings();
              },
            ),
          ),
          const Divider(),
          Card(
            color: const Color(0x0A1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Auto-categorize'),
              subtitle: const Text('Automatically categorize expenses'),
              value: _autoCategorize,
              onChanged: (value) {
                setState(() {
                  _autoCategorize = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Auto-categorize setting updated')),
                );
              },
            ),
          ),
          const Divider(),
          Card(
            color: const Color(0x0A1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showPasswordChangeDialog();
              },
            ),
          ),
          const Divider(),
          Card(
            color: const Color(0x0A1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text('Export Data'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showExportDialog();
              },
            ),
          ),
          const Divider(),
          Card(
            color: const Color(0x0A1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change feature coming soon')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Export Data'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CSV export feature coming soon')),
              );
            },
            child: const Text('CSV'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('JSON export feature coming soon')),
              );
            },
            child: const Text('JSON'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
