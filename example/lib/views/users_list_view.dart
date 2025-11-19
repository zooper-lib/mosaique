import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart' hide Icons;

/// Users list view demonstrating two-column layout
class UsersListView extends StatelessWidget {
  const UsersListView({super.key});

  static final _users = [
    {'id': '1', 'name': 'Alice Johnson', 'email': 'alice@example.com'},
    {'id': '2', 'name': 'Bob Smith', 'email': 'bob@example.com'},
    {'id': '3', 'name': 'Carol Williams', 'email': 'carol@example.com'},
    {'id': '4', 'name': 'David Brown', 'email': 'david@example.com'},
    {'id': '5', 'name': 'Eve Davis', 'email': 'eve@example.com'},
  ];

  @override
  Widget build(BuildContext context) {
    // Access route context from Mosaique
    final routeContext = context.routeContext;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Users', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Current path: ${routeContext.path}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return ListTile(
                leading: CircleAvatar(child: Text(user['name']![0])),
                title: Text(user['name']!),
                subtitle: Text(user['email']!),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to user detail using Mosaique's router adapter
                  // In a real app, you'd get the adapter from MosaiqueScope
                  // For this example, we'll use go_router directly
                  context.go('/users/${user['id']}');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Sidebar view for users section
class UsersSidebarView extends StatelessWidget {
  const UsersSidebarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('This sidebar demonstrates how different regions can be populated based on the current route.', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add User'),
            dense: true,
            onTap: () {
              // Action handler
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search Users'),
            dense: true,
            onTap: () {
              // Action handler
            },
          ),
          ListTile(
            leading: const Icon(Icons.filter_list),
            title: const Text('Filter'),
            dense: true,
            onTap: () {
              // Action handler
            },
          ),
        ],
      ),
    );
  }
}
