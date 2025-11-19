import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('MosaiqueScope', () {
    testWidgets('provides route context to descendant widgets', (tester) async {
      const testContext = RouteContext(path: '/users/123', pathParameters: {'userId': '123'});

      RouteContext? capturedContext;

      await tester.pumpWidget(
        MosaiqueScope(
          routeContext: testContext,
          child: Builder(
            builder: (context) {
              capturedContext = MosaiqueScope.of(context).routeContext;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext, equals(testContext));
    });

    testWidgets('maybeOf returns null when no MosaiqueScope exists', (tester) async {
      MosaiqueScope? capturedScope;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            capturedScope = MosaiqueScope.maybeOf(context);
            return const SizedBox();
          },
        ),
      );

      expect(capturedScope, isNull);
    });

    testWidgets('of throws assertion error when no MosaiqueScope exists', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(() => MosaiqueScope.of(context), throwsAssertionError);
            return const SizedBox();
          },
        ),
      );
    });

    testWidgets('updateShouldNotify returns true when route context changes', (tester) async {
      const initialContext = RouteContext(path: '/users/123');
      const updatedContext = RouteContext(path: '/users/456');

      final initialScope = MosaiqueScope(routeContext: initialContext, child: const SizedBox());

      final updatedScope = MosaiqueScope(routeContext: updatedContext, child: const SizedBox());

      expect(updatedScope.updateShouldNotify(initialScope), isTrue);
    });

    testWidgets('updateShouldNotify returns false when route context is unchanged', (tester) async {
      const context = RouteContext(path: '/users/123');

      final scope1 = MosaiqueScope(routeContext: context, child: const SizedBox());

      final scope2 = MosaiqueScope(routeContext: context, child: const SizedBox());

      expect(scope2.updateShouldNotify(scope1), isFalse);
    });

    testWidgets('rebuilds dependents when route context changes', (tester) async {
      const initialContext = RouteContext(path: '/users/123');
      const updatedContext = RouteContext(path: '/users/456');

      int buildCount = 0;
      RouteContext? lastContext;

      await tester.pumpWidget(
        MosaiqueScope(
          routeContext: initialContext,
          child: Builder(
            builder: (context) {
              buildCount++;
              lastContext = MosaiqueScope.of(context).routeContext;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, equals(1));
      expect(lastContext, equals(initialContext));

      // Update the route context
      await tester.pumpWidget(
        MosaiqueScope(
          routeContext: updatedContext,
          child: Builder(
            builder: (context) {
              buildCount++;
              lastContext = MosaiqueScope.of(context).routeContext;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, equals(2));
      expect(lastContext, equals(updatedContext));
    });

    testWidgets('provides consistent route context across multiple accesses', (tester) async {
      const context = RouteContext(path: '/users/123', pathParameters: {'userId': '123'}, queryParameters: {'tab': 'profile'});

      final capturedContexts = <RouteContext>[];

      await tester.pumpWidget(
        MosaiqueScope(
          routeContext: context,
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  capturedContexts.add(context.routeContext);
                  return const SizedBox();
                },
              ),
              Builder(
                builder: (context) {
                  capturedContexts.add(MosaiqueScope.of(context).routeContext);
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      );

      // All widgets should receive the same route context
      expect(capturedContexts.length, equals(2));
      expect(capturedContexts[0], equals(context));
      expect(capturedContexts[1], equals(context));
      expect(capturedContexts[0], equals(capturedContexts[1]));
    });
  });

  group('MosaiqueContextExtension', () {
    testWidgets('routeContext extension provides access to route context', (tester) async {
      const testContext = RouteContext(path: '/users/123', pathParameters: {'userId': '123'});

      RouteContext? capturedContext;

      await tester.pumpWidget(
        MosaiqueScope(
          routeContext: testContext,
          child: Builder(
            builder: (context) {
              capturedContext = context.routeContext;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext, equals(testContext));
    });

    testWidgets('routeContextOrNull returns null when no MosaiqueScope exists', (tester) async {
      RouteContext? capturedContext;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            capturedContext = context.routeContextOrNull;
            return const SizedBox();
          },
        ),
      );

      expect(capturedContext, isNull);
    });

    testWidgets('routeContextOrNull returns context when MosaiqueScope exists', (tester) async {
      const testContext = RouteContext(path: '/users/123');

      RouteContext? capturedContext;

      await tester.pumpWidget(
        MosaiqueScope(
          routeContext: testContext,
          child: Builder(
            builder: (context) {
              capturedContext = context.routeContextOrNull;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedContext, equals(testContext));
    });
  });
}

// Helper widget for testing rebuild behavior
class _TestWidget extends StatefulWidget {
  final VoidCallback onBuild;

  const _TestWidget({super.key, required this.onBuild});

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  @override
  Widget build(BuildContext context) {
    // Access the route context to create a dependency
    context.routeContext;
    widget.onBuild();
    return const SizedBox();
  }
}
