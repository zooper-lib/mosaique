import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('ViewResolver', () {
    late ViewResolver resolver;

    setUp(() {
      resolver = const ViewResolver();
    });

    test('returns null when no rules match and no default builder', () {
      final context = const RouteContext(path: '/test');
      final rules = <ViewInjectionRule>[];

      final result = resolver.resolveView('main', rules, context, null);

      expect(result, isNull);
    });

    test('returns default builder widget when no rules match', () {
      final context = const RouteContext(path: '/test');
      final rules = <ViewInjectionRule>[];
      final defaultWidget = Container(key: const Key('default'));

      final result = resolver.resolveView('main', rules, context, (ctx) => defaultWidget);

      expect(result, equals(defaultWidget));
    });

    test('returns widget from matching rule', () {
      final context = const RouteContext(path: '/test');
      final matchingWidget = Container(key: const Key('matching'));
      final rules = [ViewInjectionRule(regionKey: 'main', condition: (ctx) => true, builder: (ctx) => matchingWidget)];

      final result = resolver.resolveView('main', rules, context, null);

      expect(result, equals(matchingWidget));
    });

    test('returns highest priority rule when multiple rules match', () {
      final context = const RouteContext(path: '/test');
      final lowPriorityWidget = Container(key: const Key('low'));
      final highPriorityWidget = Container(key: const Key('high'));
      final rules = [
        ViewInjectionRule(regionKey: 'main', condition: (ctx) => true, builder: (ctx) => lowPriorityWidget, priority: 1),
        ViewInjectionRule(regionKey: 'main', condition: (ctx) => true, builder: (ctx) => highPriorityWidget, priority: 10),
      ];

      final result = resolver.resolveView('main', rules, context, null);

      expect(result, equals(highPriorityWidget));
    });

    test('ignores rules for different regions', () {
      final context = const RouteContext(path: '/test');
      final sidebarWidget = Container(key: const Key('sidebar'));
      final rules = [ViewInjectionRule(regionKey: 'sidebar', condition: (ctx) => true, builder: (ctx) => sidebarWidget)];

      final result = resolver.resolveView('main', rules, context, null);

      expect(result, isNull);
    });

    test('evaluates condition functions with route context', () {
      final context = const RouteContext(path: '/users/123', pathParameters: {'userId': '123'});
      final matchingWidget = Container(key: const Key('user'));
      final rules = [ViewInjectionRule(regionKey: 'main', condition: (ctx) => ctx.pathParameters['userId'] == '123', builder: (ctx) => matchingWidget)];

      final result = resolver.resolveView('main', rules, context, null);

      expect(result, equals(matchingWidget));
    });

    test('skips rules with non-matching conditions', () {
      final context = const RouteContext(path: '/test');
      final defaultWidget = Container(key: const Key('default'));
      final rules = [
        ViewInjectionRule(
          regionKey: 'main',
          condition: (ctx) => false,
          builder: (ctx) => Container(key: const Key('should-not-match')),
        ),
      ];

      final result = resolver.resolveView('main', rules, context, (ctx) => defaultWidget);

      expect(result, equals(defaultWidget));
    });

    test('handles condition function exceptions gracefully', () {
      final context = const RouteContext(path: '/test');
      final defaultWidget = Container(key: const Key('default'));
      final rules = [
        ViewInjectionRule(
          regionKey: 'main',
          condition: (ctx) => throw Exception('Test exception'),
          builder: (ctx) => Container(key: const Key('should-not-match')),
        ),
      ];

      final result = resolver.resolveView('main', rules, context, (ctx) => defaultWidget);

      expect(result, equals(defaultWidget));
    });

    test('first rule wins when priorities are equal', () {
      final context = const RouteContext(path: '/test');
      final firstWidget = Container(key: const Key('first'));
      final secondWidget = Container(key: const Key('second'));
      final rules = [
        ViewInjectionRule(regionKey: 'main', condition: (ctx) => true, builder: (ctx) => firstWidget, priority: 5),
        ViewInjectionRule(regionKey: 'main', condition: (ctx) => true, builder: (ctx) => secondWidget, priority: 5),
      ];

      final result = resolver.resolveView('main', rules, context, null);

      expect(result, equals(firstWidget));
    });

    test('passes route context to builder function', () {
      final context = const RouteContext(path: '/users/456', pathParameters: {'userId': '456'});
      Widget? builtWidget;
      RouteContext? receivedContext;

      final rules = [
        ViewInjectionRule(
          regionKey: 'main',
          condition: (ctx) => true,
          builder: (ctx) {
            receivedContext = ctx;
            builtWidget = Container(key: Key('user-${ctx.pathParameters['userId']}'));
            return builtWidget!;
          },
        ),
      ];

      final result = resolver.resolveView('main', rules, context, null);

      expect(receivedContext, equals(context));
      expect(result, equals(builtWidget));
    });
  });

  group('ViewResolver.findMatchingRule', () {
    late ViewResolver resolver;

    setUp(() {
      resolver = const ViewResolver();
    });

    test('returns null when no rules exist', () {
      final context = const RouteContext(path: '/test');
      final rules = <ViewInjectionRule>[];

      final result = resolver.findMatchingRule('main', rules, context);

      expect(result, isNull);
    });

    test('returns null when no rules match region', () {
      final context = const RouteContext(path: '/test');
      final rules = [ViewInjectionRule(regionKey: 'sidebar', condition: (ctx) => true, builder: (ctx) => Container())];

      final result = resolver.findMatchingRule('main', rules, context);

      expect(result, isNull);
    });

    test('returns null when no conditions match', () {
      final context = const RouteContext(path: '/test');
      final rules = [ViewInjectionRule(regionKey: 'main', condition: (ctx) => false, builder: (ctx) => Container())];

      final result = resolver.findMatchingRule('main', rules, context);

      expect(result, isNull);
    });

    test('returns matching rule', () {
      final context = const RouteContext(path: '/test');
      final matchingRule = ViewInjectionRule(regionKey: 'main', condition: (ctx) => true, builder: (ctx) => Container());
      final rules = [matchingRule];

      final result = resolver.findMatchingRule('main', rules, context);

      expect(result, equals(matchingRule));
    });

    test('returns highest priority rule among matches', () {
      final context = const RouteContext(path: '/test');
      final lowPriorityRule = ViewInjectionRule(regionKey: 'main', condition: (ctx) => true, builder: (ctx) => Container(), priority: 1);
      final highPriorityRule = ViewInjectionRule(regionKey: 'main', condition: (ctx) => true, builder: (ctx) => Container(), priority: 10);
      final rules = [lowPriorityRule, highPriorityRule];

      final result = resolver.findMatchingRule('main', rules, context);

      expect(result, equals(highPriorityRule));
    });
  });
}
