import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart';

// Shell templates
import 'shells/app_shell.dart';
import 'shells/simple_shell.dart';
import 'shells/two_column_shell.dart';

// Fixed views (injected via fixedRegions)
import 'views/fixed/app_header.dart';
import 'views/fixed/app_sidebar.dart';

// Dynamic views (injected via routes)
import 'views/dynamic/dashboard_view.dart';
import 'views/dynamic/login_view.dart';
import 'views/dynamic/products_view.dart';
import 'views/dynamic/settings_view.dart';
import 'views/dynamic/user_details_view.dart';
import 'views/dynamic/users_list_view.dart';

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
        // =====================================================================
        // REUSABLE SHELL #1: AppShell (header + sidebar + content)
        // Used by: Dashboard, Products
        // =====================================================================
        MosaiqueShellRoute(
          shellBuilder: (context) => const AppShell(),
          fixedRegions: {
            'header': (context) => const AppHeader(),
            'sidebar': (context) => const AppSidebar(),
          },
          routes: [
            // Dashboard view → injected into AppShell's content region
            MosaiqueViewRoute(
              path: '/dashboard',
              region: 'content',
              builder: (context, state) => const DashboardView(),
            ),

            // Products view → injected into AppShell's content region
            MosaiqueViewRoute(
              path: '/products',
              region: 'content',
              builder: (context, state) => const ProductsView(),
            ),

            // ==================================================================
            // REUSABLE SHELL #2: TwoColumnShell (list + details)
            // Nested inside AppShell's content region
            // Used by: Users section
            // ==================================================================
            MosaiqueShellRoute(
              shellBuilder: (context) => const TwoColumnShell(),
              region: 'content', // Inject into parent's content region
              fixedRegions: {
                'list': (context) => const UsersListView(), // Always show list
              },
              routes: [
                // Users list only (no user selected)
                MosaiqueViewRoute(
                  path: '/users',
                  region: 'details', // Empty details region
                  builder: (context, state) => const SizedBox.shrink(),
                ),

                // User details → details region
                MosaiqueViewRoute(
                  path: '/users/:userId',
                  region: 'details',
                  builder: (context, state) =>
                      UserDetailsView(userId: state.pathParameters['userId']!),
                ),
              ],
            ),
          ],
        ),

        // =====================================================================
        // REUSABLE SHELL #3: SimpleShell (full-screen content only)
        // Used by: Login
        // =====================================================================
        MosaiqueShellRoute(
          shellBuilder: (context) => const SimpleShell(),
          routes: [
            // Login view → injected into SimpleShell's content region
            MosaiqueViewRoute(
              path: '/login',
              region: 'content',
              builder: (context, state) => const LoginView(),
            ),
          ],
        ),

        // =====================================================================
        // NO SHELL: Regular GoRoute for full-screen pages
        // =====================================================================
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
