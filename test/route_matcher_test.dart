import 'package:flutter_test/flutter_test.dart';
import 'package:mosaique/mosaique.dart';

void main() {
  group('RouteMatcher', () {
    late RouteMatcher matcher;

    setUp(() {
      matcher = RouteMatcher();
    });

    group('Pattern Matching', () {
      test('matches static segments', () {
        final route = RouteDefinition(pattern: '/users/profile', shellSelector: (_) => 'main', viewRules: []);
        final context = RouteContext(path: '/users/profile');

        final result = matcher.match([route], context);

        expect(result, equals(route));
      });

      test('matches path parameters', () {
        final route = RouteDefinition(pattern: '/users/:userId', shellSelector: (_) => 'main', viewRules: []);
        final context = RouteContext(path: '/users/123');

        final result = matcher.match([route], context);

        expect(result, equals(route));
      });

      test('matches wildcards', () {
        final route = RouteDefinition(pattern: '/docs/*', shellSelector: (_) => 'main', viewRules: []);
        final context = RouteContext(path: '/docs/api/reference');

        final result = matcher.match([route], context);

        expect(result, equals(route));
      });

      test('matches optional parameters when present', () {
        final route = RouteDefinition(pattern: '/users/:userId?', shellSelector: (_) => 'main', viewRules: []);
        final context = RouteContext(path: '/users/123');

        final result = matcher.match([route], context);

        expect(result, equals(route));
      });

      test('matches optional parameters when absent', () {
        final route = RouteDefinition(pattern: '/users/:userId?', shellSelector: (_) => 'main', viewRules: []);
        final context = RouteContext(path: '/users');

        final result = matcher.match([route], context);

        expect(result, equals(route));
      });

      test('does not match when required parameter is missing', () {
        final route = RouteDefinition(pattern: '/users/:userId', shellSelector: (_) => 'main', viewRules: []);
        final context = RouteContext(path: '/users');

        final result = matcher.match([route], context);

        expect(result, isNull);
      });

      test('does not match when static segment differs', () {
        final route = RouteDefinition(pattern: '/users/profile', shellSelector: (_) => 'main', viewRules: []);
        final context = RouteContext(path: '/users/settings');

        final result = matcher.match([route], context);

        expect(result, isNull);
      });
    });

    group('Specificity Calculation', () {
      test('static segments have higher specificity than parameters', () {
        final staticRoute = RouteDefinition(pattern: '/users/profile', shellSelector: (_) => 'static', viewRules: []);
        final paramRoute = RouteDefinition(pattern: '/users/:userId', shellSelector: (_) => 'param', viewRules: []);
        final context = RouteContext(path: '/users/profile');

        final result = matcher.match([paramRoute, staticRoute], context);

        expect(result, equals(staticRoute));
      });

      test('required parameters have higher specificity than optional', () {
        final requiredRoute = RouteDefinition(pattern: '/users/:userId', shellSelector: (_) => 'required', viewRules: []);
        final optionalRoute = RouteDefinition(pattern: '/users/:userId?', shellSelector: (_) => 'optional', viewRules: []);
        final context = RouteContext(path: '/users/123');

        final result = matcher.match([optionalRoute, requiredRoute], context);

        expect(result, equals(requiredRoute));
      });

      test('parameters have higher specificity than wildcards', () {
        final paramRoute = RouteDefinition(pattern: '/docs/:section', shellSelector: (_) => 'param', viewRules: []);
        final wildcardRoute = RouteDefinition(pattern: '/docs/*', shellSelector: (_) => 'wildcard', viewRules: []);
        final context = RouteContext(path: '/docs/api');

        final result = matcher.match([wildcardRoute, paramRoute], context);

        expect(result, equals(paramRoute));
      });
    });

    group('Path Parameter Extraction', () {
      test('extracts single path parameter', () {
        final params = matcher.extractPathParameters('/users/:userId', '/users/123');

        expect(params, equals({'userId': '123'}));
      });

      test('extracts multiple path parameters', () {
        final params = matcher.extractPathParameters('/users/:userId/posts/:postId', '/users/123/posts/456');

        expect(params, equals({'userId': '123', 'postId': '456'}));
      });

      test('extracts wildcard content', () {
        final params = matcher.extractPathParameters('/docs/*', '/docs/api/reference/guide');

        expect(params, equals({'*': 'api/reference/guide'}));
      });

      test('extracts optional parameter when present', () {
        final params = matcher.extractPathParameters('/users/:userId?', '/users/123');

        expect(params, equals({'userId': '123'}));
      });

      test('handles optional parameter when absent', () {
        final params = matcher.extractPathParameters('/users/:userId?', '/users');

        expect(params, equals({}));
      });

      test('extracts parameters with static segments', () {
        final params = matcher.extractPathParameters('/users/:userId/profile', '/users/123/profile');

        expect(params, equals({'userId': '123'}));
      });

      test('returns empty map when pattern does not match', () {
        final params = matcher.extractPathParameters('/users/:userId', '/posts/123');

        expect(params, equals({}));
      });
    });
  });
}
