import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('Integration Tests', () {
    testWidgets('Complete navigation flow works correctly',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(
              body: Column(
                children: [
                  Text('Header'),
                  Expanded(child: Region('content')),
                ],
              ),
            ),
            regions: const ['content'],
            fixedRegions: {
              'header': (context) => const Text('Fixed Header'),
            },
            routes: [
              MosaiqueViewRoute(
                path: '/dashboard',
                region: 'content',
                builder: (context, state) => const _NavigationTestView(),
              ),
              MosaiqueViewRoute(
                path: '/products',
                region: 'content',
                builder: (context, state) => const Text('Products Page'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Initial state
      expect(find.text('Dashboard Page'), findsOneWidget);
      expect(find.text('Products Page'), findsNothing);

      // Navigate to products
      await tester.tap(find.text('Go to Products'));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Page'), findsNothing);
      expect(find.text('Products Page'), findsOneWidget);
    });

    testWidgets('Shell persists during navigation',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/page1',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const _PersistentShell(),
            regions: const ['header', 'content'],
            fixedRegions: {
              'header': (context) => const Text('Persistent Header'),
            },
            routes: [
              MosaiqueViewRoute(
                path: '/page1',
                region: 'content',
                builder: (context, state) => const _NavPage(
                  title: 'Page 1',
                  nextPath: '/page2',
                ),
              ),
              MosaiqueViewRoute(
                path: '/page2',
                region: 'content',
                builder: (context, state) => const Text('Page 2'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Header should be visible
      expect(find.text('Persistent Header'), findsOneWidget);
      expect(find.text('Page 1'), findsOneWidget);

      // Navigate to page 2
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Header should still be visible (persisted)
      expect(find.text('Persistent Header'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('List+detail pattern works correctly',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/users',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(
              body: Row(
                children: [
                  SizedBox(width: 200, child: Region('list')),
                  VerticalDivider(width: 1),
                  Expanded(child: Region('details')),
                ],
              ),
            ),
            regions: const ['list', 'details'],
            fixedRegions: {
              'list': (context) => const _UsersList(),
            },
            routes: [
              MosaiqueViewRoute(
                path: '/users',
                region: 'details',
                builder: (context, state) =>
                    const Text('Select a user'),
              ),
              MosaiqueViewRoute(
                path: '/users/:userId',
                region: 'details',
                builder: (context, state) =>
                    Text('User ${state.pathParameters['userId']} Details'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Initial state: list visible, no user selected
      expect(find.text('User 1'), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
      expect(find.text('Select a user'), findsOneWidget);

      // Select user 1
      await tester.tap(find.text('User 1'));
      await tester.pumpAndSettle();

      // List should still be visible (fixed region)
      expect(find.text('User 1'), findsOneWidget);
      expect(find.text('User 2'), findsOneWidget);
      expect(find.text('User 1 Details'), findsOneWidget);
      expect(find.text('Select a user'), findsNothing);
    });

    testWidgets('Navigation stack with push/pop/go works correctly',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(body: Region('content')),
            regions: const ['content'],
            routes: [
              MosaiqueViewRoute(
                path: '/home',
                region: 'content',
                builder: (context, state) => const _StackTestHomePage(),
              ),
              MosaiqueViewRoute(
                path: '/page1',
                region: 'content',
                builder: (context, state) => const _StackTestPage(
                  title: 'Page 1',
                  nextPath: '/page2',
                ),
              ),
              MosaiqueViewRoute(
                path: '/page2',
                region: 'content',
                builder: (context, state) => const _StackTestPage(
                  title: 'Page 2',
                  nextPath: '/page3',
                ),
              ),
              MosaiqueViewRoute(
                path: '/page3',
                region: 'content',
                builder: (context, state) => const Text('Page 3'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);

      // Push to page1
      await tester.tap(find.text('Push to Page 1'));
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);

      // Push to page2
      await tester.tap(find.text('Push'));
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);

      // Pop back to page1
      await tester.tap(find.text('Pop'));
      await tester.pumpAndSettle();
      expect(find.text('Page 1'), findsOneWidget);

      // Pop back to home
      await tester.tap(find.text('Pop'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Nested shells maintain separate state',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/outer/inner/test',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(
              body: Column(
                children: [
                  Text('Outer Shell'),
                  Expanded(child: Region('outer-content')),
                ],
              ),
            ),
            regions: const ['outer-content'],
            routes: [
              MosaiqueShellRoute(
                shellBuilder: (context) => const Column(
                  children: [
                    Text('Inner Shell'),
                    Expanded(child: Region('inner-content')),
                  ],
                ),
                regions: const ['inner-content'],
                region: 'outer-content',
                routes: [
                  MosaiqueViewRoute(
                    path: '/outer/inner/test',
                    region: 'inner-content',
                    builder: (context, state) => const _NestedNavTestView(),
                  ),
                  MosaiqueViewRoute(
                    path: '/outer/inner/other',
                    region: 'inner-content',
                    builder: (context, state) => const Text('Other View'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Outer Shell'), findsOneWidget);
      expect(find.text('Inner Shell'), findsOneWidget);
      expect(find.text('Test View'), findsOneWidget);

      // Navigate within inner shell
      await tester.tap(find.text('Navigate to Other'));
      await tester.pumpAndSettle();

      // Both shells should still be visible
      expect(find.text('Outer Shell'), findsOneWidget);
      expect(find.text('Inner Shell'), findsOneWidget);
      expect(find.text('Other View'), findsOneWidget);
    });
  });
}

// Helper widgets for testing

class _NavigationTestView extends StatelessWidget {
  const _NavigationTestView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Dashboard Page'),
        ElevatedButton(
          onPressed: () => context.go('/products'),
          child: const Text('Go to Products'),
        ),
      ],
    );
  }
}

class _PersistentShell extends StatelessWidget {
  const _PersistentShell();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Region('header'),
          Expanded(child: Region('content')),
        ],
      ),
    );
  }
}

class _NavPage extends StatelessWidget {
  final String title;
  final String nextPath;

  const _NavPage({required this.title, required this.nextPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        ElevatedButton(
          onPressed: () => context.go(nextPath),
          child: const Text('Navigate'),
        ),
      ],
    );
  }
}

class _UsersList extends StatelessWidget {
  const _UsersList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('User 1'),
          onTap: () => context.go('/users/1'),
        ),
        ListTile(
          title: const Text('User 2'),
          onTap: () => context.go('/users/2'),
        ),
      ],
    );
  }
}

class _StackTestHomePage extends StatelessWidget {
  const _StackTestHomePage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Home'),
        ElevatedButton(
          onPressed: () => context.push('/page1'),
          child: const Text('Push to Page 1'),
        ),
      ],
    );
  }
}

class _StackTestPage extends StatelessWidget {
  final String title;
  final String nextPath;

  const _StackTestPage({required this.title, required this.nextPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        ElevatedButton(
          onPressed: () => context.push(nextPath),
          child: const Text('Push'),
        ),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('Pop'),
        ),
      ],
    );
  }
}

class _NestedNavTestView extends StatelessWidget {
  const _NestedNavTestView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Test View'),
        ElevatedButton(
          onPressed: () => context.go('/outer/inner/other'),
          child: const Text('Navigate to Other'),
        ),
      ],
    );
  }
}
