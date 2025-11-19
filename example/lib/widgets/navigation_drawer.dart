import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation drawer widget for the example app
class AppNavigationDrawer extends StatelessWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.dashboard, size: 48, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  'Mosaique',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('Example Application', style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 14)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users List'),
            subtitle: const Text('Two-column layout'),
            onTap: () {
              Navigator.pop(context);
              context.go('/users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Detail'),
            subtitle: const Text('Path parameters'),
            onTap: () {
              Navigator.pop(context);
              context.go('/users/1');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Product Detail'),
            subtitle: const Text('Nested shell layout'),
            onTap: () {
              Navigator.pop(context);
              context.go('/products/1');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            subtitle: const Text('Query parameters'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings - Account Tab'),
            subtitle: const Text('Query parameter: ?tab=account'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings?tab=account');
            },
          ),
        ],
      ),
    );
  }
}
