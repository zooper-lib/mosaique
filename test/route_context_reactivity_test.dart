import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('Route Context Reactivity', () {
    testWidgets('views are notified when route context changes', (tester) async {
      int viewBuildCount = 0;
      RouteContext? lastSeenContext;

      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) => regions['content'] ?? const SizedBox.shrink(),
      );

      final route = RouteDefinition(
        pattern: '/page/:id',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              return _ReactiveView(
                onBuild: () {
                  viewBuildCount++;
                },
                onContextAccess: (ctx) {
                  lastSeenContext = ctx;
                },
              );
            },
          ),
        ],
      );

      // Initial render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: const RouteContext(path: '/page/1'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      expect(viewBuildCount, 1);
      expect(lastSeenContext?.path, '/page/1');
      expect(lastSeenContext?.pathParameters['id'], '1');

      // Change route context
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: const RouteContext(path: '/page/2'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      // View should be rebuilt with new context
      expect(viewBuildCount, 2);
      expect(lastSeenContext?.path, '/page/2');
      expect(lastSeenContext?.pathParameters['id'], '2');
    });

    testWidgets('views can access updated route context through MosaiqueScope', (tester) async {
      final capturedContexts = <RouteContext>[];

      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) => regions['content'] ?? const SizedBox.shrink(),
      );

      final route = RouteDefinition(
        pattern: '/page/:id',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              return _ContextAccessingView(
                onContextAccess: (ctx) {
                  capturedContexts.add(ctx);
                },
              );
            },
          ),
        ],
      );

      // Initial render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: const RouteContext(path: '/page/1'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      expect(capturedContexts.length, 1);
      expect(capturedContexts[0].path, '/page/1');

      // Change route context
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: const RouteContext(path: '/page/2'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      // View should have access to updated context
      expect(capturedContexts.length, 2);
      expect(capturedContexts[1].path, '/page/2');
    });

    testWidgets('multiple views receive consistent route context', (tester) async {
      final capturedContexts = <String, RouteContext>{};

      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) {
          return Column(
            children: [
              regions['header'] ?? const SizedBox.shrink(),
              regions['content'] ?? const SizedBox.shrink(),
              regions['footer'] ?? const SizedBox.shrink(),
            ],
          );
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
              return _ContextAccessingView(
                key: const ValueKey('header'),
                onContextAccess: (ctx) {
                  capturedContexts['header'] = ctx;
                },
              );
            },
          ),
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              return _ContextAccessingView(
                key: const ValueKey('content'),
                onContextAccess: (ctx) {
                  capturedContexts['content'] = ctx;
                },
              );
            },
          ),
          ViewInjectionRule(
            regionKey: 'footer',
            condition: (context) => true,
            builder: (context) {
              return _ContextAccessingView(
                key: const ValueKey('footer'),
                onContextAccess: (ctx) {
                  capturedContexts['footer'] = ctx;
                },
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: const RouteContext(path: '/page/123'),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      // All views should receive the same route context
      expect(capturedContexts.length, 3);
      expect(capturedContexts['header']?.path, '/page/123');
      expect(capturedContexts['content']?.path, '/page/123');
      expect(capturedContexts['footer']?.path, '/page/123');
      expect(capturedContexts['header'], equals(capturedContexts['content']));
      expect(capturedContexts['content'], equals(capturedContexts['footer']));
    });

    testWidgets('views rebuild when query parameters change', (tester) async {
      int viewBuildCount = 0;
      Map<String, String>? lastQueryParams;

      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) => regions['content'] ?? const SizedBox.shrink(),
      );

      final route = RouteDefinition(
        pattern: '/page',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              return _ReactiveView(
                onBuild: () {
                  viewBuildCount++;
                },
                onContextAccess: (ctx) {
                  lastQueryParams = ctx.queryParameters;
                },
              );
            },
          ),
        ],
      );

      // Initial render with query parameters
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: const RouteContext(
              path: '/page',
              queryParameters: {'tab': 'home'},
            ),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      expect(viewBuildCount, 1);
      expect(lastQueryParams?['tab'], 'home');

      // Change query parameters
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: const RouteContext(
              path: '/page',
              queryParameters: {'tab': 'profile'},
            ),
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      // View should rebuild with new query parameters
      expect(viewBuildCount, 2);
      expect(lastQueryParams?['tab'], 'profile');
    });

    testWidgets('views do not rebuild when route context is unchanged', (tester) async {
      int viewBuildCount = 0;

      final shellLayout = ShellLayout(
        id: 'main',
        builder: (regions) => regions['content'] ?? const SizedBox.shrink(),
      );

      final route = RouteDefinition(
        pattern: '/page',
        shellSelector: (context) => 'main',
        viewRules: [
          ViewInjectionRule(
            regionKey: 'content',
            condition: (context) => true,
            builder: (context) {
              viewBuildCount++;
              return const Text('Content');
            },
          ),
        ],
      );

      const sameContext = RouteContext(path: '/page');

      // Initial render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: sameContext,
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      expect(viewBuildCount, 1);

      // Rebuild with same context
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(
            context: sameContext,
            shellLayouts: {'main': shellLayout},
            routes: [route],
          ),
        ),
      );

      // View should not rebuild because context is unchanged
      expect(viewBuildCount, 1);
    });
  });
}

/// A test widget that tracks when it's built and accesses route context
class _ReactiveView extends StatelessWidget {
  final VoidCallback onBuild;
  final void Function(RouteContext) onContextAccess;

  const _ReactiveView({
    required this.onBuild,
    required this.onContextAccess,
  });

  @override
  Widget build(BuildContext context) {
    onBuild();
    final routeContext = context.routeContext;
    onContextAccess(routeContext);
    return Text('Path: ${routeContext.path}');
  }
}

/// A test widget that accesses route context through MosaiqueScope
class _ContextAccessingView extends StatelessWidget {
  final void Function(RouteContext) onContextAccess;

  const _ContextAccessingView({
    super.key,
    required this.onContextAccess,
  });

  @override
  Widget build(BuildContext context) {
    final routeContext = context.routeContext;
    onContextAccess(routeContext);
    return Text('Context: ${routeContext.path}');
  }
}
