import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart' hide Icons;

/// Settings view demonstrating query parameter extraction
class SettingsView extends StatelessWidget {
  final String? tab;

  const SettingsView({this.tab, super.key});

  @override
  Widget build(BuildContext context) {
    final routeContext = context.routeContext;
    final currentTab = tab ?? 'general';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
                  const SizedBox(width: 8),
                  const Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Current path: ${routeContext.path}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (routeContext.queryParameters.isNotEmpty)
                Text('Query parameters: ${routeContext.queryParameters}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        // Tab bar
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              _buildTab(context, 'general', 'General', currentTab),
              _buildTab(context, 'account', 'Account', currentTab),
              _buildTab(context, 'privacy', 'Privacy', currentTab),
              _buildTab(context, 'notifications', 'Notifications', currentTab),
            ],
          ),
        ),
        // Tab content
        Expanded(child: _buildTabContent(currentTab)),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String tabId, String label, String currentTab) {
    final isActive = tabId == currentTab;

    return Expanded(
      child: InkWell(
        onTap: () {
          // Navigate with query parameter
          context.go('/settings?tab=$tabId');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isActive ? Colors.blue : Colors.transparent, width: 2)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.blue : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String tab) {
    switch (tab) {
      case 'general':
        return _buildGeneralTab();
      case 'account':
        return _buildAccountTab();
      case 'privacy':
        return _buildPrivacyTab();
      case 'notifications':
        return _buildNotificationsTab();
      default:
        return _buildGeneralTab();
    }
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('General Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(title: const Text('Dark Mode'), subtitle: const Text('Enable dark theme'), value: false, onChanged: (value) {}),
              const Divider(height: 1),
              SwitchListTile(title: const Text('Auto-save'), subtitle: const Text('Automatically save changes'), value: true, onChanged: (value) {}),
              const Divider(height: 1),
              ListTile(title: const Text('Language'), subtitle: const Text('English'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.blue.shade50,
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Query Parameter Demo', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'This settings page uses query parameters to track the active tab. '
                  'Try clicking different tabs and notice how the URL changes with '
                  '?tab=<tabname> query parameter.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Account Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(title: const Text('Email'), subtitle: const Text('user@example.com'), trailing: const Icon(Icons.edit), onTap: () {}),
              const Divider(height: 1),
              ListTile(title: const Text('Password'), subtitle: const Text('••••••••'), trailing: const Icon(Icons.edit), onTap: () {}),
              const Divider(height: 1),
              ListTile(
                title: const Text('Two-Factor Authentication'),
                subtitle: const Text('Enabled'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Privacy Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Profile Visibility'),
                subtitle: const Text('Make profile visible to others'),
                value: true,
                onChanged: (value) {},
              ),
              const Divider(height: 1),
              SwitchListTile(title: const Text('Activity Status'), subtitle: const Text('Show when you\'re active'), value: false, onChanged: (value) {}),
              const Divider(height: 1),
              SwitchListTile(title: const Text('Data Collection'), subtitle: const Text('Allow analytics data collection'), value: true, onChanged: (value) {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Notification Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(title: const Text('Push Notifications'), subtitle: const Text('Receive push notifications'), value: true, onChanged: (value) {}),
              const Divider(height: 1),
              SwitchListTile(title: const Text('Email Notifications'), subtitle: const Text('Receive email updates'), value: true, onChanged: (value) {}),
              const Divider(height: 1),
              SwitchListTile(title: const Text('SMS Notifications'), subtitle: const Text('Receive SMS alerts'), value: false, onChanged: (value) {}),
            ],
          ),
        ),
      ],
    );
  }
}
