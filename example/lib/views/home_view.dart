import 'package:flutter/material.dart';

/// Home view demonstrating basic Mosaique usage
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.dashboard, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text('Welcome to Mosaique', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'A declarative, route-driven multi-region shell layout system for Flutter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            const Text('Features Demonstrated:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildFeatureCard(icon: Icons.view_quilt, title: 'Shell Layouts', description: 'Define reusable page structures with region placeholders'),
            const SizedBox(height: 12),
            _buildFeatureCard(icon: Icons.route, title: 'Route Definitions', description: 'Map URL patterns to layouts and views with custom rules'),
            const SizedBox(height: 12),
            _buildFeatureCard(icon: Icons.navigation, title: 'Navigation', description: 'Programmatic navigation with go_router integration'),
            const SizedBox(height: 12),
            _buildFeatureCard(icon: Icons.layers, title: 'Nested Layouts', description: 'Compose complex UI hierarchies with nested regions'),
            const SizedBox(height: 32),
            const Text(
              'Open the drawer to explore examples →',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String description}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
