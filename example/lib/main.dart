import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart';

import 'views/home_view.dart';
import 'views/users_list_view.dart';
import 'views/user_detail_view.dart';
import 'views/nested_product_view.dart';
import 'views/settings_view.dart';
import 'widgets/navigation_drawer.dart' as nav;

void main() {
  runApp(const MosaiqueExampleApp());
}

class MosaiqueExampleApp extends StatefulWidget {
  const MosaiqueExampleApp({super.key});

  @override
  State<MosaiqueExampleApp> createState() => _MosaiqueExampleAppState();
}

class _MosaiqueExampleAppState extends State<MosaiqueExampleApp> {
  late final GoRouter _router;
  late final GoRouterAdapter _adapter;

  @override
  void initState() {
    super.initState();

    // Initialize go_router
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        // All routes are handled by Mosaique
        GoRoute(
          path: '/:path(.*)',
          pageBuilder: (context, state) {
            // Return the Mosaique shell builder with custom page transitions
            return CustomTransitionPage(
              key: state.pageKey,
              child: MosaiqueShellBuilder(
                context: _adapter.getCurrentContext(),
                shellLayouts: _shellLayouts,
                routes: _routeDefinitions,
                defaultBuilders: _defaultBuilders,
                debugConfig: const MosaiqueDebugConfig(enabled: true, logRouteMatching: true, logViewResolution: true, logRebuilds: true),
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Fade transition for all page changes
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: child,
                );
              },
            );
          },
        ),
      ],
    );

    // Create the adapter
    _adapter = GoRouterAdapter(_router);
  }

  @override
  void dispose() {
    _adapter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mosaique Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      routerConfig: _router,
    );
  }
}

// ============================================================================
// Shell Layout Definitions
// ============================================================================

/// Shell layouts define the structure of the page with region placeholders
final _shellLayouts = <String, ShellLayout>{
  'main': ShellLayout(
    id: 'main',
    builder: (regions) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mosaique Example'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: regions['main'] ?? const SizedBox.shrink(),
        ),
        drawer: regions['sidebar'],
      );
    },
  ),

  'two-column': ShellLayout(
    id: 'two-column',
    builder: (regions) {
      return Scaffold(
        appBar: AppBar(title: const Text('Two Column Layout'), backgroundColor: Colors.green, foregroundColor: Colors.white),
        body: Row(
          children: [
            // Left column with animation
            Expanded(
              flex: 2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: regions['main'] ?? const SizedBox.shrink(),
              ),
            ),
            // Right column with animation
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: regions['sidebar'] ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  ),

  'nested-detail': ShellLayout(
    id: 'nested-detail',
    builder: (regions) {
      return Column(
        children: [
          // Header region with animation
          if (regions['header'] != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: regions['header'],
              ),
            ),
          // Content region with animation
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: regions['content'] ?? const SizedBox.shrink(),
            ),
          ),
        ],
      );
    },
  ),
};

// ============================================================================
// Route Definitions
// ============================================================================

/// Route definitions map URL patterns to shell layouts and view injection rules
final _routeDefinitions = <RouteDefinition>[
  // Home route - uses main shell layout
  RouteDefinition(
    pattern: '/',
    shellSelector: (context) => 'main',
    viewRules: [
      ViewInjectionRule(regionKey: 'main', condition: (context) => true, builder: (context) => const HomeView()),
      ViewInjectionRule(regionKey: 'sidebar', condition: (context) => true, builder: (context) => const nav.AppNavigationDrawer()),
    ],
  ),

  // Users list route - uses two-column layout
  RouteDefinition(
    pattern: '/users',
    shellSelector: (context) => 'two-column',
    viewRules: [
      ViewInjectionRule(regionKey: 'main', condition: (context) => true, builder: (context) => const UsersListView()),
      ViewInjectionRule(regionKey: 'sidebar', condition: (context) => true, builder: (context) => const UsersSidebarView()),
    ],
  ),

  // User detail route - uses two-column layout with parameter extraction
  RouteDefinition(
    pattern: '/users/:userId',
    shellSelector: (context) => 'two-column',
    viewRules: [
      ViewInjectionRule(
        regionKey: 'main',
        condition: (context) => true,
        builder: (context) => UserDetailView(userId: context.pathParameters['userId'] ?? ''),
      ),
      ViewInjectionRule(regionKey: 'sidebar', condition: (context) => true, builder: (context) => const UsersSidebarView()),
    ],
  ),

  // Products route with nested shell layout
  RouteDefinition(
    pattern: '/products/:productId',
    shellSelector: (context) => 'main',
    viewRules: [
      ViewInjectionRule(
        regionKey: 'main',
        condition: (context) => true,
        builder: (context) {
          // This view contains a nested shell layout
          return NestedProductView(productId: context.pathParameters['productId'] ?? '');
        },
      ),
      ViewInjectionRule(regionKey: 'sidebar', condition: (context) => true, builder: (context) => const nav.AppNavigationDrawer()),
    ],
  ),

  // Settings route with query parameters
  RouteDefinition(
    pattern: '/settings',
    shellSelector: (context) => 'main',
    viewRules: [
      ViewInjectionRule(
        regionKey: 'main',
        condition: (context) => true,
        builder: (context) => SettingsView(tab: context.queryParameters['tab']),
      ),
      ViewInjectionRule(regionKey: 'sidebar', condition: (context) => true, builder: (context) => const nav.AppNavigationDrawer()),
    ],
  ),
];

// ============================================================================
// Default Builders
// ============================================================================

/// Default builders provide fallback widgets when no rules match
final _defaultBuilders = <String, Widget Function(RouteContext)>{'main': (context) => const Center(child: Text('No content available'))};
