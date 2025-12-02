import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('MosaiqueShellRoute Tests', () {
    testWidgets('Shell builder is called correctly',
        (WidgetTester tester) async {
      var shellBuilderCalled = false;

      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) {
              shellBuilderCalled = true;
              return const Scaffold(body: Region('content'));
            },
            routes: [
              MosaiqueViewRoute(
                path: '/test',
                region: 'content',
                builder: (context, state) => const Text('Test View'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(shellBuilderCalled, isTrue);
      expect(find.text('Test View'), findsOneWidget);
    });

    testWidgets('Fixed regions are properly injected',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/test',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(
              body: Column(
                children: [
                  Region('header'),
                  Expanded(child: Region('content')),
                ],
              ),
            ),
            fixedRegions: {
              'header': (context) => const Text('Fixed Header'),
            },
            routes: [
              MosaiqueViewRoute(
                path: '/test',
                region: 'content',
                builder: (context, state) => const Text('Dynamic Content'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Fixed Header'), findsOneWidget);
      expect(find.text('Dynamic Content'), findsOneWidget);
    });

    testWidgets('Dynamic routes are properly matched',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/page1',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(body: Region('content')),
            routes: [
              MosaiqueViewRoute(
                path: '/page1',
                region: 'content',
                builder: (context, state) => const Text('Page 1'),
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

      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsNothing);

      router.go('/page2');
      await tester.pumpAndSettle();

      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('Multiple routes with same path populate different regions',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/users/1',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(
              body: Row(
                children: [
                  SizedBox(width: 200, child: Region('list')),
                  Expanded(child: Region('details')),
                ],
              ),
            ),
            fixedRegions: {
              'list': (context) => const Text('Users List'),
            },
            routes: [
              MosaiqueViewRoute(
                path: '/users/:userId',
                region: 'details',
                builder: (context, state) =>
                    Text('User ${state.pathParameters['userId']}'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Both list (fixed) and details (dynamic) should be visible
      expect(find.text('Users List'), findsOneWidget);
      expect(find.text('User 1'), findsOneWidget);
    });

    testWidgets('Nested shells work correctly', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/nested/test',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(
              body: Column(
                children: [
                  Text('Outer Shell'),
                  Expanded(child: Region('content')),
                ],
              ),
            ),
            routes: [
              MosaiqueShellRoute(
                shellBuilder: (context) => const Column(
                  children: [
                    Text('Inner Shell'),
                    Expanded(child: Region('inner-content')),
                  ],
                ),
                region: 'content', // Inject into parent's content region
                routes: [
                  MosaiqueViewRoute(
                    path: '/nested/test',
                    region: 'inner-content',
                    builder: (context, state) => const Text('Nested View'),
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
      expect(find.text('Nested View'), findsOneWidget);
    });

    testWidgets('Route parameters are passed correctly',
        (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/items/42',
        routes: [
          MosaiqueShellRoute(
            shellBuilder: (context) => const Scaffold(body: Region('content')),
            routes: [
              MosaiqueViewRoute(
                path: '/items/:itemId',
                region: 'content',
                builder: (context, state) =>
                    Text('Item ${state.pathParameters['itemId']}'),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Item 42'), findsOneWidget);
    });
  });
}
