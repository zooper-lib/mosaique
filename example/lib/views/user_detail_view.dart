import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart' hide Icons;

/// User detail view demonstrating path parameter extraction
class UserDetailView extends StatelessWidget {
  final String userId;

  const UserDetailView({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    // Access route context to show all parameters
    final routeContext = context.routeContext;

    // Mock user data
    final userData = _getUserData(userId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/users')),
              const SizedBox(width: 8),
              const Text('User Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Path: ${routeContext.path}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text('User ID from path parameter: $userId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(radius: 50, child: Text(userData['name']![0], style: const TextStyle(fontSize: 32))),
                  const SizedBox(height: 16),
                  Text(userData['name']!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(userData['email']!, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildDetailRow('User ID', userId),
          _buildDetailRow('Role', userData['role']!),
          _buildDetailRow('Department', userData['department']!),
          _buildDetailRow('Joined', userData['joined']!),
          const SizedBox(height: 24),
          const Text('Route Context Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Path: ${routeContext.path}'),
                  const SizedBox(height: 8),
                  Text('Path Parameters: ${routeContext.pathParameters}'),
                  const SizedBox(height: 8),
                  Text('Query Parameters: ${routeContext.queryParameters}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Map<String, String> _getUserData(String id) {
    final users = {
      '1': {'name': 'Alice Johnson', 'email': 'alice@example.com', 'role': 'Administrator', 'department': 'Engineering', 'joined': 'January 2023'},
      '2': {'name': 'Bob Smith', 'email': 'bob@example.com', 'role': 'Developer', 'department': 'Engineering', 'joined': 'March 2023'},
      '3': {'name': 'Carol Williams', 'email': 'carol@example.com', 'role': 'Designer', 'department': 'Design', 'joined': 'May 2023'},
      '4': {'name': 'David Brown', 'email': 'david@example.com', 'role': 'Manager', 'department': 'Operations', 'joined': 'February 2023'},
      '5': {'name': 'Eve Davis', 'email': 'eve@example.com', 'role': 'Analyst', 'department': 'Business', 'joined': 'April 2023'},
    };

    return users[id] ?? {'name': 'Unknown User', 'email': 'unknown@example.com', 'role': 'N/A', 'department': 'N/A', 'joined': 'N/A'};
  }
}
