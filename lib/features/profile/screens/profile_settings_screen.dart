import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/widgets/toast_overlay.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import 'widgets/profile_header.dart';
import 'widgets/personal_info_form.dart';
import 'widgets/financial_goals_form.dart';
import 'widgets/settings_section.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  String _selectedCurrency = 'USD';
  String _selectedLocale = 'en_US';
  bool _notificationsEnabled = true;
  bool _aiInsightsEnabled = true;
  bool _budgetAlertsEnabled = true;

  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
  ];

  final List<Map<String, String>> _locales = [
    {'code': 'en_US', 'name': 'English (US)'},
    {'code': 'en_GB', 'name': 'English (UK)'},
    {'code': 'es_ES', 'name': 'Spanish'},
    {'code': 'fr_FR', 'name': 'French'},
    {'code': 'de_DE', 'name': 'German'},
    {'code': 'hi_IN', 'name': 'Hindi'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final cacheService = ref.read(cacheServiceProvider);
    setState(() {
      _selectedCurrency = cacheService.getCurrency();
      _selectedLocale = cacheService.getLocale();
    });
  }

  Future<void> _saveSettings() async {
    final cacheService = ref.read(cacheServiceProvider);

    await cacheService.saveCurrency(_selectedCurrency);
    await cacheService.saveLocale(_selectedLocale);

    if (mounted) {
      ref.showSuccessToast('Settings saved successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Profile Settings',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
            const SizedBox(height: 32),

            // Profile Header
            const ProfileHeader().animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            
            // Personal Information Section
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            const PersonalInfoForm().animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),

            // Financial Goals Section
            Text(
              'Financial Goals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            FinancialGoalsForm().animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),

            // Settings Section
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            SettingsSection().animate().fadeIn(delay: 550.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            
            // Account Actions
            Card(
              color: const Color(0x0A1E293B),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red[400]),
                      title: Text(
                        'Sign Out',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red[400],
                        ),
                      ),
                      onTap: () {
                        _showSignOutDialog();
                      },
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(authStateProvider.notifier).logout();
                if (mounted) {
                  context.go(RouteNames.login);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Signed out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}