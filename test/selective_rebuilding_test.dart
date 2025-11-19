import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('Selective Rebuilding Optimization', () {
    testWidgets('rebuilds when route context changes', (tester) async {
      int headerBuildCount = 0;
      int contentBuildCount = 0;

      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) {
          return Column(children: [regions['header'] ?? const SizedBox.shrink(), regions['content'] ?? const SizedBox.shrink()]);
        },
      );

      final route = RouteDefinition(
        pattern: '/page/:id',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'header',
            condition: (context) => true,
            builder: (context) {
              headerBuildCount++;
              return const Text('Header');
            },
          ),
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              contentBuildCount++;
              return Text('Content: ${context.pathParameters['id']}');
            },
          ),
        ],
      );

      // Initial render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/page/1'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      expect(headerBuildCount, 1);
      expect(contentBuildCount, 1);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Content: 1'), findsOneWidget);

      // Change route context - both regions will rebuild because path parameters changed
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/page/2'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      // Both regions rebuild because the key changed (path parameters changed)
      expect(headerBuildCount, 2);
      expect(contentBuildCount, 2);
      expect(find.text('Content: 2'), findsOneWidget);
    });

    testWidgets('preserves state when context unchanged', (tester) async {
      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) {
          return Column(children: [regions['sidebar'] ?? const SizedBox.shrink(), regions['content'] ?? const SizedBox.shrink()]);
        },
      );

      final route = RouteDefinition(
        pattern: '/page',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'sidebar',
            condition: (context) => true,
            builder: (context) => const _StatefulCounter(key: ValueKey('sidebar-counter')),
          ),
          ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Static Content')),
        ],
      );

      // Initial render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/page'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      // Increment counter
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);

      // Rebuild with same context - state should be preserved
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/page'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      // State preserved because context and keys are the same
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('performs full rebuild when shell layout changes', (tester) async {
      int mainShellBuildCount = 0;
      int adminShellBuildCount = 0;

      final mainShell = ShellLayout(
        id: 'main',
        builder: (regions) {
          mainShellBuildCount++;
          return Column(children: [const Text('Main Shell'), regions['content'] ?? const SizedBox.shrink()]);
        },
      );

      final adminShell = ShellLayout(
        id: 'admin',
        builder: (regions) {
          adminShellBuildCount++;
          return Column(children: [const Text('Admin Shell'), regions['content'] ?? const SizedBox.shrink()]);
        },
      );

      final routes = [
        RouteDefinition(
          pattern: '/home',
          shellSelector: (context) => 'main',
          viewRules: [ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Home Content'))],
        ),
        RouteDefinition(
          pattern: '/admin',
          shellSelector: (context) => 'admin',
          viewRules: [ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Admin Content'))],
        ),
      ];

      // Initial render with main shell
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/home'),
            shellLayouts: {'main': mainShell, 'admin': adminShell},
            routes: routes,
          ),
        ),
      );

      expect(mainShellBuildCount, 1);
      expect(adminShellBuildCount, 0);
      expect(find.text('Main Shell'), findsOneWidget);
      expect(find.text('Home Content'), findsOneWidget);

      // Change to admin shell - should trigger full rebuild
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/admin'),
            shellLayouts: {'main': mainShell, 'admin': adminShell},
            routes: routes,
          ),
        ),
      );

      expect(mainShellBuildCount, 1); // Main shell not rebuilt
      expect(adminShellBuildCount, 1); // Admin shell built
      expect(find.text('Admin Shell'), findsOneWidget);
      expect(find.text('Admin Content'), findsOneWidget);
      expect(find.text('Main Shell'), findsNothing);
    });

    testWidgets('rebuilds multiple regions when context changes', (tester) async {
      int headerBuildCount = 0;
      int sidebarBuildCount = 0;
      int contentBuildCount = 0;

      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) {
          return Column(
            children: [
              regions['header'] ?? const SizedBox.shrink(),
              Row(children: [regions['sidebar'] ?? const SizedBox.shrink(), regions['content'] ?? const SizedBox.shrink()]),
            ],
          );
        },
      );

      final route = RouteDefinition(
        pattern: '/page/:section',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'header',
            condition: (context) => true,
            builder: (context) {
              headerBuildCount++;
              return const Text('Header');
            },
          ),
          ViewInjectionRule(
            regionKey: 'sidebar',
            condition: (context) => true,
            builder: (context) {
              sidebarBuildCount++;
              return Text('Sidebar: ${context.pathParameters['section']}');
            },
          ),
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              contentBuildCount++;
              return Text('Content: ${context.pathParameters['section']}');
            },
          ),
        ],
      );

      // Initial render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/page/home'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      expect(headerBuildCount, 1);
      expect(sidebarBuildCount, 1);
      expect(contentBuildCount, 1);

      // Change section - all regions rebuild because path parameters changed
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/page/about'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      // All regions rebuild because the key changed
      expect(headerBuildCount, 2);
      expect(sidebarBuildCount, 2);
      expect(contentBuildCount, 2);
      expect(find.text('Sidebar: about'), findsOneWidget);
      expect(find.text('Content: about'), findsOneWidget);
    });

    testWidgets('uses keys to identify regions', (tester) async {
      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) {
          return Column(children: [regions['region1'] ?? const SizedBox.shrink(), regions['region2'] ?? const SizedBox.shrink()]);
        },
      );

      final route = RouteDefinition(
        pattern: '/page',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(regionKey: 'region1', condition: (context) => true, builder: (context) => const Text('Region 1')),
          ViewInjectionRule(regionKey: 'region2', condition: (context) => true, builder: (context) => const Text('Region 2')),
        ],
      );

      // Initial render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/page'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      expect(find.text('Region 1'), findsOneWidget);
      expect(find.text('Region 2'), findsOneWidget);

      // Verify that regions are wrapped with keys
      final region1Widget = tester.widget<KeyedSubtree>(find.ancestor(of: find.text('Region 1'), matching: find.byType(KeyedSubtree)));
      expect(region1Widget.key, isNotNull);
    });

    testWidgets('detects shell layout changes in didUpdateWidget', (tester) async {
      final mainShell = ShellLayout(
        id: 'main',
        builder: (regions) => Column(children: [const Text('Main'), regions['content'] ?? const SizedBox.shrink()]),
      );

      final altShell = ShellLayout(
        id: 'alt',
        builder: (regions) => Column(children: [const Text('Alt'), regions['content'] ?? const SizedBox.shrink()]),
      );

      final routes = [
        RouteDefinition(
          pattern: '/main',
          shellSelector: (context) => 'main',
          viewRules: [ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Content'))],
        ),
        RouteDefinition(
          pattern: '/alt',
          shellSelector: (context) => 'alt',
          viewRules: [ViewInjectionRule(regionKey: 'content', condition: (context) => true, builder: (context) => const Text('Content'))],
        ),
      ];

      // Start with main shell
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/main'),
            shellLayouts: {'main': mainShell, 'alt': altShell},
            routes: routes,
          ),
        ),
      );

      expect(find.text('Main'), findsOneWidget);

      // Switch to alt shell
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: RouteContext(path: '/alt'),
            shellLayouts: {'main': mainShell, 'alt': altShell},
            routes: routes,
          ),
        ),
      );

      expect(find.text('Alt'), findsOneWidget);
      expect(find.text('Main'), findsNothing);
    });
  });
}

/// A stateful widget that maintains a counter for testing state preservation
class _StatefulCounter extends StatefulWidget {
  const _StatefulCounter({super.key});

  @override
  State<_StatefulCounter> createState() => _StatefulCounterState();
}

class _StatefulCounterState extends State<_StatefulCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _count++;
        });
      },
      child: Text('Count: $_count'),
    );
  }
}
