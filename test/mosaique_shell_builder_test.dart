import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('MosaiqueShellBuilder', () {
    testWidgets('builds shell with resolved views for matching route', (tester) async {
      // Create a simple shell layout
      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) {
          return Column(children: [regions['header'] ?? const SizedBox.shrink(), regions['content'] ?? const SizedBox.shrink()]);
        },
      );

      // Create route definition
      final route = RouteDefinition(
        pattern: '/home',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(regionKey: 'header', condition: (context) => true, builder: (context) => const Text('Header')),
          ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Content')),
        ],
      );

      final context = RouteContext(path: '/home');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'main': shellLayout}, routes: [route]),
        ),
      );

      // Verify the shell was built with views
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('extracts and provides path parameters to views', (tester) async {
      String? capturedUserId;

      final shellLayout = ShellLayout(id: 'main', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final route = RouteDefinition(
        pattern: '/users/:userId',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              capturedUserId = context.pathParameters['userId'];
              return Text('User: ${context.pathParameters['userId']}');
            },
          ),
        ],
      );

      final context = RouteContext(path: '/users/123');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'main': shellLayout}, routes: [route]),
        ),
      );

      expect(capturedUserId, '123');
      expect(find.text('User: 123'), findsOneWidget);
    });

    testWidgets('selects most specific route when multiple routes match', (tester) async {
      final shellLayout = ShellLayout(id: 'main', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final routes = [
        RouteDefinition(
          pattern: '/users/*',
          shellSelector: (context) => 'main',
          viewRules: [ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Wildcard'))],
        ),
        RouteDefinition(
          pattern: '/users/:userId',
          shellSelector: (context) => 'main',
          viewRules: [ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Specific'))],
        ),
      ];

      final context = RouteContext(path: '/users/123');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'main': shellLayout}, routes: routes),
        ),
      );

      // Should select the more specific route
      expect(find.text('Specific'), findsOneWidget);
      expect(find.text('Wildcard'), findsNothing);
    });

    testWidgets('uses default builder when no rules match', (tester) async {
      final shellLayout = ShellLayout(id: 'main', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final route = RouteDefinition(
        pattern: '/home',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => false, // Never matches
            builder: (context) => const Text('Never shown'),
          ),
        ],
      );

      final context = RouteContext(path: '/home');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: context,
            shellLayouts: {'main': shellLayout},
            routes: [route],
            defaultBuilders: {'content': (context) => const Text('Default')},
          ),
        ),
      );

      expect(find.text('Default'), findsOneWidget);
      expect(find.text('Never shown'), findsNothing);
    });

    testWidgets('shows not found widget when no route matches', (tester) async {
      final shellLayout = ShellLayout(id: 'main', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final route = RouteDefinition(pattern: '/home', shellSelector: (context) => 'main', viewRules: []);

      final context = RouteContext(path: '/unknown');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: context,
            shellLayouts: {'main': shellLayout},
            routes: [route],
            notFoundBuilder: (context) => const Text('Not Found'),
          ),
        ),
      );

      expect(find.text('Not Found'), findsOneWidget);
    });

    testWidgets('provides route context through MosaiqueScope', (tester) async {
      RouteContext? capturedContext;

      final shellLayout = ShellLayout(id: 'main', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final route = RouteDefinition(
        pattern: '/users/:userId',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              return Builder(
                builder: (buildContext) {
                  capturedContext = buildContext.routeContext;
                  return const Text('Content');
                },
              );
            },
          ),
        ],
      );

      final context = RouteContext(path: '/users/123');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'main': shellLayout}, routes: [route]),
        ),
      );

      expect(capturedContext, isNotNull);
      expect(capturedContext!.path, '/users/123');
      expect(capturedContext!.pathParameters['userId'], '123');
    });

    testWidgets('rebuilds when route context changes', (tester) async {
      final shellLayout = ShellLayout(id: 'main', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final route = RouteDefinition(
        pattern: '/users/:userId',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => Text('User: ${context.pathParameters['userId']}')),
        ],
      );

      final context1 = RouteContext(path: '/users/123');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context1, shellLayouts: {'main': shellLayout}, routes: [route]),
        ),
      );

      expect(find.text('User: 123'), findsOneWidget);

      // Change the route context
      final context2 = RouteContext(path: '/users/456');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context2, shellLayouts: {'main': shellLayout}, routes: [route]),
        ),
      );

      expect(find.text('User: 456'), findsOneWidget);
      expect(find.text('User: 123'), findsNothing);
    });

    testWidgets('selects correct shell layout based on selector', (tester) async {
      final mainShell = ShellLayout(
        id: 'main',
        builder: (regions) => Column(children: [const Text('Main Shell'), regions['content'] ?? const SizedBox.shrink()]),
      );

      final adminShell = ShellLayout(
        id: 'admin',
        builder: (regions) => Column(children: [const Text('Admin Shell'), regions['content'] ?? const SizedBox.shrink()]),
      );

      final route = RouteDefinition(
        pattern: '/admin/*',
        shellSelector: (context) => 'admin',
        viewRules: [ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Admin Content'))],
      );

      final context = RouteContext(path: '/admin/dashboard');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'main': mainShell, 'admin': adminShell}, routes: [route]),
        ),
      );

      expect(find.text('Admin Shell'), findsOneWidget);
      expect(find.text('Main Shell'), findsNothing);
      expect(find.text('Admin Content'), findsOneWidget);
    });
  });
}
