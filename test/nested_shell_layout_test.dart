import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('Nested Shell Layout Support', () {
    testWidgets('allows views to contain nested shell layouts', (tester) async {
      // Create outer shell layout
      final outerShell = ShellLayout(
        id: 'outer',
        builder: (regions) {
          return Column(children: [const Text('Outer Shell'), regions['main'] ?? const SizedBox.shrink()]);
        },
      );

      // Create inner shell layout
      final innerShell = ShellLayout(
        id: 'inner',
        builder: (regions) {
          return Column(children: [const Text('Inner Shell'), regions['content'] ?? const SizedBox.shrink()]);
        },
      );

      // Create routes for nested shells
      final routes = [
        RouteDefinition(
          pattern: '/nested/*',
          shellSelector: (context) => 'outer',
          viewRules: [
            ViewInjectionRule(
              regionKey: 'main',
              condition: (context) => true,
              builder: (context) {
                // View contains a nested shell layout
                return MosaiqueShellBuilder(
                  context: context,
                  shellLayouts: {'inner': innerShell},
                  routes: [
                    RouteDefinition(
                      pattern: '/nested/*',
                      shellSelector: (ctx) => 'inner',
                      viewRules: [ViewInjectionRule(regionKey: 'content', condition: (ctx) => true, builder: (ctx) => const Text('Nested Content'))],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ];

      final context = RouteContext(path: '/nested/page');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'outer': outerShell}, routes: routes),
        ),
      );

      // Verify both shells are rendered
      expect(find.text('Outer Shell'), findsOneWidget);
      expect(find.text('Inner Shell'), findsOneWidget);
      expect(find.text('Nested Content'), findsOneWidget);
    });

    testWidgets('propagates route parameters through nested shell layouts', (tester) async {
      String? outerCapturedParam;
      String? innerCapturedParam;

      final outerShell = ShellLayout(id: 'outer', builder: (regions) => regions['main'] ?? const SizedBox.shrink());

      final innerShell = ShellLayout(id: 'inner', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final routes = [
        RouteDefinition(
          pattern: '/users/:userId/posts/:postId',
          shellSelector: (context) => 'outer',
          viewRules: [
            ViewInjectionRule(
              regionKey: 'main',
              condition: (context) => true,
              builder: (context) {
                outerCapturedParam = context.pathParameters['userId'];

                // Nested shell layout
                return MosaiqueShellBuilder(
                  context: context,
                  shellLayouts: {'inner': innerShell},
                  routes: [
                    RouteDefinition(
                      pattern: '/users/:userId/posts/:postId',
                      shellSelector: (ctx) => 'inner',
                      viewRules: [
                        ViewInjectionRule(
                          regionKey: 'content',
                          condition: (ctx) => true,
                          builder: (ctx) {
                            innerCapturedParam = ctx.pathParameters['userId'];
                            return Text('User: ${ctx.pathParameters['userId']}, Post: ${ctx.pathParameters['postId']}');
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ];

      final context = RouteContext(path: '/users/123/posts/456');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'outer': outerShell}, routes: routes),
        ),
      );

      // Verify parameters are available in both outer and inner shells
      expect(outerCapturedParam, '123');
      expect(innerCapturedParam, '123');
      expect(find.text('User: 123, Post: 456'), findsOneWidget);
    });

    testWidgets('detects circular nesting and throws exception', (tester) async {
      final shellA = ShellLayout(id: 'shellA', builder: (regions) => regions['main'] ?? const SizedBox.shrink());

      final shellB = ShellLayout(id: 'shellB', builder: (regions) => regions['main'] ?? const SizedBox.shrink());

      // Create a circular reference: shellA -> shellB -> shellA
      final routesA = [
        RouteDefinition(
          pattern: '/circular',
          shellSelector: (context) => 'shellA',
          viewRules: [
            ViewInjectionRule(
              regionKey: 'main',
              condition: (context) => true,
              builder: (context) {
                // shellA contains shellB
                return MosaiqueShellBuilder(
                  context: context,
                  shellLayouts: {'shellB': shellB},
                  routes: [
                    RouteDefinition(
                      pattern: '/circular',
                      shellSelector: (ctx) => 'shellB',
                      viewRules: [
                        ViewInjectionRule(
                          regionKey: 'main',
                          condition: (ctx) => true,
                          builder: (ctx) {
                            // shellB tries to contain shellA - circular!
                            return MosaiqueShellBuilder(
                              context: ctx,
                              shellLayouts: {'shellA': shellA},
                              routes: [RouteDefinition(pattern: '/circular', shellSelector: (c) => 'shellA', viewRules: [])],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ];

      final context = RouteContext(path: '/circular');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'shellA': shellA}, routes: routesA),
        ),
      );

      // Should display error about circular nesting
      expect(find.textContaining('Circular nesting detected'), findsOneWidget);
    });

    testWidgets('nested regions rebuild independently when route changes', (tester) async {
      int outerBuildCount = 0;
      int innerBuildCount = 0;

      final outerShell = ShellLayout(id: 'outer', builder: (regions) => regions['main'] ?? const SizedBox.shrink());

      final innerShell = ShellLayout(id: 'inner', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      Widget buildTree(RouteContext context) {
        return MosaiqueShellBuilder(
          context: context,
          shellLayouts: {'outer': outerShell},
          routes: [
            RouteDefinition(
              pattern: '/page/:pageId',
              shellSelector: (ctx) => 'outer',
              viewRules: [
                ViewInjectionRule(
                  regionKey: 'main',
                  condition: (ctx) => true,
                  builder: (ctx) {
                    outerBuildCount++;
                    return MosaiqueShellBuilder(
                      context: ctx,
                      shellLayouts: {'inner': innerShell},
                      routes: [
                        RouteDefinition(
                          pattern: '/page/:pageId',
                          shellSelector: (c) => 'inner',
                          viewRules: [
                            ViewInjectionRule(
                              regionKey: 'content',
                              condition: (c) => true,
                              builder: (c) {
                                innerBuildCount++;
                                return Text('Page: ${c.pathParameters['pageId']}');
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        );
      }

      // Initial render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: buildTree(RouteContext(path: '/page/1')),
        ),
      );

      expect(find.text('Page: 1'), findsOneWidget);
      final initialOuterCount = outerBuildCount;
      final initialInnerCount = innerBuildCount;

      // Change route parameter
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: buildTree(RouteContext(path: '/page/2')),
        ),
      );

      expect(find.text('Page: 2'), findsOneWidget);

      // Both should rebuild since the parameter changed
      expect(outerBuildCount, greaterThan(initialOuterCount));
      expect(innerBuildCount, greaterThan(initialInnerCount));
    });

    testWidgets('nested shell layouts can access route context via MosaiqueScope', (tester) async {
      RouteContext? outerContext;
      RouteContext? innerContext;

      final outerShell = ShellLayout(id: 'outer', builder: (regions) => regions['main'] ?? const SizedBox.shrink());

      final innerShell = ShellLayout(id: 'inner', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final routes = [
        RouteDefinition(
          pattern: '/test/:id',
          shellSelector: (context) => 'outer',
          viewRules: [
            ViewInjectionRule(
              regionKey: 'main',
              condition: (context) => true,
              builder: (context) {
                return Builder(
                  builder: (buildContext) {
                    outerContext = buildContext.routeContext;

                    return MosaiqueShellBuilder(
                      context: context,
                      shellLayouts: {'inner': innerShell},
                      routes: [
                        RouteDefinition(
                          pattern: '/test/:id',
                          shellSelector: (ctx) => 'inner',
                          viewRules: [
                            ViewInjectionRule(
                              regionKey: 'content',
                              condition: (ctx) => true,
                              builder: (ctx) {
                                return Builder(
                                  builder: (innerBuildContext) {
                                    innerContext = innerBuildContext.routeContext;
                                    return const Text('Content');
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ];

      final context = RouteContext(path: '/test/42');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'outer': outerShell}, routes: routes),
        ),
      );

      // Both contexts should be available and consistent
      expect(outerContext, isNotNull);
      expect(innerContext, isNotNull);
      expect(outerContext!.pathParameters['id'], '42');
      expect(innerContext!.pathParameters['id'], '42');
    });

    testWidgets('multiple levels of nesting work correctly', (tester) async {
      final level1Shell = ShellLayout(
        id: 'level1',
        builder: (regions) => Column(children: [const Text('Level 1'), regions['main'] ?? const SizedBox.shrink()]),
      );

      final level2Shell = ShellLayout(
        id: 'level2',
        builder: (regions) => Column(children: [const Text('Level 2'), regions['main'] ?? const SizedBox.shrink()]),
      );

      final level3Shell = ShellLayout(
        id: 'level3',
        builder: (regions) => Column(children: [const Text('Level 3'), regions['content'] ?? const SizedBox.shrink()]),
      );

      final routes = [
        RouteDefinition(
          pattern: '/deep',
          shellSelector: (context) => 'level1',
          viewRules: [
            ViewInjectionRule(
              regionKey: 'main',
              condition: (context) => true,
              builder: (context) {
                return MosaiqueShellBuilder(
                  context: context,
                  shellLayouts: {'level2': level2Shell},
                  routes: [
                    RouteDefinition(
                      pattern: '/deep',
                      shellSelector: (ctx) => 'level2',
                      viewRules: [
                        ViewInjectionRule(
                          regionKey: 'main',
                          condition: (ctx) => true,
                          builder: (ctx) {
                            return MosaiqueShellBuilder(
                              context: ctx,
                              shellLayouts: {'level3': level3Shell},
                              routes: [
                                RouteDefinition(
                                  pattern: '/deep',
                                  shellSelector: (c) => 'level3',
                                  viewRules: [ViewInjectionRule(regionKey: 'content', condition: (c) => true, builder: (c) => const Text('Deep Content'))],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ];

      final context = RouteContext(path: '/deep');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'level1': level1Shell}, routes: routes),
        ),
      );

      // All three levels should be rendered
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text('Level 3'), findsOneWidget);
      expect(find.text('Deep Content'), findsOneWidget);
    });

    testWidgets('query parameters propagate through nested shells', (tester) async {
      String? outerQuery;
      String? innerQuery;

      final outerShell = ShellLayout(id: 'outer', builder: (regions) => regions['main'] ?? const SizedBox.shrink());

      final innerShell = ShellLayout(id: 'inner', builder: (regions) => regions['content'] ?? const SizedBox.shrink());

      final routes = [
        RouteDefinition(
          pattern: '/search',
          shellSelector: (context) => 'outer',
          viewRules: [
            ViewInjectionRule(
              regionKey: 'main',
              condition: (context) => true,
              builder: (context) {
                outerQuery = context.queryParameters['q'];

                return MosaiqueShellBuilder(
                  context: context,
                  shellLayouts: {'inner': innerShell},
                  routes: [
                    RouteDefinition(
                      pattern: '/search',
                      shellSelector: (ctx) => 'inner',
                      viewRules: [
                        ViewInjectionRule(
                          regionKey: 'content',
                          condition: (ctx) => true,
                          builder: (ctx) {
                            innerQuery = ctx.queryParameters['q'];
                            return Text('Query: ${ctx.queryParameters['q']}');
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ];

      final context = RouteContext(path: '/search', queryParameters: {'q': 'flutter'});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MosaiqueShellBuilder(context: context, shellLayouts: {'outer': outerShell}, routes: routes),
        ),
      );

      // Query parameters should be available in both levels
      expect(outerQuery, 'flutter');
      expect(innerQuery, 'flutter');
      expect(find.text('Query: flutter'), findsOneWidget);
    });
  });
}
