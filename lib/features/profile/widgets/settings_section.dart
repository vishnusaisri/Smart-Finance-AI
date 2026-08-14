import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/cache_service.dart';
import '../providers/profile_providers.dart';

class SettingsSection extends ConsumerStatefulWidget {
  const SettingsSection({super.key});

  @override
  ConsumerState<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends ConsumerState<SettingsSection> {
  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.purple[400]),
                const SizedBox(width: 12),
                Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Currency setting
            _buildSettingItem(
              context,
              'Currency',
              userProfile.getCurrencySymbol(),
              Icons.currency_exchange,
              () => _showCurrencyPicker(),
            ),
            const SizedBox(height: 16),
            
            // Locale setting
            _buildSettingItem(
              context,
              'Language',
              userProfile.locale.replaceFirst('_', ' / '),
              Icons.language,
              () => _showLocalePicker(),
            ),
            const SizedBox(height: 16),
            
            // Theme setting
            _buildSettingItem(
              context,
              'Theme',
              userProfile.darkMode ? 'Dark Mode' : 'Light Mode',
              Icons.dark_mode,
              () => _toggleTheme(),
              isToggle: true,
              toggleValue: userProfile.darkMode,
            ),
            const SizedBox(height: 16),
            
            // Notifications section
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildToggleItem(
              context,
              'Enable Notifications',
              userProfile.notificationsEnabled,
              Icons.notifications,
              (value) => ref.read(userProfileProvider.notifier).updateNotifications(
                notificationsEnabled: value,
                budgetAlertsEnabled: userProfile.budgetAlertsEnabled,
                spendingLimitAlerts: userProfile.spendingLimitAlerts,
                lowBalanceAlerts: userProfile.lowBalanceAlerts,
                weeklyReports: userProfile.weeklyReports,
                monthlyReports: userProfile.monthlyReports,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildToggleItem(
              context,
              'Budget Alerts',
              userProfile.budgetAlertsEnabled,
              Icons.warning,
              (value) => ref.read(userProfileProvider.notifier).updateNotifications(
                notificationsEnabled: userProfile.notificationsEnabled,
                budgetAlertsEnabled: value,
                spendingLimitAlerts: userProfile.spendingLimitAlerts,
                lowBalanceAlerts: userProfile.lowBalanceAlerts,
                weeklyReports: userProfile.weeklyReports,
                monthlyReports: userProfile.monthlyReports,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildToggleItem(
              context,
              'Spending Limit Alerts',
              userProfile.spendingLimitAlerts,
              Icons.currency_rupee,
              (value) => ref.read(userProfileProvider.notifier).updateNotifications(
                notificationsEnabled: userProfile.notificationsEnabled,
                budgetAlertsEnabled: userProfile.budgetAlertsEnabled,
                spendingLimitAlerts: value,
                lowBalanceAlerts: userProfile.lowBalanceAlerts,
                weeklyReports: userProfile.weeklyReports,
                monthlyReports: userProfile.monthlyReports,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildToggleItem(
              context,
              'Low Balance Alerts',
              userProfile.lowBalanceAlerts,
              Icons.account_balance,
              (value) => ref.read(userProfileProvider.notifier).updateNotifications(
                notificationsEnabled: userProfile.notificationsEnabled,
                budgetAlertsEnabled: userProfile.budgetAlertsEnabled,
                spendingLimitAlerts: userProfile.spendingLimitAlerts,
                lowBalanceAlerts: value,
                weeklyReports: userProfile.weeklyReports,
                monthlyReports: userProfile.monthlyReports,
              ),
            ),
            const SizedBox(height: 16),
            
            // Reports section
            const Divider(color: Colors.grey),
            const SizedBox(height: 16),
            
            Text(
              'Reports',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildToggleItem(
              context,
              'Weekly Reports',
              userProfile.weeklyReports,
              Icons.calendar_today,
              (value) => ref.read(userProfileProvider.notifier).updateNotifications(
                notificationsEnabled: userProfile.notificationsEnabled,
                budgetAlertsEnabled: userProfile.budgetAlertsEnabled,
                spendingLimitAlerts: userProfile.spendingLimitAlerts,
                lowBalanceAlerts: userProfile.lowBalanceAlerts,
                weeklyReports: value,
                monthlyReports: userProfile.monthlyReports,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildToggleItem(
              context,
              'Monthly Reports',
              userProfile.monthlyReports,
              Icons.calendar_month,
              (value) => ref.read(userProfileProvider.notifier).updateNotifications(
                notificationsEnabled: userProfile.notificationsEnabled,
                budgetAlertsEnabled: userProfile.budgetAlertsEnabled,
                spendingLimitAlerts: userProfile.spendingLimitAlerts,
                lowBalanceAlerts: userProfile.lowBalanceAlerts,
                weeklyReports: userProfile.weeklyReports,
                monthlyReports: value,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap, {
    bool isToggle = false,
    bool toggleValue = false,
  }) {
    return Card(
      color: const Color(0x0A1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[400]),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: isToggle
            ? Switch(
                value: toggleValue,
                onChanged: (newValue) => onTap(),
                activeThumbColor: Colors.blue,
              )
            : Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context,
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Card(
      color: const Color(0x0A1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.grey[400]),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blue,
      ),
    );
  }

  void _showCurrencyPicker() {
    final currencies = ref.read(availableCurrenciesProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Currency',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    final userProfile = ref.read(userProfileProvider);
                    final isSelected = userProfile.currency == currency['code'];
                    
                    return Card(
                      color: const Color(0x0A1E293B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Text(
                          currency['symbol']!,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        title: Text(currency['name']!),
                        trailing: isSelected
                            ? Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () {
                          ref.read(userProfileProvider.notifier).updateCurrency(currency['code']!);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Currency changed to ${currency['code']}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocalePicker() {
    final locales = ref.read(availableLocalesProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: locales.length,
                  itemBuilder: (context, index) {
                    final locale = locales[index];
                    final userProfile = ref.read(userProfileProvider);
                    final isSelected = userProfile.locale == locale['code'];
                    
                    return Card(
                      color: const Color(0x0A1E293B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(locale['name']!),
                        trailing: isSelected
                            ? Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () {
                          ref.read(userProfileProvider.notifier).updateLocale(locale['code']!);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Language changed to ${locale['name']}'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleTheme() {
    final currentTheme = ref.read(userProfileProvider).darkMode;
    final newThemeMode = !currentTheme;
    ref.read(userProfileProvider.notifier).toggleDarkMode(newThemeMode);
    ref.read(themeModeProvider.notifier).setTheme(newThemeMode ? 'dark' : 'light');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme changed to ${newThemeMode ? 'Dark' : 'Light'} Mode'),
        backgroundColor: Colors.green,
      ),
    );
  }
}