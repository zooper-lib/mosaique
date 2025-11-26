import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fixed sidebar view - injected into AppShell's sidebar region.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => context.go('/dashboard'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Products'),
            onTap: () => context.go('/products'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () => context.push('/users'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login (Simple Shell)'),
            onTap: () => context.push('/login'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings (No Shell)'),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}
