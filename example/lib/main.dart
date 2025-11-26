import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        // Main shell - used for dashboard and users
        MosaiqueShellRoute(
          shellBuilder: (context) => const MainShell(),
          regions: const ['header', 'menu', 'content'],
          fixedRegions: {
            'header': (context) => const HeaderView(),
            'menu': (context) => const MainMenuView(),
          },
          routes: [
            MosaiqueViewRoute(
              path: '/dashboard',
              region: 'content',
              builder: (context, state) => const DashboardView(),
            ),
            MosaiqueShellRoute(
              shellBuilder: (context) => const UsersShell(),
              regions: const ['list', 'details'],
              region: 'content', // inject into parent's content region
              fixedRegions: {'list': (context) => const UsersListView()},
              routes: [
                MosaiqueViewRoute(
                  path: '/users/:userId',
                  region: 'details',
                  builder: (context, state) => UserDetailsView(
                    userId: state.pathParameters['userId'] ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
        // Settings as a top-level route - completely outside the shell!
        GoRoute(
          path: '/settings',
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: const SettingsView(),
          ),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Mosaique Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

// ============================================================================
// Shells
// ============================================================================

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Region('header'),
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 250, child: Region('menu')),
                Expanded(child: Region('content')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UsersShell extends StatelessWidget {
  const UsersShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 300, child: Region('list')),
        VerticalDivider(width: 1),
        Expanded(child: Region('details')),
      ],
    );
  }
}

// ============================================================================
// Views
// ============================================================================

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.dashboard, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            'Mosaique Example App',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class MainMenuView extends StatelessWidget {
  const MainMenuView({super.key});

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
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            onTap: () => context.push('/users/1'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(
                  context,
                  'Total Users',
                  '1,234',
                  Icons.people,
                  Colors.blue,
                ),
                _buildDashboardCard(
                  context,
                  'Active Sessions',
                  '56',
                  Icons.online_prediction,
                  Colors.green,
                ),
                _buildDashboardCard(
                  context,
                  'Revenue',
                  '\$12,345',
                  Icons.attach_money,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          const ListTile(
            leading: Icon(Icons.palette),
            title: Text('Theme'),
            subtitle: Text('Choose your app theme'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Manage notification settings'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy'),
            subtitle: Text('Control your privacy settings'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('App version and information'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
