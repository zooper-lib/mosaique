import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Users list view - injected into TwoColumnShell's list region.
class UsersListView extends StatelessWidget {
  const UsersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      {'id': '1', 'name': 'Alice Johnson', 'email': 'alice@example.com'},
      {'id': '2', 'name': 'Bob Smith', 'email': 'bob@example.com'},
      {'id': '3', 'name': 'Charlie Brown', 'email': 'charlie@example.com'},
      {'id': '4', 'name': 'Diana Prince', 'email': 'diana@example.com'},
    ];

    return Container(
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Users', style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(user['name']![0])),
                  title: Text(user['name']!),
                  subtitle: Text(user['email']!),
                  onTap: () => context.go('/users/${user['id']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
