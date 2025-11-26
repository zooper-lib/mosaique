import 'package:flutter/material.dart';

/// User details view - injected into TwoColumnShell's details region.
class UserDetailsView extends StatelessWidget {
  final String userId;

  const UserDetailsView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Mock user data
    final users = {
      '1': {
        'name': 'Alice Johnson',
        'email': 'alice@example.com',
        'role': 'Administrator',
      },
      '2': {
        'name': 'Bob Smith',
        'email': 'bob@example.com',
        'role': 'Developer',
      },
      '3': {
        'name': 'Charlie Brown',
        'email': 'charlie@example.com',
        'role': 'Designer',
      },
      '4': {
        'name': 'Diana Prince',
        'email': 'diana@example.com',
        'role': 'Manager',
      },
    };

    final user =
        users[userId] ?? {'name': 'Unknown', 'email': 'N/A', 'role': 'N/A'};

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                child: Text(
                  user['name']![0],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name']!,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['role']!,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          _buildInfoRow(context, 'Email', user['email']!),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'User ID', userId),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Role', user['role']!),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}
